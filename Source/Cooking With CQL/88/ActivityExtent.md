> NOTE: This is a summary-level review of the proposed [Activity Extent](https://build.fhir.org/ig/HL7/cql-ig/patterns.html#activity-extent) topic in the January 2025 Using CQL With FHIR Ballot

FHIR offers several possibilities for describing _what_ activity (i.e. request or event) is being performed (e.g. the `code` element of a Procedure, or the `medication` element of a MedicationRequest):

1. Specify a particular code
2. Specify a higher-level code that includes all the concepts by subsumption
3. Specify the items with a value set (via the `codeOptions` extension)

These approaches allow for the _extent_ of an activity to be defined:

#### Specific Code

The first two approaches make use of terminology to define the extent of an activity, and is the most common approach. The code in a terminology may identify a single, precise concept, or it may identify a class of concepts, such as a type of procedure, or a class of medications.

For example, the following MedicationAdministration indicates a specific drug:

```json
{
  "resourceType" : "MedicationAdministration",
  ...,
  "medicationCodeableConcept" : {
      "coding" : [{
          "system" : "http://www.nlm.nih.gov/research/umls/rxnorm",
          "code" : "1116635",
          "display" : "ticagrelor 90 MG Oral Tablet"
      }]
  },
  ...
}
```

As opposed to specifying only a concept code:

```json
{
  "resourceType" : "MedicationAdministration",
  ...,
  "medicationCodeableConcept" : {
      "coding" : [{
          "system" : "http://www.nlm.nih.gov/research/umls/rxnorm",
          "code" : "11289",
          "display" : "warfarin"
      }]
  },
  ...
}
```

Retrieving resources with codes specified using these approaches can be accomplished with a simple [Retrieve](https://cql.hl7.org/02-authorsguide.html#filtering-with-terminology):

```cql
define "Antithrombotic Therapy Administered":
  [MedicationAdministration: "Antithrombotic Therapy"] AntithromboticTherapy
    where AntithromboticTherapy.status = 'completed'
      and AntithromboticTherapy.category ~ "Inpatient Setting"
```

This example retrieves `MedicationAdministration` resources that have a code in the `Antithrombotic Therapy` value set, a status of `completed`, and a category of `Inpatient Setting`.

#### Code Options

The third approach (specifying the items with a value set) is enabled through the use of the [codeOptions](https://build.fhir.org/ig/HL7/fhir-extensions/branches/br-48852-codeOptions-extension/StructureDefinition-codeOptions.html) extension. Rather than specifying a code, this extension is used to indicate that the activity may be any one of the codes in the value set:

```json
{
  "resourceType" : "MedicationAdministration",
  ...,
  "medicationCodeableConcept" : {
      "extension" : [{
          "url" : "http://hl7.org/fhir/StructureDefinition/codeOptions",
          "valueCanonical" : "http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.62"
      }],
      "text" : "Value Set: Antithrombotic Therapy for Ischemic Stroke"
  },
  ...
}
```

When this pattern is used in FHIR resources, the CQL needs to take this into account by looking for the `codeOptions` extension:

```cql
define "Antithrombotic Therapy Class Administered":
  [MedicationAdministration] Administered
    where Administered.medication.codeOptions() = "Antithrombotic Therapy".id
      and Administered.status = 'completed'
      and Administered.category ~ "Inpatient Setting"
```

This example retrieves `MedicationAdministration` resources that use the `codeOptions` extension to specify a candidate medication in the `Antithrombotic Therapy` value set, a status of `completed`, and a category of `Inpatient Setting`.

NOTE: See the FHIRCommon library for the definition of the `codeOptions()` fluent function.

To ensure both approaches are accounted for, these two expressions would then be used together:

```cql
define "Antithrombotics Administered":
  "Antithrombotic Therapy Administered"
    union "Antithrombotic Therapy Class Administered"
```

> NOTE: Profile-informed authoring exposes elements that have a `codeOptions` extension using a Choice of `CodeableConcept` and `ValueSet`, which is then translated as a union, accounting for both cases as part of profile-informed authoring.


