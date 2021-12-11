# CumulativeMedicationDuration version '0.3.000'

This library provides cumulative medication duration calculation
logic for use with Quality Data Model prescription, discharge, administration,
and dispensing events. The logic here follows the guidance provided as part of
the 5.6 version of Quality Data Model.

## Comment

Note that the logic here assumes single-instruction dosing information.
Split-dosing, tapering, and other more complex dosing instructions are not handled.

## Changelog
v0.3.000
Fixed Quantity handling in duration calculations
Fixed authorDatetime null handling
Changed to provide Date-level calculation, rather than DateTime
v0.4.000
Fixed daysSupply vs durationInDays calculation
Fixed relevantDatetime in MedicationDispensedPeriod

## Using

```cql
using QDM version '5.6'
```

## Includes

```cql
include MATGlobalCommonFunctions version '7.0.000' called Global
```

## Terminology

```cql
codesystem "SNOMEDCT": 'urn:oid:2.16.840.1.113883.6.96'

code "Every eight hours (qualifier value)": '307469008' from "SNOMEDCT" display 'Every eight hours (qualifier value)'
code "Every eight to twelve hours (qualifier value)": '396140003' from "SNOMEDCT" display 'Every eight to twelve hours (qualifier value)'
code "Every forty eight hours (qualifier value)": '396131002' from "SNOMEDCT" display 'Every forty eight hours (qualifier value)'
code "Every forty hours (qualifier value)": '396130001' from "SNOMEDCT" display 'Every forty hours (qualifier value)'
code "Every four hours (qualifier value)": '225756002' from "SNOMEDCT" display 'Every four hours (qualifier value)'
code "Every seventy two hours (qualifier value)": '396143001' from "SNOMEDCT" display 'Every seventy two hours (qualifier value)'
code "Every six hours (qualifier value)": '307468000' from "SNOMEDCT" display 'Every six hours (qualifier value)'
code "Every six to eight hours (qualifier value)": '396139000' from "SNOMEDCT" display 'Every six to eight hours (qualifier value)'
code "Every thirty six hours (qualifier value)": '396126004' from "SNOMEDCT" display 'Every thirty six hours (qualifier value)'
code "Every three to four hours (qualifier value)": '225754004' from "SNOMEDCT" display 'Every three to four hours (qualifier value)'
code "Every three to six hours (qualifier value)": '396127008' from "SNOMEDCT" display 'Every three to six hours (qualifier value)'
code "Every twelve hours (qualifier value)": '307470009' from "SNOMEDCT" display 'Every twelve hours (qualifier value)'
code "Every twenty four hours (qualifier value)": '396125000' from "SNOMEDCT" display 'Every twenty four hours (qualifier value)'
code "Every two to four hours (qualifier value)": '225752000' from "SNOMEDCT" display 'Every two to four hours (qualifier value)'
code "Four times daily (qualifier value)": '307439001' from "SNOMEDCT" display 'Four times daily (qualifier value)'
code "Once daily (qualifier value)": '229797004' from "SNOMEDCT" display 'Once daily (qualifier value)'
code "One to four times a day (qualifier value)": '396109005' from "SNOMEDCT" display 'One to four times a day (qualifier value)'
code "One to three times a day (qualifier value)": '396108002' from "SNOMEDCT" display 'One to three times a day (qualifier value)'
code "One to two times a day (qualifier value)": '396107007' from "SNOMEDCT" display 'One to two times a day (qualifier value)'
code "Three times daily (qualifier value)": '229798009' from "SNOMEDCT" display 'Three times daily (qualifier value)'
code "Twice a day (qualifier value)": '229799001' from "SNOMEDCT" display 'Twice a day (qualifier value)'
code "Two to four times a day (qualifier value)": '396111001' from "SNOMEDCT" display 'Two to four times a day (qualifier value)'
```

## Context

```cql
context Patient
```

## Guidance and Documentation
Goal is to get to number of days

Two broad approaches to the calculation:

1) Based on supply and frequency, calculate the number of expected days the medication will cover/has covered
2) Based on relevant period, determine a covered interval and calculate the length of that interval in days

