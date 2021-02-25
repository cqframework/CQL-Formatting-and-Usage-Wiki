library CumulativeMedicationDuration

/*
This library provides guidance for calculating Cumulative Medication Duration
using QDM 5.5 and above.
*/

using QDM version '5.5'

codesystem "EventTiming": 'urn:oid:2.16.840.1.113883.4.642.1.69' // http://hl7.org/fhir/event-timing

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

context Patient

/*
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

// NOTE: This guidance explicitly excludes the Medication, Active QDM data type

*/

/*
  For the first approach, we need to get from frequency to a frequency/day
  So we define ToDaily
*/

define function ToDaily(Frequency Quantity):
  case Frequency.unit
    when 'h' then (24.0 / Frequency.value)
    when 'min' then (24.0 / Frequency.value) * 60
    when 's' then (24.0 / Frequency.value) * 60 * 60
    when 'd' then (24.0 / Frequency.value) / 24
    when 'wk' then (24.0 / Frequency.value) / (24 * 7)
    when 'mo' then (24.0 / Frequency.value) / (24 * 30) // assuming 30 days in month
    when 'a' then (24.0 / Frequency.value) / (24 * 365) // assuming 365 days in year
    else null
  end

define function ToDaily(Frequency Code):
  case Frequency
    when "C" then 3
    // etc.
    else null
  end

define function ToDaily(Frequency Choice<Quantity, Code>):
  case
    when Frequency is Quantity then ToDaily(Frequency as Quantity)
    else ToDaily(Frequency as Code)
  end

/*
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

If the relevantPeriod element is present (and completely specified), then we can use that directly

    relevantPeriod

If the daysSupplied element is present, then the duration in days is simply

    daysSupplied * (1 + refills)

If daysSupplied is not present, then daysSupplied must be calculated based on
the supply, dosage, and frequency:

    (supply / (dosage * frequency)) * (1 + refills)

This calculation results in a number of days, which can then be turned into a
period by anchoring that to the authorDatetime

   Interval[authorDatetime, authorDatetime + durationInDays]

The following function illustrates this completely:
*/

/*
Calculates the Medication Period for a single Medication, Order
*/
define function MedicationOrderPeriod(Order "Medication, Order"):
  if HasEnd(Order.relevantPeriod) then
    Interval[Coalesce(start of Order.relevantPeriod, Order.authorDatetime), end of Order.relevantPeriod]
  else
    (
      Coalesce(
        Order.daysSupplied,
        Order.supply / (Order.dosage * ToDaily(Order.frequency))
      ) * (1 + Coalesce(Order.refills, 0))
    ) durationInDays
      let startDatetime: Coalesce(start of Order.relevantPeriod, Order.authorDatetime)
      return Interval[startDatetime, startDatetime + durationInDays]

/*
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

If the relevantPeriod element is present (and completely specified), then we can use that directly

    relevantPeriod

If the daysSupplied element is present, then the duration in days is simply

    daysSupplied

Note specifically that we are not considering refills, as those would be covered
by subsequent dispense records.

If daysSupplied is not present, then daysSupplied must be calculated based on
the supply, dosage, and frequency:

    (supply / (dosage * frequency))

This calculation results in a number of days, which can then be turned into a
period by anchoring that to the authorDatetime

   Interval[authorDatetime, authorDatetime + durationInDays]
*/

/*
Calculates Medication Period for a given Medication, Dispensed
*/

define function MedicationDispensedPeriod(Dispense "Medication, Dispensed"):
  if HasEnd(Dispense.relevantPeriod) then
    Interval[Coalesce(start of Dispense.relevantPeriod, Dispense.authorDatetime), end of Dispense.relevantPeriod]
  else
    (
      Coalesce(
        Dispense.daysSupplied,
        Dispense.supply / (Dispense.dosage * ToDaily(Dispense.frequency))
      )
    ) durationInDays
      let startDatetime: Coalesce(start of Dispense.relevantPeriod, Dispense.authorDatetime)
      return Interval[startDatetime, startDatetime + durationInDays]

/*
Next we consider Medication, Administered. This data type is typically used to
capture specific administration, with the relevantPeriod capturing start and stop
time of the administration event:

* startTime: when a single medication administration event starts (e.g., the
  initiation of an intravenous infusion, or administering a pill or IM injection to a patient)
* stopTime: when a single medication administration event ends (e.g., the end time of
  the intravenous infusion, or the administration of a pill or IM injection is completed.
  For pills and IM injections, the start and stop times are the same)

NOTE: Given the relevantPeriod is focused on just the single administration being documented, the
actual duration of the medication would need to be determined with the corresponding order/dispense
information. That means relevantPeriod on this type isn't the "duration" of the medication in the
same sense as the other types.

One potential solution to that is to define the "effectiveDuration" for a given medication
based on value set, and then define a function that lets you determine the relevant period
based on the given effective duration. Should consider potential for proportion of covered days
as well, rather than an effective duration.
*/

/*
For Medication, Discharge, we have the same elements, except no relevantPeriod:

* authorDatetime: The date the dispense was authored
* dosage: The quantity to be taken at a single administration
* supply: The quantity that was provided to a patient
* daysSupplied: The number of days over which the medication is expected to last, per dispense
* frequency: How frequently the medication should be taken
* refills: The number of refills allowed by the prescription

So the calculation is slightly different:

*/

/*
Calculates the Medication Period for a Medication, Discharge
*/
define function MedicationDischargePeriod(Medication "Medication, Discharge"):
  (
    Coalesce(
      Medication.daysSupplied,
      Medication.supply / (Medication.dosage * ToDaily(Medication.frequency))
    ) * (1 + Coalesce(Medication.refills, 0))
  ) durationInDays
    let startDatetime: Medication.authorDatetime
    return Interval[startDatetime, startDatetime + durationInDays]

/*
Now that we have functions for determining the medication period for individual
orders, discharges, and dispenses, we can combine those using
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
  Medication Choice<"Medication, Order",
    "Medication, Dispensed",
    "Medication, Discharge"
  >):
  Coalesce(
    MedicationOrderPeriod(Medication),
    MedicationDispensedPeriod(Medication),
    MedicationDischargePeriod(Medication)
  )

/*
We can then use this function, combined with the MedicationDuration functions above
to calculate Cumulative Medication Duration:
*/

define function CumulativeMedicationDuration(
  Medications List<Choice<"Medication, Order",
    "Medication, Dispensed",
    "Medication, Discharge"
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
