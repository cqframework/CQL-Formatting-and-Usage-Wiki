/*
@description: This library provides cumulative medication duration calculation
logic for use with Quality Data Model prescription, discharge, administration,
and dispensing events. The logic here follows the guidance provided as part of
the 5.6 version of Quality Data Model.
@comment: Note that the logic here assumes single-instruction dosing information.
Split-dosing, tapering, and other more complex dosing instructions are not handled.
@changelog:
v0.2.000
Fixed Quantity handling in duration calculations
Fixed authorDatetime null handling
Changed to provide Date-level calculation, rather than DateTime
*/

library CumulativeMedicationDurationFHIR4 version '0.2.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.001'

// These code systems are not known to the MAT environment yet, request to have them added submitted
codesystem "V3TimingEvent": 'http://terminology.hl7.org/CodeSystem/v3-TimingEvent'
codesystem "EventTiming": 'http://hl7.org/fhir/event-timing'
codesystem "SNOMEDCT": 'urn:oid:2.16.840.1.113883.6.96'

code "HS": 'HS' from "V3TimingEvent" // event occurs [offset] before the hour of sleep (or trying to)
code "WAKE": 'WAKE' from "V3TimingEvent" // event occurs [offset] after waking
code "C": 'C' from "V3TimingEvent" //	event occurs at a meal (from the Latin cibus)
code "CM": 'CM' from "V3TimingEvent" //	event occurs at breakfast (from the Latin cibus matutinus)
code "CD": 'CD' from "V3TimingEvent" //	event occurs at lunch (from the Latin cibus diurnus)
code "CV": 'CV' from "V3TimingEvent" //	event occurs at dinner (from the Latin ante cibus vespertinus)
code "AC": 'AC' from "V3TimingEvent" //	event occurs [offset] before a meal (from the Latin ante cibus)
code "ACM": 'ACM' from "V3TimingEvent" //	event occurs [offset] before breakfast (from the Latin ante cibus matutinus)
code "ACD": 'ACD' from "V3TimingEvent" //	event occurs [offset] before lunch (from the Latin ante cibus diurnus)
code "ACV": 'ACV' from "V3TimingEvent" //	event occurs [offset] before dinner (from the Latin ante cibus vespertinus)
code "PC": 'PC' from "V3TimingEvent" //	event occurs [offset] after a meal (from the Latin post cibus)
code "PCM": 'PCM' from "V3TimingEvent" //	event occurs [offset] after breakfast (from the Latin post cibus matutinus)
code "PCD": 'PCD' from "V3TimingEvent" //	event occurs [offset] after lunch (from the Latin post cibus diurnus)
code "PCV": 'PCV' from "V3TimingEvent" //	event occurs [offset] after dinner (from the Latin post cibus vespertinus)

code "MORN": 'MORN' from EventTiming //	Event occurs during the morning. The exact time is unspecified and established by institution convention or patient interpretation.
code "MORN.early": 'MORN.early' from EventTiming //	Early Morning	Event occurs during the early morning. The exact time is unspecified and established by institution convention or patient interpretation.
code "MORN.late": 'MORN.late' from EventTiming // Late Morning	Event occurs during the late morning. The exact time is unspecified and established by institution convention or patient interpretation.
code "NOON": 'NOON' from EventTiming //	Noon	Event occurs around 12:00pm. The exact time is unspecified and established by institution convention or patient interpretation.
code "AFT": 'AFT' from EventTiming //	Afternoon	Event occurs during the afternoon. The exact time is unspecified and established by institution convention or patient interpretation.
code "AFT.early": 'AFT.early' from EventTiming //	Early Afternoon	Event occurs during the early afternoon. The exact time is unspecified and established by institution convention or patient interpretation.
code "AFT.late": 'AFT.late' from EventTiming //	Late Afternoon	Event occurs during the late afternoon. The exact time is unspecified and established by institution convention or patient interpretation.
code "EVE": 'EVE' from EventTiming //	Evening	Event occurs during the evening. The exact time is unspecified and established by institution convention or patient interpretation.
code "EVE.early": 'EVE.early' from EventTiming //	Early Evening	Event occurs during the early evening. The exact time is unspecified and established by institution convention or patient interpretation.
code "EVE.late": 'EVE.late' from EventTiming //	Late Evening	Event occurs during the late evening. The exact time is unspecified and established by institution convention or patient interpretation.
code "NIGHT": 'NIGHT' from EventTiming //	Night	Event occurs during the night. The exact time is unspecified and established by institution convention or patient interpretation.
code "PHS": 'PHS' from EventTiming //	After Sleep	Event occurs [offset] after subject goes to sleep. The exact time is unspecified and established by institution convention or patient interpretation.

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
    else Message(null, true, 'CMDLogic.ToDaily.UnknownUnit', ErrorLevel, 'Unknown unit ' & period.unit)
  end

