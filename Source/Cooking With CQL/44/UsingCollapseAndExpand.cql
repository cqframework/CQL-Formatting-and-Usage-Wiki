library UsingCollapseAndExpand

using FHIR version '4.0.1'
using QDM version '5.5'

include FHIRHelpers version '4.0.1'
include ConversionLogic version '3.1.000' called OpioidConversionLogic

codesystem "SNOMEDCT": 'urn:oid:2.16.840.1.113883.6.96'

valueset "Opioid analgesics with ambulatory misuse potential": 'TBD'

code "Every eight hours (qualifier value)": '307469008' from "SNOMEDCT" display 'Every eight hours (qualifier value)'
code "Every eight to twelve hours (qualifier value)": '396140003' from "SNOMEDCT" display 'Every eight to twelve hours (qualifier value)'
code "Every forty eight hours (qualifier value)": '396131002' from "SNOMEDCT" display 'Every forty eight hours (qualifier value)'
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

context Patient

// [Collapse](https://cql.hl7.org/02-authorsguide.html#lists-of-intervals)
// [Collapse (reference)](https://cql.hl7.org/09-b-cqlreference.html#collapse)

/*
The collapse operator returns the unique set of intervals that completely covers
the ranges present in the given list of intervals. In other words, adjacent intervals
within a sorted list are merged if they either overlap or meet.
*/

define Collapse1To9:
  collapse { Interval[1, 4], Interval[4, 8], Interval[7, 9] }

/*
|---|
    |---|
       |---|
------------
|----------|
*/

define CollapseWithGaps:
  collapse { Interval[1, 4], Interval[2, 5], Interval[7, 9] }

/*
|---|
 |---|
       |--|
-----------
|----|
       |--|
*/

// Using collapse to determine cumulative medication duration for opioids:
define function "Days on Opioids during Period"(period Interval<Date>):
  Sum(
    (
      collapse (
        [MedicationRequest: "Opioid analgesics with ambulatory misuse potential"] OpioidPrescription
          where OpioidPrescription.status = 'active'
            and OpioidPrescription.intent = 'order'
        return "Prescription Relevant Period"( OpioidPrescription ) intersect period
      )
    ) OpioidUseInterval
      return days between start of OpioidUseInterval and end of OpioidUseInterval
  )

// [Expand](https://cql.hl7.org/02-authorsguide.html#lists-of-intervals)
// [Expand (reference)](https://cql.hl7.org/09-b-cqlreference.html#expand)

// Expand

/*
The expand operator returns the set of intervals of size per for all the intervals in the input.
*/

define ExpandExample:
  expand { Interval[1, 5] }

// This example returns a list of "unit" intervals (an interval containing a single point)
define ExpandExampleResult:
  {
    Interval[1, 1],
    Interval[2, 2],
    Interval[3, 3],
    Interval[4, 4],
    Interval[5, 5]
  }

// Expand is conceptually the opposite of collapse. In particular, the collapse of a set of intervals is the same as the collapse of the expand of a set of intervals:

define IntervalSet: { Interval[1, 4], Interval[4, 5], Interval[7, 9] }
define EquivalentResults:
  ( collapse ( IntervalSet ) ) = ( collapse ( expand (IntervalSet) ) )

// Using expand to determine average daily dosage:

define function "CalculateDailyMMEPerMedication"(medications List<"Medication, Order">, period Interval<DateTime>):
  /*Calculates the daily MME by multiplying the single administration dosage by the frequency (number of times the dose is administered per day)*/
  medications OpioidMedication
    let dosesPerDay: "DosesPerDay"(OpioidMedication.frequency),
    MME: ( OpioidConversionLogic."CalculateMorphineMilligramEquivalents" ( { {
        rxNormCode: OpioidMedication.code,
        doseQuantity: OpioidMedication.dosage,
        dosesPerDay: dosesPerDay
      } } )
    ),
    medicationPeriod: "MedicationRelevantPeriod"(OpioidMedication)
      intersect period
    return {
      rxNormCode: OpioidMedication.code,
      authortime: OpioidMedication.authorDatetime,
      effectivePeriod: medicationPeriod,
      conversionFactor: singleton from ( MME.conversionFactor ),
      daysInPeriod: "DaysInPeriodExpand"(medicationPeriod),
      mme: Sum(MME.MME)
    }

// Returns the list of days in the given period
// Note the use of the "per" argument to specify the precision for the expand
define function "DaysInPeriodExpand"(period Interval<DateTime>):
  ( expand { period } per day ) DayInterval
    return all start of DayInterval


///////////////////////////////////////////////////////////////////////////////
// Definitions in support of the above examples

define function "Prescription Relevant Period"(prescription FHIR.MedicationRequest):
  if (
    prescription.authoredOn is not null and prescription.dispenseRequest is not null
      and prescription.dispenseRequest.expectedSupplyDuration is not null
  )
  then Interval[
    date from prescription.authoredOn,
    date from prescription.authoredOn + System.Quantity{ value: GetDurationInDays(prescription.dispenseRequest.expectedSupplyDuration), unit: 'days' }
  ]
  else null

define function GetDurationInDays(value FHIR.Duration): // returns Decimal:
    case value.code.value
      when 'a' then value.value * 365.0
      when 'mo' then value.value.value * 30.0
      when 'wk' then value.value.value * 7.0
      when 'd' then value.value.value
      when 'h' then value.value.value / 24.0
      when 'min' then value.value.value / 60.0 / 24.0
      when 's' then value.value.value / 60.0 / 60.0 / 24.0
      when 'ms' then value.value.value / 60.0 / 60.0 / 24.0 / 1000.0
      else Message(1000, true, 'Undefined', 'Error', 'Unsupported duration unit ' + value.code.value)
    end

define function "MedicationRelevantPeriod"(OpioidMedication "Medication, Order"):
  Interval[start of OpioidMedication.relevantPeriod, if OpioidMedication.daysSupplied is not null then start of OpioidMedication.relevantPeriod + System.Quantity { value: OpioidMedication.daysSupplied, unit: 'd' }
    else
  end of OpioidMedication.relevantPeriod]

define function "DosesPerDay"(frequency Code):
  /*Calculates the cumulative dose per day for each prescription*/
  case
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
    else null
  end
