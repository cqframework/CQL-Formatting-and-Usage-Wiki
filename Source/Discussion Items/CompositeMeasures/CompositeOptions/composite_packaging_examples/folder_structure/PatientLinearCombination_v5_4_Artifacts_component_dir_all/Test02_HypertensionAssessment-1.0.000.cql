library Test02_HypertensionAssessment version '1.0.000'

using QDM version '5.3'

include AnnualWellness version '1.0.000' called AWV

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Annual Wellness Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1063'
valueset "Diastolic Blood Pressure": 'urn:oid:2.16.840.1.113883.3.526.3.1033'
valueset "Systolic Blood Pressure": 'urn:oid:2.16.840.1.113883.3.526.3.1032'

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'

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

define "Initial Population":
	exists ( AWV."Annual Wellness Encounters" )

define "Denominator":
	"Initial Population"

define "Numerator":
	exists ( ["Physical Exam, Performed"] Exam
			with AWV."Annual Wellness Encounters" WellnessEncounter
				such that Exam.relevantPeriod during "Measurement Period"
			where exists ( Exam.components Systolic
					where Systolic.code in "Systolic Blood Pressure"
						and Systolic.result is not null
			)
				and exists ( Exam.components Diastolic
						where Diastolic.code in "Diastolic Blood Pressure"
							and Diastolic.result is not null
				)
	)
