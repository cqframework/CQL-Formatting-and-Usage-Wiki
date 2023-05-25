library USCoreElements version '0.1.0'

using USCore version '3.1.1'

include FHIRHelpers version '4.0.1'
include USCoreCommon version '0.1.0'

valueset "Common allergy substances": 'http://hl7.org/fhir/us/core/ValueSet/us-core-allergy-substance'

code "No known allergy (situation)": '716186003' from USCoreCommon.SNOMEDCT

context Patient

// Allergy/Intolerance

/*
@description: Returns all allergies and intolerances
@comment: This definition returns all allergies and intolerances conforming to the US Core 3.1.1
[AllergyIntolerance](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-allergyintolerance.html) profile.
Allergies and intolerances returned by this definition include records with any clinical status (including none)
and any verification status (including none).
@profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-allergyintolerance
*/
define "All Allergies and Intolerances":
  [AllergyIntolerance]

define "Common Allergies and Intolerances":
  "All Allergies and Intolerances" A
    where A.code in "Common allergy substances"

define "Active Confirmed Common Allergies and Intolerances":
  "Common Allergies and Intolerances".active().confirmed()

// No Known Allergies (Not Asked)
define "No Known Allergies (Not Asked)":
  "All Allergies and Intolerances" A
    where A.code ~ "No known allergy (situation)"
      and A.isActive()
      and A.isUnconfirmed()

// No Known Allergies (Confirmed)
define "No Known Allergies (Confirmed)":
  "All Allergies and Intolerances" A
    where A.code ~ "No known allergy (situation)"
      and A.isActive()
      and A.isConfirmed()

// Condition

/*
@description: Returns all problem list items, encounter diagnoses, and health concerns
@comment: This definition returns all conditions of any category conforming to the US Core 3.1.1
[Condition](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-condition.html) profile.
Conditions returned by this definition include records with any clinical status (including none) and
any verification status (including none).
@profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-condition
*/
define "All Conditions":
  [Condition]

define "All Problem List Items":
  "All Conditions" C
    where C.isProblemListItem()

define "Active Confirmed Problem List Items":
  "All Problem List Items".active().confirmed()

define "All Encounter Diagnoses":
  "All Conditions" C
    where C.isEncounterDiagnosis()

define "All Health Concerns":
  "All Conditions" C
    where C.isHealthConcern()

// Laboratory Diagnostic Report

// Diagnostic Report

// Encounter

// Immunization

// Implantable Device

// Laboratory Result

define "All Laboratory Results":
  ["LaboratoryResultObservationProfile"]

define "Resulted Laboratory Results":
  "All Laboratory Results" L
    where L.status in { 'preliminary', 'final', 'amended', 'corrected' }

// Medication Request

define "All Medication Requests":
  [MedicationRequestProfile]

define "Active Medication Orders":
  "All Medication Requests" M
    where M.status = 'active'
      and M.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }

// Pediatric BMI for Age

// Pediatric Head Circumference Percentile

// Pediatric Weight for Height

// Procedure

// Pulse Oximetry

// Smoking Status

/*
@description: Returns all smoking status observations
@comment: This definition returns all smoking status observations conforming to the US Core 3.1.1
[Smoking Status](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-smokingstatus.html)
profile.
@profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-smokingstatus
*/
define "Smoking Status":
  [SmokingStatusProfile]

/*
@description: Returns the most recent smoking status
@comment: This definition returns the most recent (by issued time) smoking status observation conforming to the
US Core 3.1.1 [Smoking Status](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-smokingstatus.html)
profile.
*/
define "Most Recent Smoking Status":
  Last(
    "Smoking Status" SS
        where SS.status = 'final'
        sort by issued
  )

// Vital Signs Panel

// Respiratory Rate

// Heart Rate

// Oxygen Saturation

// Body Temperature

// Body Height

// Head Circumference

// Body Weight

// Body Mass Index

// Blood Pressure

// Systolic Blood Pressure

// Diastolic Blood Pressure
