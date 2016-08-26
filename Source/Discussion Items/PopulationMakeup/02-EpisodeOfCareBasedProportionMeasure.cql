library EpisodeOfCareBasedProportionMeasure version '1'

using QDM

valueset "Inpatient": 'X.Y.Z.1'
valueset "AMI": 'X.Y.Z.3'
valueset "Patient Expired": 'X.Y.Z.4'
valueset "Statin": 'X.Y.Z.5'

parameter "Measurement Period" Interval<DateTime>

/*
  For non-patient-based proportion measures, each criteria must return the
  same type. The type can be any data element, such as an Encounter, Procedure,
  or Medication.

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

define "Denominator Exception": "Valid Encounter" Encounter where false

define "Numerator":
  "Valid Encounter" Encounter
    with ["Medication, Discharge": "Statin"] Medication
      such that Medication.startDateTime >= Encounter.startDateTime

define "Numerator Exclusion": "Valid Encounter" Encounter where false

// Measure score definition starts here
// NOTE: This is the formal description of the measure score calculation for
// this type of measure. It is the same for all measures of this type, and is
// provided here for reference. It is NOT expected that this calculation be
// included in each measure.

define "Numerator Membership":
  "Initial Population"
    intersect "Denominator"
    except "Denominator Exclusion"
    intersect "Numerator"
    except "Numerator Exclusion"

define "Denominator Membership":
  "Initial Population"
    intersect "Denominator"
    except "Denominator Exclusion"
    except ("Denominator Exception" except "Numerator")

context Population

define "Measure Score":
  Count("Numerator Membership") /
    Count("Denominator Membership")
