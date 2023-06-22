library ZZ_AnnualWellnessAssessmentMeasure_PatientLinearCombination version '0.0.001'

using QDM version '5.3'

include Test01_ScreeningForAlcoholMisuse version '1.1.000' called ScreeningForAlcoholMisuse
include Test02_HypertensionAssessment version '1.0.000' called HypertensionAssessment
include Test03_ScreeningForBreastCancer version '1.0.000' called ScreeningForBreastCancer
include Test04_ScreeningForColorectalCancer version '1.0.000' called ScreeningForColorectalCancer
include Test05_ScreeningForDepression version '1.0.000' called ScreeningForDepression

codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'

code "Birth date": '21112-8' from "LOINC" display 'Birthdate'

context Patient

define "SDE Ethnicity":
	["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer":
	["Patient Characteristic Payer": "Payer"]

define "SDE Race":
	["Patient Characteristic Race": "Race"]

define "SDE Sex":
	["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Patient Record": ["Patient Characteristic Birthdate": "Birth date"]

define "Is In Screening For Alcohol Misuse Denominator":
  ScreeningForAlcoholMisuse."Initial Population"
	  and ScreeningForAlcoholMisuse."Denominator"
		and not ScreeningForAlcoholMisuse."Denominator Exclusions"
		
define "Is In Screening For Alcohol Misuse Numerator":
  "Is In Screening For Alcohol Misuse Denominator"
	  and ScreeningForAlcoholMisuse."Numerator"
		
define "Is In Hypertension Assessment Denominator":
  HypertensionAssessment."Initial Population"
	  and HypertensionAssessment."Denominator"
		//and not HypertensionAssessment."Denominator Exclusions"
		
define "Is In Hypertension Assessment Numerator":
  "Is In Hypertension Assessment Denominator"
	  and HypertensionAssessment."Numerator"

define "Is In Screening For Breast Cancer Denominator":
  ScreeningForBreastCancer."Initial Population"
	  and ScreeningForBreastCancer."Denominator"
		and not ScreeningForBreastCancer."Denominator Exclusions"
		
define "Is In Screening For Breast Cancer Numerator":
  "Is In Screening For Breast Cancer Denominator"
	  and ScreeningForBreastCancer."Numerator"

define "Is In Screening For Colorectal Cancer Denominator":
  ScreeningForColorectalCancer."Initial Population"
	  and ScreeningForColorectalCancer."Denominator"
		and not ScreeningForColorectalCancer."Denominator Exclusions"
		
define "Is In Screening For Colorectal Cancer Numerator":
  "Is In Screening For Colorectal Cancer Denominator"
	  and ScreeningForColorectalCancer."Numerator"

define "Is In Screening For Depression Denominator":
  ScreeningForDepression."Initial Population"
	  and ScreeningForDepression."Denominator"
		and not ScreeningForDepression."Denominator Exclusions"

define "Is In Screening For Depression Numerator":
  "Is In Screening For Depression Denominator"
	  and ScreeningForDepression."Numerator"

define "Denominator Score":
  ToScore("Is In Screening For Alcohol Misuse Denominator")
	  + ToScore("Is In Hypertension Assessment Denominator")
		+ ToScore("Is In Screening For Breast Cancer Denominator")
		+ ToScore("Is In Screening For Colorectal Cancer Denominator")
		+ ToScore("Is In Screening For Depression Denominator")

define "Numerator Score":
  ToScore("Is In Screening For Alcohol Misuse Numerator")
	  + ToScore("Is In Hypertension Assessment Numerator")
		+ ToScore("Is In Screening For Breast Cancer Numerator")
		+ ToScore("Is In Screening For Colorectal Cancer Numerator")
		+ ToScore("Is In Screening For Depression Numerator")

define "Initial Population":
	"Patient Record" P
		where ScreeningForAlcoholMisuse."Initial Population"
			or HypertensionAssessment."Initial Population"
			or ScreeningForBreastCancer."Initial Population"
			or ScreeningForColorectalCancer."Initial Population"
			or ScreeningForDepression."Initial Population"

define "Measure Population":
	"Patient Record" P
		where ScreeningForAlcoholMisuse."Denominator"
			or HypertensionAssessment."Denominator"
			or ScreeningForBreastCancer."Denominator"
			or ScreeningForColorectalCancer."Denominator"
			or ScreeningForDepression."Denominator"
			
define "Measure Population Exclusions":
  "Patient Record" P
		where ScreeningForAlcoholMisuse."Denominator Exclusions"
			//and HypertensionAssessment."Denominator Exclusions"
			and ScreeningForBreastCancer."Denominator Exclusions"
			and ScreeningForColorectalCancer."Denominator Exclusions"
			and ScreeningForDepression."Denominator Exclusions"

define function "Measure Observation"(PatientCharacteristic "Patient Characteristic Birthdate"):
	"Numerator Score" / "Denominator Score"

define function ToScore(value Boolean):
  if value then 1 else 0