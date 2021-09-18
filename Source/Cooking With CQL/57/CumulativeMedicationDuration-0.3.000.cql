/*
@description: This library provides cumulative medication duration calculation
logic for use with Quality Data Model prescription, discharge, administration,
and dispensing events. The logic here follows the guidance provided as part of
the 5.6 version of Quality Data Model.
@comment: Note that the logic here assumes single-instruction dosing information.
Split-dosing, tapering, and other more complex dosing instructions are not handled.
@changelog:
v0.3.000
Fixed Quantity handling in duration calculations
Fixed authorDatetime null handling
Changed to provide Date-level calculation, rather than DateTime
*/
library CumulativeMedicationDuration version '0.3.000'

using QDM version '5.6'

include MATGlobalCommonFunctions version '7.0.000' called Global

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

context Patient

/*@description: Converts a frequency quantity to a daily frequency (as a decimal)
@comment: This function considers both the value and unit of the given frequency.
E.g. the frequency `30 'min'` will result in a daily frequency of `48.0`*/
define function "QuantityToDaily"(Frequency Quantity ):
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

/*@description: Returns the equivalent daily frequency (as a decimal) of the given code
@comment: Note that for ranges, the upper range is used. E.g. `Every two to four hours`
results in `6.0` and `One to two` times a day results in `2.0`.*/
define function "CodeToDaily"(Frequency Code ):
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

/*@description: Returns the daily frequency (as a decimal) of the given input*/
define function "ToDaily"(Frequency Choice<Quantity, Code> ):
  case
    when Frequency is Quantity then QuantityToDaily(Frequency as Quantity)
    else CodeToDaily(Frequency as Code)
  end

/*@description: Calculates the Medication Period for a single Medication, Order
@comment: This function calculates the expected period of a medication order
using the following approach: If the `relevantPeriod` element is present and
completely specified, it is used directly. If the `daysSupplied` element is present,
the duration is `daysSupplied * (1 + refills)`. Otherwise, `daysSupplied` is calculated
using `(supply / dosage * frequency)) * (1 + refills)`. The result is then the interval
from `authorDatetime` to `authorDatetime + daysSupplied`.

Note that the supply and dosage Quantity values on the order are assumed to be in
terms of the same unit, typically a tablet or mL. If supply and dosage are not
expressed in the same unit, this function will return null if duration in days
must be calculated.
@seealso: [Cumulative MedicationDuration](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/blob/master/Source/Libraries/CumulativeMedicationDuration-1.0.000.md)*/
define function "MedicationOrderPeriod"(Order "Medication, Order" ):
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
    ) durationInDays
      let startDate: date from Coalesce(Order.relevantPeriod.low, Order.authorDatetime)
      return
        if durationInDays is not null then
          Interval[startDate, startDate + Quantity { value: durationInDays, unit: 'day' }]
        else
          null

/*@description: Calculates Medication Period for a given Medication, Dispensed
@comment: This function calculates the effective duration of a single medication
dispensing event using the following approach: If the `relevantPeriod` is present
(and completely specified), it is used directly. If the `daysSupplied` element is present,
the duration is `daysSupplied`. Otherwise, `daysSupplied` is calculated using
`(supply / (dosage * frequency))`. The result is then the interval
from `authorDatetime` to `authorDatetime + daysSupplied`.

Note that the supply and dosage Quantity values on the order are assumed to be in
terms of the same unit, typically a tablet or mL.
@seealso: [Cumulative MedicationDuration](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/blob/master/Source/Libraries/CumulativeMedicationDuration-1.0.000.md)*/
define function "MedicationDispensedPeriod"(Dispense "Medication, Dispensed" ):
  if Dispense.relevantPeriod.low is null and Dispense.authorDatetime is null then
    null
  else if Dispense.relevantPeriod.high is not null then
    Interval[date from Coalesce(Dispense.relevantPeriod.low, Dispense.authorDatetime), date from end of Dispense.relevantPeriod]
  else
    (
      Coalesce(
        Dispense.daysSupplied,
        Dispense.supply.value / (Dispense.dosage.value * ToDaily(Dispense.frequency))
      )
    ) durationInDays
      let startDate: date from Coalesce(Dispense.relevantPeriod.low, Dispense.authorDatetime)
      return
        if durationInDays is not null then
          Interval[startDate, startDate + Quantity { value: durationInDays, unit: 'day' }]
        else
          null

