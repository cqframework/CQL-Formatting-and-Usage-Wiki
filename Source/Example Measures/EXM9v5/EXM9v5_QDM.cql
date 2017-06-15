library EXM9 version '5.1.000'

/*
This example is a work in progress and should not be considered a final specification
or recommendation for guidance. This example will help guide and direct the process
of finding conventions and usage patterns that meet the needs of the various stakeholders
in the measure development community.
*/

using QDM version '5.0.2'

valueset "Galactosemia": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.35'
valueset "Single Live Birth": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.25'
valueset "Single Live Born Newborn Born in Hospital": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.26'
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Estimated Gestational Age at Birth": 'urn:oid:2.16.840.1.113762.1.4.1045.47'
valueset "Parenteral Nutrition": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.38'
valueset "Breast Milk": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.30'
valueset "Dietary Intake Other than Breast Milk": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.27'
valueset "Neonatal Intensive Care Unit (NICU)": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.75'
valueset "Patient Expired": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.309'
valueset "Discharge To Acute Care Facility": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.87'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'

parameter "Measurement Period" default Interval[@2015-01-01T00:00:00, @2016-01-01T00:00:00)

context Patient

define "Inpatient Encounter":
  ["Encounter, Performed": "Encounter Inpatient"] Encounter
    where Encounter.lengthOfStay <= 120 days
      and Encounter.relevantPeriod ends during "Measurement Period"

define "Gestational Age at Birth >= 37 weeks":
    ["Assessment, Performed": "Estimated Gestational Age at Birth"] Gestational
        where (Gestational.result as Quantity) >= 37 weeks // This was 259 days. It can be 37 weeks, but:
        // 1) How will the system return the data?
        // 2) Will the implementation support time-based quantity conversion? CQL spec does not require that conversions be supported, only that they be respected.

define "Gestational Age at Birth >= 37 weeks":
  ["Assessment, Performed": "Estimated Gestational Age at Birth"] Gestational
    where Gestational.result >= 259 days
    

// NOTE: Gestational age may be calculated using the ACOG ReVITALize guidelines with
// Estimated Due Date (EDD)
// Needs to be the most recent exam associated with this pregnancy
/*
define "Estimated Due Date":
  Last(
    ["Physical Exam, Performed": "Estimated Due Date"] Exam
      sort by start of relevantPeriod
  ).result as DateTime

define "Gestational Age in Days at Birth":
  (280 - (duration in days between "Estimated Due Date" and "Birth Date")) div 7
*/

define "Single Live Birth Diagnosis":
  // Question about the use of distinct here:
    distinct (
      // If this diagnosis returned the same instance
		["Diagnosis": "Single Live Birth"]
      // As this one, without the distinct, the result would include both instances
      // NOTE: This behavior is changing in CQL 1.2 so that the distinct will no longer be required, but will automatically be eliminated by the union operation
			union ["Diagnosis": "Single Live Born Newborn Born in Hospital"]
)

define "Single Live Birth Encounter":
    distinct ((
        "Inpatient Encounter" Encounter
            where Encounter.diagnosis in "Single Live Birth"
                or Encounter.diagnosis in "Single Live Born Newborn Born in Hospital"
			)
            union (
                "Inpatient Encounter" Encounter
                    with "Single Live Birth Diagnosis" Diagnosis
                        such that Diagnosis.prevalencePeriod starts during Encounter.relevantPeriod
        )
	)

define "Single Live Birth Encounter Without Galactosemia":
    "Single Live Birth Encounter" Encounter
        without ["Diagnosis": "Galactosemia"] Diagnosis
            such that Diagnosis.prevalencePeriod starts during Encounter.relevantPeriod
        where not (Encounter.diagnosis in "Galactosemia")

define "Single Live Birth Encounter Without Galactosemia or Parenteral Nutrition":
    "Single Live Birth Encounter Without Galactosemia" Encounter
        without ["Procedure, Performed": "Parenteral Nutrition"] Procedure
            such that Procedure.relevantPeriod starts during Encounter.relevantPeriod

//Region: Initial Population

define "Initial Population":
    "Single Live Birth Encounter Without Galactosemia or Parenteral Nutrition" Encounter
        with "Gestational Age at Birth >= 37 weeks" Gestational
            such that Gestational.authorDatetime during Encounter.relevantPeriod // NOTE: This should be "during", not "starts during" because authorDatetime is a point-in-time, not an interval

//EndRegion: Initial Population

//Region: Denominator

define "Denominator":
    "Initial Population"

//EndRegion: Denominator

//Region: Denominator Exclusions

define "Denominator Exclusions":
    "Inpatient Encounter" Encounter
        where Encounter.facilityLocation in "Neonatal Intensive Care Unit (NICU)"
            or Encounter.dischargeDisposition in "Patient Expired"
            or Encounter.dischargeDisposition in "Discharge To Acute Care Facility"

//EndRegion: Denominator Exclusions

//Region: Numerator

define "Breast Milk Feeding":
    ["Substance, Administered": "Breast Milk"] Feeding

define "Other Than Breast Milk Feeding":
    ["Substance, Administered": "Dietary Intake Other than Breast Milk"] Other

define "Numerator":
    "Inpatient Encounter" Encounter
        with "Breast Milk Feeding" Feeding such that Feeding.relevantPeriod starts during Encounter.relevantPeriod
        without "Other Than Breast Milk Feeding" Other such that Other.relevantPeriod starts during Encounter.relevantPeriod

//EndRegion: Numerator

//Region: Numerator Exclusions
//NONE
//EndRegion: Numerator Exclusions

//Region: Denominator Exceptions
//NONE
//EndRegion: Denominator Exceptions

//Region: Stratification
//NONE
//EndRegion: Stratification

//Region: Supplemental Data Elements

define "SDE Ethnicity":
    ["Patient Characteristic Ethnicity": "Ethnicity"] Characteristic
        return Characteristic.code

define "SDE Payer":
    ["Patient Characteristic Payer": "Payer"] Characteristic
        return Characteristic.code

define "SDE Race":
    ["Patient Characteristic Race": "Race"] Characteristic
        return Characteristic.code

define "SDE Sex":
    ["Patient Characteristic Sex": "ONC Administrative Sex"] Characteristic
        return Characteristic.code

//EndRegionL Supplemental Data Elements
