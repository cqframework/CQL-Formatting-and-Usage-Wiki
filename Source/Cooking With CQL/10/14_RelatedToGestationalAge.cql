library RelatedToGestationalAge

using QDM version '5.0'

valueset "Inpatient Encounter Codes": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Estimated Due Date Codes": 'TBD'
valueset "Time of Delivery Codes": 'TBD'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
This comes from our PC-01 (CMS113) measure denominator:

Patients delivering newborns with >= 37 and < 39 weeks of gestation completed

Currently expressed in QDM like this:

    Denominator =
        AND: Initial Population
        AND: "Physical Exam, Performed: Estimated Gestational Age at Delivery" satisfies all:
            (result >= 37 week(s))
            (result < 39 week(s))
            < 1 day(s) starts before start of ("Physical Exam, Performed: Time of Delivery" starts during Occurrence A of $EncounterInpatient )

We actually want to use the Assessment, Performed datatype to express Time of Delivery,
and would expect the Time of Delivery to be a Result that is a date/time stamp.
The timing logic of < 1 day starts before start … would then be based off of the
Result Date/time (not the author time of the assessment).

For the Estimated Gestational Age at Delivery, please use the calculated gestational
age using ACOG ReVITALize guidelines with Estimated Due Date (EDD).

Please let me know if you have any questions or need additional information.

*/

define "Inpatient Encounter":
  ["Encounter, Performed": "Inpatient Encounter Codes"] Encounter
    where duration in days of Encounter.relevantPeriod <= 120
      and end of Encounter.relevantPeriod in "Measurement Period"

define "Time of Delivery Assessment":
  Last(
    ["Assessment, Performed": "Time of Delivery Codes"] Assessment
      with "Inpatient Encounter" Encounter
        such that Assessment.authorDatetime during Encounter.relevantPeriod
      sort by authorDatetime
  )

define "Time of Delivery":
  "Time of Delivery Assessment".result as DateTime

// NOTE: Gestational age may be calculated using the ACOG ReVITALize guidelines with
// Estimated Due Date (EDD)
// http://www.acog.org/about_acog/acog_departments/patient_safety_and_quality_improvement/~/media/departments/patient%20safety%20and%20quality%20improvement/201213issuesandrationale-gestationalageterm.pdf
// Needs to be the most recent exam associated with this pregnancy
define "Estimated Due Date":
  Last(
    ["Physical Exam, Performed": "Estimated Due Date Codes"] Exam
      with "Time of Delivery Assessment" Assessment
        such that Exam.relevantPeriod starts 1 day or less before (Assessment.result as DateTime)
      sort by start of relevantPeriod
  ).result as DateTime

define "Gestational Age at Birth":
  (280 - (days between "Estimated Due Date" and "Time of Delivery")) div 7

define GestationalAgeAtBirth(EstimatedDueDate DateTime, TimeOfDelivery DateTime):
  (280 - (days between EstimatedDueDate and TimeOfDelivery)) div 7

define "Gestational Age at Birth Using a Function":
  GestationalAgeAtBirth("Estimated Due Date", "Time of Delivery")

// NOTE: This will return truncated weeks (not rounded). To express a limit including weeks and days, use:
define "Weeks and Days": 3 weeks + 5 days
