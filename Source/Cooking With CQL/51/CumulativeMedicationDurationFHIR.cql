library CumulativeMedicationDurationFHIR

/*
This library provides guidance for calculating Cumulative Medication Duration
using FHIR R4.
*/

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

codesystem "EventTiming": 'http://hl7.org/fhir/event-timing'

code "HS": 'HS' from "EventTiming" // event occurs [offset] before the hour of sleep (or trying to)
code "WAKE": 'WAKE' from "EventTiming" // event occurs [offset] after waking
code "C": 'C' from "EventTiming" //	event occurs at a meal (from the Latin cibus)
code "CM": 'CM' from "EventTiming" //	event occurs at breakfast (from the Latin cibus matutinus)
code "CD": 'CD' from "EventTiming" //	event occurs at lunch (from the Latin cibus diurnus)
code "CV": 'CV' from "EventTiming" //	event occurs at dinner (from the Latin ante cibus vespertinus)
code "AC": 'AC' from "EventTiming" //	event occurs [offset] before a meal (from the Latin ante cibus)
code "ACM": 'ACM' from "EventTiming" //	event occurs [offset] before breakfast (from the Latin ante cibus matutinus)
code "ACD": 'ACD' from "EventTiming" //	event occurs [offset] before lunch (from the Latin ante cibus diurnus)
code "ACV": 'ACV' from "EventTiming" //	event occurs [offset] before dinner (from the Latin ante cibus vespertinus)
code "PC": 'PC' from "EventTiming" //	event occurs [offset] after a meal (from the Latin post cibus)
code "PCM": 'PCM' from "EventTiming" //	event occurs [offset] after breakfast (from the Latin post cibus matutinus)
code "PCD": 'PCD' from "EventTiming" //	event occurs [offset] after lunch (from the Latin post cibus diurnus)
code "PCV": 'PCV' from "EventTiming" //	event occurs [offset] after dinner (from the Latin post cibus vespertinus)

parameter ErrorLevel String default 'Warning'

context Patient

/*
 Goal is to get to number of days
 Two broad approaches to the calculation:
  1) Based on supply and frequency, calculate the number of expected days the medication will cover/has covered
  2) Based on relevant period, determine a covered interval and calculate the length of that interval in days

This topic covers several use cases and illustrates how to calculate Cumulative
Medication Duration for each type of medication resource using the supply and
frequency approach.
*/

/*
  For the first approach, we need to get from frequency to a frequency/day
  So we define ToDaily
*/

/*
  Calculates daily frequency given frequency within a period
*/
define function ToDaily(frequency System.Integer, period System.Quantity):
  case period.unit
    when 'h' then frequency * (24.0 / period.value)
    when 'min' then frequency * (24.0 / period.value) * 60
    when 's' then frequency * (24.0 / period.value) * 60 * 60
    when 'd' then frequency * (24.0 / period.value) / 24
    when 'wk' then frequency * (24.0 / period.value) / (24 * 7)
    when 'mo' then frequency * (24.0 / period.value) / (24 * 30) /* assuming 30 days in month */
    when 'a' then frequency * (24.0 / period.value) / (24 * 365) /* assuming 365 days in year */
    when 'hour' then frequency * (24.0 / period.value)
    when 'minute' then frequency * (24.0 / period.value) * 60
    when 'second' then frequency * (24.0 / period.value) * 60 * 60
    when 'day' then frequency * (24.0 / period.value) / 24
    when 'week' then frequency * (24.0 / period.value) / (24 * 7)
    when 'month' then frequency * (24.0 / period.value) / (24 * 30) /* assuming 30 days in month */
    when 'year' then frequency * (24.0 / period.value) / (24 * 365) /* assuming 365 days in year */
    when 'hours' then frequency * (24.0 / period.value)
    when 'minutes' then frequency * (24.0 / period.value) * 60
    when 'seconds' then frequency * (24.0 / period.value) * 60 * 60
    when 'days' then frequency * (24.0 / period.value) / 24
    when 'weeks' then frequency * (24.0 / period.value) / (24 * 7)
    when 'months' then frequency * (24.0 / period.value) / (24 * 30) /* assuming 30 days in month */
    when 'years' then frequency * (24.0 / period.value) / (24 * 365) /* assuming 365 days in year */
    else Message(null, true, 'OMTKLogic.ToDaily.UnknownUnit', ErrorLevel, 'Unknown unit ' & period.unit)
  end

define function ToDaily(Frequency Code):
  case Frequency
    when "C" then 3
    // etc.
    else null
  end

