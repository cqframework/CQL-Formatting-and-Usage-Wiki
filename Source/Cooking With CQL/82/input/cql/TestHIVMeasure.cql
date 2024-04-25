library TestHIVMeasure

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

valueset "HIV Tests": 'http://example.org/fhir/ValueSet/hiv-tests'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Resulted HIV Test":
  [Observation: "HIV Tests"] O
    where O.status in { 'final', 'amended' }
      and O.value is not null

define "Active HIV Diagnosis":
  [Condition] // Assuming true for the purposes of the example

define "Initial Population":
  exists (
    "Active HIV Diagnosis" D
      where D.onset overlaps "Measurement Period"
        and D.abatement is null
  )

define "Measure Population":
  "Initial Population"

define function "Measure Observation"(patient Patient):
  Count(
    "Resulted HIV Test" T
      where T.issued during "Measurement Period"
  )

define "Denominator":
  "Initial Population"

define "Numerator":
  exists (
    "Resulted HIV Test" T
      where T.issued during "Measurement Period"
  )
