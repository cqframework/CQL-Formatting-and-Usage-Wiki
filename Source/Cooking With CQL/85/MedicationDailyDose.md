# Medication Daily Dose

Inspired by: https://chat.fhir.org/#narrow/stream/179220-cql/topic/CQL.20Coding

## Question: 

I am trying to observe prescriptions available at a certain date where the dosage is above 60 mg daily.

I put in comments at the end where the functions aren't working. I think I should just be able to convert a fhir.positiveint to decimal.

```cql
define function "GetMedicationDailyDose"(dosage Quantity, dosesPerDay Decimal):
  dosage * Quantity { value: dosesPerDay, unit: '/d' }
//This errors out and says expecting decimal but found type system.decimal. Not sure what that means.

define "methadone_prescribed at date":
[MedicationRequest] MR
        where MR.status = 'completed'
        and MR.intent = 'order'
        and MR.medication ~ HCC."methadone"
        and "GetMedicationDailyDose"(MR.dosageInstruction, "DosesPerDay"(singleton from MR.dosageInstruction.timing.repeat.frequencyMax)) >= 60 'mg/d'
//This cannot convert FHIR.positiveInt to Decimal
        and MedicationRequestPeriod(MR) starts before "Measurement Date"
        and MedicationRequestPeriod(MR) ends after "Measurement Date"
```

## Answer:

Looking at the specific errors reported, beginning with the "expecting decimal but found type System.Decimal":


```cql
define function "GetMedicationDailyDose"(dosage Quantity, dosesPerDay Decimal):
  dosage * Quantity { value: dosesPerDay, unit: '/d' }
//This errors out and says expecting decimal but found type system.decimal. Not sure what that means.
```

The issue here is that this is trying to construct a FHIR.Quantity, and that takes a FHIR.decimal and a FHIR.string, as opposed to a System.Decimal and System.String
Using a System.Quantity here should address this issue:


```cql
  dosage * System.Quantity { value: dosesPerDay, unit: '/d' }
```

Next, the "cannot convert FHIR.positiveInt to Decimal"


```cql
        and "GetMedicationDailyDose"(MR.dosageInstruction, "DosesPerDay"(singleton from MR.dosageInstruction.timing.repeat.frequencyMax)) >= 60 'mg/d'
//This cannot convert FHIR.positiveInt to Decimal
```

If the "DosesPerDay" is returning a positiveInt, then yes, you could just use a "ToDecimal()" to convert the value:

```cql
        and "GetMedicationDailyDose"(MR.dosageInstruction, ToDecimal("DosesPerDay"(singleton from MR.dosageInstruction.timing.repeat.frequencyMax))) >= 60 'mg/d'
```

