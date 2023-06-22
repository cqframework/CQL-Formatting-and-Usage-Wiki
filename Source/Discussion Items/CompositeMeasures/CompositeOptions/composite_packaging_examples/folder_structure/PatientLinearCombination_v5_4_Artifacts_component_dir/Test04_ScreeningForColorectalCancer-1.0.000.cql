library Test04_ScreeningForColorectalCancer version '1.0.000'

using QDM version '5.3'

include AnnualWellness version '1.0.000' called AWV
include MATGlobalCommonFunctions version '2.0.000' called Global

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Malignant Neoplasm of Colon": 'urn:oid:2.16.840.1.113883.3.464.1003.108.12.1001'
valueset "Fecal Occult Blood Test (FOBT)": 'urn:oid:2.16.840.1.113883.3.464.1003.198.12.1011'
valueset "Colonoscopy": 'urn:oid:2.16.840.1.113883.3.464.1003.108.12.1020'
valueset "Flexible Sigmoidoscopy": 'urn:oid:2.16.840.1.113883.3.464.1003.198.12.1010'
valueset "Total Colectomy": 'urn:oid:2.16.840.1.113883.3.464.1003.198.12.1019'

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
	exists ( ["Patient Characteristic Birthdate": "Birthdate"] BirthDate
			where Global."CalendarAgeInYearsAt"(BirthDate.birthDatetime, start of "Measurement Period")< 75
	)

define "Denominator Exclusions":
	exists ( ["Procedure, Performed": "Total Colectomy"] Colectomy
			where Colectomy.relevantPeriod ends before end of "Measurement Period"
	)
		or exists ( ["Diagnosis": "Malignant Neoplasm of Colon"] Neoplasm
				where Neoplasm.prevalencePeriod starts before end of "Measurement Period"
		)

define "Numerator":
	exists ( ["Procedure, Performed": "Colonoscopy"] Colonoscopy
			where Colonoscopy.relevantPeriod ends 9 years or less on or before end of "Measurement Period"
	)
		or exists ( ["Laboratory Test, Performed": "Fecal Occult Blood Test (FOBT)"] FOBT
				where FOBT.authorDatetime during "Measurement Period"
					and FOBT.result is not null
		)
		or exists ( ["Procedure, Performed": "Flexible Sigmoidoscopy"] Sigmoidoscopy
				where Sigmoidoscopy.relevantPeriod ends 4 years or less on or before end of "Measurement Period"
		)
