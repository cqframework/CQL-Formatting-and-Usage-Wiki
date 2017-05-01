// Numerator with Procedure, Procedure not done, and discharge status on Encounter (CMS102)

library CMS102

using QDM version '5.0'

valueset "Rehabilitation Assessment": 'Rehabilitation Assessment'
valueset "Rehabilitation Therapy": 'Rehabilitation Therapy'
valueset "Patient Refusal": 'Patient Refusal'
valueset "Medical Reason": 'Medical Reason'
valueset "Non-Elective Inpatient Encounter": 'Non-Elective Inpatient Encounter'
valueset "Discharged to Rehabilitation Facility": 'Discharged to Rehabilitation Facility'

parameter "Measurement Period" Interval<DateTime>

define "Encounter Inpatient Non Elective":
  ["Encounter, Performed": "Non-Elective Inpatient Encounter"] Encounter
    where Encounter.lengthOfStay <= 120 days
      and Encounter.relevantPeriod ends during "Measurement Period"

define "Rehabilitation Assessment Or Not":
  distinct (
    ["Procedure, Performed": "Rehabilitation Assessment"]
      union ["Procedure, Performed": "Rehabilitation Therapy"]
      union (
        ["Procedure, Not Performed": "Rehabilitation Assessment"] Procedure
          where Procedure.negationRationale in "Patient Refusal"
            or Procedure.negationRationale in "Medical Reason"
      )
  )

define "Numerator":
  distinct (
    ("Encounter Inpatient Non Elective" Encounter
      with "Rehabilitation Assessment Or Not" Assessment
        such that Assessment.relevantPeriod starts during Encounter.relevantPeriod)
    union
      "Encounter Inpatient Non Elective" Encounter
        where Encounter.dischargeDisposition in "Discharged to Rehabilitation Facility"
  )

/*
Numerator =
  AND:
    OR: Union of:
      "Procedure, Performed: Rehabilitation Assessment"
      "Procedure, Performed: Rehabilitation Therapy"
      "Procedure, Performed not done: Patient Refusal" for "Rehabilitation Assessment"
      "Procedure, Performed not done: Medical Reason" for "Rehabilitation Assessment"
      starts during Occurrence A of $EncounterInpatientNonElective
    OR: Intersection of:
      Occurrence A of $EncounterInpatientNonElective
      "Encounter, Performed: Non-Elective Inpatient Encounter (discharge status: Discharged to Rehabilitation Facility)"

$EncounterInpatientNonElective =
  "Encounter, Performed: Non-Elective Inpatient Encounter" satisfies all:
    (length of stay <= 120 day(s))
    ends during "Measurement Period"
*/
