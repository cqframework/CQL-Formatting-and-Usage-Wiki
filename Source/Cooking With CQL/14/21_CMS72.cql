library TestCMS72

// Related JIRA Ticket:
// https://oncprojectracking.healthit.gov/support/browse/CQLIT-31?page=com.atlassian.jira.plugin.system.issuetabpanels%3Aall-tabpanel
// Markup submission here:
// C:\Users\Bryn\Documents\Src\SS\Docs\CQL Example Submissions\CMS72v5 CQL Markup.docx

// Example based on CMS72v5 - Antithrombotic Therapy By End of Hospital Day 2
// Encounter-based Proportion Measure

using QDM version '5.0.2'

/*
Data Criteria (QDM Data Elements)

    "Encounter, Performed: Emergency Department Visit" using "Emergency Department Visit SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.292)"
    "Encounter, Performed: Non-Elective Inpatient Encounter" using "Non-Elective Inpatient Encounter SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.424)"
    "Intervention, Order: Comfort Measures" using "Comfort Measures SNOMEDCT Value Set (1.3.6.1.4.1.33895.1.3.0.45)"
    "Intervention, Performed: Comfort Measures" using "Comfort Measures SNOMEDCT Value Set (1.3.6.1.4.1.33895.1.3.0.45)"
    "Medication, Administered: Antithrombotic Therapy" using "Antithrombotic Therapy RXNORM Value Set (2.16.840.1.113883.3.117.1.7.1.201)"
    "Medication, Administered: Thrombolytic (t-PA) Therapy" using "Thrombolytic (t-PA) Therapy RXNORM Value Set (2.16.840.1.113883.3.117.1.7.1.226)"
    "Medication, Administered not done: Medical Reason" using "Medical Reason SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.473)"
    "Medication, Administered not done: Patient Refusal" using "Patient Refusal SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.93)"
    "Medication, Order: Antithrombotic ingredient specific" using "Antithrombotic ingredient specific RXNORM Value Set (2.16.840.1.113762.1.4.1021.8)"
    "Medication, Order not done: Medical Reason" using "Medical Reason SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.473)"
    "Medication, Order not done: Patient Refusal" using "Patient Refusal SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.93)"
    "Procedure, Performed: Intravenous or Intra-arterial Thrombolytic (t-PA) Therapy" using "Intravenous or Intra-arterial Thrombolytic (t-PA) Therapy Grouping Value Set (2.16.840.1.113762.1.4.1045.21)"
    Attribute: "Principal diagnosis: Ischemic Stroke" using "Ischemic Stroke Grouping Value Set (2.16.840.1.113883.3.117.1.7.1.247)"
    Attribute: "Principal diagnosis: Hemorrhagic Stroke" using "Hemorrhagic Stroke Grouping Value Set (2.16.840.1.113883.3.117.1.7.1.212)"

Supplemental Data Elements

    "Patient Characteristic Ethnicity: Ethnicity" using "Ethnicity CDCREC Value Set (2.16.840.1.114222.4.11.837)"
    "Patient Characteristic Payer: Payer" using "Payer SOP Value Set (2.16.840.1.114222.4.11.3591)"
    "Patient Characteristic Race: Race" using "Race CDCREC Value Set (2.16.840.1.114222.4.11.836)"
    "Patient Characteristic Sex: ONC Administrative Sex" using "ONC Administrative Sex AdministrativeGender Value Set (2.16.840.1.113762.1.4.1)"
*/

codesystem "SNOMED-CT": ''
codesystem "RXNORM": ''

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'
valueset "Non-Elective Inpatient Encounter": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.424'
valueset "Comfort Measures": 'urn:oid:1.3.6.1.4.1.33895.1.3.0.45'
valueset "Antithrombotic Therapy": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.201'
valueset "Thrombolytic (t-PA) Therapy": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.226'
valueset "Medical Reason": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.473'
valueset "Patient Refusal": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.93'
valueset "Antithrombotic ingredient specific": 'urn:oid:2.16.840.1.113762.1.4.1021.8'
valueset "Intravenous or Intra-arterial Thrombolytic (t-PA) Therapy": 'urn:oid:2.16.840.1.113762.1.4.1045.21'
valueset "Ischemic Stroke": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.247'
valueset "Hemorrhagic Stroke": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.212'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
Data Criteria (QDM Variables)
*/

