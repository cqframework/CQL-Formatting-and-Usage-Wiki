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
