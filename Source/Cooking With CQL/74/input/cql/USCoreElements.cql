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

/*
@comment: [Diagnostic Report for Laboratory Results](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-diagnosticreport-lab.html)
@profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-diagnosticreport-lab
*/

// Diagnostic Report

/*
@comment: [Diagnostic Report Note](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-diagnosticreport-note.html)
@profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-diagnosticreport-note
*/

// Encounter

/*
@comment: [Encounter](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-encounter.html)
@profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-encounter 
*/

// Immunization

/*
@comment: [Immunization](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-immunization.html)
@profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-immunization
*/

// Implantable Device

/*
@comment: [Implantable Device](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-implantable-device.html)
@profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-implantable-device
*/

// Laboratory Result

/*
@description: Returns all laboratory results
@comment: [Laboratory Result](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-observation-lab.html)
@profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-observation-lab
*/
define "All Laboratory Results":
  ["LaboratoryResultObservationProfile"]

define "Resulted Laboratory Results":
  "All Laboratory Results" L
    where L.status in { 'preliminary', 'final', 'amended', 'corrected' }

// Medication Request

/*
@description: Returns all medication requests
@comment: [Medication Request](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-medicationrequest.html)
@profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-medicationrequest
*/
define "All Medication Requests":
  [MedicationRequestProfile]

define "Active Medication Orders":
  "All Medication Requests" M
    where M.status = 'active'
      and M.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }

// Pediatric BMI for Age

/*
@comment: [Pediatric BMI for Age](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-pediatric-bmi-for-age.html)
@profile: http://hl7.org/fhir/us/core/StructureDefinition/pediatric-bmi-for-age
*/

// Pediatric Head Circumference Percentile

/*
@comment: [Pediatric Head Circumference Percentile](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-head-occipital-frontal-circumference-percentile.html)
@profile: http://hl7.org/fhir/us/core/StructureDefinition/head-occipital-frontal-circumference-percentile
*/

// Pediatric Weight for Height

/*
@comment: [Pediatric Weight for Height](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-pediatric-weight-for-height.html)
@profile: http://hl7.org/fhir/us/core/StructureDefinition/pediatric-weight-for-height
*/

// Procedure

/*
@comment: [Procedure](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-procedure.html)
@profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-procedure
*/

// Pulse Oximetry

/*
@comment: [Pulse Oximetry](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-pulse-oximetry.html)
@profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-pulse-oximetry
*/

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

/*
@comment: [Vital Signs Panel](http://hl7.org/fhir/R4/vitalspanel.html)
@profile: http://hl7.org/fhir/StructureDefinition/vitalspanel
*/

// Respiratory Rate

/*
@comment: [Respiratory Rate](http://hl7.org/fhir/R4/resprate.html)
@profile: http://hl7.org/fhir/StructureDefinition/resprate
*/

// Heart Rate

/*
@comment: [Heart Rate](http://hl7.org/fhir/R4/heartrate.html)
@profile:http://hl7.org/fhir/StructureDefinition/heartrate
*/

// Oxygen Saturation

/*
@comment: [Oxygen Saturation](http://hl7.org/fhir/R4/oxygensat.html)
@profile: http://hl7.org/fhir/StructureDefinition/oxygensat
*/

// Body Temperature

/*
@comment: [Body Temperature](http://hl7.org/fhir/R4/bodytemp.html)
@profile: http://hl7.org/fhir/StructureDefinition/bodytemp
*/

// Body Height

/*
@comment: [Body Height](http://hl7.org/fhir/R4/bodyheight.html)
@profile: http://hl7.org/fhir/StructureDefinition/bodyheight
*/

// Head Circumference

/*
@comment: [Head Circumference](http://hl7.org/fhir/R4/headcircum.html)
@profile: http://hl7.org/fhir/StructureDefinition/headcircum
*/

// Body Weight

/*
@comment: [Body Weight](http://hl7.org/fhir/R4/bodyweight.html)
@profile: http://hl7.org/fhir/StructureDefinition/bodyweight
*/

// Body Mass Index

/*
@comment: [Body Mass Index](http://hl7.org/fhir/R4/bmi.html)
@profile: http://hl7.org/fhir/StructureDefinition/bmi
*/

// Blood Pressure

/*
@comment: [Blood Pressure](http://hl7.org/fhir/R4/bp.html)
@profile: http://hl7.org/fhir/StructureDefinition/bp
*/

// Systolic Blood Pressure

// Diastolic Blood Pressure


