// Numerator with embedded concurrent and Most Recent (CMS65)

library CMS65

using QDM version '5.0'

valueset "Blood Pressure Visit": 'Blood Pressure Visit'
valueset "Delta systolic blood pressure": 'Delta systolic blood pressure'
valueset "Systolic Blood Pressure": 'Systolic Blood Pressure'

parameter "Measurement Period" Interval<DateTime>

define "Blood Pressure Encounter":
  ["Encounter, Performed": "Blood Pressure Visit"] Encounter
    with ["Physical Exam, Performed": "Systolic Blood Pressure"] Systolic
      such that Systolic.relevantPeriod during Encounter.relevantPeriod
    where Encounter.relevantPeriod ends during "Measurement Period"

define "Blood Pressure Encounter With Delta":
  from
    "Blood Pressure Encounter" A,
    "Blood Pressure Encounter" B
  let "Systolic A":
    First(
        ["Physical Exam, Performed": "Systolic Blood Pressure"] Exam
          where Exam.relevantPeriod during A.relevantPeriod
            and Exam.result is not null
          sort by end of relevantPeriod desc
    ),
    "Systolic B":
      First(
          ["Physical Exam, Performed": "Systolic Blood Pressure"] Exam
            where Exam.relevantPeriod during B.relevantPeriod
              and Exam.result is not null
            sort by end of relevantPeriod desc
      )
  where A.relevantPeriod starts 6 months or more after end of B.relevantPeriod
    and (
      Abs("Systolic A".result - "Systolic B".result) > 10 'mmHg'
        or "Systolic B".result < 140 'mmHg'
    )

/*
Numerator =
  AND: "Occurrence B of Encounter, Performed: Blood Pressure Visit" satisfies all:
    First: >= 6 month(s) starts after end of "Occurrence A of Encounter, Performed: Blood Pressure Visit"
    ends during "Measurement Period"
  AND:
    OR: "Physical Exam, Performed: Delta systolic blood pressure" satisfies all:
      (result > 10 mmHg) starts after or concurrent with end of
        Most Recent: "Physical Exam, Performed: Systolic Blood Pressure (result)"
          during "Occurrence B of Encounter, Performed: Blood Pressure Visit"
      overlaps "Occurrence B of Encounter, Performed: Blood Pressure Visit"
    OR: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
      Most Recent: (result) during "Occurrence B of Encounter, Performed: Blood Pressure Visit"
      (result < 140 mmHg)
*/
