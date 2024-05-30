library CQLIT449

using QICore version '4.1.1'

valueset "Antithrombotic Therapy": 'http://example.org/fhir/ValueSet/antithrombotic-therapy'

context Patient

define TestMedicationRequestNoPath:
  [MedicationRequest: "Antithrombotic Therapy"]

define TestMedicationRequestWithPath:
  [MedicationRequest: medication in "Antithrombotic Therapy"]

