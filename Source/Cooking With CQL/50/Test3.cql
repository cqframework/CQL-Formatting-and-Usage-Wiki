library Test3

using QDM version '5.5'

/*
# Question:
We are looking to count number of inpatient falls with major injury per 1000 patient days.

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

This does result in a ratio, but there isn't mechanism in the current CQL-based HQMF (or FHIR measure)
to specify that the ratio should be converted to "per 1000 days".

To support that aspect, we are proposing an extension of CQL-based HQMF IG to state the expected
units of a ratio measure.

NOTE: 2020-12-17 eCQM Working Group:
MAT does not support patient-based continuous variable measures because the specification
requirements for continuous variable measures require the function to take an argument of
the _element type_ of the population, and since patient-based measures have boolean-valued
population criteria, there is no element type.
Logged this as an STU comment: http://www.hl7.org/dstucomments/showdetail_comment.cfm?commentid=2109
TODO: Express as an episode-of-care based Ratio measure
TODO: Work out how to formally express the "rate per 1000" requirement

In HQMF, the MeasureObservationDefinition for a Continuous Variable Measure can specify the result type
with the value element (with a nullFlavor of DER (derived)). Add this as an example measure, and
specify the type as a quantity, with a unit of '/1000d', and guidance that if the result
of the measure observation is not of
*/

include MATGlobalCommonFunctions called Global

valueset "Inpatient": 'TBD'
valueset "Fall": 'TBD'

define "Initial Population":
  exists "Qualifying Encounters"

define "Measure Population":
  true // No additional filters

define "Qualifying Encounters":
  ["Encounter, Performed": "Inpatient"]

define "Encounter Days":
  Sum(
    "Qualifying Encounters" Q
      return duration in hours of Global.Hospitalization(Q) / 24
  )

define "Falls with Major Injury":
  ["Assessment, Performed": "Fall"]

define function "Denominator Observation"(Encounter "Encounter, Performed"):
  "Encounter Days"

define function "Numerator Observation"(Encounter "Encounter, Performed"):
  Count(
    "Falls with Major Injury" Falls
      where Falls.relevantDatetime during Encounter.relevantPeriod
        or Falls.relevantPeriod during Encounter.relevantPeriod
  )
