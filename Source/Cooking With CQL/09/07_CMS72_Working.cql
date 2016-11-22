// Denominator Exception (CMS72)

library CMS72

using QDM version '5.0'

valueset "Emergency Department Visit": 'Emergency Department Visit'
valueset "Medical Reason": 'Medical Reason'
valueset "Antithrombotic ingredient specific": 'Antithrombotic ingredient specific'
valueset "Antithrombotic Therapy": 'Antithrombotic Therapy'
valueset "Patient Refusal": 'Patient Refusal'
valueset "Antithrombotic ingredient specific": 'Antithrombotic ingredient specific'
valueset "Antithrombotic Therapy": 'Antithrombotic Therapy'
valueset "Emergency Department Visit": 'Emergency Department Visit'
valueset "Non-Elective Inpatient Encounter": 'Non-Elective Inpatient Encounter'

parameter "Measurement Period" Interval<DateTime>

/*
Denominator Exceptions =
  OR:
    AND: "Occurrence A of Encounter, Performed: Emergency Department Visit"
      <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatientNonElective
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
    AND NOT: "Encounter, Performed: Emergency Department Visit"
      <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatientNonElective

$EncounterInpatientNonElective =
  "Encounter, Performed: Non-Elective Inpatient Encounter" satisfies all:
    (length of stay <= 120 day(s))
    ends during "Measurement Period"
*/

define "Encounter Inpatient Non-Elective":
  ["Encounter, Performed": "Non-Elective Inpatient Encounter"] Encounter
    where Encounter.lengthOfStay <= 120 days
      and Encounter.relevantPeriod ends during "Measurement Period"

define "Antithrombotic Not Ordered":
  ["Medication, Not Ordered": "Antithrombotic ingredient specific"] Medication
    where Medication.negationRationale in "Medical Reason"
      or Medication.negationRationale in "Patient Refusal"

define "Antithrombotic Not Administered":
  ["Medication, Not Administered": "Antithrombotic Therapy"] Medication
    where Medication.negationRationale in "Medical Reason"
      or Medication.negationRationale in "Patient Refusal"

define "Antithrombotic Not Done":
  "Antithrombotic Not Ordered"
    union "Antithrombotic Not Administered"

define "Antithrombotic Not Done During Associated Emergency Encounter":
  "Encounter Inpatient Non-Elective" Encounter
    with (
      ["Encounter, Performed": "Emergency Department Visit"] EmergencyVisit
        with "Antithrombotic Not Done" Medication
          such that Medication.authorDatetime 1 day or less after start of EmergencyVisit.relevantPeriod
      ) EmergencyVisit
        such that EmergencyVisit.relevantPeriod ends 1 hour or less before start of Encounter.relevantPeriod

define "Antithrombotic Not Done Without Associated Emergency Encounter":
  "Encounter Inpatient Non-Elective" Encounter
    with "Antithrombotic Not Done" Medication
      such that Medication.authorDatetime 1 day or less after start of Encounter.relevantPeriod
    without ["Encounter, Performed": "Emergency Department Visit"] EmergencyVisit
      such that EmergencyVisit.relevantPeriod ends 1 hour or less before start of Encounter.relevantPeriod

define "Denominator Exceptions":
  "Antithrombotic Not Done During Associated Emergency Encounter"
    union "Antithrombotic Not Done Without Associated Emergency Encounter"
