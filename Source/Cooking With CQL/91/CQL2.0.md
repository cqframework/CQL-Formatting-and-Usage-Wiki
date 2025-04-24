Clinical Quality Language (CQL) has been published as a normative specification since December of 2020. Since that time, we have been collecting author and implementer feedback on issues with the specification as well as requests for new features. Much of the feedback has already been incorporated into the specification with the publications of CQL Errata 1 (v1.5.2) in 2023, and more recently CQL Errata 2 (v1.5.3) in March of this year.

More substantive feedback and new feature requests are being considered for a 2.0 version of the specification, with a proposed initial draft ballot in September of this year, with the following overall themes for 2.0:

1. Promotion of STU features to Normative
2. Conformance
3. Feedback and Features

This topic will provide an overview of these themes and a detailed review of the currently proposed feature set. The current roadmap for the Clinical Quality Language project is maintained at the following HL7 Confluence Page [Clinical Quality Language Project Page](https://confluence.hl7.org/spaces/CDS/pages/55935478/Clinical+Quality+Language)

The purpose of this review is to:

1. Provide visibility for stakeholders on the planned feature set
2. Provide an additional opportunity for feedback on the planned feature set
3. Help determine whether there are any gaps in the planned feature set

All the changes discussed in this topic are tracked in detail using the [CQL Tracker Status](https://confluence.hl7.org/spaces/CDS/pages/81034128/CQL+Tracker+Status) in HL7's JIRA instance. Feedback can be submitted on existing trackers (by adding comments to the discussion), or by submitting new trackers.

> NOTE: The CQL specification has been published as normative for almost 5 years. Multiple production engines and systems rely on this stability. We will not introduce any breaking changes as part of the 2.0 version.

## Normative Candidates

The following sections describe the features of the language that are currently marked trial-use and will be considered for normative status in 2.0.

### Comment Tags

Comment tags are a trial-use feature that support adding structured metadata to declarations in CQL libraries:

```cql
/*
@author: Ludwig van Beethoven
@description: Determines the cumulative duration of a list of intervals
@comment: This function collapses the input intervals prior to determining the cumulative duration
to ensure overlapping intervals do not contribute multiple times to the result
*/
define function "CumulativeDuration"(Intervals List<Interval<DateTime>>):
  Sum((collapse Intervals) X return all duration in days of X)
```

We have been collecting the various usages of documentation tags here:

https://github.com/cqframework/clinical_quality_language/wiki/Well-Known-CQL-Documentation-Tags

Implementations already make use of some of these tags as part of supporting the language, in particular the `@allowFluent` and `@deprecated` tags are used to support language features, and documentation tooling makes use of the `@author`, `@description`, and `@comment` tags.

We are proposing to make the structure of these tags Normative, as well as considering the introduction of the more widely used tags as trial-use content.

### Aggregate Clause

The [Aggregate Clause](http://build.fhir.org/ig/HL7/cql/03-developersguide.html#aggregate-queries) allows CQL queries to express _iterated calculation_ generally. For example:

```cql
define FactorialOfFive:
  ({ 1, 2, 3, 4, 5 }) Num
    aggregate Result starting 1: Result * Num
```

This feature was introduced Trial-Use, and has since become an important feature of the language, allowing for calculations that could not otherwise be expressed.

### Fluent Functions

[Fluent Functions](http://build.fhir.org/ig/HL7/cql/03-developersguide.html#fluent-functions) were introduced as trial-use, but have seen significant adoption, and are now an important and well-used aspect of the language. As such, fluent functions will be proposed for normative status.

```cql
define fluent function "confirmed"(Conditions List<Condition>):
  Conditions C where C.verificationStatus ~ "Condition Confirmed"
```

```cql
define "Diabetes Conditions":
  [Condition: "Diabetes Mellitus"]

define "Confirmed Diabetes Conditions":
  "Diabetes Conditions".confirmed()
```

### Data Types

Several new data types were introduced as Trial-Use and are being proposed for Normative status:

* [CodeSystem](http://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#codesystem)
* [Long](http://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#long-1)
* [ValueSet](http://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#valueset)
* [Vocabulary](http://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#vocabulary)

The Vocabulary type is an abstract super type for the CodeSystem and ValueSet types. These types allow functions to be defined that take CodeSystem and ValueSet references, allowing implementations to support delayed expansion of a value set reference. For example:

```cql
define fluent function observationsIn(observations List<Observation>, valueSet ValueSet):
  observations O
    where O.code in valueSet
```

### Media Types

CQL has registered IANA Media Types, and these registrations were introduced as Trial-Use:

[Media Types](http://build.fhir.org/ig/HL7/cql/07-physicalrepresentation.html#media-types-and-namespaces)

Normative status is being proposed for:

* text/cql-expression - The _expression_ rule of the CQL grammar
* text/cql-identifier - The _identifier_ rule of the CQL grammar

As well as the ability to specify the version of CQL within the media type:

```
text/cql; version=1.5
```

## New Features for Trial-Use

In addition to promoting existing Trial-Use features to Normative, the 2.0 version of CQL will add additional Trial-Use features based on stakeholder feedback.

### Conformance

One area that has surfaced as a particular need is in _conformance_, by which we mean the need for engines and systems to demonstrate conformance to the specification. The specification currently defines a set of [capabilities](https://cql.hl7.org/05-languagesemantics.html#language-capabilities). For example, the high-level categories of capabilties are:

* Data Model and Type Support
* Compatibility Level
* System Data Types
* Operators (by Category)
* Queries
* Retrieve

The 2.0 version will introduce a formal mechanism for:

1. Defining the capabilities formally (likely as part of a terminology, but perhaps using the FHIR Application Feature Framework)
2. Providing a mechanism for engines to advertise what capabilities they _support_
3. Providing a mechanism for content to advertise what capabilities it _requires_
4. So that systems can _negotiate_ to improve implementation

### Formalized Error Reporting

The CQL specification defines several types of messages that can be provided as part of development and implementation of CQL. Specifically, there are:

1. Compile-time messages (i.e. messages that may be provided by environments as part of the process of authoring CQL as part of ensuring that CQL is valid and expresses the correct intent of the author)
2. Run-time messages (i.e. messages that are provided by environments as part of executing CQL to provide feedback about the evaluation process such as errors or warnings).

Messages provided in both of these contexts have a severity, which may be:

* Information - Informational messages that do not impact correctness or prevent evaluation
* Warning - Warning messages that should be considered but are not necessarily incorrect
* Error - Errors that prevent correct evaluation

In addition, messages may have a _source_ (i.e. an indication of where or who can or needs to address the message):

* Environment - Messages that are generated by the environment (such as network or hardware issues)
* System - Messages that are related to the system infrastructure (such as unexpected engine behavior)
* Application - Messages that are related to the application (such as unexpected application behavior)
* User - Messages that are related to the user (i.e. could be addressed by correcting issues with the data being used)

And finally, many of these messages are dictated by the specification, but the [Message](https://cql.hl7.org/09-b-cqlreference.html#errors-and-messaging) operation allows CQL content to produce messages as well.

To better facilitate implementation handling for exceptions, the 2.0 version of CQL will include formalization of these, building on what is already specified in the Message operator, as well as what is currently implemented in the CQL-to-ELM translator and the various CQL engines.

In particular, the specification will propose:

* Formal severities
* Formal sources
* A mechanism for formalizing error codes
* Error codes for messages prescribed by the specification

### Formalized JSON Serialization

The published specification has some language regarding JSON serialization of ELM:

https://cql.hl7.org/07-physicalrepresentation.html#media-types-and-namespaces

However, it's fairly light, and implementation experience using various XML and JSON serializers has highlighted the need to improve this documentation to ensure JSON ELM can be reliably exchanged.

In addition, 2.0 will consider a CQL serialization format for CQL values, as proposed here:

https://github.com/cqframework/clinical_quality_language/wiki/CQL-Serialization

### FHIRPath Updates

Clinical Quality Language is a super set of FHIRPath, meaning that any valid FHIRPath expression is also a valid CQL expression. On top of FHIRPath, CQL introduces higher-level constructs that are critical for expressing clinical artifacts such as quality measures, decision support rules, and guideline recommendations:

* Libraries
* Queries
* Data Access

FHIRPath was also published as a normative specification in 2020, almost 5 years ago, and since that time has had significant adoption and implementation. A new version of the FHIRPath specification was balloted in [January 2025](https://hl7.org/fhirpath/2025Jan/), and introduced some significant new features, including:

* String manipulation functions
* Date/Time extraction functions
* Long data type
* Aggregates
* Precision and boundary functions

Some of this functionality was already present in CQL and is effectively being promoted to FHIRPath. Other new functionality is being introduced that needs to be aligned with the CQL specification. The 2.0 version will ensure CQL is aligned with these FHIRPath changes.

### Language Features

#### Default Comparison Precision

Clinical Quality Language supports specifying the comparison precision for date/time comparisons. For example:

```cql
define "Right Mastectomy Procedure":
  [Procedure: "Unilateral Mastectomy Right"] P
    where P.performed.toInterval() ends on or before end of "Measurement Period"
```

When a date/time comparison does not specify a precision, the comparison is performed by default to the millisecond. This behavior is sometimes surprising for authors and feedback has resulted in a request for the ability to specify a "default comparison precision". In the absence of a specified comparison precision such as the above, this default comparison precision would be used, rather than always carrying the comparison to the millisecond.

For example, many clinical applications only need accuracy to the minute, so allowing for a default comparison precision of minutes can improve the default behavior, as well as prevent authors from having to specify comparison precision in every date/time comparison.

#### Additional Terminology Operators

CQL currently supports terminology membership operators, specifically:

* [In(CodeSystem)](https://cql.hl7.org/09-b-cqlreference.html#in-codesystem) - Determines whether a given code or list of codes is in a CodeSystem
* [In(ValueSet)](https://cql.hl7.org/09-b-cqlreference.html#in-valueset) - Determines whether a given code or list of codes is in a ValueSet

These operations are typically invoked using the `in` keyword:

```cql
Procedure.code in "Unilateral Mastectomy Right"
```

And they are also used as part of Retrieve expressions:

```cql
[Procedure: code in "Unilateral Mastectomy Right"]
```

However, the `In` operation that represents terminology membership and the `In` operation that represents general list membership are subtly different, in that the terminology membership operation uses _equivalent_ semantics (i.e. `~`):

```cql
Procedure.code in "Unilateral Mastectomy Right"
```

whereas an integer list membership test uses _equality_ semantics (i.e. `=`)

```cql
X in { 2, 3, 4 }
```

In addition, whereas list membership has a natural complement, `contains`:

```cql
X in { 2, 3, 4 } = { 2, 3, 4 } contains X
```

Terminology membership does not have a corresponding complement. The 2.0 version will address these issues by:

1. Defining an _equivalent in_ (`~in`) operation (list membership using _equivalent_ semantics)
2. Defining an _equivalent contains_ (`~contains`) operation (list containment using _equivalent_ semantics)
3. Defining `~contains` overloads specifically for terminology usage (i.e. ValueSet contains code)
4. Supporting the use of `~in` and `~contains` in Retrieve expressions

This feature will support several current shortcomings, in particular:

1. The use of direct-reference codes when retrieving multi-cardinality primary code paths (e.g. Encounter.type)
2. The use of direct-reference codes when retrieving negation profiles (e.g. ServiceProhibited)

This issue was discussed in detail in session [#67](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/blob/5540346de7372110130d9eedc17944173f82ffc7/Source/Cooking%20With%20CQL/76/1_DRCEncounters.md?plain=1#L93)

Additional discussion and the current best-practice can be found in [Authoring Patterns - Accessing Encounters with a Direct-reference code](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns---QICore-v4.1.1#accessing-encounters-with-a-direct-reference-code)

With the proposed new terminology operators, the workarounds are no-longer necessary, and the following will work as expected:

```cql
define "Encounter With A Direct Reference Code":
  [Encounter: "Office Visit Code"]

define "Encounter Type With A Direct Reference Code":
  [Encounter: type ~contains "Office Visit Code"]

define "Encounter With Where Clause":
  [Encounter] E
    where E.type ~contains "Office Visit Code"
```

> NOTE: This feature will address [CQLIT-368](https://oncprojectracking.healthit.gov/support/browse/CQLIT-368) and [CQLIT-410](https://oncprojectracking.healthit.gov/support/browse/CQLIT-410)

#### Support Type Declarations

Clinical Quality Language is, by design, a _model agnostic_ language, meaning that CQL can be used with any model, there is no specific model built in to the language. This means that the definition of the model to be used is provided as [_model information_](https://cql.hl7.org/07-physicalrepresentation.html#data-model-references). Model info files currently exist for (among others):

* Quality Data Model (QDM)
* FHIR (DSTU2, STU3, R4)
* USCore (3.1.1, 6.1.0)
* QICore (4.1.1, 6.0.0)

In addition, there is a general mechanism for defining model information for any FHIR implementation guide, and making it available for use within CQL environments documented in the [Using ModelInfo](https://hl7.org/fhir/uv/cql/using-modelinfo.html) topic of the Using CQL With FHIR implementation guide.

In particular, profile-informed authoring has been progressed as a way to simplify authoring CQL against FHIR profiles. However, the current approach to profile-informed authoring requires intricate mappings to be encoded in the Model Information file, and then unwrapped as part of the translation process. Version 2.0 proposes to improve on this approach by moving this mapping from the model information to make use of language features directly, by allowing types to be declared in CQL. Specifically, 2.0 proposes to define support for:

* Type declarations for Simple and Class types
* Operator declarations (such as `+`)
* Generic types
* Context definitions
* Property accessors (i.e. allowing the definition of an element of a class to be provided by a function)

As an example, consider the following proposed USCore.Patient definition:

```cql
library USCore

using FHIR version '4.0.1'

define class Patient extends FHIR.Patient {
    birthSex: get this.extension('http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex').value as FHIR.code
}
```

A more detailed proposal describing these features is available in the [Models In CQL](https://github.com/cqframework/clinical_quality_language/wiki/Feature-Proposals) discussion on the CQL wiki.

#### Improved Library Organization and Usage

The next version of CQL will also propose improvements to better support library organization and usage by:

Allowing multiple versions of the same library to be included:

```cql
include USCoreCommon version '3.1.1' called UC3
include USCoreCommon version '6.1.0' called UC6
include USCoreCommon version '7.0.0' called UC7
```

Allowing aliasing of included declarations:

```cql
include USCoreCommon called UC3 {
    declaration race() called race3()
}
```

Allowing binding of parameters in included libraries:

```cql
include CQMCommon

parameter "Measurement Period" bound to CQMCommon."Measurement Period"
```

These features will improve the ability to reuse content from other authors where you may not have control over the content of the library.

### Improved Implementer Support

The next version of CQL will propose some implementer-focused simplifications as well:

#### Simplifying ELM

First, we are considering opportunities to reduce the number of types of ELM nodes. For example, there is a generic ConvertNode, as well as specific ToString node, which are conceptually implementing the same operation when dealing with conversion to a string. We are considering whether implementations could be streamlined by switching to always use the ConvertNode, for example.

In addition, this same pattern appears for many of the system-defined operations. For example, addition can be represented as an AdditionNode, as well as with a FunctionRef.

#### Standard Libraries

In addition, the 2.0 Version will consider moving some of the system-defined operations into Standard Libraries, rather than having them be part of the CQL specification itself. For example, String manipulation functions could be provided with a Standard Library, rather than as part of the base specification.