/*
  $EncounterInpatientNonElective =
      "Encounter, Performed: Non-Elective Inpatient Encounter" satisfies all:
          (length of stay <= 120 day(s))
          ends during "Measurement Period"
*/

define "Encounter Inpatient Non Elective":
  ["Encounter, Performed": "Non-Elective Inpatient Encounter"] E
    where E.lengthOfStay <= 120 days
      and E.relevantPeriod ends during "Measurement Period"

/*
  $InterventionComfortMeasures =
      Union of:
          "Intervention, Order: Comfort Measures"
          "Intervention, Performed: Comfort Measures"
*/

define "Intervention Comfort Measures":
  ["Intervention, Order": "Comfort Measures"]
    union (
      ["Intervention, Performed": "Comfort Measures"] P
        return "Intervention, Order" { 
          id: P.id,
          code: P.code,
          authorDatetime: Coalesce(start of P.relevantPeriod, P.authorDatetime)
        }
    )
    
define "Intervention Comfort Measures":
  ["Intervention, Order": "Comfort Measures"]
    union ["Intervention, Performed": "Comfort Measures"]

define "Intervention Comfort Measures During Measurement Period":
  "Intervention Comfort Measures" I
    where I.relevantPeriod during "Measurement Period"
    
define "Intervention Comfort Measures During Measurement Period":
  "Intervention Comfort Measures" I
    where I.authorDatetime during "Measurement Period"
    
define "Intervention Comfort Measures During Measurement Period":
  "Intervention Comfort Measures" I
    where Coalesce(start of I.relevantPeriod, I.authorDatetime) during "Measurement Period"
    
/*
Population Criteria
*/

/*
  Initial Population =
      AND: Age>= 18 year(s) at: Occurrence A of $EncounterInpatientNonElective
      AND:
          OR: Intersection of:
              Occurrence A of $EncounterInpatientNonElective
              "Encounter, Performed: Non-Elective Inpatient Encounter (principal diagnosis: Ischemic Stroke)"
          OR: Intersection of:
              Occurrence A of $EncounterInpatientNonElective
              "Encounter, Performed: Non-Elective Inpatient Encounter (principal diagnosis: Hemorrhagic Stroke)"
*/

define "Valid Encounter":
  "Encounter Inpatient Non Elective" E
    where E.principalDiagnosis in "Ischemic Stroke"
      or E.principalDiagnosis in "Hemorrhagic Stroke"
    where AgeInYearsAt(start of E.relevantPeriod) >= 18

define "Initial Population":
  "Valid Encounter" E
    where E.principalDiagnosis in "Ischemic Stroke"
      or E.principalDiagnosis in "Hemorrhagic Stroke"
    
/*
    Denominator =
        AND: Initial Population
        AND: Intersection of:
            Occurrence A of $EncounterInpatientNonElective
            "Encounter, Performed: Non-Elective Inpatient Encounter (principal diagnosis: Ischemic Stroke)"
*/

define "Encounter With Ischemic Stroke":
  "Valid Encounter" E
    where E.principalDiagnosis in "Ischemic Stroke"

define "Denominator":
  "Encounter With Ischemic Stroke"
  
/*
  Denominator Exclusions =
      OR:
          AND: Intersection of:
              Occurrence A of $EncounterInpatientNonElective
              "Encounter, Performed: Non-Elective Inpatient Encounter (length of stay < 2 day(s))"
          AND NOT: "Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatientNonElective
      OR: "Encounter, Performed: Emergency Department Visit" satisfies all:
          <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatientNonElective
          < 2 day(s) starts before end of Occurrence A of $EncounterInpatientNonElective
      OR:
          AND: "Occurrence A of Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatientNonElective
          AND:
              OR: Union of:
                  "Medication, Administered: Thrombolytic (t-PA) Therapy"
                  "Procedure, Performed: Intravenous or Intra-arterial Thrombolytic (t-PA) Therapy"
                  <= 24 hour(s) starts before start of "Occurrence A of Encounter, Performed: Emergency Department Visit"
              OR: "Medication, Administered: Thrombolytic (t-PA) Therapy" satisfies all:
                  starts after start of "Occurrence A of Encounter, Performed: Emergency Department Visit"
                  starts before end of Occurrence A of $EncounterInpatientNonElective
      OR: Union of:
          "Medication, Administered: Thrombolytic (t-PA) Therapy"
          "Procedure, Performed: Intravenous or Intra-arterial Thrombolytic (t-PA) Therapy"
          <= 24 hour(s) starts before start of Occurrence A of $EncounterInpatientNonElective
      OR: "Medication, Administered: Thrombolytic (t-PA) Therapy" starts during Occurrence A of $EncounterInpatientNonElective
      OR:
          AND: "Occurrence A of Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatientNonElective
          AND: $InterventionComfortMeasures <= 1 day(s) starts after start of "Occurrence A of Encounter, Performed: Emergency Department Visit"
      OR: $InterventionComfortMeasures <= 1 day(s) starts after start of $EncounterInpatientNonElective
*/

