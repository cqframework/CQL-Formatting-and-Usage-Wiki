// Continuous variable with stratification (CMS55)

library CMS55

using QDM version '5.0'

valueset "Encounter Inpatient": 'Encounter Inpatient'
valueset "Emergency Department Visit": 'Emergency Department Visit'
valueset "Psychiatric/Mental Health Patient": 'Psychiatric/Mental Health Patient'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
Initial Population =
  AND: "Occurrence A of Encounter, Performed: Emergency Department Visit"
    <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient

Measure Population =
  AND: Initial Population

Measure Population Exclusions =
  OR: "Transfer From: Hospital Settings" <= 6 hour(s)
    ends before or concurrent with start of "Occurrence A of Encounter, Performed: Emergency Department Visit"

Measure Observation =
  Median:
    Datetimediff:
      "Occurrence A of Encounter, Performed: Emergency Department Visit (facility location departure datetime)"
      "Occurrence A of Encounter, Performed: Emergency Department Visit (facility location arrival datetime)"

Stratifications =
  Stratification 1 =
    AND NOT: Intersection of:
      Occurrence A of $EncounterInpatient
      "Encounter, Performed: Encounter Inpatient (principal diagnosis: Psychiatric/Mental Health Patient)"

  Stratification 2 =
    AND: Intersection of:
      Occurrence A of $EncounterInpatient
      "Encounter, Performed: Encounter Inpatient (principal diagnosis: Psychiatric/Mental Health Patient)"

$EncounterInpatient =
  "Encounter, Performed: Encounter Inpatient" satisfies all:
    (length of stay <= 120 day(s))
    ends during "Measurement Period"
*/
