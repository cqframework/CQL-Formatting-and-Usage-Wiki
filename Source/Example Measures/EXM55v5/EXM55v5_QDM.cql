library EXM55 version '5.0.0'

/*
	Based on CMS55v5/NQF0495
	Median Time from ED Arrival to ED Departure for Admitted ED Patients

	Episode-of-Care-Based Continuous Variable Measure with stratification

	This example is a work in progress and should not be considered a final specification
	or recommendation for guidance. This example will help guide and direct the process
	of finding conventions and usage patterns that meet the needs of the various stakeholders
	in the measure development community.
*/

using QDM version '5.0.2'

valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.293'
valueset "Hospital Settings": 'urn:oid:2.16.840.1.113762.1.4.1111.126'
valueset "Psychiatric/Mental Health Patient": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.299'

valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'

parameter "Measurement Period" default Interval[@2014-01-01T00:00:00.0, @2015-01-01T00:00:00.0)

context Patient

define "Inpatient Encounters":
	["Encounter, Performed": "Encounter Inpatient"] Encounter
		where Encounter.lengthOfStay <= 120 days
			and Encounter.relevantPeriod ends during "Measurement Period"

define "Emergency Department Encounters":
	["Encounter, Performed": "Emergency Department Visit"] EmergencyEncounter
		with "Inpatient Encounters" InpatientEncounter
			such that EmergencyEncounter.relevantPeriod ends 1 hour or less before start of InpatientEncounter.relevantPeriod

define "Measure Population":
	"Emergency Department Encounters"

define "Measure Population Exclusions":
	"Emergency Department Encounters" Encounter
		where Encounter.admissionSource in "Hospital Settings"

// Measure Observation
define function "EDStayTime"(Encounter "Encounter, Performed"):
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
  ["Patient Characteristic Ethnicity": "Ethnicity"] Characteristic
    return Characteristic.code

define "SDE Payer":
  ["Patient Characteristic Payer": "Payer"] Characteristic
    return Characteristic.code

define "SDE Race":
  ["Patient Characteristic Race": "Race"] Characteristic
    return Characteristic.code

define "SDE Sex":
  ["Patient Characteristic Sex": "ONC Administrative Sex"] Characteristic
    return Characteristic.code

// End Region: Supplemental Data Elements
