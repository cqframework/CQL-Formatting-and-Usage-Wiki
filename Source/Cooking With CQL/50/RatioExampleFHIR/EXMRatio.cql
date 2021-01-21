library EXMRatio

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

include MATGlobalCommonFunctions version '5.0.000' called Global

/*
Measures the number of inpatient falls with major injury per 1000 patient days.

“Patient days” are to be calculated such that:
  Sum actual hours for all patients, whether in-patient, ED or observation, and divide by 24.

The approach we envision is starting from an encounter-based eCQM with numerator
and denominator observations to arrive at the following:

Patient A has a 10 day inpatient encounter. On day 1 she fell 9 times. No more falls in that stay.

Patient B has a 2 day inpatient encounter. On day 2 he fell 1 time. No other falls in that stay

Result: 10 falls/12 days = 833/1000 patient days
*/

/*
Answer: There are multiple considerations involved in the representation of falls with major injury,
this example does not address those considerations, focusing only on the overall structure
of the measure and the final calculation.

This measure can be represented as an encounter-based ratio measure, with:

Numerator Observation: Count(Falls with Major Injury)
Denominator Observation: Sum(Encounter Days)

This does result in a ratio, but there isn't mechanism in the current FHIR measure
to specify that the ratio should be converted to "per 1000 days".

To support that aspect, we are proposing an extension of the Quality Measure IG
to state the expected units of a ratio measure.

This is submitted as a tracker to the quality measure IG here:
https://jira.hl7.org/browse/FHIR-30506

The included EXMRatioFHIRv603-Artifacts.zip is an export of this measure expressed
in the MAT which includes everything but the proprosed unitScoring extension. That
extension is proposed for inclusion in the May 2021 ballot of the quality measure ig
and is not supported by the MAT at this time.
*/

valueset "Inpatient": 'TBD'
valueset "Fall": 'TBD'

context Patient

define "Initial Population":
  "Qualifying Encounters"

define "Denominator":
  "Initial Population"

define "Numerator":
  "Initial Population"

define "Qualifying Encounters":
  ["Encounter": "Inpatient"]

define "Falls with Major Injury":
  ["Observation": "Fall"]

define function "Denominator Observation"(Encounter "Encounter"):
  duration in hours of Global.Hospitalization(Encounter) / 24

define function "Numerator Observation"(Encounter "Encounter"):
  Count(
    "Falls with Major Injury" Falls
      where Global."Normalize Interval"(Falls.effective) during Encounter.period
  )
