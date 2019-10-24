library EXM130_FHIR3 version '7.2.000'

/*
Based on CMS130v7 - Colorectal Cancer Screening
*/

/*
This example is a work in progress and should not be considered a final specification
or recommendation for guidance. This example will help guide and direct the process
of finding conventions and usage patterns that meet the needs of the various stakeholders
in the measure development community.
*/

using FHIR version '3.0.0'

include AdultOutpatientEncounters_FHIR3 version '1.1.000' called AdultOutpatientEncounters
include MATGlobalCommonFunctions_FHIR3 version '2.0.000' called Global
include Hospice_FHIR3 version '1.0.000' called Hospice
include FHIRHelpers version '3.0.0' called FHIRHelpers
include SupplementalDataElements_FHIR3 version '1.0.0' called SDE

valueset "ONC Administrative Sex": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1'
valueset "Race": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.836'
valueset "Ethnicity": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.837'
valueset "Payer": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.3591'
valueset "Colonoscopy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1020'
valueset "Fecal Occult Blood Test (FOBT)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1011'
valueset "Flexible Sigmoidoscopy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1010'
valueset "Malignant Neoplasm of Colon": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1001'
valueset "Total Colectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1019'
valueset "FIT DNA": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1039'
valueset "CT Colonography": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1038'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"

// NOTE: The interval here was closed, versus the open in the QDM expression
define "Initial Population":
	Global."CalendarAgeInYearsAt"(FHIRHelpers.ToDate(Patient.birthDate), start of "Measurement Period") in Interval[50, 75)
			and exists AdultOutpatientEncounters."Qualifying Encounters"("Measurement Period")

define "Denominator":
	true

define "Flexible Sigmoidoscopy Performed":
	[Procedure: "Flexible Sigmoidoscopy"] FlexibleSigmoidoscopy
		where FlexibleSigmoidoscopy.status = 'completed'
			and FlexibleSigmoidoscopy.performed ends 5 years or less on or before end of "Measurement Period"

define "CT Colonography Performed":
	[Procedure: "CT Colonography"] Colonography
		where Colonography.status = 'completed'
			and Colonography.performed ends 5 years or less on or before end of "Measurement Period"

define "Fecal Occult Blood Test Performed":
	[Observation: "Fecal Occult Blood Test (FOBT)"] FecalOccultResult
		where FecalOccultResult.status in {'final', 'amended', 'corrected', 'preliminary'}
			and FecalOccultResult.value is not null
			and FecalOccultResult.effective during day of "Measurement Period"
			// and FecalOccultResult.FHIR.provenance.recorded during "Measurement Period"

define "Fecal Immunochemical Test DNA":
	[Observation: "FIT DNA"] FitDNA
		where FitDNA.value is not null
			and FitDNA.effective occurs 3 years or less on or before day of end of "Measurement Period"
			// and FitDNA.FHIR.provenance.recorded occurs 3 years or less on or before end of "Measurement Period"

define "Colonoscopy Performed":
	[Procedure: "Colonoscopy"] Colonoscopy
		where Colonoscopy.status = 'completed'
		 	and Colonoscopy.performed ends 10 years or less on or before end of "Measurement Period"

define "Numerator":
	exists "Colonoscopy Performed"
		or exists "Fecal Occult Blood Test Performed"
		or exists "Flexible Sigmoidoscopy Performed"
		or exists "Fecal Immunochemical Test DNA"
		or exists "CT Colonography Performed"

define "Denominator Exclusion":
	Hospice."Has Hospice"("Measurement Period")
		or exists "Malignant Neoplasm"
		or exists "Total Colectomy Performed"

define "Malignant Neoplasm":
	[Condition: "Malignant Neoplasm of Colon"] ColorectalCancer
		where Global."Normalize Onset"(ColorectalCancer.onset) starts on or before end of "Measurement Period"

define "Total Colectomy Performed":
	[Procedure: "Total Colectomy"] Colectomy
		where Colectomy.status = 'completed'
			and Global."Get Choice Interval - dateTime or Period"(Colectomy.performed) starts on or before end of "Measurement Period"

