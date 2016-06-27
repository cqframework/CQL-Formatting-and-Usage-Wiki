/* Encounters that were performed */
["Encounter, Performed": "Inpatient"] Encounter
  where Encounter.negationRationale is null

/* Encounters that were not performed */
["Encounter, Performed": "Inpatient"] Encounter
  where Encounter.negationRationale is not null

/* Encounters that were not performed for a specific reason */
["Encounter, Performed": "Inpatient"] Encounter
  where Encounter.negationRationale in "Encounter Not Done Reason"

///////////////////////////////////////
// Filtering by Existence

/*
  "Occurrence A of Laboratory Test, Performed: CD4+ Count (result)"
*/

define "CD4+ Count With Results and Medications":
  ["Laboratory Test, Performed": "CD4+ Count"] CD4Count
    where CD4Count.result is not null

// Comparison to null is not correct

define "CD4+ Count With Results and Medications":
  ["Laboratory Test, Performed": "CD4+ Count"] CD4Count
    where CD4Count.result <> null

// This will fail because comparisons involving null are "unknown"

///////////////////////////////////////////
// Filtering by Value Set

define "Denominator Exclusions 1":
  "Encounter Inpatient" Encounter
    where Encounter.facilityLocation in "Neonatal Intensive Care Unit (NICU)"
      or Encounter.dischargeStatus in "Patient Expired"
      or Encounter.dischargeStatus in "Discharge To Acute Care Facility"

///////////////////////////////////////////////
// Filtering by Code

codesystem "SNOMED-CT": '2.16.840.1.113883.6.96' version '2016A'

define "Breastfeeding Intention Code":
  Code '123456789' from "SNOMED-CT" display 'Breastfeeding intention'

define "Breastfeeding Intention":
  ["Risk Assessment, Performed": "Breastfeeding Intention Code"] RiskAssessment
    where RiskAssessment.negationRationale is null

//////////////////////////////////////////////
// Filtering by Values and Quantities

/* "Laboratory Test, Performed: LDL-c Test (result < 100 mg/dL)" */

define "LDL-c Test In Range":
  ["Laboratory Test, Performed": "LDL-c Test"] LDLCTest
    where LDLCTest.result < 100 'mg/dL'


//////////////////////////////////////////////
// Related information

/*
  "Encounter, Performed: Hospital Inpatient" starts before start of "Diagnosis: Diabetes"
*/

define "Valid Encounters":
  ["Encounter, Performed": "Hospital Inpatient"] Encounter
    with ["Diagnosis": "Diabetes"] Diagnosis
      such that Encounter.admissionDatetime occurs before Diagnosis.onsetDatetime

///////////////////////////////////////////////
// Date and Time comparisons

define "Valid Encounters":
  ["Encounter, Performed": "Hospital Inpatient"] Encounter
    with ["Diagnosis": "Diabetes"] Diagnosis
      such that Encounter.admissionDatetime occurs same day as Diagnosis.onsetDatetime

///////////////////////////////////////////////
// Interval comparisons

/*
  "Encounter, Performed: Hospital Inpatient" during "Diagnosis: Diabetes"
*/

define "Valid Encounters":
  ["Encounter, Performed": "Hospital Inpatient"] Encounter
    with ["Diagnosis": "Diabetes"] Diagnosis
      such that Interval[Encounter.admissionDatetime, Encounter.dischargeDatetime]
        during Interval[Diagnosis.onsetDatetime, Diagnosis.abatementDatetime]

/////////////////////////////////////////////////
// Combining Conditions

/*
  AND: "Occurrence A of Encounter, Performed: BH Outpatient encounter" >=
    42 day(s) starts before start of "Measurement End Date"
  AND: "Occurrence A of Encounter, Performed: BH Outpatient encounter"
    starts after start of "Measurement Start Date"
*/

define "Valid Encounters":
  ["Encounter, Performed": "BH Outpatient encounter"] Encounter
    where Encounter.admissionDateTime occurs 42 days or less before end of "Measurement Period"
      and Encounter.admissionDateTime occurs after start of "Measurement Period"

/*
  AND: "Occurrence A of Encounter, Performed: HIV Visit" during "Measurement Period"
  AND: "Occurrence B of Encounter, Performed: HIV Visit" during "Measurement Period"
  AND: "Occurrence B of Encounter, Performed: HIV Visit" >= 90 day(s)
    starts after end of "Occurrence A of Encounter, Performed: HIV Visit"
*/

define "HIV Visits During Measurement Period":
  ["Encounter, Performed": "HIV Visit"] Encounter
    where Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime] during "Measurement Period"

