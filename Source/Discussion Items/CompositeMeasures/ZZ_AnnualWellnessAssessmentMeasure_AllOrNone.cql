library ZZ_AnnualWellnessAssessmentMeasure_AllOrNone

using QDM

include 01_ScreeningForAlcoholMisuse called "Screening For Alcohol Misuse"
include 02_HypertensionAssessment called "Hypertension Assessment"
include 03_ScreeningForBreastCancer called "Screening For Breast Cancer"
include 04_ScreeningForColorectalCancer called "Screening For Colorectal Cancer"
include 05_ScreeningForDepression called "Screening For Depression"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population":
  if (
    "Screening For Alcohol Misuse"."Initial Population"
      and "Hypertension Assessment"."Initial Population"
      and "Screening For Breast Cancer"."Initial Population"
      and "Screening For Colorectal Cancer"."Initial Population"
      and "Screening For Depression"."Initial Population"
  ) then 1
    else 0

define "Denominator":
  if (
    "Screening For Alcohol Misuse"."Initial Population" and "Screening For Alcohol Misuse"."Denominator"
      and "Hypertension Assessment"."Initial Population" and "Hypertension Assessment"."Denominator"
      and "Screening For Breast Cancer"."Initial Population" and "Screening For Breast Cancer"."Denominator"
      and "Screening For Colorectal Cancer"."Initial Population" and "Screening For Colorectal Cancer"."Denominator"
      and "Screening For Depression"."Initial Population" and "Screening For Depression"."Denominator"
  ) then 1
    else 0

define "Numerator":
  if (
    "Screening For Alcohol Misuse"."Initial Population" and "Screening For Alcohol Misuse"."Denominator" and "Screening For Alcohol Misuse"."Numerator"
      and "Hypertension Assessment"."Initial Population" and "Hypertension Assessment"."Denominator" and "Hypertension Assessment"."Numerator"
      and "Screening For Breast Cancer"."Initial Population" and "Screening For Breast Cancer"."Denominator" and "Screening For Breast Cancer"."Numerator"
      and "Screening For Colorectal Cancer"."Initial Population" and "Screening For Colorectal Cancer"."Denominator" and "Screening For Colorectal Cancer"."Numerator"
      and "Screening For Depression"."Initial Population" and "Screening For Depression"."Denominator" and "Screening For Depression"."Numerator"
  ) then 1
    else 0

context Population

define "Measure Score":
  Sum("Numerator") / Sum("Denominator")
