library CMS111 version '5.0.0'

/*
CMS 111 - Median Admit Decision Time to ED Departure Time for Admitted Patients
Continuous Variable Episode-of-Care Measure

Median time (in minutes) from admit decision time to time of discharge from the
emergency department for emergency department patients admitted to inpatient status.
*/

using QDM version '5.0.2'

valueset "Decision to Admit to Hospital Inpatient": '2.16.840.1.113883.3.117.1.7.1.295'
valueset "Emergency Department Visit": '2.16.840.1.113883.3.117.1.7.1.292'
valueset "Encounter Inpatient": '2.16.840.1.113883.3.666.5.307'
valueset "Hospital Settings": '2.16.840.1.113762.1.4.1111.126'
valueset "Psychiatric/Mental Health Patient": '2.16.840.1.113883.3.117.1.7.1.299'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
Population Criteria
*/

/*
    Initial Population =
        AND: "Occurrence A of Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient
        AND: "Occurrence A of Encounter, Order: Decision to Admit to Hospital Inpatient" starts during "Occurrence A of Encounter, Performed: Emergency Department Visit"
*/

define "ED Visit":
  ["Encounter, Performed": "Emergency Department Visit"] ED
    with ["Encounter, Order": "Decision to Admit to Hospital Inpatient"] O
      such that O.authorDatetime during ED.relevantPeriod

define "Initial Population":
  "Inpatient Encounter" E
    with "ED Visit" ED
      such that ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod

/*
    Measure Population =
        AND: Initial Population
*/

define "Measure Population":
  "Initial Population"

/*
    Measure Population Exclusions =
        OR: "Transfer From: Hospital Settings" <= 6 hour(s) ends before or concurrent with start of "Occurrence A of Encounter, Performed: Emergency Department Visit"
*/

define "Measure Population Exclusions":
  "Inpatient Encounter" E
    with "ED Visit" ED
      such that ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod
        and ED.admissionSource in "Hospital Settings"

/*
    Measure Observation =
        Median:
            Datetimediff:
                "Occurrence A of Encounter, Performed: Emergency Department Visit (facility location departure datetime)"
                "Occurrence A of Encounter, Order: Decision to Admit to Hospital Inpatient (start datetime)"
*/

define function "Related ED Visit"(Encounter "Encounter, Performed"):
  Last(
    "ED Visit" ED
      where ED.relevantPeriod ends 1 hour or less before start of Encounter.relevantPeriod
    sort by start of ED.relevantPeriod
  )

define function "Admit Decision"(Encounter "Encounter, Performed"):
  Last(
    ["Encounter, Order": "Decision to Admit to Hospital Inpatient"] O
      where O.authorDatetime during "Related ED Visit"(Encounter).relevantPeriod
      sort by authorDatetime
  )

define function "Measure Observation"(Encounter "Encounter, Performed"):
  minutes between "Admit Decision"(Encounter).authorDatetime
    and end of "Related ED Visit"(Encounter).locationPeriod

// As a single "from" query
/*
define function "Measure Observation"(Encounter "Encounter, Performed")
  duration in minutes of
    Last(
      from
        Encounter E,
        "ED Visit" ED,
        ["Encounter, Order": "Decision to Admit to Hospital Inpatient"] O
      where ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod
        and O.authorDatetime during ED.relevantPeriod
      return { admitDecisionDatetime: O.authorDatetime, departureDatetime: end of ED.locationPeriod }
      sort by admitDecisionDatetime
    )
*/

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
Data Criteria (QDM Variables)
*/

/*
    $EncounterInpatient =
        "Encounter, Performed: Encounter Inpatient" satisfies all:
            (length of stay <= 120 day(s))
            ends during "Measurement Period"
*/

define "Inpatient Encounter":
  ["Encounter, Performed": "Encounter Inpatient"] E
    where E.lengthOfStay <= 120 days
      and E.relevantPeriod ends during "Measurement Period"

/*
Data Criteria (QDM Data Elements)

    "Encounter, Order: Decision to Admit to Hospital Inpatient" using "Decision to Admit to Hospital Inpatient Grouping Value Set (2.16.840.1.113883.3.117.1.7.1.295)"
    "Encounter, Performed: Emergency Department Visit" using "Emergency Department Visit SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.292)"
    "Encounter, Performed: Encounter Inpatient" using "Encounter Inpatient SNOMEDCT Value Set (2.16.840.1.113883.3.666.5.307)"
    "Transfer From: Hospital Settings" using "Hospital Settings SNOMEDCT Value Set (2.16.840.1.113762.1.4.1111.126)"
    Attribute: "Principal diagnosis: Psychiatric/Mental Health Patient" using "Psychiatric/Mental Health Patient Grouping Value Set (2.16.840.1.113883.3.117.1.7.1.299)"
*/

/*
Supplemental Data Elements

    "Patient Characteristic Ethnicity: Ethnicity" using "Ethnicity CDCREC Value Set (2.16.840.1.114222.4.11.837)"
    "Patient Characteristic Payer: Payer" using "Payer SOP Value Set (2.16.840.1.114222.4.11.3591)"
    "Patient Characteristic Race: Race" using "Race CDCREC Value Set (2.16.840.1.114222.4.11.836)"
    "Patient Characteristic Sex: ONC Administrative Sex" using "ONC Administrative Sex AdministrativeGender Value Set (2.16.840.1.113762.1.4.1)"
*/

/*
Risk Adjustment Variables

    None
*/
