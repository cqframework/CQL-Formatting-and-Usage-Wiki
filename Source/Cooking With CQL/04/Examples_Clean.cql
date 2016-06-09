/*
Left over example from session 3

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
