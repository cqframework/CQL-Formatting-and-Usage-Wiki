// Numerator with lots of nested ORs and ANDs (CMS22)

library MoreBPReadings version '1.0.0'

using QDM version '5.0.2'

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

// There are basically four ways to satisfy the numerator:
// 1) Most recent BP is normal
// 2) Most recent BP is prehypertensive (elevated but not hypertensive) and follow up documented
// 3) Most recent BP is high and most recent within one year prior is not high (or not present) and follow up documented
// 4) Most recent BP is high and most recent within one year is also high and follow up documented.

// The intent to is identify that the most recent diastolic reading within 1 year
// prior to the most recent encounter was high (result >=90 ‘mm[Hg]’).

/* definition with errors */
define "Most Recent BP high": exists ({
    from
      "Most Recent Systolic Reading During Most Recent Encounter" Systolic,
      "Most Recent Diastolic Reading During Most Recent Encounter" Diastolic
    where (Systolic.result >= 140 'mm[Hg]' or Diastolic.result >= 90 'mm[Hg]')
})

define "Most recent diastolic before encounter high": Last(
  "Most Recent BP high" HighDiast
    with "Most Recent BP Screening Encounter" Encounter
      such that HighDiast.relevantPeriod starts 1 year before start Encounter.relevantPeriod
    sort by start of HighDiast.relevantPeriod
)

// The initial problem is that the "Most Recent BP high" expression is returning a Boolean
// (It's answering, "is the most recent BP high", rather than "what is the most recent high BP")

// However, even addressing that issue (by removing the exists), you'd have to get back to the encounter
// in order to use it the way you are wanting do in "Most recent diastolic before encounter high"
// So you'd have to get back to "Most Recent BP Screening Encounter",
// But reading the stated intent "that the most recent diastolic reading within 1 year prior to the most recent encounter was high"
// that's not what we're after either, what we need to identify is the most recent encounter with readings that is
// prior to the case under consideration, and identify whether readings associated with that encounter are high.

// So, starting with the Most Recent BP Screening Encounter, we identify the Most Recent Prior BP Screening Encounter:

// First, we'll refactor that expression to give us a way to talk about "BP Screening Encounters with Readings"
define "BP Screening Encounters with Readings":
  ["Encounter, Performed": "BP Screening Encounter Codes"] Encounter
    with ["Physical Exam, Performed": "Diastolic Blood Pressure"] Diastolic
      such that Encounter.relevantPeriod overlaps Diastolic.relevantPeriod and Diastolic.result is not null
    with ["Physical Exam, Performed": "Systolic Blood Pressure"] Systolic
      such that Encounter.relevantPeriod overlaps Systolic.relevantPeriod and Systolic.result is not null
    sort by start of Encounter.relevantPeriod

// Then redefine "Most Recent BP Screening Encounter" to use it:
define "Most Recent BP Screening Encounter":
  Last("BP Screening Encounters with Readings")

// Then use it again to get the most recent prior:
define "Most Recent Prior BP Screening Encounter":
  Last(
    "BP Screening Encounters with Readings" Encounter
      with "Most Recent BP Screening Encounter" MostRecentEncounter
        such that Encounter.relevantPeriod starts 1 year or less before MostRecentEncounter.relevantPeriod
  )

// Then we can find readings associated with that encounter to determine whether they are also high:
define "Most Recent Systolic Reading During Most Recent Prior Encounter":
  Last(
    ["Physical Exam, Performed": "Systolic Blood Pressure"] Systolic
      with "Most Recent Prior BP Screening Encounter" Encounter
        such that Systolic.relevantPeriod during Encounter.relevantPeriod
      sort by start of Systolic.relevantPeriod
  )

define "Most Recent Diastolic Reading During Most Recent Prior Encounter":
  Last(
    ["Physical Exam, Performed": "Diastolic Blood Pressure"] Diastolic
      with "Most Recent Prior BP Screening Encounter" Encounter
        such that Diastolic.relevantPeriod during Encounter.relevantPeriod
      sort by start of Diastolic.relevantPeriod
  )

define "Most Recent Prior Reading High":
  exists ({
    from
      "Most Recent Systolic Reading During Most Recent Prior Encounter" Systolic,
      "Most Recent Diastolic Reading During Most Recent Prior Encounter" Diastolic
    where (Systolic.result < 120 'mm[Hg]' and Diastolic.result < 80 'mm[Hg]')
      or (Systolic.result >= 120 'mm[Hg]' and Systolic.result < 140 'mm[Hg]' and Diastolic.result < 90 'mm[Hg]')
      or (Systolic.result < 140 'mm[Hg]' and Diastolic.result >= 80 'mm[Hg]' and Diastolic.result < 90 'mm[Hg]')
  })
