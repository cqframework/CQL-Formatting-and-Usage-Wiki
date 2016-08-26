library PatientBasedCohortMeasure version '1'

using QDM

parameter "Measurement Period" Interval<DateTime>

/*
  For patient-based cohort definitions, the initial population criteria
  must return true or false (or null)
*/

context Patient

define "Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 18