define "HIV Followup Visits":
  "HIV Visits During Measurement Period" FollowupVisit
    with "HIV Visits During Measurement Period" PriorVisit
      such that FollowupVisit.admissionDateTime occurs 90 days or more after PriorVisit.dischargeDateTime

/*
  AND: "Occurrence A of Medication, Order: Dapsone and pyrimethamine" <=
    3 month(s) starts after end of "Occurrence A of Laboratory Test, Performed: CD4+ Count (result)"
  AND: "Occurrent A of Medication, Order: Leucovorin" <= 3 month(s)
    starts after end of "Occurrence A of Laboratory Test, Performed:
      CD4+ Count (result)"
*/

define "CD4+ Count With Results and Medications":
  ["Laboratory Test, Performed": "CD4+ Count"] CD4Count
    with ["Medication, Order": "Dapsone and pyrimethamine"] DapsoneOrder
      such that DapsoneOrder.signedDatetime occurs 3 months or less before CD4Count.stopDateTime
    with ["Medication, Order": "Leucovorin"] LeucovorinOrder
      such that LeucovorinOrder.signedDatetime occurs 3 months or less before CD4Count.stopDateTime
    where CD4Count.result is not null

/////////////////////////////////////////////////////////////////
// CMS 126 v4

/*
Initial Population =
    AND: Age >= 5 year(s) at: "Measurement Period"
    AND: Age < 64 year(s) at: "Measurement Period"
    AND: "Diagnosis, Active: Persistent Asthma" overlaps "Measurement Period"
    AND: Union of:
        "Encounter, Performed: Office Visit"
        "Encounter, Performed: Face-to-Face Interaction"
        "Encounter, Performed: Preventive Care - Established Office Visit, 0 to 17"
        "Encounter, Performed: Preventive Care Services - Established Office Visit, 18 and Up"
        "Encounter, Performed: Preventive Care Services-Initial Office Visit, 18 and Up"
        "Encounter, Performed: Preventive Care- Initial Office Visit, 0 to 17"
        "Encounter, Performed: Home Healthcare Services"
        during "Measurement Period"

Denominator =
    AND: Initial Population

Denominator Exclusions =
    OR: Union of:
        "Diagnosis, Active: Chronic Obstructive Pulmonary Disease"
        "Diagnosis, Active: Emphysema"
        "Diagnosis, Active: Cystic Fibrosis"
        "Diagnosis, Active: Acute Respiratory Failure"
        overlaps "Measurement Period"

Numerator =
    AND: "Medication, Dispensed: Preferred Asthma Therapy" during "Measurement Period"

Numerator Exclusions =
    None

Denominator Exceptions =
    None
*/

define "In Demographic":
  AgeInYearsAt(start of "Measurement Period") >= 5
    and AgeInYearsAt(start of "Measurement Period") < 65

define "Asthma Diagnosis":
  ["Diagnosis": "Persistent Asthma"] Diagnosis
    where Interval[Diagnosis.onsetDatetime, Diagnosis.abatementDatetime] overlaps "Measurement Period"

define "Valid Encounters":
  (["Encounter, Performed": "Office Visit"]
    union ["Encounter, Performed": "Face-to-Face Interaction"]
    union ["Encounter, Performed": "Preventive Care - Established Office Visit, 0 to 17"]
    union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
    union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
    union ["Encounter, Performed": "Preventive Care- Initial Office Visit, 0 to 17"]
    union ["Encounter, Performed": "Home Healthcare Services"]
  ) E where Interval[E.admissionDateTime, E.dischargeDateTime] during "Measurement Period"

define "In Initial Population":
  "In Demographic"
    and exists "Asthma Diagnosis"
    and exists "Valid Encounters"

// Denominator is the same as the initial population

define "Excepted Diagnoses":
  (["Diagnosis": "Chronic Obstructive Pulmonary Disease"]
    union ["Diagnosis": "Emphysema"]
    union ["Diagnosis": "Cystic Fibrosis"]
    union ["Diagnosis": "Actue Repiratory Failure"]
  ) Diagnosis where Interval[Diagnosis.onsetDatetime, Diagnosis.abatementDatetime] overlaps "Measurement Period"

define "Denominator Exceptions":
  exists "Excepted Diagnoses"

define "Preferred Asthma Therapy":
  ["Medication, Dispensed": "Preferred Asthma Therapy"] Medication
    where Interval[Medication.startDatetime, Medication.stopDateTime] during "Measurement Period"

define "Numerator":
  exists "Preferred Asthma Therpay"
