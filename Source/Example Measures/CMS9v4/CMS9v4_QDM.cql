library CMS9 version '4.0.0'

/*
  CMS9v4
  Exclusive Breast Milk Feeding

  Episode-of-Care-Based Proportion Measure with multiple populations
*/

using QDM version '5.0'

valueset "Feeding Intention-Breast": 'urn:oid:2.16.840.1.113762.1.4.1045.29'
valueset "Galactosemia": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.35'
valueset "Single Live Birth": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.25)'
valueset "Single Live Born Newborn Born in Hospital": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.26'
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Estimated Gestational Age at Birth": 'urn:oid:2.16.840.1.113762.1.4.1045.47'
valueset "Parenteral Nutrition": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.38'
valueset "Breast Milk": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.30'
valueset "Dietary Intake Other than Breast Milk": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.27'
valueset "Neonatal Intensive Care Unit (NICU)": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.75'
valueset "Patient Expired": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.309'
valueset "Discharge To Acute Care Facility": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.87'

valueset "Ethnicity CDCREC": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer SOP": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Race CDCREC": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "ONC Administrative Sex AdministrativeGender": 'urn:oid:2.16.840.1.113762.1.4.1'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Inpatient Encounter":
  ["Encounter, Performed": "Encounter Inpatient"] E
    where duration in days of E.relevantPeriod <= 120
      and end of E.relevantPeriod in "Measurement Period"

define "Gestational Age at Birth <= 37 weeks":
  ["Physical Exam, Performed": "Estimated Gestational Age at Birth"] O
    where (O.result as Quantity) >= 259 days // 37 weeks

define "Live Birth":
  ["Diagnosis": "Single Live Birth"]
    union ["Diagnosis": "Single Live Born Newborn Born in Hospital"]

define "Galactosemia Diagnosis":
  ["Diagnosis": "Galactosemia"]

define "Parenteral Nutrition Procedure":
  ["Procedure, Performed": "Parenteral Nutrition"]

define "Live Birth Infants without Parenteral Nutrition":
  "Inpatient Encounter" E
    with "Gestational Age at Birth <= 37 weeks" G
      such that G.relevantPeriod starts during E.relevantPeriod
    with "Live Birth" B
      such that B.prevalencePeriod starts during E.relevantPeriod
    without "Galactosemia Diagnosis" D
      such that D.prevalencePeriod starts during E.relevantPeriod
    without "Parenteral Nutrition Procedure" P
      such that P.relevantPeriod starts during E.relevantPeriod

// Region: Initial Population 1

define "Initial Population 1":
  "Live Birth Infants without Parenteral Nutrition"

// EndRegion: Initial Population 1

// Region: Denominator 1

define "Denominator 1":
  "Initial Population 1"

// EndRegion: Denominator 1

// Region: Denominator Exclusions 1

define "Denominator Exclusions 1":
  "Inpatient Encounter" E
    where E.facilityLocation in "Neonatal Intensive Care Unit (NICU)"
      or E.dischargeDisposition in "Patient Expired"
      or E.dischargeDisposition in "Discharge To Acute Care Facility"

// EndRegion: Denominator Exclusions 1

// Region: Numerator 1

define "Breast Milk Feeding":
  ["Substance, Administered": "Breast Milk"]

define "Other Than Breast Milk Feeding":
  ["Substance, Administered": "Dietary Intake Other than Breast Milk"]

define "Numerator 1":
  "Inpatient Encounter" E
    with "Breast Milk Feeding" F such that F.relevantPeriod starts during E.relevantPeriod
    without "Other Than Breast Milk Feeding" O such that O.relevantPeriod starts during E.relevantPeriod

// EndRegion: Numerator 1

// Region: Numerator Exclusions 1
// NONE
// End Region: Numerator Exclusions 1

// Region: Denominator Exceptions 1
// NONE
// End Region: Denominator Exceptions 1

// Region: Stratification 1
// NONE
// End Region: Stratification 1

// Region: Initial Population 2

define "Initial Population 2":
  "Live Birth Infants without Parenteral Nutrition"

// EndRegion: Initial Population 2

// Region: Denominator 2

// EndRegion: Denominator 2

// Region: Denominator Exclusions 2

// TODO: How do we indicate that this is the infant's birth date, not the mother's?
define "Infant Birth Date":
  (singleton from (["Patient Characteristic Birthdate"])).birthDatetime

// TODO: In the source measure, this is expressed as the "absence of an intention to breast feed",
// but this is not the same as the intended "presence of intention not to breast feed"
define "Intention Not To Breast Feed":
  "Inpatient Encounter" E
    without ["Communication: From Patient To Provider": "Feeding Intention-Breast"] C
      such that C.authorDatetime 1 hour or less after "Infant Birth Date"

// NOTE: There is a LOINC concept for an Obstetrics Admission Note.  We could potentially
// request an addition (with support from the American College of Obstetrics and Gynecology - ACOG)
// to the required assessment questions such as "Intent to breast feed" with normative answers of "yes" or "no"
// Then we could address the question posed in the measure with the following define:
// 78718-4 	Obstetrics and Gynecology Admission history and physical note
/*
define "Intention Not To Breast Feed":
  ["Assessment": "Obstetrics and Gynecology Admission"] Assessment
    where exists (
      Assessment.component Question
        where Question.code in "Intent to breast feed"
          and Question.result in "Normative No"
    )
*/

define "Denominator Exclusions 2":
  "Denominator Exclusions 1"
    union "Intention Not To Breast Feed"

// EndRegion: Denominator Exclusions 2

// Region: Numerator 2

define "Numerator 2":
  "Numerator 1"

// EndRegion: Numerator 2

// Region: Numerator Exclusions 2
// NONE
// End Region: Numerator Exclusions 2

// Region: Denominator Exceptions 2
// NONE
// End Region: Denominator Exceptions 2

// Region: Stratification 2
// NONE
// End Region: Stratification 2

// Region: Supplemental Data Elements

define "SDE Ethnicity":
  ["Patient Characteristic Ethnicity": "Ethnicity CDCREC"] Characteristic
    return Characteristic.code

define "SDE Payer":
  ["Patient Characteristic Payer": "Payer SOP"] Characteristic
    return Characteristic.code

define "SDE Race":
  ["Patient Characteristic Race": "Race CDCREC"] Characteristic
    return Characteristic.code

define "SDE Sex":
  ["Patient Characteristic Sex": "ONC Administrative Sex AdministrativeGender"] Characteristic
    return Characteristic.code

// End Region: Supplemental Data Elements
