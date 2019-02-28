library MaximumValue

/*
This example is based on CMS105v7 - Discharged on Statin Medication
The illustrates finding the maximum value of a type of laboratory test
*/

using QDM version '5.3'

include MATGlobalCommonFunctions version '2.0.000' called Global

valueset "Hemorrhagic Stroke": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.212'
valueset "Ischemic Stroke": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.247'
valueset "LDL-c": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.215'
valueset "Non-Elective Inpatient Encounter": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.424'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Encounter with Max LDL less than 70 mg per dL":
	"Ischemic Stroke Encounter" IschemicStrokeEncounter
		where Max(["Laboratory Test, Performed": "LDL-c"] Ldl
				where Ldl.resultDatetime during Interval[Global."ToDate"(start of IschemicStrokeEncounter.relevantPeriod - 30 days), end of IschemicStrokeEncounter.relevantPeriod]
				return Ldl.result as Quantity
		)< 70 'mg/dL'

define "Ischemic Stroke Encounter":
	"Encounter with Principal Diagnosis and Age" EncounterWithAge
		where EncounterWithAge.principalDiagnosis in "Ischemic Stroke"
    
define "Encounter with Principal Diagnosis and Age":
	"All Stroke Encounter" AllStrokeEncounter
		with ["Patient Characteristic Birthdate"] BirthDate
			such that Global."CalendarAgeInYearsAt"(BirthDate.birthDatetime, start of AllStrokeEncounter.relevantPeriod)>= 18

define "All Stroke Encounter":
	"Non Elective Inpatient Encounter" NonElectiveEncounter
		where NonElectiveEncounter.principalDiagnosis in "Hemorrhagic Stroke"
			or NonElectiveEncounter.principalDiagnosis in "Ischemic Stroke"
      
define "Non Elective Inpatient Encounter":
	["Encounter, Performed": "Non-Elective Inpatient Encounter"] NonElectiveEncounter
		where Global."LengthInDays"(NonElectiveEncounter.relevantPeriod)<= 120
			and NonElectiveEncounter.relevantPeriod ends during "Measurement Period"
      
