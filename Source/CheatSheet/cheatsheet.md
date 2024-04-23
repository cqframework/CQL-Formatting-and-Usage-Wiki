# CQL Cheat Sheet

Clinical Quality Language [(CQL)](http://cql.hl7.org) is a Health Level 7 Standard for representing clinical logic. This cheat sheet provides a quick reference for the most commonly used features of the language. For more resources, see the [Getting Started](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Getting-Started) page of the CQL Formatting and Usage Wiki.

## Syntax

### [**Declarations**](https://cql.hl7.org/02-authorsguide.html#declarations)

Constructs expressed within CQL are packaged in libraries. Each library consists of a set of declarations such as terminology, expressions, and functions that are used to define and share clinical logic.

1) [Library syntax](https://cql.hl7.org/02-authorsguide.html#library) - The `library` declaration specifies both the name of the library and optional version

```cql
library AlphoraCommon version '1.0.0'
```

2) [Using syntax](https://cql.hl7.org/02-authorsguide.html#data-models) - A CQL library can reference zero or more data models with the `using` declaration. These data models define the structures that can be referenced in the library.

```cql
using FHIR version '4.0.1'
```

3) [Include syntax](https://cql.hl7.org/02-authorsguide.html#libraries) - A CQL library can reference zero or more other CQL libraries with the `include` declaration. Declarations in included libraries can be used anywhere within the referencing library. The `called` clause defines an optional qualifier to use to reference declarations in the included library.

```cql
include FHIRCommon called FC
```

4) [Parameter syntax](https://cql.hl7.org/02-authorsguide.html#parameters) - A CQL library can define zero or more parameters using the `parameter` declaration. Parameters defined in a library can be referenced anywhere within the library.

```cql
parameter MeasurementPeriod default Interval[@2013-01-01, @2014-01-01)
```

```cql
parameter MeasurementPeriod Interval<DateTime>
```

5) [Context syntax](https://cql.hl7.org/02-authorsguide.html#context) - The `context` declaration defines the "extent" of data available to be retrieved (e.g. the data for a patient). When no context is specified in the library, and the model has not declared a default context, the default context is Unfiltered. If the Unfiltered context is used, the results of any given retrieve will not be limited to a particular context.

```cql
context Patient
context Practitioner
context Unfiltered
```

6) [Value Sets & Code Systems](https://cql.hl7.org/02-authorsguide.html#terminology) - Value set and code system declarations allow terminology to be referenced anywhere within the library.

```cql
valueset "Acute Pharyngitis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.102.12.1011'
```

### [**Retrieve syntax**](https://cql.hl7.org/02-authorsguide.html#retrieve)

The retrieve expression is the central construct for accessing clinical information within CQL. The retrieve in CQL has two main parts: the "type part" and the "terminology filter part".

1) [type part](https://cql.hl7.org/02-authorsguide.html#clinical-statement-structure) : identifies the type of data that is to be retrieved

```cql
[Encounter]
```

2) [terminology filter part](https://cql.hl7.org/02-authorsguide.html#filtering-with-terminology) : the retrieve expression allows the results to be filtered using terminology, including value sets, code systems, or by specifying a single code.

```cql
[Condition: "Acute Pharyngitis"] where Acute Pharyngitis is the value set.
```

<!-- TODO: Do we want to introduce the code path here? If we do, it needs to be done correctly, (i.e. it shouldn't be using an `=`, it should be using either `in` or `~`, and if it uses `~`, it should be a direct-reference code, not a value set)
```cql
define "Inpatient Encounters": 
[Encounter: class ~ "Inpatient Encounter"]
```  -->

### [**Function Syntax**](https://cql.hl7.org/19-l-cqlsyntaxdiagrams.html#function)

A function in CQL is a named expression that is allowed to take any number of arguments. A function can be invoked directly by name. A colon must end the quoted identifier.

```cql
define function MostRecent(observations List<Observation>):
  Last(
    observations O
      sort by issued
  )
```

In this example, the function takes a list of Observations, sorts them by their issued date and returns the last one that has been issued.

## Strings vs Identifiers

**Strings use single quotation marks.**

[Single Quotes](https://cql.hl7.org/19-l-cqlsyntaxdiagrams.html#string) 

Single quotes are limited to string literals
1) text
```cql
define "string literal": 'hello'
```

2) codesystem and valueset object identifiers (OID)
```cql
valueset "example":  'urn:oid:2.16.840.1.113883.3.560.100.2'
```

3) version identifiers
```cql
valueset "example":  'urn:oid:2.16.840.1.113883.3.560.100.2' version '123'
```

