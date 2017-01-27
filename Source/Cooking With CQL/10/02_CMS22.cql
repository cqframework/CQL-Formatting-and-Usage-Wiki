// Numerator with lots of nested ORs and ANDs (CMS22)

library CMS22

using QDM version '5.0'

valueset "BP Screening Encounter Codes": 'BP Screening Encounter Codes'
valueset "Diastolic Blood Pressure": 'Diastolic Blood Pressure'
valueset "Systolic Blood Pressure": 'Systolic Blood Pressure'

parameter "Measurement Period" Interval<DateTime>

define "Most Recent BP Screening Encounter":
  Last(
    ["Encounter, Performed": "BP Screening Encounter Codes"] Encounter
      with ["Physical Exam, Performed": "Diastolic Blood Pressure"] Diastolic
        such that Encounter.relevantPeriod overlaps Diastolic.relevantPeriod and Diastolic.result is not null
      with ["Physical Exam, Performed": "Systolic Blood Pressure"] Systolic
        such that Encounter.relevantPeriod overlaps Systolic.relevantPeriod and Systolic.result is not null
      sort by start of Encounter.relevantPeriod
  )

define "Most Recent Systolic Reading During Most Recent Encounter":
  Last(
    ["Physical Exam, Performed": "Systolic Blood Pressure"] Systolic
      with "Most Recent BP Screening Encounter" Encounter
        such that Systolic.relevantPeriod during Encounter.relevantPeriod
      sort by start of Systolic.relevantPeriod
  )

define "Most Recent Diastolic Reading During Most Recent Encounter":
  Last(
    ["Physical Exam, Performed": "Diastolic Blood Pressure"] Diastolic
      with "Most Recent BP Screening Encounter" Encounter
        such that Diastolic.relevantPeriod during Encounter.relevantPeriod
      sort by start of Diastolic.relevantPeriod
  )

define "Numerator":
  exists ({
    from
      "Most Recent Systolic Reading During Most Recent Encounter" Systolic,
      "Most Recent Diastolic Reading During Most Recent Encounter" Diastolic
    where (Systolic.result < 120 'mm[Hg]' and Diastolic.result < 80 'mm[Hg]')
      or (Systolic.result >= 120 'mm[Hg]' and Systolic.result < 140 'mm[Hg]' and Diastolic.result < 90 'mm[Hg]')
      or (Systolic.result < 140 'mm[Hg]' and Diastolic.result >= 80 'mm[Hg]' and Diastolic.result < 90 'mm[Hg]')
  })

// During the most recent encounter with both diastolic and systolic blood pressure readings,
//   the most recent systolic reading during that encounter was less than 120 mmHg
//     and the most recent diastolic reading during that encounter was less than 80 mmHg
// or
//   the most recent systolic reading during that encounter was greater than or equal to 120 mmHg and less than 140 mmHg
//     and the most recent diastolic reading during that encounter was less than 90 mmHg
// or
//   the most recent systolic reading during that encounter was less than 140 mmHg
//     and the most recent diastolic reading during that encounter was greater than or equal to 80 mmHg and less than 90 mmHg

/*
Numerator =
  AND: Most Recent:
    "Occurrence A of Encounter, Performed: BP Screening Encounter Codes" satisfies all:
      overlaps "Physical Exam, Performed: Diastolic Blood Pressure (result)"
      overlaps "Physical Exam, Performed: Systolic Blood Pressure (result)"
  AND:
    OR:
      AND: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
        Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
        (result < 120 mmHg)
      AND: "Physical Exam, Performed: Diastolic Blood Pressure" satisfies all:
        Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
        (result < 80 mmHg)
    OR:
      AND:
        OR:
          AND: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
            Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
            (result >= 120 mmHg)
            (result < 140 mmHg)
          AND: "Physical Exam, Performed: Diastolic Blood Pressure" satisfies all:
            Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
            (result < 90 mmHg)
        OR:
          AND: "Physical Exam, Performed: Diastolic Blood Pressure" satisfies all:
            Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
            (result >= 80 mmHg)
            (result < 90 mmHg)
          AND: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
            Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
            (result < 140 mmHg)
*/