/*@description: Returns the established therapeutic duration for a given medication.
@comment: This is likely measure specific, though could potentially be established for
any drug and distributed as a CodeSystem supplement.
Defaulting to 14 days here for illustration.
@seealso: [Cumulative MedicationDuration](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/blob/master/Source/Libraries/CumulativeMedicationDuration-1.0.000.md)*/
define function "TherapeuticDuration"(medication Code ):
  14 days

/*@description: Calculates Medication Period for a given Medication, Administration
@comment: This function calculates the effective duration of a single medication
administration event using the following approach: If a TherapeuticDuration is
defined for the medication, the result is the interval from the earliest of the
`relevantDatetime` and `relevantPeriod` elements, to the end of the therapeutic duration.
@seealso: [Cumulative MedicationDuration](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/blob/master/Source/Libraries/CumulativeMedicationDuration-1.0.000.md)*/
define function "MedicationAdministrationPeriod"(Administration "Medication, Administered" ):
  Administration M
    let
      therapeuticDuration: TherapeuticDuration(Administration.code),
      startDate: date from Global.EarliestOf(Administration.relevantDatetime, Administration.relevantPeriod)
    return
      if startDate is not null and therapeuticDuration is not null then
        Interval[startDate, startDate + therapeuticDuration]
      else
        null

/*@description: Calculates the Medication Period for a Medication, Discharge
@comment: This function calculates the effective duration of a single medication
discharge event using the following approach: If the `daysSupplied` element is present,
the duration is `daysSupplied * (1 + refills)`. Otherwise, the duration is calculated using
`(supply / (dosage * frequency)) * (1 + refills)`. The result is then the interval
from `authorDatetime` to `authorDatetime + daysSupplied`.

Note that the supply and dosage Quantity values on the order are assumed to be in
terms of the same unit, typically a tablet or mL.
@seealso: [Cumulative MedicationDuration](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/blob/master/Source/Libraries/CumulativeMedicationDuration-1.0.000.md)*/
define function "MedicationDischargePeriod"(Medication "Medication, Discharge" ):
  (
    Coalesce(
      Medication.daysSupplied,
      Medication.supply.value / (Medication.dosage.value * ToDaily(Medication.frequency))
    ) * (1 + Coalesce(Medication.refills, 0))
  ) durationInDays
    let startDate: date from Medication.authorDatetime
    return
      if startDate is not null and durationInDays is not null then
        Interval[startDate, startDate + Quantity { value: durationInDays, unit: 'day' }]
      else
        null

/*@description: Returns the total duration in days covered by the given periods.
@comment: This function calculates the total duration in days covered by the given
periods. If multiple periods in the input include the same day, that day is only
counted once in the final result.*/
define function "CumulativeDuration"(Intervals List<Interval<Date>> ):
  Sum((collapse Intervals) X return all difference in days between start of X and end of X)

/*@description: Rolls out periods so that overlapping periods delay the start of subsequent periods.
@comment: Returns the periods with overlapping periods delayed so that there is no overlap between
any two periods in the result.*/
define function "RolloutIntervals"(intervals List<Interval<Date>> ):
  intervals I
    aggregate R starting (null as List<Interval<Date>>):
      R union ({
        I X
          let
            S: Max({ end of Last(R) + 1 day, start of X }),
            E: S + duration in days of X
          return Interval[S, E]
      })

/*@description: Calculates the effective duration of the given medication event, whether it
is an order, dispense, discharge, or administration.*/
define function "MedicationPeriod"(Medication Choice<"Medication, Order",
    "Medication, Dispensed",
    "Medication, Discharge",
    "Medication, Administered"
  > ):
  Coalesce(
    MedicationOrderPeriod(Medication),
    MedicationDispensedPeriod(Medication),
    MedicationDischargePeriod(Medication),
    MedicationAdministrationPeriod(Medication)
  )

/*@description: Calculates the cumulative medication duration of the given medication
events.
@comment: This function will _roll out_ periods from dispense and administration
events, and then collapse across that result and periods from prescriptions. The
separation of medications by type should already be done prior to using this function. In addition,
calculations that combine dosages from different types of medications (such as Morphine Milligram Equivalent (MME)
) require further consideration.*/
define function "CalculateCumulativeMedicationDuration"(Medications List<Choice<"Medication, Order",
    "Medication, Dispensed",
    "Medication, Discharge",
    "Medication, Administered"
  >> ):
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
