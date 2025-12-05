This page documents proposed changes to the [Observation Patterns](https://build.fhir.org/ig/HL7/us-cql-ig/patterns-observation.html) in the US CQL IG

#### Status

The USCoreCommon library defines functions and terminology declarations to support determining status of an observation:

* [`isResulted()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isResulted,-%28observation%20FHIR): returns true if the status is `final`, `amended`, or `corrected`
* [`isFinal()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isFinal,-%28observation%20FHIR): Returns true if the status is `final`
* [`isAmended()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isAmended,-%28observation%20FHIR): Returns true if the status is `amended`
* [`isCorrected()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isCorrected,-%28observation%20FHIR): Returns true if the status is `corrected`

As well as for filtering lists of observations with a given status:

* [`resulted()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,resulted,-%28observations%20List): returns Observations in the given list with a status is `final`, `amended`, or `corrected`
* [`final()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,final,-%28observations%20List): Returns Observations in the given list with a status is `final`
* [`amended()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,amended,-%28observations%20List): Returns Observations in the given list with a status is `amended`
* [`corrected()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,corrected,-%28observations%20List): Returns Observations in the given list with a status is `corrected`

#### Category

* [`.hasCategory(Code)`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,hasCategory,-%28observation%20FHIR): Returns true if the given observation has the given category
* [`.isSocialHistory()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isSocialHistory,-%28observation%20FHIR): Returns true if the given observation has a category of social history
* [`.isVitalSign()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isVitalSign,-%28observation%20FHIR): Returns true if the given observation has a category of vital sign
* [`.isImaging()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isImaging,-%28observation%20FHIR): Returns true if the given observation has a category of imaging
* [`.isLaboratory()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isLaboratory,-%28observation%20FHIR): Returns true if the given observation has a category of laboratory
* [`.isProcedure()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isProcedure,-%28observation%20FHIR): Returns true if the given observation has a category of procedure
* [`.isSurvey()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isSurvey,-%28observation%20FHIR): Returns true if the given observation has a category of survey
* [`.isExam()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isExam,-%28observation%20FHIR): Returns true if the given observation has a category of exam
* [`.isActivity()`](http://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isActivity,-%28observation%20FHIR): Returns true if the given observation has a category of activity

#### Interpretation

Note that the interpretation element of an observation may not be present, and may not be coded as expected. Care must be taken in the use of this element to ensure that data conforms with the expectations of the logic.

* [`.positive()`](http://build.fhir.org/ig/HL7/us-cql-ig/Library-USCoreCommon.html#:~:text=define%20fluent%20function-,positive,-%28observations%20List): Returns Observations in the given list that have an interpretation of positive
* [`.negative()`](http://build.fhir.org/ig/HL7/us-cql-ig/Library-USCoreCommon.html#:~:text=define%20fluent%20function-,negative,-%28observations%20List): Returns Observations in the given list that have an interpretation of negative

#### Timings

* [`.during(Encounter)`](http://build.fhir.org/ig/HL7/us-cql-ig/Library-USCoreCommon.html#:~:text=define%20fluent%20function-,during,-%28observations%20List): Returns Observations in the given list that were issued during the given Encounter
* [`.within(Quantity)`](http://build.fhir.org/ig/HL7/us-cql-ig/Library-USCoreCommon.html#:~:text=define%20fluent%20function-,within,-%28observations%20List): Returns Observations in the given list that were issued within the given time duration before now
* [`.consecutively()`](http://build.fhir.org/ig/HL7/us-cql-ig/Library-USCoreCommon.html#:~:text=define%20fluent%20function-,consecutively,-%28observations%20List): Returns Observations consecutively by when they were issued
* [`.consecutivelyFrom(Observation)`](http://build.fhir.org/ig/HL7/us-cql-ig/Library-USCoreCommon.html#:~:text=define%20fluent%20function-,consecutivelyFrom,-%28observations%20List): Returns Observations consecutively by when they were issued, on or after when the given Observation was issued  

#### Observation Elements

In addition, the USCoreElements library defines expressions for accessing the various USCore profiles, such as:

* [`"All Laboratory Results"`](http://build.fhir.org/ig/HL7/us-cql-ig/Library-USCoreElements.html#:~:text=observation%2Dlab%0A*/%0Adefine-,%22All%20Laboratory%20Results%22,-%3A%0A%20%20%5B%22LaboratoryResultObservationProfile)
* [`"Resulted Laboratory Results"`](http://build.fhir.org/ig/HL7/us-cql-ig/Library-USCoreElements.html#:~:text=%22Resulted%20Laboratory%20Results%22)
* `"Pediatric BMI for Age"`

In general, the expressions to retrieve observations for a particular profile include the `.resulted()` function to ensure only final, amended, or corrected observations are returned.

### Examples

#### Three Consecutive Negative Stick Tests

This example illustrates logic for identifying three consecutive negative "stick tests":

```cql
define StickTest:
  [Observation: "Stick Test Codes"] O
    where O.status in { 'final', 'amended', 'corrected' }

define "Three Consecutive Negative Stick Tests":
  exists (
    StickTest.during(Encounter).consecutively().take(3).negative().count() = 3
  )
```

In addition, this expression can be parameterized with current context (for example from a trigger context) with:

```cql
StickTest.consecutivelyFrom(%context).take(3).negative().count() = 3
```

> These changes are proposed for inclusion in the US CQL IG: (https://jira.hl7.org/browse/FHIR-53459)