In previous versions of QDM, general guidance on Cumulative Medication Duration used the
relevant period approach. However, feedback from measure authors and implementers has
led to the suggestion that since that data is not readily available for many use cases,
the first approach is preferred. This topic will cover several use cases and illustrate
how to calculate Cumulative Medication Duration for each using the supply and frequency
approach.

NOTE: This guidance explicitly excludes the Medication, Active QDM data type

### Calculating Days Supplied

For the first approach, we need to get from frequency to a frequency/day
So we define ToDaily

```
define function QuantityToDaily(Frequency Quantity):
  case Frequency.unit
    when 'h' then (24.0 / Frequency.value)
    when 'min' then (24.0 / Frequency.value) * 60
    when 's' then (24.0 / Frequency.value) * 60 * 60
    when 'd' then (24.0 / Frequency.value) / 24
    when 'wk' then (24.0 / Frequency.value) / (24 * 7)
    when 'mo' then (24.0 / Frequency.value) / (24 * 30) /* assuming 30 days in month */
    when 'a' then (24.0 / Frequency.value) / (24 * 365) /* assuming 365 days in year */
    when 'hour' then (24.0 / Frequency.value)
    when 'minute' then (24.0 / Frequency.value) * 60
    when 'second' then (24.0 / Frequency.value) * 60 * 60
    when 'day' then (24.0 / Frequency.value) / 24
    when 'week' then (24.0 / Frequency.value) / (24 * 7)
    when 'month' then (24.0 / Frequency.value) / (24 * 30) /* assuming 30 days in month */
    when 'year' then (24.0 / Frequency.value) / (24 * 365) /* assuming 365 days in year */
    when 'hours' then (24.0 / Frequency.value)
    when 'minutes' then (24.0 / Frequency.value) * 60
    when 'seconds' then (24.0 / Frequency.value) * 60 * 60
    when 'days' then (24.0 / Frequency.value) / 24
    when 'weeks' then (24.0 / Frequency.value) / (24 * 7)
    when 'months' then (24.0 / Frequency.value) / (24 * 30) /* assuming 30 days in month */
    when 'years' then (24.0 / Frequency.value) / (24 * 365) /* assuming 365 days in year */
    else null
  end

define function CodeToDaily(Frequency Code):
  case
    when Frequency ~ "Once daily (qualifier value)" then 1.0
    when Frequency ~ "Twice a day (qualifier value)" then 2.0
    when Frequency ~ "Three times daily (qualifier value)" then 3.0
    when Frequency ~ "Four times daily (qualifier value)" then 4.0
    when Frequency ~ "Every twenty four hours (qualifier value)" then 1.0
    when Frequency ~ "Every twelve hours (qualifier value)" then 2.0
    when Frequency ~ "Every thirty six hours (qualifier value)" then 0.67
    when Frequency ~ "Every eight hours (qualifier value)" then 3.0
    when Frequency ~ "Every four hours (qualifier value)" then 6.0
    when Frequency ~ "Every six hours (qualifier value)" then 4.0
    when Frequency ~ "Every seventy two hours (qualifier value)" then 0.34
    when Frequency ~ "Every forty eight hours (qualifier value)" then 0.5
    when Frequency ~ "Every eight to twelve hours (qualifier value)" then 2.0
    when Frequency ~ "Every six to eight hours (qualifier value)" then 3.0
    when Frequency ~ "Every three to four hours (qualifier value)" then 6.0
    when Frequency ~ "Every three to six hours (qualifier value)" then 4.0
    when Frequency ~ "Every two to four hours (qualifier value)" then 6.0
    when Frequency ~ "One to four times a day (qualifier value)" then 4.0
    when Frequency ~ "One to three times a day (qualifier value)" then 3.0
    when Frequency ~ "One to two times a day (qualifier value)" then 2.0
    when Frequency ~ "Two to four times a day (qualifier value)" then 4.0
    else null
  end

define function ToDaily(Frequency Choice<Quantity, Code>):
  case
    when Frequency is Quantity then QuantityToDaily(Frequency as Quantity)
    else CodeToDaily(Frequency as Code)
  end
```

