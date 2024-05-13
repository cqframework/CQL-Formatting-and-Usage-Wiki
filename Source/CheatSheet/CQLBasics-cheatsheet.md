# CQL Basics Cheat Sheet

## [Values](https://cql.hl7.org/02-authorsguide.html#values)

|Value|Description|Example|
|-----|-----------|-------|
|Null|The null literal|<pre lang="cql">null</pre>|
|Boolean|The boolean literals|<pre lang="cql">true, false</pre>|
|Integer|Sequences of digits in the range 0..2<sup>31</sup>-1|<pre lang="cql">16, -28</pre>|
|Long|Sequences of digits in the range 0..2<sup>63</sup>-1|<pre lang="cql">16000000000, -28000000000</pre>|
|Decimal|Sequences of digits with a decimal point, in the range 0.0.. (10<sup>28</sup>-1)/10<sup>8</sup>|<pre lang="cql">100.015</pre>|
|String|Strings of any character enclosed within single-ticks (')|<pre lang="cql">'pending', 'active', 'complete'</pre>|
|Date|The at-symbol (@) followed by an ISO-8601 compliant representation of a date|<pre lang="cql">@2014-01-25</pre>|
|DateTime|The at-symbol (@) followed by an ISO-8601 compliant representation of a datetime|<pre lang="cql">@2014-01-25T14:30:14.559&#13;@2014-01T</pre>|
|Time|The at-symbol (@) followed by an ISO-8601 compliant representation of a time|<pre lang="cql">@T12:00&#13;@T14:30:14.559</pre>|
|Quantity|An integer or decimal literal followed by a datetime precision specifier, or a UCUM unit specifier|<pre lang="cql">6 'gm/cm3'&#13;80 'mm[Hg]'&#13;3 months</pre>|
|Ratio|A ratio of two quantities, separated by a colon (:)|<pre lang="cql">1:128&#13;5 'mg' : 10 'mL'</pre>|
|Code|Construct consistent with the way terminologies are typically represented|<pre lang="cql">Code '66071002' from "SNOMED-CT" display 'Type B viral hepatitis'</pre>|
|Concept|Construct to specify multiple terminologies used to code for the same concept|<pre lang="cql">Concept {&#13;  Code '66071002' from "SNOMED-CT",&#13;  Code 'B18.1' from "ICD-10-CM"&#13;} display 'Type B viral hepatitis'</pre>|
|Tuple|Structured values that contain named elements, each having a value of some type|<pre lang="cql">define "Info":&#13;  Tuple {&#13;    Name: 'Patrick',&#13;    DOB: @2014-01-01,&#13;    Address: Tuple { Line1: '41 Spinning Ave', City: 'Dayton', State: 'OH' },&#13;    Phones: { Tuple { Number: '202-413-1234', Use: 'Home' } }&#13;  }</pre>|
|List|A collection of values of any type|<pre lang="cql">{ 1, 2, 3, 4, 5 }&#13;[Condition: code in "Acute Pharyngitis"]</pre>|
|Interval|Set of values between two boundaries that can be inclusive ([]) or exclusive (())|<pre lang="cql">Interval[3, 5) // 3 and 4, but not 5&#13;Interval[@2014-01-01, @2015-01-01) // same as Interval[@2014-01-01, @2014-12-31]</pre>|

## [Symbols](https://cql.hl7.org/03-developersguide.html#symbols)

|Symbol|Description|
|------|-----------|
|:|Definition operator, typically read as "defined as". Also used to separate the numerator from denominator in Ratio literals|
|()|Parentheses for delimiting groups, as well as specifying and passing function parameters|
|[]|Brackets for indexing into lists and strings, as well as delimiting the retrieve expression|
|{}|Braces for delimiting lists and tuples|
|<>|Angle-brackets for delimiting generic types within type specifiers|
|.|Period for qualifiers and accessors|
|,|Comma for delimiting items in a syntactic list|
|= != ~ !~ <= < > >=|Comparison operators for comparing values|
|+ - * / ^|Arithmetic operators for performing calculations|

## [Identifiers](https://cql.hl7.org/03-developersguide.html#identifiers)

|Type|Description|Example|
|----|-----------|-------|
|Simple|Any alphabetical character or an underscore, followed by any number of alpha-numeric characters or underscores|<pre lang="cql">Foo1</pre>|
|Delimited|any sequence of characters enclosed in backticks (`)|<pre lang="cql">\`Encounter, Performed\`</pre>|
|Quoted|Any sequence of characters enclosed in double-quotes (")|<pre lang="cql">"Inpatient Encounters"</pre>|
|Qualified|Identifiers can be combined using the qualifier operator (.)|<pre lang="cql">Common.ConditionsIndicatingSexualActivity</pre>|

## [Comments](https://cql.hl7.org/03-developersguide.html#comments)

|Type|Example|
|----|-------|
|single-line|<pre lang="cql">define "Foo": 1 + 1 // This is a single-line comment</pre>|
|multi-line|<pre lang="cql">/\*&#13;This is a multi-line comment&#13;Any text enclosed within is ignored&#13;\*/</pre>|

## [Declarations](https://cql.hl7.org/02-authorsguide.html#declarations)

|Construct|Description|
|---------|-----------|
|library|Header information for the library, including the name and version, if any|
|using|Data model information, specifying that the library may access types from the referenced data model|
|include|Referenced library information, specifying that the library may access constructs defined in the referenced library|
|codesystem|Codesystem information, specifying that logic within the library may reference the specified codesystem by the given name|
|valueset|Valueset information, specifying that logic within the library may reference the specified valueset by the given name|
|code|Code information, specifying that logic within the library may reference the specified code by the given name|
|concept|Concept information, specifying that logic within the library may reference the specified concept by the given name|
|parameter|Parameter information, specifying that the library expects parameters to be supplied by the evaluating environment|
|context|Specifies the overall context, such as Patient or Practitioner, to be used in the statements that are declared in the library|
|define|The basic unit of logic within a library, a define statement introduces a named expression that can be referenced within the library, or by other libraries|
|function|A named expression that is allowed to take any number of arguments, each of which has a name and a declared type|

```cql
library ExampleLibraryWithAllDeclarations version '1.0.0'

using FHIR version '4.0.1'

include CommonLibrary called Common

codesystem LOINC: 'http://loinc.org'
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'
code "Blood Pressure Panel": '85354-9' from LOINC
concept "Blood Pressure Codes": { "Blood Pressure Panel" }

parameter "Measurement Period" default Interval[@2013-01-01, @2014-01-01)

context Patient

define "Inpatient Encounters":
  [Encounter: "Encounter Inpatient"] Encounter
    where Common.NormalizePeriod(Encounter.period) ends during day of "Measurement Period"

define "Most Recent Blood Pressure Labs":
  MostRecent([Observation: value in "Blood Pressure Codes"]) 

define function MostRecent(observations List<Observation>):
  Last(
    observations O
      sort by issued
  )
```

## [Named Expressions](https://cql.hl7.org/02-authorsguide.html#statements)

|Type|Example|
|----|-------|
|Statement|<pre lang="cql">define SimpleStatement: 'This is simple!'</pre>|
|Function|<pre lang="cql">define function MostRecent(observations List<Observation>):&#13;  Last(&#13;    observations O&#13;      sort by issued&#13;  )</pre>|

## [Retrieve (Primary Source)](https://cql.hl7.org/02-authorsguide.html#retrieve)

|Concept|Description|Example|
|-------|-----------|-------|
|Clinical Statement|Determines the structure of the data that is returned by the retrieve, as well as the semantics of the data involved|<pre lang="cql">[Encounter]</pre>|
|Filtering with Terminology|The retrieve expression allows the results to be filtered using terminology, including valuesets, code systems, or by specifying a single code|<pre lang="cql">[Condition: severity in "Acute Severity"]</pre>|

## [Query](https://cql.hl7.org/02-authorsguide.html#queries)

|Clause|Operation|Example|
|------|---------|-------|
|Relationship (with/without)|Allows relationships between the primary source and other clinical information to be used to filter the result|<pre lang="cql">[Encounter: "Ambulatory/ED Visit"] E&#13;  with [Condition: "Acute Pharyngitis"] P&#13;    such that P.onsetDateTime during E.period&#13;      and P.abatementDate after end of E.period</pre>|
|Where|The where clause allows conditions to be expressed that filter the result to only the information that meets the condition|<pre lang="cql">[Encounter: "Inpatient"] E&#13;  where duration in days of E.period >= 120</pre>|
|Return|The return clause allows the result set to be shaped as needed, removing elements, or including new calculated values|<pre lang="cql">[Encounter: "Inpatient"] E&#13;  return E.lengthOfStay</pre>|
|Sort|The sort clause allows the result set to be ordered according to any criteria as needed|<pre lang="cql">[Encounter: "Inpatient"] E&#13;  sort by start of period</pre>|
