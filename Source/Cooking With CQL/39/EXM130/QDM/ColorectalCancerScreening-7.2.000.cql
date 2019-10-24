library ColorectalCancerScreening version '7.2.000'

using QDM version '5.3'

include Adult_Outpatient_Encounters version '1.1.000' called AdultOutpatientEncounters
include MATGlobalCommonFunctions version '2.0.000' called Global
include Hospice version '1.0.000' called Hospice

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Colonoscopy": 'urn:oid:2.16.840.1.113883.3.464.1003.108.12.1020'
valueset "Fecal Occult Blood Test (FOBT)": 'urn:oid:2.16.840.1.113883.3.464.1003.198.12.1011'
valueset "Flexible Sigmoidoscopy": 'urn:oid:2.16.840.1.113883.3.464.1003.198.12.1010'
valueset "Malignant Neoplasm of Colon": 'urn:oid:2.16.840.1.113883.3.464.1003.108.12.1001'
valueset "Total Colectomy": 'urn:oid:2.16.840.1.113883.3.464.1003.198.12.1019'
valueset "FIT DNA": 'urn:oid:2.16.840.1.113883.3.464.1003.108.12.1039'
valueset "CT Colonography": 'urn:oid:2.16.840.1.113883.3.464.1003.108.12.1038'

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
	exists ["Patient Characteristic Birthdate"] BirthDate
		where Global."CalendarAgeInYearsAt"(BirthDate.birthDatetime, start of "Measurement Period")in Interval[50, 75 )
			and exists AdultOutpatientEncounters."Qualifying Encounters"

define "Denominator":
	"Initial Population"

define "Flexible Sigmoidoscopy Performed":
	["Procedure, Performed": "Flexible Sigmoidoscopy"] FlexibleSigmoidoscopy
		where FlexibleSigmoidoscopy.relevantPeriod ends 5 years or less on or before end of "Measurement Period"

define "CT Colonography Performed":
	["Procedure, Performed": "CT Colonography"] Colonography
		where Colonography.relevantPeriod ends 5 years or less on or before end of "Measurement Period"

define "Fecal Occult Blood Test Performed":
	["Laboratory Test, Performed": "Fecal Occult Blood Test (FOBT)"] FecalOccultResult
		where FecalOccultResult.result is not null
			and FecalOccultResult.authorDatetime during "Measurement Period"

define "Fecal Immunochemical Test DNA":
	["Laboratory Test, Performed": "FIT DNA"] FitDNA
		where FitDNA.result is not null
			and FitDNA.authorDatetime occurs 3 years or less on or before end of "Measurement Period"

define "Colonoscopy Performed":
	["Procedure, Performed": "Colonoscopy"] Colonoscopy
		where Colonoscopy.relevantPeriod ends 10 years or less on or before end of "Measurement Period"

define "Numerator":
	exists "Colonoscopy Performed"
		or exists "Fecal Occult Blood Test Performed"
		or exists "Flexible Sigmoidoscopy Performed"
		or exists "Fecal Immunochemical Test DNA"
		or exists "CT Colonography Performed"

define "Malignant Neoplasm":
	["Diagnosis": "Malignant Neoplasm of Colon"] ColorectalCancer
		where ColorectalCancer.prevalencePeriod starts on or before end of "Measurement Period"

define "Total Colectomy Performed":
	["Procedure, Performed": "Total Colectomy"] Colectomy
		where Colectomy.relevantPeriod starts on or before end of "Measurement Period"

define "Denominator Exclusions":
	Hospice."Has Hospice"
		or exists "Malignant Neoplasm"
		or exists "Total Colectomy Performed"

