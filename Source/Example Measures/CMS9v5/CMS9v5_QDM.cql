library CMS9 version '5'

using QDM //version '4.2'

valueset "Galactosemia": '2.16.840.1.113883.3.117.1.7.1.35'
valueset "Single Live Birth": '2.16.840.1.113883.3.117.1.7.1.25)'
valueset "Single Live Born Newborn Born in Hospital": '2.16.840.1.113883.3.117.1.7.1.26'
valueset "Encounter Inpatient": '2.16.840.1.113883.3.666.5.307'
valueset "Estimated Gestational Age at Birth": '2.16.840.1.113762.1.4.1045.47'
valueset "Parenteral Nutrition": '2.16.840.1.113883.3.117.1.7.1.38'
valueset "Breast Milk": '2.16.840.1.113883.3.117.1.7.1.30'
valueset "Dietary Intake Other than Breast Milk": '2.16.840.1.113883.3.117.1.7.1.27'
valueset "Neonatal Intensive Care Unit (NICU)": '2.16.840.1.113883.3.117.1.7.1.75'
valueset "Patient Expired": '2.16.840.1.113883.3.117.1.7.1.309'
valueset "Discharge To Acute Care Facility": '2.16.840.1.113883.3.117.1.7.1.87'

valueset "Ethnicity CDCREC": '2.16.840.1.114222.4.11.837'
valueset "Payer SOP": '2.16.840.1.114222.4.11.3591'
valueset "Race CDCREC": '2.16.840.1.114222.4.11.836'
valueset "ONC Administrative Sex AdministrativeGender": '2.16.840.1.113762.1.4.1'

parameter "Measurement Period" Interval<DateTime>

// NOTE: The patient here is the infant, not the mother
context Patient

define "Inpatient Encounter":
  ["Encounter, Performed": "Encounter Inpatient"] Encounter
    where days between Encounter.admissionDatetime and Encounter.dischargeDatetime <= 120
      and Encounter.dischargeDatetime in "Measurement Period"
      and Encounter.negationRationale is null

List<Code> { 92550, 92551, 92552, ... }

define "All Encounters":
  ["Encounter, Performed"]

Encounter { typeCode: 92550, admissionDateTime: @2015-06-01, ... }
Encounter { typeCode: 92551, ... }
Encounter { typeCode: 92552, ... }
Encounter { typeCode: 89982, ... }

define "Specific Encounter":
  ["Encounter, Performed": "Encounter Inpatient"] Encounter
    where Encounter.typeCode = Code 92550

  Encounter { typeCode: 92550, ... }
  Encounter { typeCode: 92551, ... }
  Encounter { typeCode: 92552, ... }



define "Live Birth Diagnosis":
  ["Diagnosis": "Single Live Birth"]
    union ["Diagnosis": "Single Live Born Newborn Born in Hospital"]

define "Live Birth Encounter":
  "Inpatient Encounter" Encounter
    where Encounter.diagnosis in "Single Live Birth"
      or Encounter.diagnosis in "Single Live Born Newborn Born in Hospital"
      or exists (
        "Live Birth Diagnosis" Diagnosis
          where Diagnosis.onsetDatetime between Encounter.admissionDatetime and Encounter.dischargeDatetime
      )

// NOTE: There are two options for calculating Gestational Age at Birth
// First as documentation of Gestational Age specifically:
define "Documented Gestational Age at Birth":
  ["Physical Exam, Performed": "Gestational Age At Birth"] Exam
    where Exam.negationRationale is null
    return Exam.result as Quantity

// Second as calculated based on the most recently documented Estimated Due Date:
define "Calculated Gestational Age at Birth":
  Floor(
    (280 - duration in days
      between Last(["Patient Characterstic Estimated Due Date": "Estimated Due Date"])
        and ["Patient Characteristic Birthdate": "Birthdate"]
    ) / 7
  )

define "Gestational Age at Birth >= 37 weeks":
  "Documentated Gestational Age at Birth" >= 37 weeks
    or "Calculated Gestational Age at Birth" >= 37

define "Galactosemia Diagnosis":
  ["Diagnosis": "Galactosemia"]

define "Parenteral Nutrition Procedure":
  ["Procedure, Performed": "Parenteral Nutrition"] Nutrition
    where Nutrition.negationRationale is null

define "Live Birth Infants without Parenteral Nutrition":
  "Live Birth Encounter" Encounter
    with "Gestational Age at Birth <= 37 weeks" GestationalAge
      such that GestationalAge.startDatetime between Encounter.admissionDatetime and Encounter.dischargeDatetime
    without "Galactosemia Diagnosis" Galactosemia
      such that Galactosemia.onsetDatetime between Encounter.admissionDatetime and Encounter.dischargeDatetime
    without "Parenteral Nutrition Procedure" Nutrition
      such that Nutrition.startDatetime between Encounter.admissionDatetime and Encounter.dischargeDatetime
    where not ( Encounter.diagnosis in "Galactosemia" )

// Region: Initial Population

define "Initial Population":
  "Live Birth Infants without Parenteral Nutrition"

// EndRegion: Initial Population

// Region: Denominator

// TODO: This should be discussed, it goes against the "criteria are not additive convention"
define "Denominator":
  "Initial Population"

// EndRegion: Denominator

// Region: Denominator Exclusions

define "Denominator Exclusions":
  "Live Birth Encounter" Encounter
    where Encounter.facilityLocation in "Neonatal Intensive Care Unit (NICU)"
      or Encounter.dischargeStatus in "Patient Expired"
      or Encounter.dischargeStatus in "Discharge To Acute Care Facility"

// EndRegion: Denominator Exclusions

// Region: Numerator

define "Breast Milk Feeding":
  ["Substance, Administered": "Breast Milk"] Feeding
    where Feeding.negationRationale is null

define "Other Than Breast Milk Feeding":
  ["Substance, Administered": "Dietary Intake Other than Breast Milk"] OtherFeeding
    where OtherFeeding.negationRationale is null

define "Numerator":
  "Live Birth Encounter" Encounter
    with "Breast Milk Feeding" Feeding
      such that Feeding.startDatetime between Encounter.admissionDatetime and Encounter.dischargeDatetime
    without "Other Than Breast Milk Feeding" OtherFeeding
      such that OtherFeeding.startDatetime between Encounter.admissionDatetime and Encounter.dischargeDatetime

// EndRegion: Numerator

// Region: Numerator Exclusions
// NONE
// End Region: Numerator Exclusions

// Region: Denominator Exceptions
// NONE
// End Region: Denominator Exceptions

// Region: Stratification
// NONE
// End Region: Stratification

// Region: Supplemental Data

define "Ethnicity": ["Patient Characteristic Ethnicity": "Ethnicity CDCREC"]
define "Payer": ["Patient Characteristic Payer": "Payer SOP"]
define "Race": ["Patient Characteristic Race": "Race CDCREC"]
define "Sex": ["Patient Characteristic Sex": "ONC Administrative Sex AdministrativeGender"]

// End Region: Supplemental Data
