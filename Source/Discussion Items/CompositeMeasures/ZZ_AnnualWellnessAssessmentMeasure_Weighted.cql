library ZZ_AnnualWellnessAssessmentMeasure_Weigthed

using QDM

include 01_ScreeningForAlcoholMisuse called "Screening For Alcohol Misuse"
include 02_HypertensionAssessment called "Hypertension Assessment"
include 03_ScreeningForBreastCancer called "Screening For Breast Cancer"
include 04_ScreeningForColorectalCancer called "Screening For Colorectal Cancer"
include 05_ScreeningForDepression called "Screening For Depression"

parameter "Measurement Period" Interval<DateTime>

context Population

// Take the average of the weigthed measure scores

define "Measure Score":
  ("Screening For Alcohol Misuse"."Measure Score" * "Screening for Alcohol Misuse Weigthing Factor"
    + "Hypertension Assessment"."Measure Score" * "Hypertension Assessment Weighting Factor"
    + "Screening for Breast Cancer"."Measure Score" * "Screening for Breast Cancer Weighting Factor"
    + "Screening for Colorectal Cancer"."Measure Score" * "Screening for Colorectal Cancer Weigthing Factor"
    + "Screening for Depression"."Measure Score" * "Screening for Depression Weigthing Factor")
    / 5

