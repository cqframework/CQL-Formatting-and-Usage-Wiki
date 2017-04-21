// Continuous variable with stratification (CMS55)

library CMS55

using QDM version '5.0'

valueset "Encounter Inpatient": 'Encounter Inpatient'
valueset "Emergency Department Visit": 'Emergency Department Visit'
valueset "Hospital Settings": '2.16.840.1.113762.1.4.1111.126'
valueset "Psychiatric/Mental Health Patient": 'Psychiatric/Mental Health Patient'

parameter "Measurement Period" Interval<DateTime>

/*
Initial Population =
  AND: "Occurrence A of Encounter, Performed: Emergency Department Visit"
    <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient
*/

define "Initial Population":
  "Inpatient Encounter" E
    with ["Encounter, Performed": "Emergency Department Visit"] ED
      such that ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod

/*
Measure Population =
  AND: Initial Population
*/

define "Measure Population":
  "Initial Population"

/*
Measure Population Exclusions =
  OR: "Transfer From: Hospital Settings" <= 6 hour(s)
    ends before or concurrent with start of "Occurrence A of Encounter, Performed: Emergency Department Visit"
*/

define "Measure Population Exclusions":
  "Inpatient Encounter" E
    with ["Encounter, Performed": "Emergency Department Visit"] ED
      such that ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod
        and ED.admissionSource in "Hospital Settings"

/*
Measure Observation =
  Median:
    Datetimediff:
      "Occurrence A of Encounter, Performed: Emergency Department Visit (facility location departure datetime)"
      "Occurrence A of Encounter, Performed: Emergency Department Visit (facility location arrival datetime)"
*/

define function "Related ED Visit"(Encounter "Encounter, Performed"):
  Last(
    ["Encounter, Performed": "Emergency Department Visit"] ED
      where ED.relevantPeriod ends 1 hour or less before start of Encounter.relevantPeriod
      sort by start of ED.relevantPeriod
  )

define function "Measure Observation"(Encounter "Encounter, Performed"):
  duration in minutes of "Related ED Visit"(Encounter).locationPeriod

/*
Stratifications =
*/

/*
  Stratification 1 =
    AND NOT: Intersection of:
      Occurrence A of $EncounterInpatient
      "Encounter, Performed: Encounter Inpatient (principal diagnosis: Psychiatric/Mental Health Patient)"
*/

define "Stratification 1":
  "Inpatient Encounter" E
    where not (E.principalDiagnosis in "Psychiatric/Mental Health Patient")

/*
  Stratification 2 =
    AND: Intersection of:
      Occurrence A of $EncounterInpatient
      "Encounter, Performed: Encounter Inpatient (principal diagnosis: Psychiatric/Mental Health Patient)"
*/

define "Stratification 2":
  "Inpatient Encounter" E
    where E.principalDiagnosis in "Psychiatric/Mental Health Patient"

define "Stratification 3":
  "Inpatient Encounter" E
    where E.principalDiagnosis is null

/*
$EncounterInpatient =
  "Encounter, Performed: Encounter Inpatient" satisfies all:
    (length of stay <= 120 day(s))
    ends during "Measurement Period"
*/

define "Inpatient Encounter":
  ["Encounter, Performed"] E
    where E.lengthOfStay <= 120 days
      and E.relevantPeriod ends during "Measurement Period"
