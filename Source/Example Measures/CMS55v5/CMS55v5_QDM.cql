library CMS55 version '5'

/*
	CMS55v1 NQF0495
	Median Time from ED Arrival to ED Departure for Admitted ED Patients

	Episode-of-Care-Based Continuous Variable Measure with stratification

	Population Criteria

	    Initial Population =
	        AND: "Occurrence A of Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient
	    Measure Population =
	        AND: Initial Population
	    Measure Population Exclusions =
	        OR: "Transfer From: Hospital Settings" <= 6 hour(s) ends before or concurrent with start of "Occurrence A of Encounter, Performed: Emergency Department Visit"
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

	Data Criteria (QDM Variables)

	    $EncounterInpatient =
	        "Encounter, Performed: Encounter Inpatient" satisfies all:
	            (length of stay <= 120 day(s))
	            ends during "Measurement Period"

	Data Criteria (QDM Data Elements)

	    "Encounter, Performed: Emergency Department Visit" using "Emergency Department Visit SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.292)"
	    "Encounter, Performed: Encounter Inpatient" using "Encounter Inpatient SNOMEDCT Value Set (2.16.840.1.113883.3.666.5.307)"
	    "Transfer From: Hospital Settings" using "Hospital Settings SNOMEDCT Value Set (2.16.840.1.113762.1.4.1111.126)"
	    Attribute: "Principal diagnosis: Psychiatric/Mental Health Patient" using "Psychiatric/Mental Health Patient Grouping Value Set (2.16.840.1.113883.3.117.1.7.1.299)"

	Supplemental Data Elements

	    "Patient Characteristic Ethnicity: Ethnicity" using "Ethnicity CDCREC Value Set (2.16.840.1.114222.4.11.837)"
	    "Patient Characteristic Payer: Payer" using "Payer SOP Value Set (2.16.840.1.114222.4.11.3591)"
	    "Patient Characteristic Race: Race" using "Race CDCREC Value Set (2.16.840.1.114222.4.11.836)"
	    "Patient Characteristic Sex: ONC Administrative Sex" using "ONC Administrative Sex AdministrativeGender Value Set (2.16.840.1.113762.1.4.1)"

	Risk Adjustment Variables

	    None
*/

using QDM version '5.0'

valueset "Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.293'
valueset "Hospital Settings": 'urn:oid:2.16.840.1.113762.1.4.1111.126'
valueset "Psychiatric/Mental Health Patient": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.299'

valueset "Ethnicity CDCREC": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer SOP": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Race CDCREC": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "ONC Administrative Sex AdministrativeGender": 'urn:oid:2.16.840.1.113762.1.4.1'

parameter "Measurement Period" default Interval[@2014-01-01T00:00:00.0, @2015-01-01T00:00:00.0)

context Patient

define "Inpatient Encounters":
	["Encounter, Performed": "Inpatient"] Encounter
		where Encounter.lengthOfStay <= 120 days
			and Encounter.relevantPeriod ends during "Measurement Period"

define "Emergency Department Encounters":
	["Encounter, Performed": "Emergency Department Visit"] EmergencyEncounter
		with "Inpatient Encounters" InpatientEncounter
			such that EmergencyEncounter.relevantPeriod ends 1 hour or less before start of InpatientEncounter.relevantPeriod

define "Measure Population":
	"Emergency Department Encounters" Encounter

define "Measure Population Exclusions":
	"Emergency Department Encounters" Encounter
		where Encounter.admissionSource in "Hospital Settings"
		// NOTE: QDM 5.0 removed the Transfer From, so we cannot express the requirement
		//  that the transfer was less than 6 hours before the ED encounter

// Measure Observation
define function EDStayTime(Encounter "Encounter, Performed"):
	duration in minutes of Encounter.locationPeriod

// NOTE: The calculation method is specified in the HQMF, so will not be specified here
// The measure calculates the Median of EDStayTime

// Region: Stratifiers

define "Stratification 1":
	"Emergency Department Encounters" Encounter
		where not (Encounter.principalDiagnosis in "Psychiatric/Mental Health Patient")

define "Stratification 2":
	"Emergency Department Encounters" Encounter
		where Encounter.principalDiagnosis in "Psychiatric/Mental Health Patient"

// NOTE: Added this stratification because the above two will not completely cover the measure population.
// This third stratification would be required to capture those encounters where we do not know the principal diagnosis.
// Alternatively, it could be added to stratification 1 if we are okay with the assumption that not knowing the principal
// diagnosis means it was not a psychiatric/mental health patient.
define "Stratification 3":
	"Emergency Department Encounters" Encounter
		where Encounter.principalDiagnosis is null

// End Region: Stratifiers

// Region: Supplemental Data Elements

define "SDE Ethnicity":
  ["Patient Characteristic Ethnicity": "Ethnicity CDCREC"] Characteristic
    return Characteristic.code

define "SDE Payer":
  ["Patient Characteristic Payer": "Payer SOP"] Characteristic
    return Characteristic.code

define "SDE Race":
  ["Patient Characteristic Race": "Race CDCREC"] Characteristic
    return Characteristic.code

define "SDE Sex":
  ["Patient Characteristic Sex": "ONC Administrative Sex AdministrativeGender"] Characteristic
    return Characteristic.code

// End Region: Supplemental Data Elements
