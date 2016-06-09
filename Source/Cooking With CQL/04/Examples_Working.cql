/*
Left over example from Session 3

Example 14:
IP: Timing, diagnoses, satisfies – oh my! (CMS159)

Initial Population =
  AND: Age>= 18 year(s) at: $DepressionIndex

$DepressionEncounter =
  "Encounter, Performed: Office Visit" satisfies all:
    < 12 month(s) ends before start of "Measurement Period"
    > 0 month(s) ends before start of "Measurement Period"
    satisfies any:
      overlaps "Diagnosis: Major Depression Including Remission"
      overlaps "Diagnosis: Dysthymia"

$DepressionEncounterBH =
  "Encounter, Performed: Psych Visit" satisfies all:
    < 12 month(s) ends before start of "Measurement Period"
    > 0 month(s) ends before start of "Measurement Period"
  satisfies any:
    (principal diagnosis: Major Depression Including Remission)
    (principal diagnosis: Dysthymia)

$DepressionF2FSnomed =
  "Encounter, Performed: Face to Face Interaction - No ED" satisfies all:
    < 12 month(s) ends before start of "Measurement Period"
    > 0 month(s) ends before start of "Measurement Period"
  satisfies any:
    overlaps "Diagnosis: Major Depression Including Remission"
    overlaps "Diagnosis: Dysthymia"

$DepressionIndex =
  "Risk Category Assessment: PHQ-9 Tool (result > 9 )" during Union of:
    $DepressionEncounter
    $DepressionEncounterBH
    $DepressionF2FSnomed
*/

define "Major Depression or Dysthymia Diagnosis":
  ["Diagnosis": "Major Depression Including Remission"]
    union ["Diagnosis": "Dysthymia"]

define "Depression Encounter":
  ["Encounter, Performed": "Office Visit"] Encounter
    with "Major Depression or Dysthymia Diagnosis" Diagnosis
      such that Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime]
        overlaps Interval[Diagnosis.onsetDateTime, Diagnosis.abatementDateTime]
    where Encounter.dischargeDateTime in Interval[start of "Measurement Period" - 12 months, start of "Measurement Period"]

define "Depression Encounter BH":
  ["Encounter, Performed": "Psych Visit"] Encounter
    where Encounter.dischargeDateTime in Interval[start of "Measurement Period" - 12 months, start of "Measurement Period"]
      and (
        Encounter.principalDiagnosis in "Major Depression Including Remission"
          or Encounter.principalDiagnosis in "Dysthymia"
      )

define "Depression Face-to-Face":
  ["Encounter, Performed": "Face to Face Interaction - No ED"] Encounter
    with "Major Depression or Dysthymia Diagnosis" Diagnosis
      such that Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime]
        overlaps Interval[Diagnosis.onsetDateTime, Diagnosis.abatementDateTime]
    where Encounter.dischargeDateTime in Interval[start of "Measurement Period" - 12 months, start of "Measurement Period"]

define "Depression Index":
  ["Risk Category Assessment": "PHQ-9 Tool"] Assessment
    with ("Depression Encounter" union "Depression Encounter BH" union "Depression Face-to-Face") Encounter
      such that Interval[Assessment.startDateTime, Assessment.stopDateTime]
        during Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime]
    where Assessment.result > 9

define "Initial Population":
  exists (
    "Depression Index" Index
      where AgeInYearsAt(Index.startDateTime) >= 18
  )
