library TestHIVMeasure

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include HIVCommon called HC

valueset "HIV Tests": 'http://example.org/fhir/ValueSet/hiv-tests'
valueset "HIV Diagnosis Codes": 'http://example.org/fhir/ValueSet/hiv-diagnosis-codes'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population":
  exists (
    HC."Active HIV Diagnosis" D
      where D.onset overlaps "Measurement Period"
        and D.abatement is null
  )

define "Measure Population":
  "Initial Population"

define function "Measure Observation"(patient Patient):
  Count(
    HC."Resulted HIV Test" T
      where T.issued during "Measurement Period"
  )

define "Denominator":
  "Initial Population"

define "Numerator":
  exists (
    HC."Resulted HIV Test" T
      where T.issued during "Measurement Period"
  )
