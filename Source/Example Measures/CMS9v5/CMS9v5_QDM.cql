library CMS9 version '5.1.000'

using QDM version '5.0'

valueset "Galactosemia Grouping Value Set": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.35'
valueset "Single Live Birth SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.25'
valueset "Single Live Born Newborn Born in Hospital Grouping Value Set": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.26'
valueset "Encounter Inpatient SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Estimated Gestational Age at Birth SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113762.1.4.1045.47'
valueset "Parenteral Nutrition Grouping Value Set": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.38'
valueset "Breast Milk SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.30'
valueset "Dietary Intake Other than Breast Milk SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.27'
valueset "Neonatal Intensive Care Unit (NICU) SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.75'
valueset "Patient Expired SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.309'
valueset "Discharge To Acute Care Facility SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.87'
valueset "Ethnicity CDCREC Value Set": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer SOP Value Set": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Race CDCREC Value Set": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "ONC Administrative Sex AdministrativeGender Value Set": 'urn:oid:2.16.840.1.113762.1.4.1'

parameter "Measurement Period" Interval<DateTime>

/*
  $EncounterInpatient =
      "Encounter, Performed: Encounter Inpatient" satisfies all:
          (length of stay <= 120 day(s))
          ends during "Measurement Period"
*/

define "Encounter Inpatient":
  ["Encounter, Performed": "Encounter Inpatient SNOMEDCT Value Set"] Encounter
    where Encounter.lengthOfStay <= 120 days
      and Encounter.relevantPeriod ends during "Measurement Period"

/*
Initial Population =
    AND: "Physical Exam, Performed: Estimated Gestational Age at Birth (result >= 37 week(s))" starts during Occurrence A of $EncounterInpatient
    AND:
        OR: Intersection of:
            Occurrence A of $EncounterInpatient
            "Encounter, Performed: Encounter Inpatient" satisfies any:
                (diagnosis: Single Live Birth)
                (diagnosis: Single Live Born Newborn Born in Hospital)
        OR: Union of:
            "Diagnosis: Single Live Birth"
            "Diagnosis: Single Live Born Newborn Born in Hospital"
            starts during Occurrence A of $EncounterInpatient
    AND NOT: Union of:
        "Diagnosis: Galactosemia" starts during Occurrence A of $EncounterInpatient
        Intersection of:
            Occurrence A of $EncounterInpatient
            "Encounter, Performed: Encounter Inpatient (diagnosis: Galactosemia)"
    AND NOT: "Procedure, Performed: Parenteral Nutrition" starts during Occurrence A of $EncounterInpatient
*/

define "Single Live Birth Diagnosis":
  ["Diagnosis": "Single Live Birth SNOMEDCT Value Set"]
    union ["Diagnosis": "Single Live Born Newborn Born in Hospital Grouping Value Set"]

define "Single Live Birth Encounter":
  distinct
    "Encounter Inpatient" Encounter
      where Encounter.diagnosis in "Single Live Birth SNOMEDCT Value Set"
        or Encounter.diagnosis in "Single Live Born Newborn Born in Hospital Grouping Value Set"
    union
      "Encounter Inpatient" Encounter
        with "Single Live Birth Diagnosis" Diagnosis
          such that Diagnosis.onsetDateTime during Encounter.relevantPeriod

define "Single Live Birth Encounter Without Galactosemia":
  "Single Live Birth Encounter" Encounter
    without ["Diagnosis": "Galactosemia Grouping Value Set"] Diagnosis
      such that Diagnosis.onsetDateTime during Encounter.relevantPeriod
    where not (Encounter.diagnosis in "Galactosemia Grouping Value Set")

define "Single Live Birth Encounter Without Galactosemia or Parenteral Nutrition":
  "Single Live Birth Encounter Without Galactosemia" Encounter
    without ["Procedure, Performed": "Parenteral Nutrition Grouping Value Set"] Procedure
      such that Procedure.relevantPeriod starts during Encounter.relevantPeriod

define "Initial Population":
  "Single Live Birth Encounter Without Galactosemia or Parenteral Nutrition" Encounter
    with ["Assessment, Performed": "Estimated Gestational Age at Birth SNOMEDCT Value Set"] Assessment
      such that Assessment.authorDateTime during Encounter.relevantPeriod
        and Assessment.result >= 37 weeks

/*
Denominator =
    AND: Initial Population
*/

define "Denominator":
  "Initial Population"

/*
Denominator Exclusions =
    OR: Intersection of:
        Occurrence A of $EncounterInpatient
        "Encounter, Performed: Encounter Inpatient" satisfies any:
            (facility location: Neonatal Intensive Care Unit (NICU))
            (discharge status: Patient Expired)
            (discharge status: Discharge To Acute Care Facility)
*/

define "Denominator Exclusions":
  "Initial Population" Encounter
    where Encounter.facilityLocation in "Neonatal Intensive Care Unit (NICU) SNOMEDCT Value Set"
      or Encounter.dischargeDisposition in "Patient Expired SNOMEDCT Value Set"
      or Encounter.dischargeDisposition in "Discharge To Acute Care Facility SNOMEDCT Value Set"

/*
Numerator =
    AND: "Substance, Administered: Breast Milk" starts during Occurrence A of $EncounterInpatient
    AND NOT: "Substance, Administered: Dietary Intake Other than Breast Milk" starts during Occurrence A of $EncounterInpatient
*/

define "Numerator":
  "Initial Population" Encounter
    with ["Substance, Administered": "Breast Milk SNOMEDCT Value Set"] Substance
      such that Substance.relevantPeriod starts during Encounter.relevantPeriod
    without ["Substance, Administered": "Dietary Intake Other than Breast Milk SNOMEDCT Value Set"] Substance
      such that Substance.relevantPeriod starts during Encounter.relevantPeriod

/*
Numerator Exclusions =
    None
*/

/*
Denominator Exceptions =
    None
*/

/*
Stratification =
    None
*/

/*
Supplemental Data Elements

    "Patient Characteristic Ethnicity: Ethnicity" using "Ethnicity CDCREC Value Set (2.16.840.1.114222.4.11.837)"
    "Patient Characteristic Payer: Payer" using "Payer SOP Value Set (2.16.840.1.114222.4.11.3591)"
    "Patient Characteristic Race: Race" using "Race CDCREC Value Set (2.16.840.1.114222.4.11.836)"
    "Patient Characteristic Sex: ONC Administrative Sex" using "ONC Administrative Sex AdministrativeGender Value Set (2.16.840.1.113762.1.4.1)"
*/

define "SDE Patient Ethnicity": ["Patient Characteristic Ethnicity": "Ethnicity CDCREC Value Set"]
define "SDE Patient Payer": ["Patient Characteristic Payer": "Payer SOP Value Set"]
define "SDE Patient Race": ["Patient Characteristic Race": "Race CDCREC Value Set"]
define "SDE Patient Sex": ["Patient Characteristic Sex": "ONC Administrative Sex AdministrativeGender Value Set"

/*
Risk Adjustment Variables
    None
*/