4) code declarations
```cql
code "code": '123' from "codesystem identifier"
```

5) units
```cql
define "quantity": 12.0 'L'
```

**Identifiers may use double quotation marks.**

[Quoted Identifiers](https://cql.hl7.org/19-l-cqlsyntaxdiagrams.html#QUOTEDIDENTIFIER)
This applies to definitions, functions, valuesets, codes, etc... 

```cql
"SNOMED CT" // A CodeSystem declaration
"Inpatient Encounters" // A Defined Code
```

<!-- TODO: Identifiers should probably be introduced before queries?
### [**Identifiers**](https://cql.hl7.org/19-l-cqlsyntaxdiagrams.html#identifier)
TODO: Probably need to introduce "Identifiers" somewhere?
Identifiers that include spaces or other non-alphnumeric characters -->


### [**Full Query Syntax**](https://cql.hl7.org/02-authorsguide.html#full-query)

The clauses described in the clauses section later must appear in the correct order in order to specify a valid CQL query. The general order of clauses is:

```bnf
<primary-source> <alias>
  <with-or-without-clauses>
  <where-clause>
  <return-clause>
  <sort-clause>
```

TODO: Should probably organize discussions about each clause here

## Bracket Syntax

1. [Intervals](https://cql.hl7.org/19-l-cqlsyntaxdiagrams.html#intervalSelector) use [] and ()

```cql
Interval[3,5) // An interval >= 3 and < 5
Interval(3,5) // An interval > 3 and < 5
Interval(3,5] // An interval > 3 and <= 5
```

2. [Lists and Tuples](https://cql.hl7.org/19-l-cqlsyntaxdiagrams.html#tupleSelector) use { }

``` cql
{ 1, 2, 3 } union { 3, 4, 5 }

define "Info": 
  Tuple { Name: 'Patrick', DOB: @2014-01-01 }
```

## Queries

### [**Alias Functionality**](https://cql.hl7.org/02-authorsguide.html#queries)

A query construct often begins by introducing an alias for the primary source.
 
```cql
["Encounter": "Inpatient"] E
  where E.period during "Measurement Period"
```

### [**Single-source queries**](https://cql.hl7.org/03-developersguide.html#queries-1) 

CQL provides single-source queries to allow for the retrieval of data from a single source. The query in the example below returns "Ambulatory/ED Visit" encounters performed where the patient also has a condition of "Acute Pharyngitis" that overlaps after the period of the encounter. It will only return Encounters.

``` cql
define Encounter Ambulatory
  [Encounter: "Ambulatory/ED Visit"] E
    with [Condition: "Acute Pharyngitis"] P
      such that P.onset during A.period
        and P.abatement after end of A.period
```

// TODO: All the things from the "developer's guide" should probably be on Page 2, like organize the whole thing so that the first page is just "Author's Guide" stuff, the simple CQL, and the more advanced content is on page 2

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

1. [Boolean](https://cql.hl7.org/02-authorsguide.html#boolean) 

```cql
True/False
```

2. [Integer](https://cql.hl7.org/02-authorsguide.html#integer)

```cql
16, -28
```

3. [Decimal](https://cql.hl7.org/02-authorsguide.html#decimal) 

```cql
100.015
```

4. [String](https://cql.hl7.org/02-authorsguide.html#string) 

```cql
'pending'
'active'
'complete'
```

5. [Date](https://cql.hl7.org/02-authorsguide.html#date-datetime-and-time) 

```cql
@2014-01-25
```

6. [DateTime](https://cql.hl7.org/02-authorsguide.html#date-datetime-and-time)

```cql
@2014-01-25T14:30:14.559
```

7. [Time](https://cql.hl7.org/02-authorsguide.html#date-datetime-and-time) 
 
```cql
@T12:00
```

### [**Clinical Values**](https://cql.hl7.org/02-authorsguide.html#clinical-values)

1. [Quantities](https://cql.hl7.org/02-authorsguide.html#quantities) 

```cql
3 months
5 'mg'
```

2. [Ratio](https://cql.hl7.org/02-authorsguide.html#ratios) 

```cql
5 'mg' : 10 'mL'
```

3. [Code](https://cql.hl7.org/02-authorsguide.html#code) 

```cql
code "Blood pressure": '55284-4' from "LOINC" display 'Blood pressure'
```

4. [Tuples](https://cql.hl7.org/02-authorsguide.html#structured-values-tuples) 

```cql
define "PatientExpression": 
  Patient { Name: 'Patrick', DOB: @2014-01-01 }
```

5. [Missing Information](https://cql.hl7.org/02-authorsguide.html#missing-information)

```cql
null
```

6. [List Values](https://cql.hl7.org/02-authorsguide.html#list-values) 

```cql
{ 1, 2, 3, 4, 5 }
```
7. [Interval values](https://cql.hl7.org/02-authorsguide.html#interval-values) 

```cql
Interval[3, 5)
```

## Query Clauses  

[**Where clause where exists + where not exists + exists**](https://cql.hl7.org/02-authorsguide.html#filtering) to filter retrieved data 

```cql
define "Inpatient Encounters":
  ["Encounter": "Inpatient"] Encounter
    where Encounter.period during "Measurement Period"
```

```cql
define "Quantitative Laboratory Encounters ":
  [Encounter] E
    where exists (["Observation"] O)
```

```cql
define "Encounter Without Procedure ":
  [Encounter] E
    where not exists
    ( [Procedure] P
      where P.performed as dateTime during E.period 
    )
```

```cql
define "Had chest CT in past year":
  exists ("Chest CT procedure" P
    where FC.ToInterval(P.performed) ends 1 year or less before Today() 
  )
```  

[**With/Without clause and such that**](https://cql.hl7.org/02-authorsguide.html#sorting) : to define relationships with other data. When multiple with or without clauses appear in a single query, the result will only include elements that meet the “such that” conditions for all the relationship clauses.

```cql
define "Inpatient Encounters":
  [Encounter": "Inpatient"] Encounter
    with ["Observation": "Streptococcus Test"] Lab Test
      such that Observation.issued during Encounter.period
```  

[**Return clause**](https://cql.hl7.org/02-authorsguide.html#shaping) : determines the overall shape of the query result.

```cql
define "Inpatient Encounters":
  [Encounter: "Inpatient"] Encounter
    return Encounter.period
```

[**Sort clause**](https://cql.hl7.org/02-authorsguide.html#sorting): to order the results ascending or descending.

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

// TODO: "determines the overall result of the query" is the "result clause", not the "aggregate clause"
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

- Addition + , Subtraction - , Multiply \* , Divide /
- Truncate () – round the value backwards
- Round () - round the value frontwards
- Floor () - round to the greatest integer less than a decimal
- Ceiling () - round to the least integer greater than a decimal
- Convert ()

```cql
convert 5000 'g' to 'kg'.
```

- Count ()

```cql
Count({ 1, 2, 3, 4, 5 })
```

- Sum() 

```cql
Sum({1,2,3,4}) // returns the sum of values
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

IndexOf({ 'a', 'b', 'c' }, 'b')

to obtain the number of elements in a list

```cql
Count({ 1, 2, 3, 4, 5 }) 
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
First({ 1, 2, 3, 4, 5 })
```

2. [Comparing Lists](https://cql.hl7.org/02-authorsguide.html#comparing-lists)

`includes`, `includes in`, `properly includes` and `properly included in` are tools we can use to compare lists

```cql
{ 1, 2, 3 } includes { 1, 2 } // returns true
```

3.  [Computing Lists](https://cql.hl7.org/02-authorsguide.html#computing-lists)

To eliminate duplicates.

```cql
Distinct({ 1, 2, 3, 4, 4})
```

To combine lists (union eliminates duplicates).
```cql
{ 1, 2, 3 } union { 3, 4, 5 }
```

To only return the elements that are in both lists.

```cql
{ 1, 2, 3 } intersection { 3, 4, 5 }
```

The flatten operation can flatten lists of lists.

```cql
flatten { { 1, 2, 3 }, { 3, 4, 5 } }
```

4. [Aggregate Operators](https://cql.hl7.org/02-authorsguide.html#aggregate-operators)

// TODO: It returns, not would return, right? (i.e. no passive voice)
This would return the number of encounters in the list

```cql
Count([Encounter])
```

This would return the sum of the values in the list i.e 15

```cql
Sum({ 1, 2, 3, 4, 5 })
```

### [**Date Time Operators**](https://cql.hl7.org/02-authorsguide.html#datetime-operators)

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
point from Interval[3, 3]
width of Interval[3, 5]
```
2. [Comparing Intervals](https://cql.hl7.org/02-authorsguide.html#comparing-intervals) \- the comparison between two interval values using a complete set of operations. This includes `same as`, `before`, `meets before`, `overlaps before` among others.

```cql
X same as Y
Interval [3,5) // includes all numbers >= 3 and < 5
start of Interval[3, 5) // 3
width of Interval[3, 5) // 1
end of Interval[3, 5) // 4
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

// TODO: `is` and `as` are not logical operators, they are type operators
// TODO: `in` is a membership operator, not a logical operator
// TODO: Logical operators are `and`, `or`, `not`, `xor`, and `implies`
// TODO: In other words, they are only operators that take boolean values as input and return boolean values
`and`, `is`, `in`, `as`, `or`, `not`

```cql
AgeInYears() >= 18 and AgeInYears() < 24
```

```cql
define TestPrimitives:
  Patient P
    where P.gender.value = 'male'
      and P.active.value is true
      and P.maritalStatus in "Marital Status"
```

```cql
define "Former smoker observation":
  "Most recent smoking status observation" O
    where (O.value as CodeableConcept) ~ "Former Smoker"
```

```cql
define "Absence of Cervix":
  [Procedure: "Hysterectomy with No Residual Cervix"] NoCervixProcedure
    where FC.ToInterval(NoCervixProcedure.performed) ends on or before end of "Measurement Period" 
      and NoCervixProcedure.status = 'completed'
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

// TODO: If it must be invoked with parentheses, it's a "function", whereas "operator" means a symbolic or keyword-based operation

1. `Length` Operator is used to determine the length of string 

```cql
Length(X)
```

2. `PositionOf` Operator is used to determine the position of a string and will return the index of the string

```cql
PositionOf('cde', 'abcdefg')
```

3. `Combine` operator is used to combine a list of strings

```cql
Combine({ 'ab', 'cd', 'ef' })
```

4. `Split` Operator is used to split a list of strings

```cql
Split('completed;refused;pending', ';') // returns { 'completed', 'refused', 'pending' }
```

## Caveats

1.  Sort clauses don’t require usage of an alias. We don’t need to say E.sort by length of stay.

```
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

- String Equality is case sensitive 

```cql
('Abel' = 'abel') is false
```
- String Equivalence ignores case, locale, and normalizes whitespace (meaning all whitespace characters are equivalent). 

```cql
('Abel' = 'abel') is true
```

4.  The Sum function works on lists of quantities or numbers not a list of structures like Encounters
5.  Inclusive a.k.a closed boundaries are indicated with square brackets `[ ]`, and exclusive a.k.a open boundaries are indicated with parentheses `( )`.

## Glossary

1.  [Declarations](https://cql.hl7.org/02-authorsguide.html#declarations) and [LIbraries](https://cql.hl7.org/03-developersguide.html#libraries-1)
2.  [Types of Queries](https://cql.hl7.org/02-authorsguide.html#queries) 
3.  [Values supported in CQL](https://cql.hl7.org/02-authorsguide.html#values)
4.  [Operations supported in CQL](https://cql.hl7.org/02-authorsguide.html#operations)

  

