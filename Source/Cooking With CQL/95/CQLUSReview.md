We are in the Work Group publication review period for the CQL US Common Artifacts Implementation Guide, with final publication taking place within a few weeks.

A brief overview of the content in the implementation guide, especially focused on authoring patterns and re-usable elements:

* [Patterns](https://build.fhir.org/ig/HL7/us-cql-ig/branches/main/patterns.html)

In addition to providing overall guidance, for each profile, the guidance discusses:

* Modifier elements and how they impact logic
* Search parameters and how they align with use cases
* Cross-version considerations (whether and how profiles have evolved from US Core 3 through 7)
* Common elements, functions, and use cases

For example:

* [Overall Patterns](https://build.fhir.org/ig/HL7/us-cql-ig/branches/main/patterns-overall.html)
* [Patient Patterns](https://build.fhir.org/ig/HL7/us-cql-ig/branches/main/patterns-patient.html)
* [Condition Patterns](https://build.fhir.org/ig/HL7/us-cql-ig/branches/main/patterns-condition.html)

In addition, the IG includes:

* [USCoreCommon](https://build.fhir.org/ig/HL7/us-cql-ig/branches/main/Library-USCoreCommon.html) - A complementary library to [FHIRCommon](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html) that introduces terminology and functions for use in the US Realm specifically
* [USCoreElements](https://build.fhir.org/ig/HL7/us-cql-ig/branches/main/Library-USCoreElements.html) - The main library of reusable US Core functions and expressions for accessing data elements
* [CumulativeMedicationDuration](https://build.fhir.org/ig/HL7/us-cql-ig/branches/main/Library-CumulativeMedicationDuration.html) - Functions and expressions for calculating cumulative medication duration, as developed through usage in decision support and measure authoring content

For each of these libraries, the IG also includes a set of comprehensive unit tests to validate intended capability.

The intent of this content is to support sharing and re-use of CQL artifacts across the healthcare community.
