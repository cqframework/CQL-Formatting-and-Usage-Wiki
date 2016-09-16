// Numerator with Physical Exam and various timings (CMS165)

library CMS165

using QDM version '5.0'

valueset "Adult Outpatient Visit": 'Adult Outpatient Visit'
valueset "Essential Hypertension": 'Essential Hypertension'
valueset "Diastolic Blood Pressure": 'Diastolic Blood Pressure'
valueset "Systolic Blood Pressure": 'Systolic Blood Pressure'

parameter "Measurement Period" Interval<DateTime>

define "Outpatient Visit":
  ["Encounter, Performed": "Adult Outpatient Visit"] Encounter
    with ["Diagnosis": "Essential Hypertension"] Diagnosis
      such that Encounter.relevantPeriod overlaps Diagnosis.prevalencePeriod
    with ["Physical Exam, Performed": "Diastolic Blood Pressure"] Diastolic
      such that Encounter.relevantPeriod overlaps Diastolic.relevantPeriod
        and Diastolic.result is not null
    with ["Physical Exam, Performed": "Systolic Blood Pressure"] Systolic
      such that Encounter.relevantPeriod overlaps Systolic.relevantPeriod
        and Systolic.result is not null

define "Most Recent Outpatient Visit":
  First("Outpatient Visit" Visit sort by end of relevantPeriod desc)

define "Numerator":
  "Most Recent Outpatient Visit" Visit
    where
      First(["Physical Exam, Performed": "Diastolic Blood Pressure"] Diastolic
        where Diastolic.relevantPeriod during Visit.relevantPeriod
        sort by end of relevantPeriod desc
      ).result < 90 'mmHg'
      and
      First(["Physical Exam, Performed": "Systolic Blood Pressure"] Systolic
        where Systolic.relevantPeriod during Visit.relevantPeriod
        sort by end of relevantPeriod desc
      ).result < 140 'mmHg'

/*
Numerator =
  AND: Most Recent:
    "Occurrence A of Encounter, Performed: Adult Outpatient Visit" satisfies all:
      overlaps "Occurrence A of Diagnosis: Essential Hypertension"
      during "Measurement Period"
      overlaps "Physical Exam, Performed: Diastolic Blood Pressure (result)"
      overlaps "Physical Exam, Performed: Systolic Blood Pressure (result)"
  AND: "Physical Exam, Performed: Diastolic Blood Pressure" satisfies all:
    Most Recent: during "Occurrence A of Encounter, Performed: Adult Outpatient Visit"
    (result < 90 mmHg)
  AND: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
    Most Recent: during "Occurrence A of Encounter, Performed: Adult Outpatient Visit"
    (result < 140 mmHg)
*/
