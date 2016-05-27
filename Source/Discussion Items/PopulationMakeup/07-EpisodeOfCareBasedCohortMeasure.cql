library EpisodeOfCareBasedCohortMeasure version '1'

using QDM

valueset "Inpatient": 'X.Y.Z.1'

parameter "Measurement Period" Interval<DateTime>

/*
  For non-patient-based cohort measures, the initial population may return
  any type.
*/

define "Initial Population":
  ["Encounter, Performed": "Inpatient"] Encounter
    where Encounter.startDateTime during "Measurement Period"
