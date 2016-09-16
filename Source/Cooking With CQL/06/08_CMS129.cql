// Variable definition with Most Recent and attributes (CMS129)

library CMS129

using QDM version '5.0'

valueset "Cancer Staging": 'Cancer Staging'

parameter "Measurement Period" Interval<DateTime>

/*
$MostRecentPrCaCancerStaging =
  "Procedure, Performed: Cancer Staging" satisfies all:
    Most Recent: starts before start of $FirstProstateCancerTreatment
    satisfies any:
      (result: Prostate Cancer Primary Tumor Size T1a)
      (result: Prostate Cancer Primary Tumor Size T1b)
      (result: Prostate Cancer Primary Tumor Size T1c)
      (result: Prostate Cancer Primary Tumor Size T2a)
*/
