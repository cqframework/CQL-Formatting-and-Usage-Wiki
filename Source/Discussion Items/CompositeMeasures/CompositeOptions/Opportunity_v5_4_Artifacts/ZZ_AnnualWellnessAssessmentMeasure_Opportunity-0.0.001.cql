library ZZ_AnnualWellnessAssessmentMeasure_Opportunity version '0.0.001'

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

// NOTE: The cases in the population are service opportunities per patient
// Which means measures where the patient was in the initial population

define "Patient Record": ["Patient Characteristic Birthdate": "Birth date"]

define "Initial Population":
  ("Patient Record" P where ScreeningForAlcoholMisuse."Initial Population" return { service: 'Screening For Alcohol Misuse' })
	  union ("Patient Record" P where HypertensionAssessment."Initial Population" return { service: 'Hypertension Assessment' })
		union ("Patient Record" P where ScreeningForBreastCancer."Initial Population" return { service: 'Screening For Breast Cancer' })
		union ("Patient Record" P where ScreeningForColorectalCancer."Initial Population" return { service: 'Screening For Colorectal Cancer' })
		union ("Patient Record" P where ScreeningForDepression."Initial Population" return { service: 'Screening For Depression' })

define "Denominator":
  ("Patient Record" P where ScreeningForAlcoholMisuse."Denominator" return { service: 'Screening For Alcohol Misuse' })
	  union ("Patient Record" P where HypertensionAssessment."Denominator" return { service: 'Hypertension Assessment' })
		union ("Patient Record" P where ScreeningForBreastCancer."Denominator" return { service: 'Screening For Breast Cancer' })
		union ("Patient Record" P where ScreeningForColorectalCancer."Denominator" return { service: 'Screening For Colorectal Cancer' })
		union ("Patient Record" P where ScreeningForDepression."Denominator" return { service: 'Screening For Depression' })

define "Denominator Exclusions":
  ("Patient Record" P where ScreeningForAlcoholMisuse."Denominator Exclusions" return { service: 'Screening For Alcohol Misuse' })
	  //union ("Patient Record" P where HypertensionAssessment."Denominator Exclusion" return { service: 'Hypertension Assessment' })
		  union ("Patient Record" P where ScreeningForBreastCancer."Denominator Exclusions" return { service: 'Screening For Breast Cancer' })
  		union ("Patient Record" P where ScreeningForColorectalCancer."Denominator Exclusions" return { service: 'Screening For Colorectal Cancer' })
		  union ("Patient Record" P where ScreeningForDepression."Denominator Exclusions" return { service: 'Screening For Depression' })

define "Numerator":
  ("Patient Record" P where ScreeningForAlcoholMisuse."Numerator" return { service: 'Screening For Alcohol Misuse' })
	  union ("Patient Record" P where HypertensionAssessment."Numerator" return { service: 'Hypertension Assessment' })
		union ("Patient Record" P where ScreeningForBreastCancer."Numerator" return { service: 'Screening For Breast Cancer' })
		union ("Patient Record" P where ScreeningForColorectalCancer."Numerator" return { service: 'Screening For Colorectal Cancer' })
		union ("Patient Record" P where ScreeningForDepression."Numerator" return { service: 'Screening For Depression' })

