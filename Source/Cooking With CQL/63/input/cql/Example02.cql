library Example02

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include MATGlobalCommonFunctionsFHIR4 version '6.1.000' called Global

codesystem "ObservationCategoryCodes": 'http://terminology.hl7.org/CodeSystem/observation-category'

valueset "Congenital or Acquired Absence of Cervix": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.111.12.1016'
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016'
valueset "HPV Test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1059'
valueset "Hysterectomy with No Residual Cervix": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1014'
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089'
valueset "Pap Test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1017'
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023'
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080'

code "laboratory": 'laboratory' from "ObservationCategoryCodes" display 'Laboratory'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2019-01-01T00:00:00.0, @2020-01-01T00:00:00.0)

context Patient

define "Initial Population":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[23, 64)
    and Patient.gender = 'female'
    and exists "Qualifying Encounters"

define "Qualifying Encounters":
  ( [Encounter: "Office Visit"]
    union [Encounter: "Preventive Care Services - Established Office Visit, 18 and Up"]
    union [Encounter: "Preventive Care Services-Initial Office Visit, 18 and Up"]
    union [Encounter: "Home Healthcare Services"]
    union [Encounter: "Telephone Visits"]
    union [Encounter: "Online Assessments"]
  ) ValidEncounter
    where ValidEncounter.status = 'finished'
      and ValidEncounter.period during "Measurement Period"

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  exists "Absence of Cervix"
    //or Hospice."Has Hospice"
    //or PalliativeCare."Palliative Care in the Measurement Period"

define "Numerator":
  exists "Cervical Cytology Within 3 Years"
    or exists "HPV Test Within 5 Years for Women Age 30 and Older"

define "Absence of Cervix":
  ( [Procedure: "Hysterectomy with No Residual Cervix"] NoCervixProcedure
    where NoCervixProcedure.status = 'completed'
      and Global."Normalize Interval"(NoCervixProcedure.performed) ends on or before end of "Measurement Period"
  )
    union ( [Condition: "Congenital or Acquired Absence of Cervix"] NoCervixDiagnosis
        where Global."Prevalence Period"(NoCervixDiagnosis) starts on or before end of "Measurement Period"
    )

define "Cervical Cytology Within 3 Years":
  [Observation: "Pap Test"] CervicalCytology
    where CervicalCytology.status in { 'final', 'amended', 'corrected' }
      and exists ( CervicalCytology.category CervicalCytologyCategory
        where "laboratory" in FHIRHelpers.ToConcept(CervicalCytologyCategory).codes
      )
      and Global."Latest"(CervicalCytology.effective) 3 years or less on or before end of "Measurement Period"
      and CervicalCytology.value is not null

define "HPV Test Within 5 Years for Women Age 30 and Older":
  [Observation: "HPV Test"] HPVTest
    where HPVTest.status in { 'final', 'amended', 'corrected' }
      and exists ( HPVTest.category HPVTestCategory
          where "laboratory" in FHIRHelpers.ToConcept(HPVTestCategory).codes
      )
      and AgeInYearsAt(date from start of Global."Normalize Interval"(HPVTest.effective)) >= 30
      and Global."Latest"(HPVTest.effective) 5 years or less on or before end of "Measurement Period"
      and HPVTest.value is not null
