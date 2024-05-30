# CQLIT-450

* [CQLIT-450](https://oncprojectracking.healthit.gov/support/browse/CQLIT-450)

## Question

What is the primary code path for [QICore 4.1.1 Device](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-device.html)? More generally, where is this Model Info information located in the IG? Thank you!

## Answer

The _primary code path_ in CQL refers to the default path used by the translator for terminology-based filtering in a retrieve when no path is specified.

For example:

```cql
define "Inpatient Encounter":
  [Encounter: "Inpatient Encounter Codes"]
```

Because the retrieve does not specify a path for the terminology filter, the _primary code path_ as specified in the ModelInfo is used, `type` in this case. This can always be specified explicitly, as in:

```cql
define "Inpatient Encounter":
  [Encounter: type in "Inpatient Encounter Codes"]
```

The primary code path is chosen for each type based on the most commonly used access path. To address this question generally, we have prepared the following page of documentation for QICore:

* [QICore 4.1.1 ModelInfo)[https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/QI-Core-4.1.1-Model-Info]

And are working on similar pages for other versions of QICore. In addition, we are working on including this information in the QICore implementation guide in future versions. Specifically, the Using CQL With FHIR implementation guide now has an extension that can be defined in the IG to specify this information for each profile: [cqf-modelInfo-primaryCodePath](https://hl7.org/fhir/extensions/5.1.0-ballot/StructureDefinition-cqf-modelInfo-primaryCodePath.html).

