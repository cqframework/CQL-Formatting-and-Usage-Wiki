/*
This library illustrates patterns for accessing related FHIR resources through
references. Although timing is often used to establish relationships between
events in quality measures and decision support logic, if the model supports
explicit relationships (_references_ in FHIR), then those can be used as part
of where clauses and such that criteria, as illustrated by the examples in
this library.
*/
library FHIRReferences

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

valueset "Diabetes": 'TBD'
valueset "Healthcare Provider": 'TBD'
valueset "Aspirin": 'TBD'

context Patient

/*
Singleton element that is a reference
[MedicationRequest.encounter](http://hl7.org/fhir/medicationrequest-definitions.html#MedicationRequest.encounter)
dataRequirement: { type: MedicationRequest, relatedDataRequirement: { type: Encounter, relatedByPath: encounter } }
*/
define MedicationRequestWithEncounter:
  [MedicationRequest] M
    with [Encounter] E
      such that E.id = Last(Split(M.encounter.reference, '/'))

/*
Singleton element that is a reference to the subject
[Patient.managingOrganization](http://hl7.org/fhir/patient-definitions.html#Patient.managingOrganization)
dataRequirement: { type: Patient, relatedDataRequirement: { type: Organization, code: type, valueset: "Healthcare Provider", relatedByPath: managingOrganization } }
*/
define PatientManagedByHealthcareProvider:
  Patient P
    with [Organization: type in "Healthcare Provider"] O
      such that O.id = Last(Split(P.managingOrganization.reference, '/'))

// http://example.org/fhir/Organization/123
// http:
//
// example.org
// fhir
// Organization
// 123

/*
Plural element that is a reference
[Encounter.reasonReference](http://hl7.org/fhir/encounter-definitions.html#Encounter.reasonReference)
*/
define EncountersWithDiabetes:
  [Encounter] E
    with [Condition: "Diabetes"] C
      such that C.id in E.reasonReference R return Last(Split(R.reference, '/'))

/*
Element that is a choice, one of which is a reference:
[MedicationRequest.medication](http://hl7.org/fhir/medicationrequest-definitions.html#MedicationRequest.medication_x_)
*/
define MedicationRequestForAspirin:
  [MedicationRequest] R
    with [Medication] M
      such that M.id = Last(Split(R.medication.reference, '/'))
        and M.code in "Aspirin"

/*
Can also bring it in to the query with a let:
*/
define MedicationRequestWithAspirin:
  [MedicationRequest] R
    let M: [Medication: id = Last(Split(R.medication.reference, '/'))]
    where M.code in "Aspirin"

/*
1.5 Translator supports .resolve() and .reference() from FHIRPath
*/
// If a reference is resolved in the scope of a query, that resolve can be rewritten as an include in the retrieve for that source
// MedicationRequest
define TestMedicationRequest1:
  [MedicationRequest] MR
    where MR.medication.reference.resolve().as(Medication).code in "Aspirin"

// Expected FHIR URL for the retrieve
// [base]/MedicationRequest?patient=123&_include=MedicationRequest:medication

/*
.reference() function returns a "Reference" to a resource suitable
for comparison with equality
*/
define TestMedicationRequest1A:
  [MedicationRequest] MR
    with [Medication] M
      such that MR.medication = M.reference()
        and M.code in "Aspirin"

/*
1.5 Translator also supports related context retrieve usage:
*/
define TestMedicationRequest1B:
  [MedicationRequest] MR
    with [MR.medication -> Medication] M
      such that M.code in "Aspirin"

/*
Can also be brought in to the query with a let:
*/
define TestMedicationRequest1C:
  [MedicationRequest] MR
    let M: singleton from ([MR.medication -> Medication])
    where M.code in "Aspirin"


define TestMedicationRequirement:
  [Medication]

// If only TestBoundDataRequirement is referenced, the data requirement should only be [Medication: code]
define TestBoundDataRequirement:
  TestMedicationRequirement R
    where R.code in "Aspirin"
