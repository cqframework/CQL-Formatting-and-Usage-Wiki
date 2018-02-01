library ZZ_AnnualWellnessAssessmentMeasure_PatientLinearCombination

using QDM

include 01_ScreeningForAlcoholMisuse called "Screening For Alcohol Misuse"
include 02_HypertensionAssessment called "Hypertension Assessment"
include 03_ScreeningForBreastCancer called "Screening For Breast Cancer"
include 04_ScreeningForColorectalCancer called "Screening For Colorectal Cancer"
include 05_ScreeningForDepression called "Screening For Depression"

parameter "Measurement Period" Interval<DateTime>

context Patient

// Modeled as a continuous variable measure where the observation is the proportion
// of component measures for which the patient is in the numerator

define "Initial Population":
  // Return Patient Characteristic as an element that is guaranteed to have a single return for each patient
  // This is a workaround for the fact that continuous variable measures cannot be defined on Patient-based
  // populations (i.e. populations that return true/false) due to CQL-Based HQMF IG Conformance Requirement 13.
  ["Patient Characteristic: Birthdate"] P
    // True if any initial population is true
    where "Screening For Alcohol Misuse"."Initial Population"
      or "Hypertension Assessment"."Initial Population"
      or "Screening For Breast Cancer"."Initial Population"
      or "Screening For Colorectal Cancer"."Initial Population"
      or "Screening For Depression"."Initial Population"

define "Measure Population":
  ["Patient Characteristic: Birthdate"] P
  // True if any denominator is true
    where "Screening For Alcohol Misuse"."Denominator"
      or "Hypertension Assessment"."Denominator"
      or "Screening For Breast Cancer"."Denominator"
      or "Screening For Colorectal Cancer"."Denominator"
      or "Screening For Depression"."Denominator"
    
define "Denominator Score":
  if "Screening For Alcohol Misuse"."Initial Population" and "Screening For Alcohol Misuse"."Denominator" then 1 else 0
    + if "Hypertension Assessment"."Initial Population" and "Hypertension Assessment"."Denominator" then 1 else 0
    + if "Screening For Breast Cancer"."Initial Population" and "Screening For Breast Cancer"."Denominator" then 1 else 0
    + if "Screening For Colorectal Cancer"."Initial Population" and "Screening For Colorectal Cancer"."Denominator" then 1 else 0
    + if "Screening For Depression"."Initial Population" and "Screening For Depression"."Denominator" then 1 else 0

define "Numerator Score":
  if "Screening For Alcohol Misuse"."Initial Population" and "Screening For Alcohol Misuse"."Denominator" and "Screening For Alcohol Misuse"."Numerator" then 1 else 0
    + if "Hypertension Assessment"."Initial Population" and "Hypertension Assessment"."Denominator" and "Hypertension Assessment"."Numerator" then 1 else 0
    + if "Screening For Breast Cancer"."Initial Population" and "Screening For Breast Cancer"."Denominator" and "Screening For Breast Cancer"."Numerator" then 1 else 0
    + if "Screening For Colorectal Cancer"."Initial Population" and "Screening For Colorectal Cancer"."Denominator" and "Screening For Colorectal Cancer"."Numerator" then 1 else 0
    + if "Screening For Depression"."Initial Population" and "Screening For Depression"."Denominator" and "Screening For Depression"."Numerator" then 1 else 0

define "Measure Observation"(PatientCharacteristic "Patient Characteristic: Birthdate"):
  "Numerator Score" / "Denominator Score"
