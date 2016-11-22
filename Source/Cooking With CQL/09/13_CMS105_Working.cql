library CMS105 version '5.2.000'

using QDM version '5.0'

/*
Population Criteria
Initial Population =
  AND: Age>= 18 year(s) at: Occurrence A of $EncounterInpatientNonElective
  AND:
    OR: Intersection of:
      Occurrence A of $EncounterInpatientNonElective
      "Encounter, Performed: Non-Elective Inpatient Encounter (principal diagnosis: Ischemic Stroke)"
    OR: Intersection of:
      Occurrence A of $EncounterInpatientNonElective
      "Encounter, Performed: Non-Elective Inpatient Encounter (principal diagnosis: Hemorrhagic Stroke)"

Denominator =
  AND: Initial Population
  AND: Intersection of:
    Occurrence A of $EncounterInpatientNonElective
    "Encounter, Performed: Non-Elective Inpatient Encounter (principal diagnosis: Ischemic Stroke)"

Denominator Exclusions =
  OR: "Laboratory Test, Performed: LDL-c" satisfies all:
    (result < 70 mg/dL)
    satisfies any:
      <= 30 day(s) ends before start of Occurrence A of $EncounterInpatientNonElective
      starts during Occurrence A of $EncounterInpatientNonElective
  OR: Intersection of:
    Occurrence A of $EncounterInpatientNonElective
    "Encounter, Performed: Non-Elective Inpatient Encounter" satisfies any:
      (discharge status: Discharge To Acute Care Facility)
      (discharge status: Left Against Medical Advice)
      (discharge status: Patient Expired)
      (discharge status: Discharged to Home for Hospice Care)
      (discharge status: Discharged to Health Care Facility for Hospice Care)
  OR: $InterventionComfortMeasures starts during ("Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatientNonElective )
  OR: $InterventionComfortMeasures starts during Occurrence A of $EncounterInpatientNonElective

Numerator =
  AND: "Medication, Discharge: Statin Grouper" starts during Occurrence A of $EncounterInpatientNonElective

Numerator Exclusions =
  None

Denominator Exceptions =
  OR: "Medication, Allergy: Statin Allergen" starts before or concurrent with end of Occurrence A of $EncounterInpatientNonElective
  OR: Union of:
    "Medication, Discharge not done: Patient Refusal" for "Statin ingredient specific"
    "Medication, Discharge not done: Medical Reason" for "Statin ingredient specific"
    starts during Occurrence A of $EncounterInpatientNonElective

Stratification =
  None

Data Criteria (QDM Variables)
  $EncounterInpatientNonElective =
  "Encounter, Performed: Non-Elective Inpatient Encounter" satisfies all:
    (length of stay <= 120 day(s))
    ends during "Measurement Period"

$InterventionComfortMeasures =
  Union of:
    "Intervention, Order: Comfort Measures"
    "Intervention, Performed: Comfort Measures"

Data Criteria (QDM Data Elements)
  "Encounter, Performed: Emergency Department Visit" using "Emergency Department Visit SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.292)"
  "Encounter, Performed: Non-Elective Inpatient Encounter" using "Non-Elective Inpatient Encounter SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.424)"
  "Intervention, Order: Comfort Measures" using "Comfort Measures SNOMEDCT Value Set (1.3.6.1.4.1.33895.1.3.0.45)"
  "Intervention, Performed: Comfort Measures" using "Comfort Measures SNOMEDCT Value Set (1.3.6.1.4.1.33895.1.3.0.45)"
  "Laboratory Test, Performed: LDL-c" using "LDL-c LOINC Value Set (2.16.840.1.113883.3.117.1.7.1.215)"
  "Medication, Allergy: Statin Allergen" using "Statin Allergen RXNORM Value Set (2.16.840.1.113883.3.117.1.7.1.423)"
  "Medication, Discharge: Statin Grouper" using "Statin Grouper Grouping Value Set (2.16.840.1.113762.1.4.1110.19)"
  "Medication, Discharge: Statin ingredient specific" using "Statin ingredient specific RXNORM Value Set (2.16.840.1.113762.1.4.1021.7)"
  "Medication, Discharge not done: Patient Refusal" using "Patient Refusal SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.93)"
  "Medication, Discharge not done: Medical Reason" using "Medical Reason SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.473)"
  Attribute: "Discharge status: Patient Expired" using "Patient Expired SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.309)"
  Attribute: "Discharge status: Left Against Medical Advice" using "Left Against Medical Advice SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.308)"
  Attribute: "Discharge status: Discharged to Health Care Facility for Hospice Care" using "Discharged to Health Care Facility for Hospice Care SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.207)"
  Attribute: "Principal diagnosis: Ischemic Stroke" using "Ischemic Stroke Grouping Value Set (2.16.840.1.113883.3.117.1.7.1.247)"
  Attribute: "Discharge status: Discharge To Acute Care Facility" using "Discharge To Acute Care Facility SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.87)"
  Attribute: "Discharge status: Discharged to Home for Hospice Care" using "Discharged to Home for Hospice Care SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.209)"
  Attribute: "Principal diagnosis: Hemorrhagic Stroke" using "Hemorrhagic Stroke Grouping Value Set (2.16.840.1.113883.3.117.1.7.1.212)"

Supplemental Data Elements
  "Patient Characteristic Ethnicity: Ethnicity" using "Ethnicity CDCREC Value Set (2.16.840.1.114222.4.11.837)"
  "Patient Characteristic Payer: Payer" using "Payer SOP Value Set (2.16.840.1.114222.4.11.3591)"
  "Patient Characteristic Race: Race" using "Race CDCREC Value Set (2.16.840.1.114222.4.11.836)"
  "Patient Characteristic Sex: ONC Administrative Sex" using "ONC Administrative Sex AdministrativeGender Value Set (2.16.840.1.113762.1.4.1)"

Risk Adjustment Variables
  None

*/

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'
valueset "Non-Elective Inpatient Encounter": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.424'
valueset "Comfort Measures": 'urn:oid:1.3.6.1.4.1.33895.1.3.0.45'
valueset "LDL-c": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.215'
valueset "Statin Allergen": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.423'
valueset "Statin Grouper": 'urn:oid:2.16.840.1.113762.1.4.1110.19'
valueset "Statin ingredient specific": 'urn:oid:2.16.840.1.113762.1.4.1021.7'
valueset "Medical Reason": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.473'
valueset "Patient Refusal": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.93'
valueset "Patient Expired": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.309'
valueset "Left Against Medical Advice": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.308'
valueset "Discharged to Health Care Facility for Hospice Care": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.207'
valueset "Ischemic Stroke": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.247'
valueset "Discharge To Acute Care Facility": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.87'
valueset "Discharged to Home for Hospice Care": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.209'
valueset "Hemorrhagic Stroke": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.212'

valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'

parameter "Measurement Period" default Interval[@2015-01-01T00:00:00, @2016-01-01T00:00:00)

context Patient

//Region: Initial Population
define "Non-Elective Inpatient Encounter":
  ["Encounter, Performed": "Non-Elective Inpatient Encounter"] NonElectiveEncounter
    where NonElectiveEncounter.lengthOfStay <= 120 days
      and NonElectiveEncounter.relevantPeriod ends during "Measurement Period"

define "Encounter with Principal Diagnosis of Hemorrhagic or Ischemic Stroke":
    "Non-Elective Inpatient Encounter" NonElectiveEncounter
        where NonElectiveEncounter.principalDiagnosis in "Hemorrhagic Stroke"
            or NonElectiveEncounter.principalDiagnosis in "Ischemic Stroke"

define "Initial Population":
  "Encounter with Principal Diagnosis of Hemorrhagic or Ischemic Stroke" Encounter
	  where AgeInYearsAt(start of Encounter.relevantPeriod) >= 18

  //EndRegion: Initial Population

//Region: Denominator

define "Encounter with Principal Diagnosis of Ischemic Stroke":
  "Non-Elective Inpatient Encounter" Encounter
    where Encounter.principalDiagnosis in "Ischemic Stroke"

define "Denominator":
    "Initial Population"
        intersect "Encounter with Principal Diagnosis of Ischemic Stroke"

//EndRegion: Denominator

//Region: Denominator Exclusions

// Encounter won't be recognized here, need to express this in terms of a relationship to an encounter
define "LDL-c < 70 mg/dL":
  "Encounter with Principal Diagnosis of Ischemic Stroke" Encounter
    with ["Laboratory Test, Performed": "LDL-c"] Ldl
        such that Ldl.result is < 70 'mg/dL'
            and Ldl.resultDatetime 30 days or less before start of Encounter.relevantPeriod
             or Ldl.resultDatetime starts during Encounter.relevantPeriod


define "Intervention Comfort Measures":
  distinct (
 ["Intervention, Order": "Comfort Measures"]
   union (
    ["Intervention, Performed": "Comfort Measures"] Intervention
       return "Intervention, Order" {
        authorDatetime: start of Intervention.relevantPeriod,
            reason: Intervention.reason
          }
       )
    )

define "Encounters with Comfort Measures":
    "Non-Elective Inpatient Encounter" NonElectiveEncounter
        with "Intervention Comfort Measures" ComfortMeasure
            such that ComfortMeasure.authorDatetime during NonElectiveEncounter.relevantPeriod


define "Denominator Exclusions":
   distinct ((
    "Non-Elective Inpatient Encounter" Encounter
      where Encounter.dischargeDisposition in "Discharge To Acute Care Facility"
         or Encounter.dischargeDisposition in "Left Against Medical Advice"
         or Encounter.dischargeDisposition in "Patient Expired"
         or Encounter.dischargeDisposition in "Discharged to Home for Hospice Care"
         or Encounter.dischargeDisposition in "Discharged to Health Care Facility for Hospice Care"
    )
     union
       "Encounters with Comfort Measures"
    // What we're describing here is a list of encounters, so we can't "or" that
		or "LDL-c < 70 mg/dL"
 )

//EndRegion: Denominator Exclusions

//Region: Numerator

define "Statin at Discharge":
    ["Medication, Discharge": "Statin Grouper"] Statin

define "Numerator":
    "Non-Elective Inpatient Encounter" Encounter
        with "Statin at Discharge" such that Statin.authorDatetime starts during Encounter.relevantPeriod

//EndRegion: Numerator

//Region: Numerator Exclusions
//NONE
//EndRegion: Numerator Exclusions

//Region: Denominator Exceptions
define "Statin Allergy":
    ["Allergy/Intolerance": "Statin Allergen"] Allergy

define "Statin Not Given at Discharge":
    ["Medication, Not Discharge": "Statin ingredient specific"] StatinDischarge
        where StatinDischarge.negationRationale in "Medical Reason"
            or StatinDischarge.negationRationale in "Patient Refusal"

define "Denominator Exceptions":
    "Non-Elective Inpatient Encounter" Encounter
        with "Statin Not Given at Discharge" such that StatinDischarge.authorDatetime starts during Encounter.relevantPeriod
        or "Statin Allergy" such that Allergy.PrevalencePeriod starts before or concurrent with end of Encounter.relevantPeriod

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

//EndRegion: Supplemental Data Elements
