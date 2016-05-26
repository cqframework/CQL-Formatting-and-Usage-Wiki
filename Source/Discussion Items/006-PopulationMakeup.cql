/*
Initial Population =
    AND: Age >= 5 year(s) at: "Measurement Period"
    AND: Age < 64 year(s) at: "Measurement Period"
    AND: "Diagnosis, Active: Persistent Asthma" overlaps "Measurement Period"
    AND: Union of:
        "Encounter, Performed: Office Visit"
        "Encounter, Performed: Face-to-Face Interaction"
        "Encounter, Performed: Preventive Care - Established Office Visit, 0 to 17"
        "Encounter, Performed: Preventive Care Services - Established Office Visit, 18 and Up"
        "Encounter, Performed: Preventive Care Services-Initial Office Visit, 18 and Up"
        "Encounter, Performed: Preventive Care- Initial Office Visit, 0 to 17"
        "Encounter, Performed: Home Healthcare Services"
        during "Measurement Period"

Denominator =
    AND: Initial Population

Denominator Exclusions =
    OR: Union of:
        "Diagnosis, Active: Chronic Obstructive Pulmonary Disease"
        "Diagnosis, Active: Emphysema"
        "Diagnosis, Active: Cystic Fibrosis"
        "Diagnosis, Active: Acute Respiratory Failure"
        overlaps "Measurement Period"

Numerator =
    AND: "Medication, Dispensed: Preferred Asthma Therapy" during "Measurement Period"

Numerator Exclusions =
    None

Denominator Exceptions =
    None
*/

define "In Demographic":
  AgeInYearsAt(start of "Measurement Period") >= 5
    and AgeInYearsAt(start of "Measurement Period") < 65

define "Asthma Diagnosis":
  ["Diagnosis": "Persistent Asthma"] Diagnosis
    where Interval[Diagnosis.onsetDatetime, Diagnosis.abatementDatetime] overlaps "Measurement Period"

define "Valid Encounters":
  (["Encounter, Performed": "Office Visit"]
    union ["Encounter, Performed": "Face-to-Face Interaction"]
    union ["Encounter, Performed": "Preventive Care - Established Office Visit, 0 to 17"]
    union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
    union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
    union ["Encounter, Performed": "Preventive Care- Initial Office Visit, 0 to 17"]
    union ["Encounter, Performed": "Home Healthcare Services"]
  ) E where Interval[E.admissionDateTime, E.dischargeDateTime] during "Measurement Period"

define "In Initial Population":
  "In Demographic"
    and exists "Asthma Diagnosis"
    and exists "Valid Encounters"

define "In Denominator":
  "In Initial Population" // Can repeat the condition, or omit the definition as implied by the structure of the measure

define "Exclusionary Diagnoses":
  (["Diagnosis": "Chronic Obstructive Pulmonary Disease"]
    union ["Diagnosis": "Emphysema"]
    union ["Diagnosis": "Cystic Fibrosis"]
    union ["Diagnosis": "Actue Repiratory Failure"]
  ) Diagnosis where Interval[Diagnosis.onsetDatetime, Diagnosis.abatementDatetime] overlaps "Measurement Period"

define "Denominator Exceptions":
  exists "Exclusionary Diagnoses"

define "Preferred Asthma Therapy":
  ["Medication, Dispensed": "Preferred Asthma Therapy"] Medication
    where Interval[Medication.startDatetime, Medication.stopDateTime] during "Measurement Period"

define "Numerator":
  exists "Preferred Asthma Therpay"


/*
  For consistency across all measure types, population expressions will
  be named based on the type of population:

  "Initial Population"
  "Denominator"
  "Numerator"
  ...

  We will document for each type of measure and population what the expected
  type of the result is for that population. e.g. A patient-based population
  expression should return a single value of type Boolean

*/

// Patient-based Initial Population
define "Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 20

// Episode-of-care Numerator:
define "Numerator":
  "Encounters With Procedure"


/*
  Proportion Measure
    Initial Population
    Denominator
    Denominator Exclusion
    Denominator Exception
    Numerator
    Numerator Exclusion
*/

/* Patient-based Measures, all criteria must return true or false*/
define "Measure Score":
  Count(
      "Initial Population"
        and "Denominator"
        and not "Denominator Exclusion"
        and "Numerator"
        and not "Numerator Exclusion"
  ) /
    Count(
      "Initial Population"
        and "Denominator"
        and not "Denominator Exclusion"
        and not ("Denominator Exception" and not "Numerator")
    )


/* Episode-of-care measures, all criteria must return the same type */
define "Measure Score":
  Count(
    "Initial Population"
      intersect "Denominator"
      except "Denominator Exclusion"
      intersect "Numerator"
      except "Numerator Exclusion"
  ) /
    Count(
      "Initial Population"
        intersect "Denominator"
        except "Denominator Exclusion"
        except ("Denoinator Exception" except "Numerator")
    )

/*
  Ratio Measure
    Initial Population
    Denominator
    Denominator Exclusion
    Numerator
    Numerator Exclusion
*/

/* Patient-based Measures, all criteria must return true or false */
define "Measure Ratio Numerator":
  Count(
      "Initial Population"
        and "Denominator"
        and not "Denominator Exclusion"
        and "Numerator"
        and not "Numerator Exclusion"
  )

define "Measure Ratio Denominator":
    Count(
      "Initial Population"
        and "Denominator"
        and not "Denominator Exclusion"
    )

/* Episode-of-care measures, all criteria must return the same type */
define "Measure Ratio Denominator":
  Count(
    "Initial Population"
      intersect "Denominator"
      except "Denominator Exclusion"
  )

define "Measure Ratio Numerator":
  Count(
    "Initial Population"
      intersect "Denominator"
      except "Denominator Exclusion"
      intersect "Numerator"
      except "Numerator Exclusion"
  )

/*
  Continuous Variable Measure
    Initial Population
    Measure Population
    Measure Population Exclusion
    Measure Observation
*/

/* Measure Observation is specified in terms of the type of elements in the Measure Population */
/* Measure criteria must return the same type (list of elements to be counted)*/
/* See CMS55v1_QDM.cql */

/*
  Cohort Measure
    Initial Population
*/

/* Patient-based, criteria must return true/false */
/* Otherwise, "cohort" members are the type of the result */
