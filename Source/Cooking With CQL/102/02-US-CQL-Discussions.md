Common CQL Artifacts for FHIR (US-based) has been balloted and we are reconciling feedback received and applying changes, targeting a late July/early August publication.

The following topics have either been added or had substantive change, and we are seeking review and comment on the proposed updates to address comments received during ballot:

## Patient Name

In addition to several fixes, [FHIR-56948](https://jira.hl7.org/browse/FHIR-56948) points out that the name functions for Patient, Practitioner, and HumanName, are very thin wrappers and so potentially violate the "No trivial wrapper" principle. The proposed disposition here is to document that while these are simple functions, they do provide for consistent handling of US-specific names, and so are appropriate for use in US-specific applications.

## Patient Sex

[FHIR-56801](https://jira.hl7.org/browse/FHIR-56801) points out that the sex extension in US Core 6 is deprecated in future versions of US Core, and provides background for the change. To address this, as well as [FHIR-56999](https://jira.hl7.org/browse/FHIR-56999) which asks for the sex element to be document in the Patient patterns page, a new _sex_ element discussion was added:

[Patient sex](https://build.fhir.org/ig/HL7/us-cql-ig/en/patterns-patient.html#patient-sex)

Basically, retain the `sex()` function for backwards compatibility, but introduce a new `individualSex()` function that returns the value of the individualSex extension if it is defined, otherwise, it falls back to the value of the sex extension, but mapped to the values defined in the individualSex extension. This will allow it to be used in `SupplementalDataElements` without having to put that mapping logic into the measure library.

In addition, to align with industry best-practices, the `sexParameterForClinicalUse()` function was added.

## Electronically Transmitted Prescription

In response to requests for representation in FHIR of an electronically transmitted prescription, [FHIR-57486](https://jira.hl7.org/browse/FHIR-57486) adds a `transmissionMethod` element for MedicationDispense:

[Electronically Transmitted Prescriptions](https://build.fhir.org/ig/HL7/us-cql-ig/en/patterns-medication.html#electronically-transmitted-prescriptions)

## Diagnoses Active During an Encounter

Quality improvement applications often need to determine whether or not a particular diagnosis was active during an encounter, but due to variations in data representation and collection patterns, this is not a straightforward question to answer. To address [FHIR-57466](https://jira.hl7.org/browse/FHIR-57446), the following section was added to condition patterns:

[Evidence of Diagnosis During an Encounter](https://build.fhir.org/ig/HL7/us-cql-ig/en/patterns-condition.html#evidence-of-diagnosis-during-an-encounter)

In particular note the use of:

* `encounter` reference
* `recordedDate`
* `assertedDate()`

To establish the relationship to an encounter if a prevalence interval is not available.

## Allergy and Intolerance Status and Content

For allergy and intolerance patterns, to address [FHIR-56992](https://jira.hl7.org/browse/FHIR-56992), additional guidance was added around determining status as of a given date (i.e. retroactively), as well as clarification of example content to address [FHIR-56993](https://jira.hl7.org/browse/FHIR-56993):

Retrospective guidance was added to the [Clinical and verification status](https://build.fhir.org/ig/HL7/us-cql-ig/en/patterns-allergy.html#clinical-and-verification-status) discussion, and support for the `assertedDate` extension was added to the [Onset, Abatement, and Prevalence Interval](https://build.fhir.org/ig/HL7/us-cql-ig/en/patterns-allergy.html#onset-abatement-and-prevalence-interval) discussion.

## Observation Pattern Updates

[FHIR-56944](https://jira.hl7.org/browse/FHIR-56944) points out that the various Observation timing functions make use of `issued`, but that `effective` is often the more relevant timing element for observations. As part of discussion, it was also noted that the `issued` element is not part of any US Core profile, and so `effective` is the better choice for that reason as well. To address this comment, all the timing functions were updated to use `effective` rather than `issued`:

[Timings](https://build.fhir.org/ig/HL7/us-cql-ig/en/patterns-observation.html#timings)

[FHIR-56947](https://jira.hl7.org/browse/FHIR-56947) discusses the use of `singleton from` when accessing systolic and diastolic functions. We will add documentation that singleton is the expected use case, since multiple components would be an error case and should throw (rather than silently return null).


## Document Specimen Collection Time

[FHIR-57872](https://jira.hl7.org/browse/FHIR-57872) requests documentation for specimen collection time element:

[Specimen Collection Time](https://build.fhir.org/ig/HL7/us-cql-ig/en/patterns-observation.html#specimen-collection-time)

## Pregnancy Status Logic and Timing Issues

[FHIR-56996](https://jira.hl7.org/browse/FHIR-56996) points out that the Pregnancy Status patterns are inconsistent in that some of them are looking for overlaps of the measurement period, while some are looking for starts during. To clarify, the example was updated to consistently look for "evidence of pregnancy at any point in the measurement period" (i.e. all timings were changed to use `overlaps`):

[Pregnancy Status](https://build.fhir.org/ig/HL7/us-cql-ig/en/patterns-observation.html#pregnancy-status)

## EndsWith Change Throughout

[FHIR-56951](https://jira.hl7.org/browse/FHIR-56951) points out that the pattern of using `EndsWith` to determine whether a reference in FHIR matches a resource is fragile because it does not account for the possibility of external references. To address this, we have updated all the uses of `EndsWith` to use the FHIRCommon `references()` approach instead. This allows the issue of how external references are to be handled to be implemented in the Using CQL FHIRCommon library, rather than in the US-specific libraries.

See the functions beginning with [RequestingProvider](https://build.fhir.org/ig/HL7/us-cql-ig/en/Library-USCoreElements.html#:~:text=define%20function-,RequestingProvider,-(serviceRequest%20FHIR) in US Core Elements.

## ServiceRequest Updates

[FHIR-56950](https://jira.hl7.org/browse/FHIR-56950) and [FHIR-56949](https://jira.hl7.org/browse/FHIR-56949) correct issues with the service request patterns. In particular, the MostRecent functions for service request should be using the FHIRCommon.mostRecent functions instead.

## Type Identifier Conventions

[FHIR-56943](https://jira.hl7.org/browse/FHIR-56943) points out that the `tribalAffiliation` function does not use a type name qualifier when describing the result, while many of the other functions do. The comment asks for consistent use. Related to this, we have already been discussing whether a best-practice of always using type name qualifiers when multiple models are in use should be adopted. We propose to adopt this as a best practice as part of the resolution for this ticket, and have updated the USCoreCommon and USCoreElements to conform to this practice.

## Naming Conventions

[FHIR-56988](https://jira.hl7.org/browse/FHIR-56988) proposes some general naming conventions for adoption, particularly in shared content, to ensure that declarations can be effectively and safely re-used:

Specifically:

To ensure that declarations in shared libraries can be clearly understood when used in other contexts, the following section provides best-practices for naming declarations in shared libraries. This is a curated list of rules that may grow depending on when important distinctions are found, so feedback is welcome, both on these best-practices, as well as how they are applied in the shared content here.

1. Unless there can be no confusion, include clarity over the type of resource returned
    1. e.g. 'Metformin RxNorm Code', Metformin Valueset, 'Metformin AllergyIntolerances' 'Metformin MedicationResources', 'Renal Dialysis Procedures', 'Renal Dialysis Conditions', etc.
2. When a set of items is returned use a plural form (e.g. add s). When not in plural form the definition should return a singleton and where applicable, how that singleton was obtained from the set
    1. e.g. 'Most Recent Systolic Blood Pressure Quantity'
3. When a parameter quantity (or set of parameter quantities) is returned as a primitive (e.g. Decimal), include any qualifying unit in the name 
    1. e.g. 'Patient Age in Days'
4. When a resource list is filtered or processed, it should include clarity over how it is filtered or processed
    1. e.g. 'Active Confirmed Conditions'
5. When a resource list is unfiltered (except the primary code) clarify with 'All'
6. Non-fluent functions should generally begin with a verb to distinguish from definitions 
    1. e.g. 'GetX', 'ComputeX', 'MapToX', etc.

[Naming Best-practices](https://build.fhir.org/ig/HL7/us-cql-ig/en/patterns-overall.html#naming-best-practices)