/*
Now that we have a ToDaily function, we can approach calculation of the
duration of medication for an order. First, consider the definitions
for each element:

* 1 and only 1 dosageInstruction
* 1 and only 1 doseAndRate
* 1 timing with 1 repeat
* frequency, frequencyMax, defaulting to 1
* period, periodUnit, defaulting to 1 'd'
* doseQuantity or doseRange
* timeOfDay

* authoredOn: The date the prescription was written
* dispenseRequest.validityPeriod: Time period supply is authorized for
* dispenseRequest.quantity: amount of medication supplied per dispense
* dispenseRequest.numberOfRepeatsAllowed: number of refills authorized
* dispenseRequest.expectedSupplyDuration: number of days supply per dispense
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

If the boundsPeriod is present (and completely specified), we can use that directly

    dosage.timing.repeat.boundsPeriod

If expectedSupplyDuration is present, then the duration is

    expectedSupplyDuration * (1 + numberOfRepeatsAllowed)

If expectedSupplyDuration is not present, then it must be calculated based on the quantity, dosage, and frequency:

    (quantity / (dosage * frequency)) * (1 + numberOfRepeatsAllowed)

    dosage: Coalesce(end of doseAndRate.doseRange, doseAndRate.doseQuantity)
    frequency: Coalesce(frequencyMax, frequency)
    period: Quantity(period, periodUnit)

This calculation results in a number of days, which can then be turned into a period by anchoring that to the
start of the validityPeriod or the authoredOn:

    Interval[earliestDispensable, earliestDispensable + expectedSupplyDuration]

    earliestDispensable: Coalesce(start of validityPeriod, authoredOn)

The following function illustrates this completely:
*/

/*
Calculates the Medication Period for a single MedicationRequest
*/
define function MedicationRequestPeriod(Request "MedicationRequest"):
  Request R
    let
      dosage: singleton from R.dosageInstruction,
      doseAndRate: singleton from dosage.doseAndRate,
      doseRange: doseAndRate.dose as Range,
      doseQuantity: doseAndRate.dose as SimpleQuantity,
      dose: Coalesce(end of doseRange, doseQuantity),
      timing: dosage.timing,
      frequency: Coalesce(timing.repeat.frequencyMax, timing.repeat.frequency),
      period: System.Quantity { value: timing.repeat.period, unit: timing.repeat.periodUnit.value },
      dosesPerDay: Coalesce(ToDaily(frequency, period), Count(timing.repeat.timeOfDay), 1.0),
      boundsPeriod: timing.repeat.bounds as Period,
      daysSupply: R.dispenseRequest.expectedSupplyDuration,
      quantity: R.dispenseRequest.quantity,
      refills: Coalesce(R.dispenseRequest.numberOfRepeatsAllowed, 0),
      startDate:
        Coalesce(
          start of boundsPeriod,
          start of R.dispenseRequest.validityPeriod,
          R.authoredOn
        )
    return
      if HasEnd(boundsPeriod) then
        Interval[startDate, end of boundsPeriod]
      else
        (
          Coalesce(daysSupply, quantity / (dose * dosesPerDay))
            * (1 + refills)
        ) durationInDays
          return Interval[startDate, startDate + durationInDays]

/*
Next, consider the MedicationDispense case:

* whenHandedOver: When product was given out
* quantity: Amount dispensed
* daysSupply: Amount of medication expressed as a timing amount
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

We have effectively the same elements, with the same meanings, with the exception that the
event is documenting a single dispense, and dose not contain refill information. In addition,
multiple dispense events would typically be present, and those would all have to be considered
as part of an overall calculation. That will be considered when we combine results, but for
this function, we'll focus on calculating the duration of a single dispense.

With a MedicationDispense, boundsPeriod covers only the time period for the specific
dispensing event (i.e. not considering refills).

If the boundsPeriod element is present (and completely specified), then we can use that directly

    boundsPeriod

If the daysSupply element is present, then the duration in days is simply

    daysSupply

Note specifically that we are not considering refills, as those would be covered
by subsequent dispense records.

If daysSupplied is not present, then daysSupplied must be calculated based on
the quantity, dosage, and frequency:

    (quantity / (dosage * frequency))

This calculation results in a number of days, which can then be turned into a
period by anchoring that to the whenHandedOver

   Interval[whenHandedOver, whenHandedOver + durationInDays]
*/

/*
Calculates Medication Period for a given MedicationDispense
*/

// TODO: Consider whenPrepared as a default for whenHandedOver
// Many systems don't populate the whenHandedOver versus the whenPrepared

define function MedicationDispensePeriod(Dispense "MedicationDispense"):
  Dispense D
    let
      dosage: singleton from D.dosageInstruction,
      doseAndRate: singleton from dosage.doseAndRate,
      doseRange: doseAndRate.dose as Range,
      doseQuantity: doseAndRate.dose as SimpleQuantity,
      dose: Coalesce(end of doseRange, doseQuantity),
      timing: dosage.timing,
      frequency: Coalesce(timing.repeat.frequencyMax, timing.repeat.frequency),
      period: System.Quantity { value: timing.repeat.period, unit: timing.repeat.periodUnit.value },
      dosesPerDay: Coalesce(ToDaily(frequency, period), Count(timing.repeat.timeOfDay), 1.0),
      boundsPeriod: timing.repeat.bounds as Period,
      startDate:
        Coalesce(
          start of boundsPeriod,
          D.whenHandedOver
        )
    return
      if HasEnd(boundsPeriod) then
        Interval[startDate, end of boundsPeriod]
      else
        (
          Coalesce(D.daysSupply, D.quantity / (dose * dosesPerDay))
        ) durationInDays
          return Interval[startDate, startDate + durationInDays]