### Calculating Duration of a Prescription

Now that we have a ToDaily function, we can approach calculation of the
duration of medication for an order. First, consider the definitions
for each element:

* authorDatetime: The date the prescription was written
* relevantPeriod: The time period for which the ordered supply is authorized to be dispensed (including refills)
* dosage: The quantity to be taken at a single administration
* supply: The quantity that was provided to a patient
* daysSupplied: The number of days over which the medication is expected to last, per dispense
* frequency: How frequently the medication should be taken
* refills: The number of refills allowed by the prescription

If there is no relevantPeriod start or authorDatetime, we cannot determine a start date and cannot
calculate a medication period, and so return null

If the relevantPeriod element is present (and completely specified), then we can use that directly

    relevantPeriod

If the daysSupplied element is present, then the duration in days is simply

    daysSupplied * (1 + refills)

If daysSupplied is not present, then daysSupplied must be calculated based on
the supply, dosage, and frequency:

    (supply / (dosage * frequency)) * (1 + refills)

Note that the supply and dosage Quantity values on the order are assumed to be in
terms of the same unit, typically a tablet or mL.

This calculation results in a number of days, which can then be turned into a
period by anchoring that to the authorDatetime

   Interval[authorDatetime, authorDatetime + daysSupplied - 1]

The following function illustrates this completely:

```cql
/*
Calculates the Medication Period for a single Medication, Order
*/
define function MedicationOrderPeriod(Order "Medication, Order"):
  if Order.relevantPeriod.low is null and Order.authorDatetime is null then
    null
  else if Order.relevantPeriod.high is not null then
    Interval[date from Coalesce(Order.relevantPeriod.low, Order.authorDatetime), date from end of Order.relevantPeriod]
  else
    (
      Coalesce(
        Order.daysSupplied,
        Order.supply.value / (Order.dosage.value * ToDaily(Order.frequency))
      ) * (1 + Coalesce(Order.refills, 0))
    ) totalDaysSupplied
      let startDate: date from Coalesce(Order.relevantPeriod.low, Order.authorDatetime)
      return
        if totalDaysSupplied is not null then
          Interval[startDate, startDate + Quantity { value: totalDaysSupplied - 1, unit: 'day' }]
        else
          null
```

### Calculating Duration of a Dispense

Next, consider the Medication, Dispensed case:

* authorDatetime: The date the dispense was authored
* relevantPeriod: The time period the dispense is expected to cover (not including refills)
* dosage: The quantity to be taken at a single administration
* supply: The quantity that was provided to a patient
* daysSupplied: The number of days over which the medication is expected to last, per dispense
* frequency: How frequently the medication should be taken
* refills: The number of refills remaining on the prescription

We have effectively the same elements, with the same meanings, with the exception that
if refills are specified on a dispense, it will indicate refills _remaining_ rather than
refills on the original prescription. In addition, multiple dispense events would typically
be present, and those would all have to be considered as part of an overall calculation.
That will be considered when we combine results, but for this function, we'll focus on
calculating the duration of a single dispense.

With a Medication, Dispense, relevantPeriod covers only the time period for the specific
dispensing event (i.e. not considering refills).

If there is no relevantPeriod start or authorDatetime, we cannot determine a start date and cannot
calculate a medication period, and so return null

If the relevantPeriod element is present (and completely specified), then we can use that directly

    relevantPeriod

If the daysSupplied element is present, then the duration in days is simply

    daysSupplied

Note specifically that we are not considering refills, as those would be covered
by subsequent dispense records.

If daysSupplied is not present, then daysSupplied must be calculated based on
the supply, dosage, and frequency:

    (supply / (dosage * frequency))

Again, note that the supply and dosage Quantity values on the order are assumed to be in
terms of the same unit, typically a tablet or mL.

This calculation results in a number of days, which can then be turned into a
period by anchoring that to the authorDatetime

   Interval[authorDatetime, authorDatetime + totalDaysSupplied - 1]

