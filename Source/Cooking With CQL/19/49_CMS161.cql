library TestCMS161 version '0.0.010'

// This example is an excerpt of CMS161
// Only the relevant logic is included

using QDM version '5.3'

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1010'
valueset "Face-to-Face Interaction": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1048'
valueset "Office Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Outpatient Consultation": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1008'
valueset "Psych Visit - Diagnostic Evaluation": 'urn:oid:2.16.840.1.113883.3.526.3.1492'
valueset "Psych Visit - Psychotherapy": 'urn:oid:2.16.840.1.113883.3.526.3.1496'
valueset "Psychoanalysis": 'urn:oid:2.16.840.1.113883.3.526.3.1141'
valueset "Suicide Risk Assessment": 'urn:oid:2.16.840.1.113883.3.526.3.1484'
valueset "Major Depressive Disorder-Active": 'urn:oid:2.16.840.1.113883.3.526.3.1491'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Encounter with Major Depressive Disorder Diagnosis":
	( ["Encounter, Performed": "Psych Visit - Diagnostic Evaluation"]
		union ["Encounter, Performed": "Emergency Department Visit"]
		union ["Encounter, Performed": "Face-to-Face Interaction"]
		union ["Encounter, Performed": "Office Visit"]
		union ["Encounter, Performed": "Outpatient Consultation"]
		union ["Encounter, Performed": "Psych Visit - Psychotherapy"]
		union ["Encounter, Performed": "Psychoanalysis"] ) Enc
		where exists ( Enc.diagnoses d
				where d in "Major Depressive Disorder-Active"
		)

define "Encounter with Major Depressive Disorder Diagnosis During Measurement Period":
	"Encounter with Major Depressive Disorder Diagnosis" Encounter
	  where Encounter.relevantPeriod ends during "Measurement Period"

// Distinct is not required here
/*
define "Encounter with Major Depressive Disorder Diagnosis":
	( ["Encounter, Performed": "Psych Visit - Diagnostic Evaluation"]
		union ["Encounter, Performed": "Emergency Department Visit"]
		union ["Encounter, Performed": "Face-to-Face Interaction"]
		union ["Encounter, Performed": "Office Visit"]
		union ["Encounter, Performed": "Outpatient Consultation"]
		union ["Encounter, Performed": "Psych Visit - Psychotherapy"]
		union ["Encounter, Performed": "Psychoanalysis"] ) Enc
		where exists ( Enc.diagnoses d
				where d in "Major Depressive Disorder-Active"
		)
			and Enc.relevantPeriod during "Measurement Period"
*/

define "Encounter with Major Depressive Disorder Diagnosis":
	( ["Encounter, Performed": "Psych Visit - Diagnostic Evaluation"]
		union ["Encounter, Performed": "Emergency Department Visit"]
		union ["Encounter, Performed": "Face-to-Face Interaction"]
		union ["Encounter, Performed": "Office Visit"]
		union ["Encounter, Performed": "Outpatient Consultation"]
		union ["Encounter, Performed": "Psych Visit - Psychotherapy"]
		union ["Encounter, Performed": "Psychoanalysis"] ) Enc
		where exists ( Enc.diagnoses d
				where d in "Major Depressive Disorder-Active"
		)

// Because these are both using "Encounter with Major Depressive Disorder Diagnosis",
// all the encounters considered will be during the measurement period. This will exclude
// encounters that occurred prior to the measurement year for the purposes of "104 days before"
define "Initial Population":
	"Encounter with Major Depressive Disorder Diagnosis" Enc1
		without "Encounter with Major Depressive Disorder Diagnosis" Enc2
			such that Enc2.relevantPeriod ends 104 days or less before start of Enc1.relevantPeriod
		where Enc1.relevantPeriod during "Measurement Period"
			and AgeInYearsAt(start of "Measurement Period")>= 17

