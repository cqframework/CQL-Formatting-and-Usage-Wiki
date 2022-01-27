# CQL Errata Review

Since the 1.5 publication of CQL in May of 2021, several issues have been reported. We are collecting and addressing those issues and are preparing for an Errata publication to the specification. In addition to several technical corrections and clarifications, the following main areas are being addressed:

1. Backwards-compatibility of value set references
2. Version parameter support for media types
3. Errors in test cases
4. Document specific differences in behavior between 1.3, 1.4, and 1.5
5. Document translation options that affect language behavior

## Backwards-compatibility of value set references

In 1.5, new types were introduced to support the use of value sets as references. In particular, this new trial-use language feature allows value sets to be passed as arguments to functions, preserving the value set semantics of the reference. For example, consider a function that filters a list of `Condition` resources based on a value set. In 1.4, this would have to be done by providing the list of codes (i.e. the expansion of the value set):

```cql
define function "Conditions in ValueSet"(conditions List<Condition>, valueset List<System.Code>):
  conditions C
    where FHIRHelpers.ToConcept(C.code) in valueset
```

However, with the new `ValueSet` type in 1.5, this function can be written as:

```cql
define function "Conditions in ValueSet"(conditions List<Condition>, valueset ValueSet):
  conditions C
    where FHIRHelpers.ToConcept(C.code) in valueset
```

In 1.5, this preserves the value set semantics and means that the `in` operator will be treated as a value set membership operation, rather than as a strict list membership operation as it is in the 1.4 version.

To see why this is a breaking change, consider the following use of the above 1.4 function:

```cql
define "Narcolepsy Conditions":
  "Conditions in ValueSet"([Condition], "Narcolepsy")
```

In 1.4, this works and the value set reference (`"Narcolepsy"`) results in a `List<Code>`. However, in the initial release of 1.5, the reference to the `"Narcolepsy"` value set results in a value of type `ValueSet`, rather than a `List<Code>` and since the function is defined with `List<Code>`, the compile fails.

To address this, the specification is adding an implicit conversion from a `ValueSet` to a `List<Code>`, so that with the Errata publication (v1.5.2), the translation will succeed and backwards-compatibility is preserved.

In addition, content wishing to take advantage of the new `ValueSet` type can change the functions that currently take a `List<Code>` to take a `ValueSet` and existing content that uses those functions will not need to be updated.

For a more complete discussion of the issue and the solution, refer to the [Implementing the CQL 1.5 Terminology Types](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Implementing-the-CQL-1.5-Terminology-Types) topic in the CQL Formatting and Usage Wiki.

## Version parameter support for media types

Since the publication of 1.5, issues related to ensuring continued support for 1.4 content and environments has highlighted the need for a version specifier in the CQL media types. This is being added as a `version` parameter in the media types, allowing content packages to identify the version of CQL they contain. For example, the `contentType` element of a FHIR `Library` containing CQL can now indicate the version of CQL as:

```
text/cql; version=1.4
```

This version parameter can be used with any of the CQL/ELM media types, and can specify the major and minor version of any published version of the specification (currently `1.0` through `1.5`).

## Errors in test cases

The CQL specification includes a set of informative test cases that can be used to verify the behavior of a CQL implementation. Since the initial publication, running those test cases against existing implementations has identified multiple issues with the test cases. The errata publication will include an update to those test cases that includes all the fixes that have been submitted to this point.

## Document specific differences in behavior between 1.3, 1.4, and 1.5

To help support implementers, we have compiled a list of all the behavior differences between the 1.3, 1.4, and 1.5 versions of the specification. The proposed list can be previewed here:

https://build.fhir.org/ig/HL7/cql/branches/feature-32679-version-differences/05-languagesemantics.html#version-differences

## Document translation options that affect language behavior

To help support implementers, we have compiled a list of all translation options that affect language behavior. The proposed documentation can be previewed here:

https://build.fhir.org/ig/HL7/cql/branches/feature-34199-language-impacting-options/06-translationsemantics.html#translation-options
