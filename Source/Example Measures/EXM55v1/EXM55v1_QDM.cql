library EXM55 version '1'

/*
	Based on CMS55v1/NQF0495
	Median Time from ED Arrival to ED Departure for Admitted ED Patients

	Episode-of-Care-Based Continuous Variable Measure with stratification

	This example is a work in progress and should not be considered a final specification
	or recommendation for guidance. This example will help guide and direct the process
	of finding conventions and usage patterns that meet the needs of the various stakeholders
	in the measure development community.

Population criteria

    Initial Patient Population =
        AND: "Occurrence A of Encounter, Performed: Encounter Inpatient (length of stay <= 120 day(s))"
        AND: "Occurrence A of Encounter, Performed: Encounter Inpatient (discharge datetime)" during "Measurement Period"
    Measure Population =
        AND: "Initial Patient Population"
        AND: "Occurrence A of Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before start of "Occurrence A of Encounter, Performed: Encounter Inpatient"

Measure observations

    Median of:Time difference of:
        AND: "Occurrence A of Encounter, Performed: Emergency Department Visit (facility location arrival datetime)"
        AND: "Occurrence A of Encounter, Performed: Emergency Department Visit (facility location departure datetime)"

Data criteria (QDM Data Elements)

    "Diagnosis, Active: Psychiatric/Mental Health Patient" using "Psychiatric/Mental Health Patient Grouping Value Set (2.16.840.1.113883.3.117.1.7.1.299)"
    "Encounter, Performed: Emergency Department Visit" using "Emergency Department Visit Grouping Value Set (2.16.840.1.113883.3.117.1.7.1.293)"
    "Encounter, Performed: Encounter Inpatient" using "Encounter Inpatient SNOMED-CT Value Set (2.16.840.1.113883.3.666.5.307)"
    Attribute: "Ordinality: Principal Diagnosis" using "Principal Diagnosis SNOMED-CT Value Set (2.16.840.1.113883.3.117.2.7.1.14)"

Reporting Stratification

    Reporting Stratum 1 =
        AND: "Occurrence A of Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before start of "Occurrence A of Encounter, Performed: Encounter Inpatient"
    Reporting Stratum 2 =
        AND NOT: "Diagnosis, Active: Psychiatric/Mental Health Patient (ordinality: 'Principal Diagnosis')" starts during "Occurrence A of Encounter, Performed: Emergency Department Visit"
    Reporting Stratum 3 =
        AND: "Diagnosis, Active: Psychiatric/Mental Health Patient (ordinality: 'Principal Diagnosis')" starts during "Occurrence A of Encounter, Performed: Emergency Department Visit"

Supplemental Data Elements

    "Patient Characteristic Ethnicity: Ethnicity" using "Ethnicity CDC Value Set (2.16.840.1.114222.4.11.837)"
    "Patient Characteristic Payer: Payer" using "Payer Source of Payment Typology Value Set (2.16.840.1.114222.4.11.3591)"
    "Patient Characteristic Race: Race" using "Race CDC Value Set (2.16.840.1.114222.4.11.836)"
    "Patient Characteristic Sex: ONC Administrative Sex" using "ONC Administrative Sex Administrative Sex Value Set (2.16.840.1.113762.1.4.1)"

*/

using QDM version '5.0'

valueset "Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.293'
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

// Measure Observation
define function EDStayTime(Encounter "Encounter, Performed"):
	duration in minutes of Encounter.locationPeriod

// NOTE: The calculation method is specified in the HQMF, so will not be specified here
// The measure calculates the Median of EDStayTime

// Region: Stratifiers

define "Stratification 1":
	"Emergency Department Encounters"

define "Stratification 2":
	"Emergency Department Encounters" Encounter
		without ["Diagnosis": "Psychiatric/Mental Health Patient"] Diagnosis
			such that Diagnosis.prevalencePeriod starts during Encounter.relevantPeriod
		where not (Encounter.principalDiagnosis in "Psychiatric/Mental Health Patient")

define "Stratification 3":
	distinct ((
		"Emergency Department Encounters" Encounter
			with ["Diagnosis": "Psychiatric/Mental Health Patient"] Diagnosis
				such that Diagnosis.prevalencePeriod starts during Encounter.relevantPeriod
		)
		union (
			"Emergency Department Encounters" Encounter
				where Encounter.principalDiagnosis in "Psychiatric/Mental Health Patient"
		)
	)

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
