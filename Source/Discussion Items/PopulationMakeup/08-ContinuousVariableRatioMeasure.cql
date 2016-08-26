library ContinuousVariableRatioMeasure version '1'

using QDM

valueset "Inpatient": 'X.Y.Z.1'
valueset "AMI": 'X.Y.Z.3'
valueset "Patient Expired": 'X.Y.Z.4'
valueset "Statin": 'X.Y.Z.5'

parameter "Measurement Period" Interval<DateTime>

/*
  For continuous variable ratio measures, each criteria must return the
  same type. The type can be any data element, such as an Encounter, Procedure,
  or Medication.

  The Measure Observation is defined in the same way as a continuous variable
  measure, and the aggregation method is described in the HQMF.

  The measure score is described in the population context section below.
*/

context Patient

define "Valid Encounter":
  ["Encounter, Performed": "Inpatient"] Encounter
    where Encounter.startDateTime during "Measurement Period"

define "Initial Population":
  "Valid Encounter" Encounter
    where AgeInYearsAt(Encounter.startDateTime) >= 18

define "Denominator":
  "Valid Encounter" Encounter
    with ["Diagnosis": "AMI"] AMIDiagnosis
      such that AMIDiagnosis.startDateTime <= Encounter.startDateTime

define "Denominator Exclusion":
  "Valid Encounter" Encounter
    where Encounter.dischargeStatus in "Patient Expired"

define "Numerator":
  "Valid Encounter" Encounter
    with ["Medication, Discharge": "Statin"] Medication
      such that Medication.startDateTime >= Encounter.startDateTime

define "Numerator Exclusion": "Valid Encounter" Encounter where false

// Measure score definition starts here
// NOTE: This is the formal description of the measure score calculation for
// this type of measure. It is the same for all measures of this type, and is
// provided here for reference. It is NOT expected that this calculation be
// included in each measure, with the exception that for when a measure
// observation is included in a ratio measure, the aggregation method is
// specified in the HQMF to indicate how to measure observations for each
// criteria are to be aggregated.

define function "Measure Observation"(Encounter "Encounter, Performed")
	return minutes between Encounter.facilityLocationArrivalDatetime and Encounter.facilityLocationDepartureDatetime

define "Numerator Membership":
    "Initial Population"
      intersect "Numerator"
      except "Numerator Exclusion"

define "Denominator Membership":
    "Initial Population"
      intersect "Denominator"
      except "Denominator Exclusion"

context Population

define "Measure Score Numerator":
  Avg("Numerator Membership" Numerator return "Measure Observation"(Numerator))

define "Measure Score Denominator":
  Avg("Denominator Membership" Denominator return "Measure Observation"(Denominator)
