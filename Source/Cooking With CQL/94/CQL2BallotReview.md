Clinical Quality Language has been published as an HL7 and ANSI Normative standard since December of 2020. ANSI Normative standards must be reaffirmed every 5 years, so the time has come to reaffirm the specification. In addition, we have been steadily gathering implementer feedback and author feature requests over the years. There have been 2 errata publications where we have found issues that needed correction or clarification, but feedback and requests that are substantive in nature have had to wait for the next release. We have discussed, resolved, and applied that feedback to the specification, and will be balloting the proposed update in the September cycle.

As a result, there are two ballots for CQL in the September cycle.

1. Reaffirmation of Clinical Quality Language, Release 1
2. STU Ballot of Clinical Quality Language, Release 2

Signup pools are still open through Thursday, August 7th.

This topic will provide an overview of the substantive changes to the specification proposed in the ballot.

Importantly, no breaking changes have been introduced in CQL R2.

### Directives

* [FHIR-41326](https://jira.hl7.org/browse/FHIR-41326) - Added directive support and defined default comparison precision

Directives provide an ability for translator options to be provided as part of the language.

https://build.fhir.org/ig/HL7/cql/03-developersguide.html#directives

#### Default Comparison Precision

The first usage of directives is to provide a _default comparison precision_:

```cql
#DefaultComparisonPrecision: minutes
```

Means that all comparisons within the library that do not explicitly specify a precision will be performed to the minute.

```cql
#DefaultComparisonPrecision: minutes default included libraries
```

Means that this behavior will also be carried to included libraries that do not specify their own default comparison precision.

https://build.fhir.org/ig/HL7/cql/03-developersguide.html#defaultcomparisonprecision

### Using Enhancements

CQL R2 introduces several enhancements to data model support.

#### Model Qualifiers

* [FHIR-31019](https://jira.hl7.org/browse/FHIR-31019)

Using statements can now include namespace qualifiers, allowing models to be referenced globally in the same way that libraries are.

```cql
using hl7.fhir.us.core.USCore
```

#### Model Aliases

* [FHIR-48762](https://jira.hl7.org/browse/FHIR-48762)

Using statements can now also include a `called` clause, allowing multiple versions of the same model to referenced:

```cql
using hl7.fhir.us.core.USCore version '7.0.0' called USCore7
using hl7.fhir.us.core.USCore version '8.0.0' called USCore8
```

https://build.fhir.org/ig/HL7/cql/03-developersguide.html#data-models-1

#### Model Definitions

* [FHIR-34014](https://jira.hl7.org/browse/FHIR-34014) - Added the ability to declare named tuple types
* [FHIR-48760](https://jira.hl7.org/browse/FHIR-48760) - Added the ability to define models including types, contexts, and conversions in CQL directly

In addition, the components of models can now be defined directly within CQL with the introduction of `define type`, `define context`, and `define conversion` statements:

https://build.fhir.org/ig/HL7/cql/03-developersguide.html#defining-models

##### Type Definitions

CQL R2 includes support for defining named types with the new `define type` statement:

```cql
define public type Quantity extends System.Any {
  value System.Decimal,
  unit System.String
}
```

Once defined in a library, these types function like any other type defined in a model brought in with a using statement, allowing authors to build data models directly in CQL.

https://build.fhir.org/ig/HL7/cql/03-developersguide.html#defining-class-types

##### Context Definitions

CQL R2 includes support for defining contexts with the new `define context` statement:

```cql
define context Patient of type FHIR.Patient with key { id }
```

Once a context is defined, it can be used in a context statement like any context brought in with a using statement.

In addition, types can declare their relationship to contexts with the `related to` clause of the `define type` statement:

```cql
define type Observation extends DomainResource {
  subject Patient,
  code CodeableConcept,
  value Choice<CodeableConcept, Quantity>
  ...
}
related to Patient by { subject }
```

https://build.fhir.org/ig/HL7/cql/03-developersguide.html#defining-contexts

##### Conversion Definitions

CQL R2 includes support for defining conversions with the new `define conversion` statement:

```cql
define implicit conversion 
  from FHIR.Period to System.Interval<System.DateTime> 
  using FHIRHelpers.ToInterval
```

Once an implicit conversion is defined, it can be used to support implicit conversions like any other conversion brought in with a using statement.

Once an explicit conversion is defined, it can be referenced with the `convert` function like any other conversion.

https://build.fhir.org/ig/HL7/cql/03-developersguide.html#defining-conversions

### Parameter Enhancements

#### Parameter Constraints

* [FHIR-48682](https://jira.hl7.org/browse/FHIR-48682) - Added support for parameter constraints

CQL R2 includes support for parameter constraints:

```cql
/*
@constraint: error
@message: Measurement period must be a year
*/
define IsYearly: start of "Measurement Period" same year as end of "Measurement Period"
```

These constraints are expressions that must evaluate to true in order to make use of any expressions within the library.

https://build.fhir.org/ig/HL7/cql/03-developersguide.html#parameter-constraints

#### Parameter Binding

* [FHIR-33126](https://jira.hl7.org/browse/FHIR-33126) - Added parameter binding support

CQL R2 also introduces support for parameter binding:

```cql
include ColorectalCancerElements called CCE
  bind { AsOf: end of "Measurement Period" }
```

This example illustrates setting the `AsOf` parameter in the `ColorectalCancerElements` library to the `end of "Measurement Period"` in the current library.

https://build.fhir.org/ig/HL7/cql/03-developersguide.html#parameter-binding

### Terminology Enhancements

#### Equivalent Contains

* [FHIR-31675](https://jira.hl7.org/browse/FHIR-31675) - Added equivalent contains (~contains)

CQL R2 introduces support for _equivalent contains_, a contains operator that uses equivalent semantics, rather than equality semantics.

```cql
define "EquivalentContainsIsTrue": { 'A', 'B', 'C' } ~contains 'a'
define "EquivalentContainsIsFalse": { 'B', 'C' } ~contains 'a'
```

This support enables not only equivalent contains use cases like the above examples, but terminological contains as well:

```cql
define CodeSystemContainsExample: SNOMED ~contains "Random SNOMED Code"
define ValueSetContainsExample: "Inpatient Encounter" ~contains "Random CPT Code"
```

In addition to providing a generally useful operation, this is used in the retrieve later to enable an important set of use cases involving negation and direct-reference codes.

https://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#equivalentcontains

https://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#contains-codesystem

https://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#in-codesystem

#### Equivalent In


* [FHIR-33247](https://jira.hl7.org/browse/FHIR-33247) - Added equivalent in (~in)

CQL R2 introduced the _equivalent in_ operator to clearly distinguish between equality- and equivalent-based membership:

```cql
define "EquivalentInIsTrue": 'a' ~in { 'A', 'B', 'C' }
define "EquivalentInIsFalse": 'a' ~in { 'B', 'C' }
```

And as with the ~contains operator, the terminological membership operators then make use of this new equivalent in:

```cql
define InCodeSystemExample: "Random SNOMED Code" ~in "SNOMED"
define InValueSetExample: "Random CPT Code" ~in "Inpatient Encounter"
```

For backwards compatibility, `in` still resolves to the terminological membership operators, but using the new `~in` operator makes it explicit that equivalent in is being used.

https://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#equivalentin

https://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#in-codesystem

https://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#in-valueset


#### Contains In a Retrieve

* [FHIR-31392](https://jira.hl7.org/browse/FHIR-31392) - Added ~contains as a retrieve terminology comparator

A significant outstanding issue with supporting the use of direct-reference codes throughout CQL is the negation patterns. When the _extent_ of an activity is represented with a value set, rather than a specific code, then the negation statement looking for negation of a particular code requires the use of the new `~contains` operation. This can now be specified explicitly as in:

```cql
define "Reason for Macular Edema Absent Not Communicated (Explicit equivalent contains)":
  [CommunicationNotDone: reasonCode ~contains "Macular edema absent (situation)"]
```

And this now means that direct-reference codes can be the target of a negation retrieve, such as:

```cql
define "Reason for Macular Edema Absent Not Communicated (Implicit equivalent contains)":
  [CommunicationNotDone: "Macular edema absent (situation)"]
```

https://build.fhir.org/ig/HL7/cql/04-logicalspecification.html#codecomparator

### Miscellaneous New Functions

#### Round(Quantity)

* [FHIR-51030](https://jira.hl7.org/browse/FHIR-51030)

CQL R2 adds the ability to round Quantity values:

```cql
define "QuantityRound": Round(2.54 'cm') // 2 'cm'
```

https://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#round

#### MatchesFull

* [FHIR-50456](https://jira.hl7.org/browse/FHIR-50456)

CQL R2 adds a MatchesFull function, which is a regex match that is required to match the entire string, as opposed to the Matches operation which by default uses partial matching.

```cql
define MatchesFullFalse: 'http://fhir.org/guides/cqf/common/Library/FHIR-ModelInfo|4.0.1'.matchesFull('Library') // returns false
define MatchesFullAlsoFalse: 'N8000123123'.matchesFull('N[0-9]{8}') // returns false as the string is not an 8 char number (it has 10)
define MatchesFullTrue: 'N8000123123'.matchesFull('N[0-9]{10}') // returns true as the string has an 10 number sequence in it starting with `N`
```

https://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#matchesfull

#### Slice

* [FHIR-40612](https://jira.hl7.org/browse/FHIR-40612)

CQL R2 adds a Slice function that is a generalization of the Take, Skip, and Tail functions:

```cql
define SliceStart: Slice({ 1, 2, 3, 4, 5 }, 1) // { 2, 3, 4, 5 }
define SliceEnd: Slice({ 1, 2, 3, 4, 5 }, 1, 3) // { 2, 3 }
```

https://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#slice

### FHIRPath Alignment

* [FHIR-48809](https://jira.hl7.org/browse/FHIR-48809) - Added FHIRPath mapping for additional string functions
* [FHIR-48829](https://jira.hl7.org/browse/FHIR-44829) - Added FHIRPath mapping for precision and boundary functions
* [FHIR-48828](https://jira.hl7.org/browse/FHIR-44828) - Added FHIRPath mapping for date/time extractors
* [FHIR-44827](https://jira.hl7.org/browse/FHIR-44827) - Added FHIRPath mapping for defineVariable

In addition, CQL R2 incorporates updates made to FHIRPath as part of a ballot earlier this year. In that update, FHIRPath added support for several capabilities and functions that were already defined in CQL. This support was added to FHIRPath with the same semantics as CQL, and now this update to CQL R2 adds FHIRPath mappings for that functionality to ensure that we maintain alignment between the two specifications.

https://build.fhir.org/ig/HL7/cql/16-i-fhirpathtranslation.html

### Non-Substantive Changes

In addition CQL R2 includes a host of corrections, fixes, and clarifications, including providing more examples of FHIR usage throughout.

The final ballot specification will include a complete description of the changes made to the specification.

The ballot will be open for voting August 8th to September 8th.