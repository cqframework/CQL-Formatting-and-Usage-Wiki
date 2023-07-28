library MedicationRequestTest

using QICore version '4.1.1'

include FHIRHelpers version '4.2.000'
include QICoreCommon version '1.3.000'

valueset "Antithrombotic Therapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.62' 

context Patient

/*
[CQLIT-373](https://oncprojectracking.healthit.gov/support/browse/CQLIT-373)
[Translator Issue #1146](https://github.com/cqframework/clinical_quality_language/issues/1146)
[Authoring Patterns Update](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns---QICore-v4.1.1#medication-ordered-as-a-reference)
*/

define "Antithrombotic Therapy at Discharge":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] Antithrombotic
    where (Antithrombotic.isCommunity() or Antithrombotic.isDischarge())
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent = 'order'

// Proposed update to the pattern to address medications represented as references: https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns---QICore-v4.1.1#medication-ordered-as-a-reference

define "Antithrombotic Therapy at Discharge (by Reference)":
  ["MedicationRequest"] Antithrombotic
    where Antithrombotic.medication().code in "Antithrombotic Therapy" 
      and (Antithrombotic.isCommunity() or Antithrombotic.isDischarge())
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent = 'order'

define fluent function medication(medicationRequest MedicationRequest):
  singleton from ([Medication] M where M.id = medicationRequest.medication.reference.getId())

define fluent function medicationIs(medicationRequest MedicationRequest, valueSet ValueSet):
  medicationRequest.medication in valueSet
    or medicationRequest.medication().code in valueSet

define "Antithrombotic Therapy at Discharge (combined)":
  ["MedicationRequest"] Antithrombotic
    where Antithrombotic.medicationIs("Antithrombotic Therapy")
      and (Antithrombotic.isCommunity() or Antithrombotic.isDischarge())
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent = 'order'