/*
Next we consider MedicationAdministration. This data type is typically used to
capture specific administration, with the relevantPeriod capturing start and stop
time of the administration event:

* effective[x]: Start and end time of administration

In this case, we just consider the duration of the effective period:
*/

define function MedicationAdministrationPeriod(Administration "MedicationAdministration"):
  Administration.effective as Period

/*
Now that we have functions for determining the medication period for individual
prescriptions, administrations, and dispenses, we can combine those using
an overall cumulative medication duration calculation.

First, we define a function that simply calculates CumulativeDuration of a set of
intervals:
*/

define function CumulativeDuration(Intervals List<Interval<DateTime>>):
  Sum((collapse Intervals) X return all difference in days between start of X and end of X)

/*
Then, we define a function that allows us to calculate based on the various medication
types:
*/

define function MedicationPeriod(
  Medication Choice<"MedicationRequest",
    "MedicationDispense"
  >):
  Coalesce(
    MedicationRequestPeriod(Medication),
    MedicationDispensePeriod(Medication)
  )

/*
We can then use this function, combined with the MedicationDuration functions above
to calculate Cumulative Medication Duration:
*/

define function CumulativeMedicationDuration(
  Medications List<Choice<"MedicationRequest",
    "MedicationDispense"
  >>):
  CumulativeDuration(
    Medications M
      return MedicationPeriod(M)
  )

/*
// Illustrative Examples
# Example 1:
“Medication, Order”  2 tabs 3x/day   #180/2
* dosage = 2
* frequency = 3x /day (i.e., repeats / period = day)
* supply = 180
* daysSupplied = 30 days
* refills = 2

derived daysSupplied = [supply (180) / ((dosage (2) x frequency (3))] = 30
daysSuppliedWithRefills = [supply (180) x (1 + refills (2)) / ((dosage (2) x frequency (3))] = 30 x 3 = 90 days

# Example 2:
“Medication, Dispensed”  2 tabs 3x/day #180/2*
* dosage = 2
* frequency = 3x /day (i.e., repeats / period = day)
* supply = 180
* daysSupplied = 30 days
* refills = n/a

derived daysSupplied = [supply (180) / ((dosage (2) x frequency (3))] = 30

# Example 3:
“Medication, Order” ½ tab 2x/day #30/2
* dosage = 1/2
* frequency = 2x /day (i.e., repeats / period = day)
* supply = 30
* daysSupplied = 30
* refills = 2

derived daysSupplied = [supply (30) / ((dosage (1/2) x frequency (2))] = 30
daysSuppliedWithRefills = [supply (30) x (1 + refills (2)) / ((dosage (1/2) x frequency (2) = 30 x 3 = 90 days

# Example 4:
“Medication, Dispensed” ½ tab 2x/day #30/2*
* dosage = 1/2
* frequency = 2x /day (i.e., repeats / period = day)
* supply = 30
* daysSupplied = 30
* refills = n/a

derived daysSupplied = [supply (30) / ((dosage (1/2) x frequency (2))] = 30

# Example 5:
“Medication, Order” 5 ml 3x/day  #150 ml/0
* dosage = 5 ml
* frequency = 3x /day (i.e., repeats / period = day)
* supply = 150 ml
* daysSupplied = 10
* refills = 0

derived daysSupplied = [supply (150 ml) / ((dosage (5 ml) x frequency (3)) = 10 days
daysSuppliedWithRefills = [supply (150 ml) x (1 + refills (0)) / ((dosage (5 ml) x frequency (3)) = 10 days

# Example 6:
“Medication, Dispensed” 5 ml 3x/day  #150 ml/0*
* dosage = 5 ml
* frequency = 3x /day (i.e., repeats / period = day)
* supply = 150 ml
* daysSupplied = 10
* refills = n/a

* CMD calculated for “Medication, Dispensed” does not use the number of refills; rather, the days covered by each dispensing event must be retrieved and added.
*/

/*Given an interval, return true if the interval has an ending boundary specified (i.e. the end of the interval is not null and not the maximum DateTime value)*/
define function HasEnd(period Interval<DateTime>):
  not (end of period is null or end of period = maximum DateTime)

/* Given an interval, return true if the interval has a starting boundary specified (i.e. the start of the interval is not null and not the minimumDateTime value)*/
define function HasStart(period Interval<DateTime>):
  not (start of period is null or start of period = minimum DateTime)
