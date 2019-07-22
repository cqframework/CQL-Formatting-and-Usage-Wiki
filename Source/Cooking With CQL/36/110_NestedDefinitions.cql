library NestedDefinitions version '0.0.000'

/*
This example is taken from CMS31v7 - Hearing Screening Prior To Hospital Discharge
The Denominator Exclusions in this measure exclude live birth encounters where the patient expired
and a complete hearing screening was not performed (because we don't want to exclude patients that 
expired where a complete hearing screening _was_ performed).

The issue is that the check for complete hearing screening is not restricted to the relevant
encounter, so if there are multiple encounters, an encounter that meets the criteria that the
patient expired but doesn't have an associated complete hearing screening might still not be
excluded if there is another encounter that doesn't meet the patient expired criteria but _does_
have an associated complete hearing screening.
*/


using QDM version '5.3'

include MATGlobalCommonFunctions version '2.0.000' called Global

codesystem "SNOMEDCT:2017-09": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2017-09'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Live Birth Newborn Born in Hospital": 'urn:oid:2.16.840.1.113762.1.4.1046.6'
valueset "Medical Reasons": 'urn:oid:2.16.840.1.114222.4.1.214079.1.1.7'
valueset "Newborn Hearing Screen Left": 'urn:oid:2.16.840.1.114222.4.1.214079.1.1.3'
valueset "Newborn Hearing Screen Right": 'urn:oid:2.16.840.1.114222.4.1.214079.1.1.4'
valueset "Pass Or Refer": 'urn:oid:2.16.840.1.114222.4.1.214079.1.1.6'

code "Patient deceased during stay (discharge status = dead) (finding)": '371828006' from "SNOMEDCT:2017-09" display 'Patient deceased during stay (discharge status = dead) (finding)'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity":
	["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer":
	["Patient Characteristic Payer": "Payer"]

define "SDE Race":
	["Patient Characteristic Race": "Race"]

define "SDE Sex":
	["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Inpatient Encounters":
	["Encounter, Performed": "Encounter Inpatient"] Encounter
		where Global."LengthInDays"(Encounter.relevantPeriod)<= 120
			and Encounter.relevantPeriod ends during "Measurement Period"

define "Diagnosis Live Birth Newborn Born in Hospital":
	"Inpatient Encounters" InpatientEncounter
		with ["Diagnosis": "Live Birth Newborn Born in Hospital"] QualifyingDiagnosis
			such that QualifyingDiagnosis.prevalencePeriod starts during InpatientEncounter.relevantPeriod

define "Encounter with Live Birth Diagnosis":
	"Inpatient Encounters" InpatientEncounter
		where exists InpatientEncounter.diagnoses EncounterDiagnosis
			where EncounterDiagnosis in "Live Birth Newborn Born in Hospital"

define "Numerator":
	"Has Complete Hearing Screening"
		union "Hearing Screen Not Done Due to Medical Reasons"

define "Initial Population":
	"Encounter with Live Birth Diagnosis"
		union "Diagnosis Live Birth Newborn Born in Hospital"

define "Denominator":
	"Initial Population"

define "Hearing Screen Not Done Due to Medical Reasons":
	"Initial Population" LiveBirthEncounter
		with ( ["Diagnostic Study, Not Performed": "Newborn Hearing Screen Left"]
			union ["Diagnostic Study, Not Performed": "Newborn Hearing Screen Right"] ) ScreenNotDone
			such that ScreenNotDone.negationRationale in "Medical Reasons"
				and ScreenNotDone.authorDatetime during LiveBirthEncounter.relevantPeriod

define "Left Hearing Screen Performed":
	["Diagnostic Study, Performed": "Newborn Hearing Screen Left"] LeftScreen
		where LeftScreen.result in "Pass Or Refer"

define "Right Hearing Screen Performed":
	["Diagnostic Study, Performed": "Newborn Hearing Screen Right"] RightScreen
		where RightScreen.result in "Pass Or Refer"

define "Has Complete Hearing Screening":
	"Inpatient Encounters" InpatientEncounter
		where exists "Left Hearing Screen Performed" LeftHearingScreen
			where LeftHearingScreen.authorDatetime during InpatientEncounter.relevantPeriod
				and exists "Right Hearing Screen Performed" RightHearingScreen
					where RightHearingScreen.authorDatetime during InpatientEncounter.relevantPeriod

// Issue is here
// In the case of single encounter, there is no possibility for an issue
// However, in the case of multiple encounters, because "Has Complete Hearing Screening"
// is not related to LiveBirthEncounter, there is a possibility for the exclusion to be
// calculated without being associated to a LiveBirthEncounter.
define "Denominator Exclusions":
	"Initial Population" LiveBirthEncounter
		where LiveBirthEncounter.dischargeDisposition ~ "Patient deceased during stay (discharge status = dead) (finding)"
			and not exists "Has Complete Hearing Screening"

// To account for this possibility, we could use an except to say that live birth encounters with a complete hearing screening
// should not be considered for exclusion
define "Encounter-Restricted Denominator Exclusions":
  ("Initial Population" 
		except "Has Complete Hearing Screening"
	) LiveBirthEncounter
	  where LiveBirthEncounter.dischargeDisposition ~ "Patient deceased during stay (discharge status = dead) (finding)"