define "ED Visit":
  ["Encounter, Performed": "Emergency Department Visit"]
  
define "Encounter Less Than Two Days Without ED Visit":
  "Encounter With Ischemic Stroke" E
    without "ED Visit" ED
      such that ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod // TODO: Should be "before or on"
    where E.lengthOfStay < 2 days

define "Encounter With ED Visit Less Than Two Days":
  "Encounter With Ischemic Stroke" E
    with "ED Visit" ED
      such that ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod // TODO: Should be "before or on"
        and ED.relevantPeriod starts 2 days or less before end of E.relevantPeriod // TODO: Should be "less than 2 days"

define "Thrombolytic Medication":
  ["Medication, Administered": "Thrombolytic (t-PA) Therapy"]

define "Thrombolytic Therapy Medication Or Procedures":
  "Thrombolytic Medication"
    union (
      ["Procedure, Performed": "Intravenous or Intra-arterial Thrombolytic (t-PA) Therapy"] P
        return "Medication, Administered" {
          id: P.id,
          code: P.code,
          patientId: P.patientId,
          reporter: P.reporter,
          recorder: P.recorder,
          authorDatetime: P.authorDatetime,
          relevantPeriod: P.relevantPeriod
        }
    )

define "Encounter With ED Visit With Thrombolytic Therapy":
  from
    "Encounter With Ischemic Stroke" E,
    "ED Visit" ED,
    "Thrombolytic Therapy Medication Or Procedures" T
  where ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod // TODO: Should be "before or on"
    and T.relevantPeriod starts 24 hours or less before start of ED.relevantPeriod 
  return E
  
define "Encounter With ED Visit With Thrombolytic Medication":
  from
    "Encounter With Ischemic Stroke" E,
    "ED Visit" ED,
    "Thrombolytic Medication" M
  where ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod // TODO: Should be "before or on"
    and M.relevantPeriod starts after start of ED.relevantPeriod
    and M.relevantPeriod starts before end of E.relevantPeriod
  return E
  
define "Encounter With Thrombolytic Therapy":
  "Encounter With Ischemic Stroke" E
    with "Thrombolytic Therapy Medication Or Procedures" P
      such that P.relevantPeriod starts 24 hours or less before start of E.relevantPeriod
      
define "Encounter With Thrombolytic Medication":
  "Encounter With Ischemic Stroke" E
    with "Thrombolytic Medication" M
      such that M.relevantPeriod starts during E.relevantPeriod
      
define "Encounter With ED Visit With Comfort Measures":
  from
    "Encounter With Ischemic Stroke" E,
    "ED Visit" ED,
    "Intervention Comfort Measures" M
  where ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod // TODO: Should be "before or on"
    and M.authorDatetime 1 day or less after start of ED.relevantPeriod
  return E
    
define "Encounter With Comfort Measures":
  "Encounter With Ischemic Stroke" E
    with "Intervention Comfort Measures" M
      such that M.authorDatetime 1 day or less after start of E.relevantPeriod

define "Denominator Exclusions":
  "Encounter Less Than Two Days Without ED Visit"
    union "Encounter With ED Visit Less Than Two Days"
    union "Encounter With ED Visit With Thrombolytic Therapy"
    union "Encounter With ED Visit With Thrombolytic Medication"
    union "Encounter With Thrombolytic Therapy"
    union "Encounter With Thrombolytic Medication"
    union "Encounter With ED Visit With Comfort Measures"
    union "Encounter With Comfort Measures"

