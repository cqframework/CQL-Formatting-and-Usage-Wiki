// Numerator with Substance and Denominator Exclusion with discharge status and facility location (CMS9)

library CMS9

using QDM version '5.0'

valueset "Encounter Inpatient": 'Encounter Inpatient'
valueset "Neonatal Intensive Care Unit (NICU)": 'Neonatal Intensive Care Unit (NICU)'
valueset "Patient Expired": 'Patient Expired'
valueset "Discharge To Acute Care Facility": 'Discharge To Acute Care Facility'
valueset "Breast Milk": 'Breast Milk'
valueset "Dietary Intake Other than Breast Milk": 'Dietary Intake Other than Breast Milk'

parameter "Measurement Period" Interval<DateTime>

/*
Denominator Exclusions =
  OR: Intersection of:
    Occurrence A of $EncounterInpatient
    "Encounter, Performed: Encounter Inpatient" satisfies any:
      (facility location: Neonatal Intensive Care Unit (NICU))
      (discharge status: Patient Expired)
      (discharge status: Discharge To Acute Care Facility)

Numerator =
  AND: "Substance, Administered: Breast Milk" starts during Occurrence A of $EncounterInpatient
  AND NOT: "Substance, Administered: Dietary Intake Other than Breast Milk" starts during Occurrence A of $EncounterInpatient

$EncounterInpatient =
  "Encounter, Performed: Encounter Inpatient" satisfies all:
    (length of stay <= 120 day(s))
    ends during "Measurement Period"
*/
