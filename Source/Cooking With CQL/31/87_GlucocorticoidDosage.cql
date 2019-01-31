library GlucocorticoidDosage

using QDM version '5.3'

include DayMonthTimings version '0.9.000' called Timing

codesystem "SNOMEDCT:2018-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2018-03'
codesystem "SNOMEDCT": 'urn:oid:2.16.840.1.113883.6.96'

valueset "Glucocorticoids (oral only)": '2.16.840.1.113883.3.464.1003.196.12.1266'

code "Every eight hours (qualifier value)": '307469008' from "SNOMEDCT:2018-03" display 'Every eight hours (qualifier value)'
code "Every eight to twelve hours (qualifier value)": '396140003' from "SNOMEDCT" display 'Every eight to twelve hours (qualifier value)'
code "Every forty eight hours (qualifier value)": '396131002' from "SNOMEDCT:2018-03" display 'Every forty eight hours (qualifier value)'
code "Every four hours (qualifier value)": '225756002' from "SNOMEDCT" display 'Every four hours (qualifier value)'
code "Every seventy two hours (qualifier value)": '396143001' from "SNOMEDCT:2018-03" display 'Every seventy two hours (qualifier value)'
code "Every six hours (qualifier value)": '307468000' from "SNOMEDCT:2018-03" display 'Every six hours (qualifier value)'
code "Every six to eight hours (qualifier value)": '396139000' from "SNOMEDCT" display 'Every six to eight hours (qualifier value)'
code "Every thirty six hours (qualifier value)": '396126004' from "SNOMEDCT:2018-03" display 'Every thirty six hours (qualifier value)'
code "Every three to four hours (qualifier value)": '225754004' from "SNOMEDCT" display 'Every three to four hours (qualifier value)'
code "Every three to six hours (qualifier value)": '396127008' from "SNOMEDCT" display 'Every three to six hours (qualifier value)'
code "Every twelve hours (qualifier value)": '307470009' from "SNOMEDCT:2018-03" display 'Every twelve hours (qualifier value)'
code "Every twenty four hours (qualifier value)": '396125000' from "SNOMEDCT:2018-03" display 'Every twenty four hours (qualifier value)'
code "Every two to four hours (qualifier value)": '225752000' from "SNOMEDCT" display 'Every two to four hours (qualifier value)'
code "Four times daily (qualifier value)": '307439001' from "SNOMEDCT:2018-03" display 'Four times daily (qualifier value)'
code "Once daily (qualifier value)": '229797004' from "SNOMEDCT:2018-03" display 'Once daily (qualifier value)'
code "One to four times a day (qualifier value)": '396109005' from "SNOMEDCT" display 'One to four times a day (qualifier value)'
code "One to three times a day (qualifier value)": '396108002' from "SNOMEDCT" display 'One to three times a day (qualifier value)'
code "One to two times a day (qualifier value)": '396107007' from "SNOMEDCT" display 'One to two times a day (qualifier value)'
code "Three times daily (qualifier value)": '229798009' from "SNOMEDCT:2018-03" display 'Three times daily (qualifier value)'
code "Twice a day (qualifier value)": '229799001' from "SNOMEDCT:2018-03" display 'Twice a day (qualifier value)'
code "Two to four times a day (qualifier value)": '396111001' from "SNOMEDCT" display 'Two to four times a day (qualifier value)'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
Glucocorticoid Dosage

What we really need is to know is if the patient was on Glucocorticoids >= 5 mg/per day for 90 days or more.

Here is an example:

Patient receives the following:

    30-day prescriptions for Glucocorticoid A on Jan 1, Feb 1, and March 1 – each is 3 mg/day.
    30-day prescription for Glucocorticoid B on Feb 14 – 5 mg/day.  

The patient isn’t excluded because they didn’t have >= 90 days of glucocorticoids >=5 mg/day. 
They only have 30.  From Feb 14 to Feb 28, they had 5 mg/day.  
From March 1 to March 15, they had 8 mg/day.

*/

define "Glucocorticoid Medication Active":
  ["Medication, Active": "Glucocorticoids (oral only)"] Glucocorticoid
    where Glucocorticoid.relevantPeriod starts before end of "Measurement Period"
    
/*
Dosage: Quantity to be taken at a single administration
Frequency: How frequently the medication should be/was taken
Relevant Period: Start/Stop of the medication
Supply: Quantity of medication made available
Days Supplied: Number of days over which the medication is expected to last

Approach here is to use Frequency and Dosage to determine mg/day
*/

/*
Frequency is expected to be specified as a code, so we turn it into a value for computation
*/

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

/*
Calculating daily dosage, assuming the quantity has units of 'mg'
Note that this is simplified and would need to account for unit conversion
*/

define function "GetMedicationDailyDose"(dosage Quantity, dosesPerDay Decimal):
  dosage * Quantity { value: dosesPerDay, unit: '/d' }
  
/*
Next, we need to calculate the combined dosage per day for the medication periods.
Cumulative medication duration would give us combined durations for potentially
overlapping periods, but we need to combine that result with the medication dosage
on each day during the periods.
*/

define "Glucocorticoids Daily Dosage Per Medication":
  "Glucocorticoid Medication Active" M
    let 
      dosesPerDay: "DosesPerDay"(M.frequency),
      dailyDosage: "GetMedicationDailyDose"(M.dosage, dosesPerDay),
      medPeriod: M.relevantPeriod intersect "Measurement Period"
    return {
      code: M.code,
      daysInPeriod: Timing."DaysInPeriod"(medPeriod),
      dailyDosage: dailyDosage
    }
    
define function "Glucocorticoids Dosage Per Day"(glucocorticoids List<Tuple {
  code Code,
  daysInPeriod List<DateTime>,
  dailyDosage Quantity
}>):
  (distinct(flatten(glucocorticoids G return all G.daysInPeriod))) Day
    return {
      medicationDay: Day,
      totalDailyDosage: 
        Sum(glucocorticoids InnerG where Day in InnerG.daysInPeriod return all InnerG.dailyDosage)
    }

/*
Now we have a list of days on which the patient was prescribed glucocorticoids, and the
total daily dosage for each day.
*/

define "Glucocorticoids greater than 5 mg per day for 90 or more days":
  Count(
    ("Glucocorticoids Dosage Per Day"("Glucocorticoids Daily Dosage Per Medication")) D
      where D.totalDailyDosage >= 5 'mg/d'
  ) >= 90
  


