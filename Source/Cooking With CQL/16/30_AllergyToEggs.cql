library AllergyToEggs

using QDM version '5.0.2'

valueset "Allergy to Eggs": 'X.Y.Z'

parameter "Measurement Period" Interval<DateTime>

/*
  QDM:
    OR:
      AND: "Occurrence A of Diagnosis: Allergy to Eggs" overlaps "Measurement Period"
      AND NOT: "Occurrence A of Diagnosis: Allergy to Eggs" > 89 day(s) starts after start of "Measurement Period"
      AND NOT: "Occurrence A of Diagnosis: Allergy to Eggs" <= 89 day(s) ends after start of "Measurement Period"
*/

// NOTE: The issue here is that the "not" is being invoked around both conditions, which changes the logic
define "Allergy to Eggs Diagnosis (1)": ["Diagnosis": "Allergy to Eggs"] Dx
    where Dx.prevalencePeriod overlaps "Measurement Period"
        and not (Dx.prevalencePeriod starts 90 days or more after start of "Measurement Period" 
          and Dx.prevalencePeriod ends 89 days or less after start of "Measurement Period")


// NOTE: The issue here is that the "not" has a higher precendence than the timing phrases, so it is
// being applied to the "Dx.prevalencePeriod" rather than to the conditions, so we get the error:
// Could not resolve call to operator Not with signature (interval<System.DateTime>)
define "Allergy to Eggs Diagnosis (2)":  ["Diagnosis": "Allergy to Eggs"] Dx
    where Dx.prevalencePeriod overlaps "Measurement Period"
        and not Dx.prevalencePeriod starts 90 days or more after start of "Measurement Period"
        and not Dx.prevalencePeriod ends 89 days or less after start of "Measurement Period"

// NOTE: So the correction is to use parentheses to force the "not" to apply to the conditions
// Note also that as of CQL 1.2, we can use "more than 89 days"
define "Allergy to Eggs Diagnosis (3)":
  ["Diagnosis": "Allergy to Eggs"] Dx
    where Dx.prevalencePeriod overlaps "Measurement Period"
      and not (Dx.prevalencePeriod starts more than 89 days after start of "Measurement Period")
      and not (Dx.prevalencePeriod ends 89 days or less after start of "Measurement Period")
      
