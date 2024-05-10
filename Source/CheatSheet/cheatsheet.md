# CQL Cheat Sheet

Clinical Quality Language [(CQL)](http://cql.hl7.org) is a Health Level 7 Standard for representing clinical logic. This cheat sheet provides a quick reference for the most commonly used features of the language. For more resources, see the [Getting Started](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Getting-Started) page of the CQL Formatting and Usage Wiki.

## [**Declarations**](https://cql.hl7.org/02-authorsguide.html#declarations)

CQL libraries consist of a set of _declarations_:

The [Library](https://cql.hl7.org/02-authorsguide.html#library) declaration specifies the name of the library and optionally a version

```cql
library AlphoraCommon version '1.0.0'
```

[Using](https://cql.hl7.org/02-authorsguide.html#data-models) declarations indicate which data model(s) can be used in the library

```cql
using FHIR version '4.0.1'
```

[Include](https://cql.hl7.org/02-authorsguide.html#libraries) declarations allow you to reference declarations from other libraries. The `called` clause lets you specify what identifier to use to access declarations in the included library

```cql
include FHIRCommon called FC
```

[Terminology](https://cql.hl7.org/02-authorsguide.html#terminology) declarations let you reference externally defined terminologies

```cql
codesystem LOINC: 'http://loinc.org'
valueset "Inpatient Encounter Codes": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'
code "Blood pressure panel": '85354-9' from LOINC
```

[Parameter](https://cql.hl7.org/02-authorsguide.html#parameters) declarations let you define parameters that can be used in the library

```cql
parameter "Measurement Period" default Interval[@2013-01-01, @2014-01-01)
```

[Context](https://cql.hl7.org/02-authorsguide.html#context) declarations define the _extent_ of data available to be retrieved (e.g. the data for a patient)

```cql
context Patient
```

[Statement](https://cql.hl7.org/02-authorsguide.html#statements) declarations let you define named expressions that can be used to build quality measures and decision support rules

```cql
define "Inpatient Encounter":
  [Encounter: "Encounter Inpatient"] Encounter
    where Encounter.status = 'finished'
      and Encounter.period ends during day of "Measurement Period"
```
  
### [**Retrieve syntax**](https://cql.hl7.org/02-authorsguide.html#retrieve)

The retrieve expression is the central construct for accessing clinical information within CQL. The retrieve in CQL has two main parts: the "type part" and the "terminology filter part".

1) [type part](https://cql.hl7.org/02-authorsguide.html#clinical-statement-structure) : identifies the type of data that is to be retrieved

```cql
[Encounter]
```

2) [terminology filter part](https://cql.hl7.org/02-authorsguide.html#filtering-with-terminology) : the retrieve expression allows the results to be filtered using terminology, including value sets, code systems, or by specifying a single code.

- The example below filters the results to only Conditions whose code is in the "Acute Pharyngitis" value set.

```cql
[Condition: "Acute Pharyngitis"]
```

- The example below returns Encounters with type in the "Encounter Inpatient" value set.

```cql
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'

define "Inpatient Encounter":
  [Encounter: type in "Encounter Inpatient"]
```

- The example below retrieves Conditions with codes equivalent to the "Diabetes Code" direct-reference code.

```cql
code "Diabetes Code": '123' from "LOINC"

define "Diabetes Conditions":
  [Condition: code ~ "Diabetes Code"]
```

### [**Functions**](https://cql.hl7.org/19-l-cqlsyntaxdiagrams.html#function)

A function in CQL is a named expression that is allowed to take any number of arguments. A function can be invoked directly by name.

```cql
define function MostRecent(observations List<Observation>):
  Last(
    observations O
      sort by issued
  )
```

In this example, the function takes a list of Observations, sorts them by their issued date and returns the last one that has been issued.

### [**Identifiers**](https://cql.hl7.org/03-developersguide.html#identifiers)
Identifiers are used to name various elements within the language. There are three types of identifiers in CQL, simple, delimited, and quoted.

```cql
Foo1 // simple
`Encounter, Performed` // delimited
"Inpatient Encounters" // quoted
```

## Strings vs Identifiers

**Strings use single quotation marks.**

[Single Quotes](https://cql.hl7.org/19-l-cqlsyntaxdiagrams.html#string) 

Single quotes are used for string values, as well as for the values of parts of declarations such as terminology identifiers
1) text
```cql
define "String Value": 'hello'
```

2) Code system and value set identifiers
```cql
valueset "Example Value Set":  'http://example.org/fhir/ValueSet/example'
```

3) version identifiers
```cql
valueset "Example Code System":  'http://example.org/fhir/ValueSet/example' version '123'
```

4) code declarations
```cql
code "Example Code": '123' from "http://example.org/fhir/CodeSystem/example"
```

5) units
```cql
define "Example Quantity": 12.0 'L'
```

**Double quotes are used for identifiers**

[Quoted Identifiers](https://cql.hl7.org/19-l-cqlsyntaxdiagrams.html#QUOTEDIDENTIFIER)

This applies to expression definitions, functions, valuesets, codes, etc... 

```cql
"SNOMED CT" // A code system declaration
"Inpatient Encounters" // A Value Set
```

## Brackets

1. [Intervals](https://cql.hl7.org/19-l-cqlsyntaxdiagrams.html#intervalSelector) use [] and (). Following standard mathematics notation, inclusive (closed) boundaries are indicated with square brackets, and exclusive (open) boundaries are indicated with parentheses.

```cql
Interval[3,5) // An interval >= 3 and < 5
Interval(3,5) // An interval > 3 and < 5
Interval(3,5] // An interval > 3 and <= 5
```

2. [Lists and Tuples](https://cql.hl7.org/19-l-cqlsyntaxdiagrams.html#tupleSelector) use { }

```cql
define "Union Example":
  { 1, 2, 3 } union { 3, 4, 5 }

define "Info": 
  Tuple { Name: 'Patrick', DOB: @2014-01-01 }
```

## Queries

### [**Full Query Syntax**](https://cql.hl7.org/02-authorsguide.html#full-query)

The clauses, described in the clauses section later, must appear in the correct order in order to specify a valid CQL query. The general order of clauses is:

```bnf
<primary-source> <alias>
  <with-or-without-clauses>
  <where-clause>
  <return-clause>
  <sort-clause>
```
[Jump to query clauses section](#queryclauses)

### [**Aliases**](https://cql.hl7.org/02-authorsguide.html#queries)

Queries begin by introducing an alias (`E` in the following example), followed by _clauses_ (a where clause in this example):
 
```cql
define "Ambulatory Encounters":
  [Encounter: "Ambulatory/ED Visit] E
    where E.status = 'finished'
```

### [**With/Without**](https://cql.hl7.org/02-authorsguide.html#relationships)

```cql
define "Ambulatory Encounter With Acute Pharyngitis":
  [Encounter: "Ambulatory/ED Visit"] E
    with [Condition: "Acute Pharyngitis"] P
      such that P.onset during A.period
        and P.abatement after end of A.period
```

<!-- // TODO: All the things from the "developer's guide" should probably be on Page 2, like organize the whole thing so that the first page is just "Author's Guide" stuff, the simple CQL, and the more advanced content is on page 2 -->

### [**Multi-source queries**](https://cql.hl7.org/03-developersguide.html#multi-source-queries) 

CQL provides multi-source queries to allow for the simple expression of complex relationships between different sets of data. In Multi-source queries multiple objects are returned.

```cql
define "Encounters with Warfarin and Parenteral Therapies":
  from "Encounters" E,
    "Warfarin Therapy" W,
    "Parenteral Therapy" P
  where W.effectiveTime starts during E.period and P.effectiveTime starts during E.period
```

## Expressions

### [**Conditional expressions**](https://cql.hl7.org/03-developersguide.html#conditional-expressions)

CQL provides two flavors of conditional expressions, the `if` expression, and the `case` expression.

1) If expression: It allows one single condition to be selected

```cql
if Count(X) > 0 then X[1] else 0
```

2) Case expression : It allows multiple conditions to be tested.

```cql
case
  when X > Y then X
  when Y > X then Y
  else 0
end
```
## Values

### [**Simple values**](https://cql.hl7.org/02-authorsguide.html#simple-values) 

| Type | Examples |
|----|----|
| [Boolean](https://cql.hl7.org/02-authorsguide.html#boolean) | `true`, `false` |
| [Integer](https://cql.hl7.org/02-authorsguide.html#integer) | `16`, `-28` |
| [Decimal](https://cql.hl7.org/02-authorsguide.html#decimal) | `100.015` |
| [String](https://cql.hl7.org/02-authorsguide.html#string) | `pending`, `John Doe`, `complete` |
| [Date](https://cql.hl7.org/02-authorsguide.html#date-datetime-and-time) | `@2014-01-25` |
| [DateTime](https://cql.hl7.org/02-authorsguide.html#date-datetime-and-time) | `@2014-01-25T14:30:14.559Z` |
| [Time](https://cql.hl7.org/02-authorsguide.html#date-datetime-and-time) | `@T12:00` |

### [**Clinical Values**](https://cql.hl7.org/02-authorsguide.html#clinical-values)

| Type | Examples |
|----|----|
| [Quantity](https://cql.hl7.org/02-authorsguide.html#quantities) | `3 months`, `5 'mg'` |
| [Ratio](https://cql.hl7.org/02-authorsguide.html#ratios) | `5 'mg' : 10 'mL'`, `2 : 20` |
| [Code](https://cql.hl7.org/02-authorsguide.html#code) | `code "Blood pressure": '55284-4' from "LOINC" display 'Blood pressure'` |

4. [Tuples](https://cql.hl7.org/02-authorsguide.html#structured-values-tuples) are values that contain named elements, each having a value of some type. In this example, the tuple type is set using the keyword `Patient`

```cql
define "PatientExpression": 
  Patient { Name: 'Patrick', DOB: @2014-01-01 }
```

5. [Missing Information](https://cql.hl7.org/02-authorsguide.html#missing-information) is common in clinical settings, and CQL uses the keyword `null` to represent the unknown or missing information. In this example, the statement will return Observations that have no value. 

```cql
define "Missing Status":
  [Observation] O 
    where O.value is null
```

6. [List Values](https://cql.hl7.org/02-authorsguide.html#list-values) can be of any type of value (including other lists). Although some operations may result in lists containing mixed types, in normal use cases, lists contain items that are all of the same type.

```cql
{ 1, 2, 3, 4, 5 }
```

7. [Interval values](https://cql.hl7.org/02-authorsguide.html#interval-values) can be inclusive or exclusive and represent the low and high points of an interval

```cql
Interval[3, 5)
```

## <a name="queryclauses">Query Clauses</a>  

[**Where clause where exists + where not exists + exists**](https://cql.hl7.org/02-authorsguide.html#filtering) to filter retrieved data. Where clauses are allowed to contain any arbitrary combination of operations of CQL, so long as the overall result of the condition is boolean-valued.

In the example below, the `where` clause is used to filter encounters based on the encounter period

```cql
define "Inpatient Encounters":
  [Encounter: "Inpatient"] Encounter
    where Encounter.period during "Measurement Period"
```

`where exists` filters data based on an existing query

```cql
define "Quantitative Laboratory Encounters":
  [Encounter] E
    where exists (["Observation"] O)
```

```cql
define "Had chest CT in past year":
  exists ("Chest CT procedure" P
    where FC.ToInterval(P.performed) ends 1 year or less before Today() 
  )
``` 

`where not exists` filters data based on a missing or non existant query

```cql
define "Encounter Without Procedure ":
  [Encounter] E
    where not exists
    ( [Procedure] P
      where P.performed as dateTime during E.period 
    )
``` 

[**With/Without clause and such that**](https://cql.hl7.org/02-authorsguide.html#relationships) : to define relationships with other data. When multiple with or without clauses appear in a single query, the result will only include elements that meet the “such that” conditions for all the relationship clauses.

```cql
define "Inpatient Encounters":
  [Encounter: "Inpatient"] Encounter
    with ["Observation": "Streptococcus Test"] Lab Test
      such that Observation.issued during Encounter.period
```  

[**Return clause**](https://cql.hl7.org/02-authorsguide.html#shaping) : determines the overall shape of the query result.

```cql
define "Inpatient Encounters":
  [Encounter: "Inpatient"] Encounter
    return Encounter.period
```

[**Sort clause**](https://cql.hl7.org/02-authorsguide.html#sorting): to order the results ascending or descending. If no order is specified, the order will defult to ascending.

```cql
define "Performed Encounters":
  ["Encounter" : "Inpatient"] Encounter
    sort by start of period
```

[**Let clause**](https://cql.hl7.org/03-developersguide.html): to help introduce content that can be referenced within the scope of the query, they do not impact the type of the result unless referenced within a return clause.

```cql
define "Medication Ingredients":
  "Medications" M
    let ingredients: GetIngredients(M.rxNormCode)
    return ingredients
```

[**Aggregate clause**](https://cql.hl7.org/03-developersguide.html#aggregate-queries): allows an expression to be repeatedly evaluated for each element of a list. **Important Note: The aggregate clause is a new feature of CQL 1.5, and is trial-use.**

```cql
define FactorialOfFive:
  ({ 1, 2, 3, 4, 5 }) Num
    aggregate Result starting 1: Result * Num
```

## Basic Operators

### [**Indexing**](https://cql.hl7.org/03-developersguide.html#string-operators)  
Indexes are 0 based, index 1, is index 0

```cql
define "FirstInpatientEncounter":
  return (Encounter [0])
```  

### [**Arithmetic Operators**](https://cql.hl7.org/02-authorsguide.html#arithmetic-operators)
CQL provides a complete set of arithmetic operations for expressing computational logic.

- Addition + , Subtraction - 

```cql
5 + 10 //returns 15
100 - 5 //returns 95
```

- Multiply \* , Divide /

```cql
3 months * 2 months //returns 6 months
12 months / 2 months //returns 6 months
```

- Truncate () – Returns the integer component of its argument

```cql
Truncate(12.4) //returns 12
```

- Round () - round to the nearest whole value

```cql
Round(123.5) //returns 124
```

- Floor () - round to the first integer less than or equal to it's argument (decimal)

```cql
Floor(123.456) //returns 123
```

- Ceiling () - round to the first integer greater than or equal to it's argument (decimal)

```cql
Ceiling(123.456) //returns 124
```

- Convert ()

```cql
convert 5000 'g' to 'kg' // returns 5.0 'kg'
```

- Count ()

```cql
Count({ 1, 2, 3, 4, 5 }) // returns 5
```

- Sum() 

```cql
Sum({ 1, 2, 3, 4, 5}) // returns 15
```

- Indexing

```cql
IndexOf({ 'a', 'b', 'c’ }, 'b') // returns 1
```
  
### [**List computation tools**](https://cql.hl7.org/02-authorsguide.html#list-operators)

1. [Operating on Lists](https://cql.hl7.org/02-authorsguide.html#interval-values)

if a list contains a single element, the singleton from operator can be used to extract it.

```cql
singleton from { 1 }
```

to obtain the index of a value within the list

```cql
IndexOf({ 'a', 'b', 'c' }, 'b') // returns 1
```

to obtain the number of elements in a list

```cql
Count({ 1, 2, 3, 4, 5 }) // returns 5
```

Membership in lists can be determined using the in operator and its inverse, contains

```cql
{ 1, 2, 3, 4, 5 } contains 4
4 in { 1, 2, 3, 4, 5 } 
```

To test whether a list contains any elements

```cql
exists ({ 1, 2, 3, 4, 5 })
```

The First and Last operators can be used to retrieve the first and last elements of a list.

```cql
First({ 1, 2, 3, 4, 5 }) // returns 11
```

2. [Comparing Lists](https://cql.hl7.org/02-authorsguide.html#comparing-lists)

`includes`, `includes in`, `properly includes` and `properly included in` are tools we can use to compare lists

- `includes` returns true if if every element in list Y is also in list X

```cql
{ 1, 2, 3, 4, 5 } includes { 5, 2, 3 } // returns true
{ 1, 2, 3, 4, 5 } includes { 4, 5, 6 } // returns false
```

- `included in` returns true if every element in list X is also in list Y

```cql
{ 5, 2, 3 } included in { 1, 2, 3, 4, 5 } // returns true
{ 4, 5, 6 } included in { 1, 2, 3, 4, 5 } // returns false
```

- `properly includes` returns true if every element in list Y is also in list X, and list X has more elements than list Y

```cql
{ 1, 2, 3 } properly includes { 1, 2, 3, 4, 5} // returns true
{ 1, 2, 3 } properly includes { 1, 2, 3 } // returns false
```

- `properly included in` return true if if every element in list X is also in list Y, and list Y has more elements than list X

```cql
{ 2, 3, 4 } properly included in { 1, 2, 3, 4, 5 } // returns true
{ 1, 2, 3 } properly included in { 1, 2, 3 } // returns false
```

3.  [Computing Lists](https://cql.hl7.org/02-authorsguide.html#computing-lists)

- `distinct` is used to eliminate duplicates.

```cql
Distinct({ 1, 2, 3, 4, 4}) // returns { 1, 2, 3, 4 }
```

- `union` is used to combine lists and eliminates duplicates.

```cql
{ 1, 2, 3 } union { 3, 4, 5 } // returns { 1, 2, 3, 4, 5 }
```

- `intersect` is used to only return the elements that are in both lists.

```cql
{ 1, 2, 3 } intersect { 3, 4, 5 } // returns { 3 }
```

- `flatten` is used to flatten lists of lists (does not eliminate duplicates).

```cql
flatten { { 1, 2, 3 }, { 3, 4, 5 } } // returns { 1, 2, 3, 3, 4, 5 }
```

4. [Aggregate Operators](https://cql.hl7.org/02-authorsguide.html#aggregate-operators)

This returns the number of encounters in the list

```cql
Count([Encounter])
```

This would return the sum of the values in the list

```cql
Sum({ 1, 2, 3, 4, 5 }) // returns 15
```

### [**Date Time Operators**](https://cql.hl7.org/02-authorsguide.html#datetime-operators)

**Important Note: All Date, Time and DateTime values are specified using an at-symbol (@) followed by an ISO-8601 textual representation of the DateTine value**

1. [Comparing Dates and Times](https://cql.hl7.org/02-authorsguide.html#comparing-dates-and-times) - Using comparison operators on dates

```cql
@2014-01-31 < @2014-02-01
```

2. [Extracting Date and Time Components](https://cql.hl7.org/02-authorsguide.html#extracting-date-and-time-components) - 
extracts only date/time/year.

```cql
date from @2014-01-25T14:30:14 // returns @2014-01-25
time from @2014-01-25T14:30:14 // returns @T14:30:14
year from @2014-01-25T14:30:14 // return 2014
```

3.  [Date Time Arithmetic](https://cql.hl7.org/02-authorsguide.html#datetime-arithmetic) -

where we are subtracting 1 year out of todays date to return the date 1 year back from now

```cql
Today() - 1 year
```

4.  [Computing Durations and Differences](https://cql.hl7.org/02-authorsguide.html#computing-durations-and-differences) -

```cql
duration in months between @2014 - 01 - 31 and @2014-02-01
```

5. [Current Time Date Operators](https://cql.hl7.org/02-authorsguide.html#constructing-datetime-values)

```cql
Now() // Current date and time
Today() // Current Date
TimeOfDay() // Current Time
```

### [**Interval tools**](https://cql.hl7.org/02-authorsguide.html#timing-and-interval-operators)

CQL supports the representation of intervals, or ranges, of values of various types.

1. [General Interval Operators](https://cql.hl7.org/02-authorsguide.html#operating-on-intervals) - `contains`, `start of`, `end of`,`point from` , `width of`

```cql
point from Interval[3, 3] // returns 3
width of Interval[3, 5] // returns 2
end of Interval[3, 5) // returns 4 
```

2. [Comparing Intervals](https://cql.hl7.org/02-authorsguide.html#comparing-intervals) \- the comparison between two interval values using a complete set of operations. This includes `same as`, `before`, `meets before`, `overlaps before` among others.

```cql
Interval[2, 6] same as Interval[2, 6] // returns true
Interval[1, 5] before Interval[6, 10] // returns true
Interval[1, 7] overlaps before Interval[5, 10] // returns true
Interval[1, 5] meets before Interval[6, 10] // returns true
```

3. [Timing operators on Intervals](https://cql.hl7.org/02-authorsguide.html#timing-relationships)

-  `same year as`

```cql
Date(2014) same year as Date(2014, 7, 11)
```

- `during`

```cql
["Encounter": "Inpatient"]
  where Encounter.period during "Measurement Period"
```

- `before/after`

```cql
Date(2014, 4) same month or before Date(2014, 7, 11)
Date(2014, 4) same month or after Date(2014, 7, 11)
```

- `within`

```cql
starts within 3 days of start (2014, 7, 11)
```

- `overlaps` 

```cql
[Condition: "Other Female Reproductive Conditions"] C
  where Interval[C.onsetDate, C.abatementDate] overlaps "Measurement Period"
```

4. [Computing Intervals](https://cql.hl7.org/02-authorsguide.html#computing-intervals)\- Using `union`, `intersect,` `except` to compute intervals

```cql
Interval[1, 3] union Interval[3, 6]
```

5. [Date Time Intervals](https://cql.hl7.org/02-authorsguide.html#datetime-intervals) 

```cql
Interval[Date(2014), Date(2015, 1, 1)]
```
  
### [**Comparison Operators**](https://cql.hl7.org/02-authorsguide.html#comparison-operators)

Can be used on numbers, strings, integers, dates, decimals

- Equality `=`
- Inequality `!=`
- Greater than `>`
- Less than `<`
- Greater than or equal `>=`
- Less than or equal `<=`
- Equivalent `~`
-  Inequivalent `!~`

```cql
4 >= 2 and 4 <= 8
```

### [**Logical Operators**](https://cql.hl7.org/02-authorsguide.html#logical-operators)

Logical operators are only operators that take boolean values as input and return boolean values.

```cql
AgeInYears() >= 18 and AgeInYears() < 24
```

```cql
define TestPrimitives:
  Patient P
    where P.gender.value = 'male' 
      and P.gender.value != 'female'
```

```cql
define "Absence of Cervix":
  [Procedure: "Hysterectomy with No Residual Cervix"] NoCervixProcedure
    where FC.ToInterval(NoCervixProcedure.performed) ends on or before end of "Measurement Period" 
      and NoCervixProcedure.status = 'completed'
```

### [**Type Operators**](https://cql.hl7.org/09-b-cqlreference.html#type-operators-1)

The `as` operator allows the result of an expression to be cast as a given target type

```cql
define "Former smoker observation":
  "Most recent smoking status observation" O
    where (O.value as CodeableConcept) ~ "Former Smoker"
```

The `is` operator allows the type of a result to be tested

```cql
define "Patient BirthDate is a Date":
  Patient P
    return P.birthDate is FHIR.date
```

### [**Nullological Operators**](https://cql.hl7.org/03-developersguide.html#nullological-operators)

1.  Null Test is used to test whether an expression is `null`

```cql
X is null 
X is not null
```

2. `Coalesce` operator is used to return the first non-null result among two or more expressions

```cql
Coalesce(X, Y, Z)
```

### [**String Operators**](https://cql.hl7.org/03-developersguide.html#string-operators)

<!-- // TODO: If it must be invoked with parentheses, it's a "function", whereas "operator" means a symbolic or keyword-based operation 
  NOTE (https://cql.hl7.org/03-developersguide.html#string-operators): spec defines these as string operators. This section matches the spec logic.-->

1. `Length` Operator is used to determine the length of string 

```cql
Length(X)
```

2. `PositionOf` Operator is used to determine the position of a string and will return the index of the string

```cql
PositionOf('cde', 'abcdefg') // returns 2
```

3. `Combine` operator is used to combine a list of strings

```cql
Combine({ 'ab', 'cd', 'ef' }) // returns 'abcdef'
```

4. `Split` Operator is used to split a list of strings

```cql
Split('completed;refused;pending', ';') // returns { 'completed', 'refused', 'pending' }
```

## Caveats

1.  Sort clauses don’t require usage of an alias. We don’t need to say E.sort by length of stay.

```cql
[Encounter: "Inpatient"] E
  return Tuple { id: E.identifier, lengthOfStay: duration in days of E.period }
  sort by lengthOfStay
```

2.  Return clause default behavior is to return distinct data.
Eg. if the query is to retrieve all blood pressure observations and if there are two blood pressure observations on the same date, only one observation will be returned. The all operator should be used to undo the default distinct behavior.
Eg. If two encounters have the same value for lengthOfStay, that value will only appear once in the result unless the all keyword is used

```cql
[Encounter: "Inpatient"] E
  return all E.lengthOfStay
```

3. Equality and Equivalence 

-  Note the use of the equivalent operator (~) rather than equality (=). For codes, equivalence tests only if the `system` and `code` are the same, but does not check the `version` or `display` elements

- String Equality (`=`) is case sensitive 

```cql
('Abel' = 'abel') is false
```
- String Equivalence (`~`) ignores case, locale, and normalizes whitespace (meaning all whitespace characters are equivalent). 

```cql
('Abel' ~ 'abel') is true
```

4.  The Sum function works on lists of quantities or numbers not a list of structures like Encounters
5.  Inclusive a.k.a closed boundaries are indicated with square brackets `[ ]`, and exclusive a.k.a open boundaries are indicated with parentheses `( )`.

## Glossary

1.  [Declarations](https://cql.hl7.org/02-authorsguide.html#declarations) and [LIbraries](https://cql.hl7.org/03-developersguide.html#libraries-1)
2.  [Types of Queries](https://cql.hl7.org/02-authorsguide.html#queries) 
3.  [Values supported in CQL](https://cql.hl7.org/02-authorsguide.html#values)
4.  [Operations supported in CQL](https://cql.hl7.org/02-authorsguide.html#operations)

  

