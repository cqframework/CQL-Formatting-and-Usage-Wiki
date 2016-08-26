library PatientBasedRatioMeasure version '1'

using QDM

valueset "Inpatient": 'X.Y.Z.1'
valueset "DepressionAssessment": 'X.Y.Z.2'

parameter "Measurement Period" Interval<DateTime>

/*
  For patient-based ratio measures, each criteria must return true or false (or null).

  The measure score calculation is described by the "Denominator Membership",
  "Numerator Membership" and "Measure Ratio Numerator" and "Measure Ratio Denominator"
  expressions.
*/

context Patient

define "Initial Population": AgeInYearsAt(start of "Measurement Period") >= 18
define "Denominator":
  exists (
    ["Encounter, Performed": "Inpatient"] Encounter
      where Encounter.startDateTime during "Measurement Period"
  )

define "Denominator Exclusion": false
define "Numerator":
  exists (
    ["Procedure, Performed": "Depression Assessment"] Procedure
      where Procedure.startDateTime during "Measurement Period"
  )

define "Numerator Exclusion": false

// Measure score definition starts here
// NOTE: This is the formal description of the measure score calculation for
// this type of measure. It is the same for all measures of this type, and is
// provided here for reference. It is NOT expected that this calculation be
// included in each measure.

define "Denominator Membership":
  "Initial Population"
    and "Denominator"
    and not "Denominator Exclusion"

define "Numerator Membership":
  "Initial Population"
    and "Numerator"
    and not "Numerator Exclusion"

context Population

define "Measure Ratio Numerator":
  Count("Numerator Membership" IsMember where IsMember is true)

define "Measure Ratio Denominator":
  Count("Denominator Membership" IsMember where IsMember is true)
