library ZZ_AnnualWellnessAssessmentMeasure_LinearCombination

using QDM

include 01_ScreeningForAlcoholMisuse called "Screening For Alcohol Misuse"
include 02_HypertensionAssessment called "Hypertension Assessment"
include 03_ScreeningForBreastCancer called "Screening For Breast Cancer"
include 04_ScreeningForColorectalCancer called "Screening For Colorectal Cancer"
include 05_ScreeningForDepression called "Screening For Depression"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population":
  if "Screening For Alcohol Misuse"."Initial Population" then 1 else 0
    + if "Hypertension Assessment"."Initial Population" then 1 else 0
    + if "Screening For Breast Cancer"."Initial Population" then 1 else 0
    + if "Screening For Colorectal Cancer"."Initial Population" then 1 else 0
    + if "Screening For Depression"."Initial Population" then 1 else 0

define "Denominator":
  if "Screening For Alcohol Misuse"."Initial Population" and "Screening For Alcohol Misuse"."Denominator" then 1 else 0
    + if "Hypertension Assessment"."Initial Population" and "Hypertension Assessment"."Denominator" then 1 else 0
    + if "Screening For Breast Cancer"."Initial Population" and "Screening For Breast Cancer"."Denominator" then 1 else 0
    + if "Screening For Colorectal Cancer"."Initial Population" and "Screening For Colorectal Cancer"."Denominator" then 1 else 0
    + if "Screening For Depression"."Initial Population" and "Screening For Depression"."Denominator" then 1 else 0

define "Numerator":
  if "Screening For Alcohol Misuse"."Initial Population" and "Screening For Alcohol Misuse"."Denominator" and "Screening For Alcohol Misuse"."Numerator" then 1 else 0
    + if "Hypertension Assessment"."Initial Population" and "Hypertension Assessment"."Denominator" and "Hypertension Assessment"."Numerator" then 1 else 0
    + if "Screening For Breast Cancer"."Initial Population" and "Screening For Breast Cancer"."Denominator" and "Screening For Breast Cancer"."Numerator" then 1 else 0
    + if "Screening For Colorectal Cancer"."Initial Population" and "Screening For Colorectal Cancer"."Denominator" and "Screening For Colorectal Cancer"."Numerator" then 1 else 0
    + if "Screening For Depression"."Initial Population" and "Screening For Depression"."Denominator" and "Screening For Depression"."Numerator" then 1 else 0

define "Patient Score":
  Sum("Numerator") / Sum("Denominator")

context Population

define "Measure Score":
  Avg("Patient Score")