/*
    Numerator =
        AND:
            OR: "Medication, Administered: Antithrombotic Therapy" <= 1 day(s) starts after start of Occurrence A of $EncounterInpatientNonElective
            OR: "Encounter, Performed: Emergency Department Visit" satisfies all:
                <= 1 day(s) starts before start of "Medication, Administered: Antithrombotic Therapy"
                <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatientNonElective
*/

define "Encounter With Antithrombotic Therapy":
  "Encounter With Ischemic Stroke" E
    with ["Medication, Administered": "Antithrombotic Therapy"] M
      such that M.relevantPeriod starts 1 day or less after start of E.relevantPeriod
      
define "Encounter With ED Visit With Antithrombotic Therapy":
  from
    "Encounter With Ischemic Stroke" E,
    "ED Visit" ED
  where ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod // TODO: Should be "before or on"
    and exists (
      ["Medication, Administered": "Antithrombotic Therapy"] M 
        where M.relevantPeriod starts 1 day or less before start of ED.relevantPeriod
    )
  return E

define "Numerator":
  "Encounter With Antithrombotic Therapy"
    union "Encounter With ED Visit With Antithrombotic Therapy"

/*
    Numerator Exclusions =
        None
*/

/*
  Denominator Exceptions =
      OR:
          AND: "Occurrence A of Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatientNonElective
          AND: Union of:
              "Medication, Order not done: Medical Reason" for "Antithrombotic ingredient specific"
              "Medication, Administered not done: Medical Reason" for "Antithrombotic Therapy"
              "Medication, Order not done: Patient Refusal" for "Antithrombotic ingredient specific"
              "Medication, Administered not done: Patient Refusal" for "Antithrombotic Therapy"
              <= 1 day(s) starts after start of "Occurrence A of Encounter, Performed: Emergency Department Visit"
      OR:
          AND: Union of:
              "Medication, Order not done: Medical Reason" for "Antithrombotic ingredient specific"
              "Medication, Administered not done: Medical Reason" for "Antithrombotic Therapy"
              "Medication, Order not done: Patient Refusal" for "Antithrombotic ingredient specific"
              "Medication, Administered not done: Patient Refusal" for "Antithrombotic Therapy"
              <= 1 day(s) starts after start of Occurrence A of $EncounterInpatientNonElective
          AND NOT: "Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatientNonElective
*/

define "Antithrombotic Medication Not Ordered":
  ["Medication, Not Ordered": "Antithrombotic ingredient specific"] O
    where O.negationRationale in "Medical Reason"
      or O.negationRationale in "Patient Refusal"
      
define "Antithrombotic Medication Not Administered":
  ["Medication, Not Administered": "Antithrombotic Therapy"] M
    where M.negationRationale in "Medical Reason"
      or M.negationRationale in "Patient Refusal"
      
define "Antithrombotic Medication Not Ordered Or Administered":
  distinct (
    "Antithrombotic Medication Not Ordered"
      union (
          "Antithrombotic Medication Not Administered" M
            return "Medication, Not Ordered" {
              id: M.id,
              code: M.code,
              patientId: M.patientId,
              reporter: M.reporter,
              recorder: M.recorder,
              authorDatetime: start of M.relevantPeriod
            }
      )
  )

define "Encounter Without ED Visit With Antithrombotic Negated":
  "Encounter With Ischemic Stroke" E
    without "ED Visit" ED
      such that ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod // TODO: Should be "before or on"
    with "Antithrombotic Medication Not Ordered Or Administered" M
      such that M.authorDatetime 1 day or less after start of E.relevantPeriod
      
define "Encounter With ED Visit With Antithrombotic Negated":
  from
    "Encounter With Ischemic Stroke" E,
    "ED Visit" ED
  where ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod // TODO: Should be "before or on"
    and exists (
      "Antithrombotic Medication Not Ordered Or Administered" M 
        where M.authorDatetime 1 day or less after start of ED.relevantPeriod
    )
  return E
      
/*
    Stratification =
        None
*/

/*
Risk Adjustment Variables

    None
*/