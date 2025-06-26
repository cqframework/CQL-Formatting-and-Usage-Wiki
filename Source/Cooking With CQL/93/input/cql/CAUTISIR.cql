library CAUTISIR

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '2.0.0'

include CAUTIRate

codesystem "NHSN Regression Model Parameter Codes": 'TBD'

code "Intercept": 'Intercept' from "NHSN Regression Model Parameter Codes"
// declare codes for CDC Locations

parameter "Measurement Period" Interval<DateTime> default Interval[@2025-01-01, @2025-12-31]

context Patient

define "Acute Care Hospital Parameters": {
    { "code": "Intercept", estimate: -10.2667, standardError: 0.1618, pValue: Quantity { value: 0.001, comparator: '<' } },
    { "code": "Burn Critical Care", estimate: 3.3318, standardError: 0.1580, pValue: Quantity { value: 0.001, comparator: '<' } }
    // ...
}

define "Location Parameters"(location Location):
  {
    "Intercept",
    location.type.toCDCLocationCode(),
    location.medicalSchoolAffiliation(),
    location.facilityBedSize(),
    location.facilityType()
  }

define function "Denominator Observation"(location Location):
  Sum(
    from "Location Parameters"(location) P, "Acute Care Hospital Parameters" H
      where P ~ H.code
      return all H.estimate
  ) * "Patient Days"(location)

define function "Numerator Observation"():
  Count(CAUTIRate."Catheter-Associated UTI")

define "Denominator Initial Population":
  [Location] L
    with "Encounter During Measurement Period" E
     such that E.location.references(L)

define "Denominator":
  "Denominator Initial Population"

define "Encounter During Measurement Period":
  [Encounter] E
    where E.period during "Measurement Period"

define function "Patient Days"(location Location):
  Sum(
    "Encounter During Measurement Period" E
      where E.location.references(location)
      return all duration in days of E.period
  )

define "Encounter During Measurement Period":
  [Encounter] E
    where E.period during "Measurement Period"

define "Numerator Initial Population":
  exists ("Encounter During Measurement Period")

define "Numerator":
  "Numerator Initial Population"
