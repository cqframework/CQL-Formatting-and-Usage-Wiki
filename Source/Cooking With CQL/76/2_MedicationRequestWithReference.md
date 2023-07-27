#MedicationRequest With Medication Reference

#### Medication ordered (as a reference)
_Updated 2023-07-25_

The QICore MedicationRequest profile allows the [`medication`](http://hl7.org/fhir/us/qicore/StructureDefinition-qicore-medicationrequest-definitions.html#key_MedicationRequest.medication[x]) element to be represented as either a code or a reference. This means that systems can represent MedicationRequests using either a code:

```json
{
  "resourceType" : "MedicationRequest",
  "id" : "example",
  "meta" : {
    "profile" : ["http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-medicationrequest"]
  },
  ...
  "status" : "active",
  "intent" : "order",
  "medicationCodeableConcept" : {
    "coding" : [{
      "system" : "http://www.nlm.nih.gov/research/umls/rxnorm",
      "code" : "1594660",
      "display" : "alemtuzumab 10 MG/ML [Lemtrada]"
    }]
  },
  "subject" : {
    "reference" : "Patient/example"
  },
  ...
}
```

or a reference:

```json
{
  "resourceType" : "MedicationRequest",
  "id" : "example",
  "meta" : {
    "profile" : ["http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-medicationrequest"]
  },
  ...
  "status" : "active",
  "intent" : "order",
  "medicationReference": {
    "reference": "Medication/example"
  },
  "subject" : {
    "reference" : "Patient/example"
  },
  ...
}
```

referencing a Medication resource:

```json
{
  "resourceType" : "Medication",
  "id" : "example",
  "meta" : {
    "profile" : ["http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-medication"]
  },
  ...
  "code" : {
    "coding" : [{
      "system" : "http://www.nlm.nih.gov/research/umls/rxnorm",
      "code" : "1594660",
      "display" : "alemtuzumab 10 MG/ML [Lemtrada]"
    }]
  },
  ...
}
```

Because the retrieve expression supports terminology-based filtering, the following expression will retrieve only MedicationRequest instances that represent the medication with a code:

```cql
define "Antithrombotic Therapy at Discharge":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] Antithrombotic
    where (Antithrombotic.isCommunity() or Antithrombotic.isDischarge())
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent = 'order'
```

To ensure retrieval on data from systems that represent medication using a reference, the following pattern can be used:

```cql
define "Antithrombotic Therapy at Discharge (by Reference)":
  ["MedicationRequest"] Antithrombotic
    where Antithrombotic.medication().code in "Antithrombotic Therapy" 
      and (Antithrombotic.isCommunity() or Antithrombotic.isDischarge())
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent = 'order'

define fluent function medicationAlternate(medicationRequest MedicationRequest):
  singleton from ([Medication] M where M.id = medicationRequest.medication.reference.getId())
```

This pattern defines a `medication()` fluent function that resolves the reference, retrieving the Medication resource by its `id` element directly.

## See Also
* [CQLIT-373](https://oncprojectracking.healthit.gov/support/browse/CQLIT-373)
* [Translator Issue #1146](https://github.com/cqframework/clinical_quality_language/issues/1146)
* [Authoring Patterns Update](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns---QICore-v4.1.1#medication-ordered-as-a-reference)
