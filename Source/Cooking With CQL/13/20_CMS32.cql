library CMS32 version '6.0.0'

/*
CMS 32: Median Time from ED Arrival to ED Departure for Discharged ED Patients
Continuous Variable Episode-of-Care Measure

Median elapsed time from emergency department arrival to emergency room departure
for patients discharged from the emergency department.
*/

using QDM version '5.0.2'

valueset "Emergency Department Visit": '2.16.840.1.113883.3.117.1.7.1.292'
valueset "Encounter Inpatient": '2.16.840.1.113883.3.666.5.307'
valueset "Acute care hospital": '2.16.840.1.113883.3.666.5.684'
valueset "Patient Expired": '2.16.840.1.113883.3.117.1.7.1.309'
valueset "Psychiatric/Mental Health Patient": '2.16.840.1.113883.3.117.1.7.1.299'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
Population Criteria
*/

/*
    Initial Population =
        AND: "Occurrence A of Encounter, Performed: Emergency Department Visit" during "Measurement Period"
*/

define "ED Visit":
  ["Encounter, Performed": "Emergency Department Visit"] ED
    where ED.relevantPeriod during "Measurement Period"

define "Initial Population":
  "ED Visit"

/*
    Measure Population =
        AND: Initial Population
*/

define "Measure Population":
  "Initial Population"

/*
    Measure Population Exclusions =
        OR: "Occurrence A of Encounter, Performed: Emergency Department Visit (discharge status: Patient Expired)"
        OR: "Occurrence A of Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of "Encounter, Performed: Encounter Inpatient"
*/

define "Measure Population Exclusions":
  (
    "ED Visit" ED
      where ED.dischargeDisposition in "Patient Expired"
  )
    union (
      "ED Visit" ED
        with ["Encounter, Performed": "Encounter Inpatient"] E
          such that ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod
    )

/*
    Measure Observation =
        Median:
            Datetimediff:
                "Occurrence A of Encounter, Performed: Emergency Department Visit (facility location departure datetime)"
                "Occurrence A of Encounter, Performed: Emergency Department Visit (facility location arrival datetime)"
*/

define function "Measure Observation"(Encounter "Encounter, Performed"):
  duration in minutes of Encounter.locationPeriod

/*
    Stratifications =
*/

/*
        Stratification 1 =
            AND: "Occurrence A of Encounter, Performed: Emergency Department Visit (principal diagnosis: Psychiatric/Mental Health Patient)"
*/

define "Stratification 1":
  "ED Visit" ED
    where ED.principalDiagnosis in "Psychiatric/Mental Health Patient"

/*
        Stratification 2 =
            AND: "Transfer To: Acute care hospital" <= 6 hour(s) starts after or concurrent with end of "Occurrence A of Encounter, Performed: Emergency Department Visit"
*/

define "Stratification 2":
  "ED Visit" ED
    where ED.dischargeDisposition in "Acute care hospital"

/*
        Stratification 3 =
            AND NOT: "Occurrence A of Encounter, Performed: Emergency Department Visit (principal diagnosis: Psychiatric/Mental Health Patient)"
            AND NOT: "Transfer To: Acute care hospital" <= 6 hour(s) starts after or concurrent with end of "Occurrence A of Encounter, Performed: Emergency Department Visit"
*/

define "Stratification 3":
  "ED Visit" ED
    where not (ED.principalDiagnosis in "Psychiatric/Mental Health Patient")
      and not (ED.dischargeDisposition in "Acute care hospital")

/*
Data Criteria (QDM Variables)

    None
*/

/*
Data Criteria (QDM Data Elements)

    "Encounter, Performed: Emergency Department Visit" using "Emergency Department Visit SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.292)"
    "Encounter, Performed: Encounter Inpatient" using "Encounter Inpatient SNOMEDCT Value Set (2.16.840.1.113883.3.666.5.307)"
    "Transfer To: Acute care hospital" using "Acute care hospital SNOMEDCT Value Set (2.16.840.1.113883.3.666.5.684)"
    Attribute: "Discharge status: Patient Expired" using "Patient Expired SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.309)"
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