/*
  Returns a daily frequency for the given code representation of frequency.
  The function expects codes from the [EventTiming](http://hl7.org/fhir/codesystem-event-timing.html) or
  [V3TimingEvent](http://hl7.org/fhir/v3/TimingEvent/cs.html) code systems.
  // TODO: Determine whether or not we should use timing.code at all....
*/
define function ToDaily(frequency Code):
  case
    when frequency ~ "HS" then 1 // event occurs [offset] before the hour of sleep (or trying to)
    when frequency ~ "WAKE" then 1 // event occurs [offset] after waking
    when frequency ~ "C" then 3 //	event occurs at a meal (from the Latin cibus)
    when frequency ~ "CM" then 1 //	event occurs at breakfast (from the Latin cibus matutinus)
    when frequency ~ "CD" then 1 //	event occurs at lunch (from the Latin cibus diurnus)
    when frequency ~ "CV" then 1 //	event occurs at dinner (from the Latin ante cibus vespertinus)
    when frequency ~ "AC" then 3 //	event occurs [offset] before a meal (from the Latin ante cibus)
    when frequency ~ "ACM" then 1 //	event occurs [offset] before breakfast (from the Latin ante cibus matutinus)
    when frequency ~ "ACD" then 1 //	event occurs [offset] before lunch (from the Latin ante cibus diurnus)
    when frequency ~ "ACV" then 1 //	event occurs [offset] before dinner (from the Latin ante cibus vespertinus)
    when frequency ~ "PC" then 3 //	event occurs [offset] after a meal (from the Latin post cibus)
    when frequency ~ "PCM" then 1 //	event occurs [offset] after breakfast (from the Latin post cibus matutinus)
    when frequency ~ "PCD" then 1 //	event occurs [offset] after lunch (from the Latin post cibus diurnus)
    when frequency ~ "PCV" then 1 //	event occurs [offset] after dinner (from the Latin post cibus vespertinus)

    when frequency ~ "MORN" then 1 //	Event occurs during the morning. The exact time is unspecified and established by institution convention or patient interpretation.
    when frequency ~ "MORN.early" then 1 //	Early Morning	Event occurs during the early morning. The exact time is unspecified and established by institution convention or patient interpretation.
    when frequency ~ "MORN.late" then 1 // Late Morning	Event occurs during the late morning. The exact time is unspecified and established by institution convention or patient interpretation.
    when frequency ~ "NOON" then 1 //	Noon	Event occurs around 12:00pm. The exact time is unspecified and established by institution convention or patient interpretation.
    when frequency ~ "AFT" then 1 //	Afternoon	Event occurs during the afternoon. The exact time is unspecified and established by institution convention or patient interpretation.
    when frequency ~ "AFT.early" then 1 //	Early Afternoon	Event occurs during the early afternoon. The exact time is unspecified and established by institution convention or patient interpretation.
    when frequency ~ "AFT.late" then 1 //	Late Afternoon	Event occurs during the late afternoon. The exact time is unspecified and established by institution convention or patient interpretation.
    when frequency ~ "EVE" then 1 //	Evening	Event occurs during the evening. The exact time is unspecified and established by institution convention or patient interpretation.
    when frequency ~ "EVE.early" then 1 //	Early Evening	Event occurs during the early evening. The exact time is unspecified and established by institution convention or patient interpretation.
    when frequency ~ "EVE.late" then 1 //	Late Evening	Event occurs during the late evening. The exact time is unspecified and established by institution convention or patient interpretation.
    when frequency ~ "NIGHT" then 1 //	Night	Event occurs during the night. The exact time is unspecified and established by institution convention or patient interpretation.
    when frequency ~ "PHS" then 1 //	After Sleep	Event occurs [offset] after subject goes to sleep. The exact time is unspecified and established by institution convention or patient interpretation.

    when frequency ~ "Once daily (qualifier value)" then 1.0
    when frequency ~ "Twice a day (qualifier value)" then 2.0
    when frequency ~ "Three times daily (qualifier value)" then 3.0
    when frequency ~ "Four times daily (qualifier value)" then 4.0
    when frequency ~ "Every twenty four hours (qualifier value)" then 1.0
    when frequency ~ "Every twelve hours (qualifier value)" then 2.0
    when frequency ~ "Every thirty six hours (qualifier value)" then 0.67
    when frequency ~ "Every eight hours (qualifier value)" then 3.0
    when frequency ~ "Every four hours (qualifier value)" then 6.0
    when frequency ~ "Every six hours (qualifier value)" then 4.0
    when frequency ~ "Every seventy two hours (qualifier value)" then 0.34
    when frequency ~ "Every forty eight hours (qualifier value)" then 0.5
    when frequency ~ "Every eight to twelve hours (qualifier value)" then 2.0
    when frequency ~ "Every six to eight hours (qualifier value)" then 3.0
    when frequency ~ "Every three to four hours (qualifier value)" then 6.0
    when frequency ~ "Every three to six hours (qualifier value)" then 4.0
    when frequency ~ "Every two to four hours (qualifier value)" then 6.0
    when frequency ~ "One to four times a day (qualifier value)" then 4.0
    when frequency ~ "One to three times a day (qualifier value)" then 3.0
    when frequency ~ "One to two times a day (qualifier value)" then 2.0
    when frequency ~ "Two to four times a day (qualifier value)" then 4.0

    else Message(null, true, 'CMDLogic.ToDaily.UnknownFrequencyCode', ErrorLevel, 'Unknown frequency code ' & frequency.code)
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
Calculates the Medication Period for a single MedicationRequest.
MedicationRequest instances provided to this function are expected
to conform to the [MMEMedicationRequest](http://build.fhir.org/ig/cqframework/opioid-mme-r4/StructureDefinition-mmemedicationrequest.html)
profile, which expects:
* 1 and only 1 dosageInstruction, multiple dosageInstruction elements will result in an error
* 1 and only 1 doseAndRate, multiple doseAndRate elements will result in an error
* 1 timing with 1 repeat, missing timing or repeat elements will result in a null
* frequency, frequencyMax, defaulting to 1
* period, periodUnit, defaulting to 1 'd'
* timeOfDay
* doseQuantity or doseRange, missing doseQuantity and doseRange will result in a null
Note that MedicationRequest status is not considered by this calculation, as the
list of MedicationRequest instances provided to this function should already have
considered appropriate statuses, depending on the use case, typically `completed`.
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
      daysSupply: convert R.dispenseRequest.expectedSupplyDuration to days,
      quantity: R.dispenseRequest.quantity,
      refills: Coalesce(R.dispenseRequest.numberOfRepeatsAllowed, 0),
      startDate:
        Coalesce(
          date from start of boundsPeriod,
          date from R.authoredOn,
          date from start of R.dispenseRequest.validityPeriod
        ),
      durationInDays: Coalesce(daysSupply, quantity / (dose * dosesPerDay)) * (1 + refills)
    return
      if startDate is not null and boundsPeriod."end" is not null then
        Interval[startDate, end of boundsPeriod]
      else if startDate is not null and durationInDays is not null then
        Interval[startDate, startDate + (durationInDays - 1 day) ]
      else
        null

/*
Next, consider the MedicationDispense case:

* whenPrepared: When product was prepared
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
event is documenting a single dispense, and does not contain refill information. In addition,
multiple dispense events would typically be present, and those would all have to be considered
as part of an overall calculation. That will be considered when we combine results, but for
this function, we'll focus on calculating the duration of a single dispense.

With a MedicationDispense, dosage information is expected to be the same as the related
MedicationRequest, so boundsPeriod would still cover the entire prescription (including refills)
and so cannot be used to calculate the interval covered by the dispense.

If the daysSupply element is present, then the duration in days is simply

    daysSupply

Note specifically that we are not considering refills, as those would be covered
by subsequent dispense records.

If daysSupplied is not present, then daysSupplied must be calculated based on
the quantity, dosage, and frequency:

    (quantity / (dosage * frequency))

This calculation results in a number of days, which can then be turned into a
period by anchoring that to the startDate, as determined by the first available
value of the start of the boundsPeriod, whenHandedOver, and whenPrepared.

   Interval[startDate, startDate + durationInDays - 1 day]
*/

/*
Calculates Medication Period for a given MedicationDispense
MedicationDispense instances provided to this function are expected
to conform to the [TODO: MMEMedicationDispense](http://build.fhir.org/ig/cqframework/opioid-mme-r4/StructureDefinition-mmemedicationdispense.html)
profile, which expects:
* 1 and only 1 dosageInstruction, multiple dosageInstruction elements will result in an error
* 1 and only 1 doseAndRate, multiple doseAndRate elements will result in an error
* 1 timing with 1 repeat, missing timing or repeat elements will result in a null
* frequency, frequencyMax, defaulting to 1
* period, periodUnit, defaulting to 1 'd'
* timeOfDay
* doseQuantity or doseRange, missing doseQuantity and doseRange will result in a null
* whenHandedOver or whenPrepared, if missing both whenHandedOver and whenPrepared will result in a null

Note that MedicationDispense status is not considered by this calculation, as the
list of MedicationDispense instances provided to this function should already have
considered appropriate statuses, depending on the use case, typically `completed`,
especially since whenHandedOver would be expected to be present for a completed
MedicationDispense.

Note also that the dosage information recorded in a dispense is expected to be a copy of the
dispense information from the related medication request. As such, the boundsPeriod would be expected
to cover the entire range, and should _not_ be used for timing of the event.

There is also active discussion in the Pharmacy WG about what date should be used if whenPrepared/whenHandedOver is not present.
This may take the form of an "original creation date", but may also be a "status change date" for dispense events that are updating
status of an existing dispense. That discussion is ongoing, so until that is resolved, this logic will return
null if whenPrepared/whenHandedOver are not available.
*/
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
      daysSupply: convert D.daysSupply to days,
      dosesPerDay: Coalesce(ToDaily(frequency, period), Count(timing.repeat.timeOfDay), 1.0),
      startDate:
        Coalesce(
          date from D.whenHandedOver,
          date from D.whenPrepared
        ),
      durationInDays: Coalesce(daysSupply, D.quantity / (dose * dosesPerDay))
    return
      if startDate is not null and durationInDays is not null then
        Interval[startDate, startDate + (durationInDays - 1 day)]
      else
        null

/*
Returns the established therapeutic duration for a given medication.
This is likely measure specific, though could potentially be established for
any drug and distributed as a CodeSystem supplement.
Defaulting to 14 days here for illustration.
*/
define function TherapeuticDuration(medication Concept):
  14 days

/*
Next we consider MedicationAdministration. This data type is typically used to
capture specific administration, with the relevantPeriod capturing start and stop
time of the administration event:

* effective[x]: Start and end time of administration

However, when calculating cumulative medication duration, it is typically the
therapeutic period of the medication that should be considered. Currently neither
the Medication nor MedicationKnowledge resources provide this information, so
we model it here as a function that can potentially be implemented in a variety
of ways, including measure-specific values, as well as distribution as an RxNorm
code system supplement.

However it is obtained, if therapeutic duration can be obtained, and the effective
period has a start, the result will be

    Interval[startDate, startDate + therapeuticDuration - 1 day]
*/
define function MedicationAdministrationPeriod(Administration "MedicationAdministration"):
  Administration M
    let
      therapeuticDuration: TherapeuticDuration(Administration.medication),
      startDate: date from start of Administration.effective
    return
      if startDate is not null and therapeuticDuration is not null then
        Interval[startDate, startDate + (therapeuticDuration - 1 day)]
      else
        null

/*
Now that we have functions for determining the medication period for individual
prescriptions, administrations, and dispenses, we can combine those using
an overall cumulative medication duration calculation.

There are two broad approaches to calculating cumulative duration, one that _collapses_
overlapping intervals so that calculations are not duplicated, and one that _rolls out_
overlapping intervals so that the durations are laid end-to-end.

First, we define a function that simply calculates CumulativeDuration of a set of
intervals:
*/
define function CumulativeDuration(Intervals List<Interval<DateTime>>):
  Sum((collapse Intervals per day) X return all difference in days between start of X and end of X)

/*
Next, we define a function that rolls out intervals:
*/
define function RolloutIntervals(intervals List<Interval<DateTime>>):
  intervals I
    aggregate R starting (null as List<Interval<DateTime>>):
      R union ({
        I X
          let
            S: Max({ end of Last(R) + 1 day, start of X }),
            E: S + duration in days of X
          return Interval[S, E]
      })

/*
Then, we define a function that allows us to calculate based on the various medication
types:
*/

define function MedicationPeriod(
  medication Choice<"MedicationRequest",
    "MedicationDispense",
    "MedicationAdministration"
  >):
  case
    when medication is MedicationRequest then MedicationRequestPeriod(medication)
    when medication is MedicationDispense then MedicationDispensePeriod(medication)
    when medication is MedicationAdministration then MedicationAdministrationPeriod(medication)
    else null
  end

/*
We can then use this function, combined with the MedicationDuration functions above
to calculate Cumulative Medication Duration:

Generally speaking, we want to _roll out_ intervals from dispense and administration
events, and then collapse across that result and intervals from prescriptions.

Note also that the separation of medications by type should already be done
by this stage as well.

Calculations that combine dosages from different types of medications (such as Morphine Milligram Equivalent (MME)
or Average MME) require further consideration.
*/

define function CumulativeMedicationDuration(
  Medications List<Choice<"MedicationRequest",
    "MedicationDispense",
    "MedicationAdministration"
  >>):
  CumulativeDuration((
      Medications M
        where M is MedicationRequest
        return MedicationPeriod(M)
    )
      union (
        RolloutIntervals(
          Medications M
            where M is MedicationDispense or M is MedicationAdministration
            return MedicationPeriod(M)
        )
      )
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
