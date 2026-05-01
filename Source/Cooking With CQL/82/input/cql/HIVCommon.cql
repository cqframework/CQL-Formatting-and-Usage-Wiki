library HIVCommon

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

valueset "HIV Tests": 'http://example.org/fhir/ValueSet/hiv-tests'
valueset "HIV Diagnosis Codes": 'http://example.org/fhir/ValueSet/hiv-diagnosis-codes'

context Patient

define "Resulted HIV Test":
  [Observation: "HIV Tests"] O
    where O.status in { 'final', 'amended' }
      and O.value is not null

define "Active HIV Diagnosis":
  [Condition: "HIV Diagnosis Codes"] // Assuming true for the purposes of the example