```cql
/*
Calculates Medication Period for a given Medication, Dispensed
*/
define function MedicationDispensedPeriod(Dispense "Medication, Dispensed"):
  Dispense Dispense
    let
      startDate: date from Coalesce(Dispense.relevantDatetime, Dispense.relevantPeriod.low, Dispense.authorDatetime),
      totalDaysSupplied:
        Coalesce(
          Dispense.daysSupplied,
          Dispense.supply.value / (Dispense.dosage.value * ToDaily(Dispense.frequency))
        )
    return
      if startDate is null then
        null
      else if Dispense.relevantPeriod.high is not null then
        Interval[startDate, date from end of Dispense.relevantPeriod]
      else if totalDaysSupplied is not null then
        Interval[startDate, startDate + Quantity { value: totalDaysSupplied - 1, unit: 'day' }]
      else
        null
```

### Calculating Duration of an Administration

Next we consider Medication, Administered. This data type is typically used to
capture specific administration, with the relevantPeriod capturing start and stop
time of the administration event:

* startTime: when a single medication administration event starts (e.g., the
  initiation of an intravenous infusion, or administering a pill or IM injection to a patient)
* stopTime: when a single medication administration event ends (e.g., the end time of
  the intravenous infusion, or the administration of a pill or IM injection is completed.
  For pills and IM injections, the start and stop times are the same)

However, when calculating cumulative medication duration, it is typically the
therapeutic period of the medication that should be considered. Currently neither
the Medication nor MedicationKnowledge resources provide this information, so
we model it here as a function that can potentially be implemented in a variety
of ways, including measure-specific values, as well as distribution as an RxNorm
code system supplement.

However it is obtained, if therapeutic duration can be obtained, and the effective
period has a start, the result will be

      Interval[startDate, startDate + therapeuticDuration - 1 day]

```cql
define function MedicationAdministrationPeriod(Administration "Medication, Administered"):
  Administration M
    let
      therapeuticDuration: TherapeuticDuration(Administration.code),
      startDate: date from Global.EarliestOf(Administration.relevantDatetime, Administration.relevantPeriod)
    return
      if startDate is not null and therapeuticDuration is not null then
        Interval[startDate, startDate + therapeuticDuration - 1 day]
      else
        null
```

```cql
/*
Returns the established therapeutic duration for a given medication.
This is likely measure specific, though could potentially be established for
any drug and distributed as a CodeSystem supplement.
Defaulting to 14 days here for illustration.
*/
define function TherapeuticDuration(medication Code):
  14 days
```

### Calculating Duration of a Discharge Medication

For Medication, Discharge, we have the same elements, except no relevantPeriod:

* authorDatetime: The date the dispense was authored
* dosage: The quantity to be taken at a single administration
* supply: The quantity that was provided to a patient
* daysSupplied: The number of days over which the medication is expected to last, per dispense
* frequency: How frequently the medication should be taken
* refills: The number of refills allowed by the prescription

So the calculation is slightly different:

```cql
/*
Calculates the Medication Period for a Medication, Discharge
*/
define function MedicationDischargePeriod(Medication "Medication, Discharge"):
  (
    Coalesce(
      Medication.daysSupplied,
      Medication.supply.value / (Medication.dosage.value * ToDaily(Medication.frequency))
    ) * (1 + Coalesce(Medication.refills, 0))
  ) totalDaysSupplied
    let startDate: date from Medication.authorDatetime
    return
      if startDate is not null and totalDaysSupplied is not null then
        Interval[startDate, startDate + Quantity { value: totalDaysSupplied - 1, unit: 'day' }]
      else
        null
```

### Calculating Cumulative Medication Duration

Now that we have functions for determining the medication period for individual
orders, discharges, and dispenses, we can combine those using
an overall cumulative medication duration calculation.

First, we define a function that simply calculates CumulativeDuration of a set of
intervals:

```cql
define function CumulativeDuration(Intervals List<Interval<Date>>):
  Sum((collapse Intervals per day) X return all difference in days between start of X and end of X) + 1
```

Next, we define a function that rolls out intervals:

```cql
define function RolloutIntervals(intervals List<Interval<Date>>):
  intervals I
    aggregate R starting (null as List<Interval<Date>>):
      R union ({
        I X
          let
            S: Max({ end of Last(R) + 1 day, start of X }),
            E: S + duration in days of X
          return Interval[S, E]
      })
```

