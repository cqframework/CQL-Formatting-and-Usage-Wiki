// Denominator Exclusion with multiple discharge statuses (CMS104)

library CMS104

using QDM version '5.0'

valueset "Non-Elective Inpatient Encounter": 'Non-Elective Inpatient Encounter'
valueset "Discharge To Actue Care Facility": 'Discharge To Actue Care Facility'
valueset "Left Against Medical Active": 'Left Against Medical Active'
valueset "Patient Expired": 'Patient Expired'
valueset "Discharged to Home for Hospice Care": 'Discharged to Home for Hospice Care'
valueset "Discharged to Health Care Facility for Hospice Care": 'Discharged to Health Care Facility for Hospice Care'
valueset "Emergency Department Visit": 'Emergency Department Visit'

parameter "Measurement Period" Interval<DateTime>

/*
Denominator Exclusions =
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

$EncounterInpatientNonElective =
  "Encounter, Performed: Non-Elective Inpatient Encounter" satisfies all:
    (length of stay <= 120 day(s))
    ends during "Measurement Period"
*/
