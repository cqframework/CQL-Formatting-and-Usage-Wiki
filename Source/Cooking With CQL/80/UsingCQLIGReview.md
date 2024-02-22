# Using CQL With FHIR IG Review

The Using CQL With FHIR IG is an implementation guide that refactors previously published content relating to the use of FHIR and CQL from the following sources:

* Quality Measures
* Clinical Guidelines
* electronic Case Reporting
* Quality Improvement Core (QICore)

The implementation guide was created based on the recognition that much of the guidance published in these other implementation guides was a) duplicative, and b) more generally applicable from both a realm and use case perspective.

The continuous integration build is available here:

http://build.fhir.org/ig/HL7/cql-ig

The guide was balloted in the January 2024 cycle and is currently in reconciliation. The Clinical Decision Support and Clinical Quality Information work groups are targeting early March for publication.

## Content Areas

The implementation guide contains:

* Conformance criteria and best practices for CQL Libraries used with FHIR
* CQL-related operations (Library/$evaluate and $cql)
* Guidance and support for the use of ModelInfo

### Conformance Criteria and Best Practices

The [Using CQL](http://build.fhir.org/ig/HL7/cql-ig/using-cql.html) page defines conformance criteria and documents best practices for the use of CQL with FHIR

### CQL-related Profiles

https://build.fhir.org/ig/HL7/cql-ig/profiles.html

### CQL-related Operations

* [Library/$evaluate](https://build.fhir.org/ig/HL7/cql-ig/OperationDefinition-cql-library-evaluate.html)
* [$cql](https://build.fhir.org/ig/HL7/cql-ig/OperationDefinition-cql-cql.html)
* [CQL Evaluation Service](https://build.fhir.org/ig/HL7/cql-ig/CapabilityStatement-cql-evaluation-service.html)

### CQL ModelInfo Support

https://build.fhir.org/ig/HL7/cql-ig/using-cql.html#modelinfo