Then, we define a function that allows us to calculate based on the various medication
types:

```cql
define function MedicationPeriod(
  Medication Choice<"Medication, Order",
    "Medication, Dispensed",
    "Medication, Discharge",
    "Medication, Administered"
  >):
  Coalesce(
    MedicationOrderPeriod(Medication),
    MedicationDispensedPeriod(Medication),
    MedicationDischargePeriod(Medication),
    MedicationAdministrationPeriod(Medication)
  )
```

We can then use this function, combined with the MedicationDuration functions above
to calculate Cumulative Medication Duration:

Generally speaking, we want to _roll out_ intervals from dispense and administration
events, and then collapse across that result and intervals from prescriptions.

Note also that the separation of medications by type should already be done
by this stage as well.

Calculations that combine dosages from different types of medications (such as Morphine Milligram Equivalent (MME)
or Average MME) require further consideration.


```cql
define function CumulativeMedicationDuration(
  Medications List<Choice<"Medication, Order",
    "Medication, Dispensed",
    "Medication, Discharge",
    "Medication, Administered"
  >>):
  CumulativeDuration((
      Medications M
        where M is "Medication, Order" or M is "Medication, Discharge"
        return MedicationPeriod(M)
    )
      union (
        RolloutIntervals(
          Medications M
            where M is "Medication, Dispensed" or M is "Medication, Administered"
            return MedicationPeriod(M)
        )
      )
  )
```

## Illustrative Examples
### Example 1:
“Medication, Order”  2 tabs 3x/day   #180/2
* dosage = 2
* frequency = 3x /day (i.e., repeats / period = day)
* supply = 180
* daysSupplied = 30 days
* refills = 2

derived daysSupplied = [supply (180) / ((dosage (2) x frequency (3))] = 30
daysSuppliedWithRefills = [supply (180) x (1 + refills (2)) / ((dosage (2) x frequency (3))] = 30 x 3 = 90 days

### Example 2:
“Medication, Dispensed”  2 tabs 3x/day #180/2*
* dosage = 2
* frequency = 3x /day (i.e., repeats / period = day)
* supply = 180
* daysSupplied = 30 days
* refills = n/a

derived daysSupplied = [supply (180) / ((dosage (2) x frequency (3))] = 30

### Example 3:
“Medication, Order” ½ tab 2x/day #30/2
* dosage = 1/2
* frequency = 2x /day (i.e., repeats / period = day)
* supply = 30
* daysSupplied = 30
* refills = 2

derived daysSupplied = [supply (30) / ((dosage (1/2) x frequency (2))] = 30
daysSuppliedWithRefills = [supply (30) x (1 + refills (2)) / ((dosage (1/2) x frequency (2) = 30 x 3 = 90 days

### Example 4:
“Medication, Dispensed” ½ tab 2x/day #30/2*
* dosage = 1/2
* frequency = 2x /day (i.e., repeats / period = day)
* supply = 30
* daysSupplied = 30
* refills = n/a

derived daysSupplied = [supply (30) / ((dosage (1/2) x frequency (2))] = 30

### Example 5:
“Medication, Order” 5 ml 3x/day  #150 ml/0
* dosage = 5 ml
* frequency = 3x /day (i.e., repeats / period = day)
* supply = 150 ml
* daysSupplied = 10
* refills = 0

derived daysSupplied = [supply (150 ml) / ((dosage (5 ml) x frequency (3)) = 10 days
daysSuppliedWithRefills = [supply (150 ml) x (1 + refills (0)) / ((dosage (5 ml) x frequency (3)) = 10 days

### Example 6:
“Medication, Dispensed” 5 ml 3x/day  #150 ml/0*
* dosage = 5 ml
* frequency = 3x /day (i.e., repeats / period = day)
* supply = 150 ml
* daysSupplied = 10
* refills = n/a

* CMD calculated for “Medication, Dispensed” does not use the number of refills; rather, the days covered by each dispensing event must be retrieved and added.