Taking a step back though, if the intent is to determine the dailyDose from a FHIR MedicationRequest, there are some considerations.
It looks like, based on some of the logic in the submitted content, that some of the common medication logic already available is being used, such as 
[CumulativeMedicationDuration](http://github.com/cqframework/ecqm-content-qicore-2024/input/cql/CumulativeMedicationDuration.cql)

That logic does make use of daily dose calculations, but it is focused on calculating medication periods, rather than dosage.

To help address this, I've drafted a "MedicationLogic" library that uses some of the same logic to determine daily dose, and this topic walks through the new "dailyDose" functions

Focusing on calculating dailyDose from a MedicationRequest, consider the definitions for each relevant element:

* dispenseRequest.quantity: amount of medication supplied per dispense
* dosageInstruction.timing.repeat.boundsDuration: total duration of the repeat
* dosageInstruction.timing.repeat.boundsRange: range of durations of the repeat
* dosageInstruction.timing.repeat.boundsPeriod: period bounds of the repeat
* dosageInstruction.timing.repeat.count: number of times to repeat
* dosageInstruction.timing.repeat.countMax: maximum number of times to repeat
* dosageInstruction.timing.repeat.frequency: event occurs frequency times per period
* dosageInstruction.timing.repeat.frequencyMax: event occurs up to frequencyMax times per period
* dosageInstruction.timing.repeat.period: event occurs frequency times per period
* dosageInstruction.timing.repeat.periodMax: upper limit of period
* dosageInstruction.timing.repeat.periodUnit: period duration (s | min | h | d | wk | mo | a)
* dosageInstruction.timing.repeat.timeOfDay: time of day for the event (0..*)
* dosageInstruction.timing.repeat.when: event timing (HS | WAKE | C | CM | CD | CV | AC | ACM...)
* dosageInstruction.timing.code: BID | TID | QID | AM | PM | QD | QOD...
* dosageInstruction.asNeeded
* dosageInstruction.doseAndRate.doseQuantity
* dosageInstruction.doseAndRate.doseRange

Specifically, the logic will make use of:

* 1 and only 1 dosageInstruction
* 1 and only 1 doseAndRate
* 1 timing with 1 repeat
* frequency, frequencyMax, defaulting to 1
* period, periodUnit, defaulting to 1 'd'
* doseQuantity or doseRange
* timeOfDay


```cql
define fluent function dailyDose(Request "MedicationRequest"):
  Request R
    let
      dosage: singleton from R.dosageInstruction,
      doseAndRate: singleton from dosage.doseAndRate,
      timing: dosage.timing,
      frequency: Coalesce(timing.repeat.frequencyMax, timing.repeat.frequency),
      period: Quantity(timing.repeat.period, timing.repeat.periodUnit),
      doseRange: doseAndRate.dose as Range,
      doseQuantity: doseAndRate.dose as SimpleQuantity,
      dose: Coalesce(doseRange.high, doseQuantity),
      dosesPerDay: Coalesce(ToDaily(frequency, period), Count(timing.repeat.timeOfDay), 1.0),
      quantity: R.dispenseRequest.quantity
    return
      quantity / (dose * dosesPerDay)
```

and the same logic, applied to the MedicationDispense:

```cql
define fluent function dailyDose(Dispense "MedicationDispense"):
  Dispense D
    let
      dosage: singleton from D.dosageInstruction,
      doseAndRate: singleton from dosage.doseAndRate,
      timing: dosage.timing,
      frequency: Coalesce(timing.repeat.frequencyMax, timing.repeat.frequency),
      period: Quantity(timing.repeat.period, timing.repeat.periodUnit),
      doseRange: doseAndRate.dose as Range,
      doseQuantity: doseAndRate.dose as SimpleQuantity,
      dose: Coalesce(doseRange.high, doseQuantity),
      dosesPerDay: Coalesce(ToDaily(frequency, period), Count(timing.repeat.timeOfDay), 1.0)
    return
      D.quantity / (dose * dosesPerDay)
```

> NOTE: The MedicationLogic library is a work in progress. There are test cases in the MedicationLogicTests library, extended from the CMD tests that are being worked through. Community input on validating this logic and these tests is welcome :)

This logic takes the same approach to determining dosesPerDay as the Cumulative Medication Duration calculation, which is based on guidance from the Pharmacy Work Group in making use of the dosageInstruction and timing elements to determine the number of doses per day, as well as the dose quantity.

Note that if the dose is specified as a range, this logic uses the **high** range for that value, and if the frequency is specified with a range, the **max** frequency is assumed. In other words, this logic assumes the highest dosage.

This function can then be used with any MedicationRequest to determine the dailyDosage:

```cql
define PrescriptionDailyDoses:
  Prescriptions P
    return P.dailyDose()
```

Note carefully though that this dose quantity will be in terms of the prescribed quantity, which will often be in the dose form of the medication (e.g. tablets, patches, etc.)

Converting the dose form to the actual prescribed quantity of the medication requires understanding information about the quantity for each dose form, and potentially involves breaking down the medication into constituent ingredients if it is a compound medication. For an example of how this can be done using RxNorm drug information, refer to the [Opioid MME Calculator](https://fhir.org/guides/cdc/opioid-mme-r4/)

