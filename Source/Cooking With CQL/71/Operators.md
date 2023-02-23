# Operators in Clinical Quality Language

This deep dive will review the various _operators_ and _functions_ available in Clinical Quality Language for comparing and manipulating values.

This deep dive assumes familiarity with the material covered in session #68 on [Types and Values](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/blob/master/Source/Cooking%20With%20CQL/68/TypesAndValues.md).

## Operators and Functions

The syntax, or structure, of CQL is built from several basic elements that are all classified as _tokens_. There are four different types of tokens present in CQL: 

* _symbols_, such as `+` and `*`
* _keywords_, such as `define` and `from`
* _literals_, such as `5` and `'active'`
* _identifiers_, such as `Patient` and `"Inpatient Encounters"`

Statements of CQL are built up by combining these basic elements, separated by _whitespace_ (spaces, tabs, and returns). The most basic of these language elements is an _expression_, which is any statement of CQL that returns a _value_.

Expressions are made up of _terms_ (literals or identifiers) combined using _operators_. Operators can be symbolic, such as `+` and `-`, phrases such as `and`, `exists`, and `starts during`, or named operators called _functions_, such as `First()` and `AgeInYears()`.

CQL defines an extensive set of operators and functions for manipulating the various types of values supported in the language. The following sections introduce these operators.

## Comparison Operators

CQL supports three categories of comparison, _equality_, _equivalence_, and _relative_.

```cql
'Abel' = 'abel' // equality, false
'Abel' ~ 'abel' // equivalence, true
'Abel' < 'abel' // relative, true
```

CQL also defines _not equal_ and _not equivalent_ operators:

```cql
'Abel' != 'abel' // not equal, true
'Abel' !~ 'abel' // not equivalent, false
```

Equality comparisons are strict equality and propagate unknowns (`null`):

```cql
'Abel' = null // null
```

Equivalence comparisons are more loose and consider unknowns equivalent:

```cql
'Abel' ~ null // false
null ~ null // true
```

And note that logical connectors (such as `and` and `or`) have lower _precedence_ than comparisons

```cql
A > B and C < D
```

## Equality vs Equivalence

Equality propagates unknowns (`null`), equivalence does not

For structured values, this means missing elements affect equality, but not equivalence. Note that for equality, elements that are `null` in both inputs are ignored.

```cql
define T1: { X: 1, Y: null }
define T2: { X: 1, Y: null }
define T3: { X: 1, Y: 2 }

define TEqual:
  (T1 = T2) is true

define TEqualWithNull:
  (T2 = T3) is null

define TEquivalent:
  (T2 ~ T3) is false
```
  
For Code values in particular, Equivalence is defined in terms of the code and system only, it ignores display and version

```cql
define C1:
  Code {
    code: 'ABC',
    display: 'Code ABC',
    system: 'http://example.com',
    version: '2017-01'
  }

define C2:
  Code {
    code: 'ABC',
    display: 'Variant Description',
    system: 'http://example.com',
    version: '2017-05'
  }

define CEqual:
  (C1 = C2) is false

define CEquivalent:
  (C1 ~ C2) is true
```

## Arithmetic

For arithmetic, CQL defines a standard set of arithmetic operators with the expected semantics for:

* Addition
* Subtraction
* Multiplication
* Division
* Truncated Division
* Modulo
* Negation
* Absolute Value

```cql
define "Standard Precedence":
  (2 + 5 * 10 = 52) is true

define "Force Precedence":
  ((2 + 5) * 10 = 70) is true

define "Division Always Results in a Decimal":
  (10 / 2 = 5.0) is true

define "Truncated Divide for Integer Division":
  (10 div 2 = 5) is true

define "Modulo is the Remainder":
  (10 mod 2 = 0) is true

define "Negation":
  (-(10) = -10) is true

define "Absolute Value":
  (Abs(-10) = 10) is true
```

For types with _relative_ comparisons defined (such as numbers, dates, and times), CQL also supports:
* minimum and maximum value
* successor and predecessor

```cql
define "Successor Of":
  (successor of 1 = 2) is true

define "Predecessor Of":
  (predecessor of 1 = 0) is true

define "Minimum Integer":
  (minimum Integer = -2147483647 - 1) is true

define "Maximum Integer":
  (maximum Integer = 2147483647) is true
```

## Rounding and Exponents

CQL supports standard rounding, 0.5 and above rounds up, 0.4 and below rounds down. The second argument, if supplied, specifies the precision of the result.

```cql
define "Default Round":
  (Round(5.5) = 6) is true

define "Precision Round":
  (Round(5.55, 1) = 5.6) is true
```

`Truncate()` returns the integer component of a decimal.

```cql
define "Truncate":
  (Truncate(5.5) = 5) is true

define "Truncate Negative":
  (Truncate(-5.5) = -5) is true
```

`Floor()` returns the greatest integer less than a decimal. `Ceiling()` returns the least integer greater than a decimal.

```cql
define "Floor":
  (Floor(5.5) = 5) is true

define "Floor Negative":
  (Floor(-5.5) = -6) is true

define "Ceiling":
  (Ceiling(5.5) = 6) is true

define "Ceiling Negative":
  (Ceiling(-5.5) = -5) is true
```

CQL supports exponents and roots with `^`. 

```cql
define "Integer Exponent":
  (2 ^ 5 = 25) is true

define "Decimal Exponent":
  (25 ^ 0.5 = 5) is true
```

Logarithms to a given base use `Log()`.

```cql
define "Logarithm Base 5":
  (Log(25, 5) = 2) is true

define "Logarithm Base 25":
  (Log(5, 25) = 0.5) is true
```

Natural logarithms use `Ln()` and `Exp()`.

```cql
define "Natural Logarithm":
  (Ln(10) = 2.30258209288405) is true

define "Exponent":
  (Exp(2.30258509288405) = 10) is true
```

## String Manipulation

String concatenation using `+` propagates missing information, using `&` does not

```cql
define "String Concatenate":
   'AB' + 'CD' = 'ABCD'

define "String Concatenate With Nulls":
  'AB' + null

define "String Null Concatenate":
  'AB' & null & 'CD'
```

CQL supports a standard set of string manipulation operators with expected semantics

```cql
define "String Length":
  Length('ABCD')

define "String Indexer":
  'ABCD'[0]

define "PositionOf":
  PositionOf('C', 'ABCDCBA')

define "LastPositionOf":
  LastPositionOf('C', 'ABCDCBA')

define "StartsWith":
  StartsWith('AB', 'ABCDCBA')

define "EndsWith":
  EndsWith('AB', 'ABCDCBA')
```

> Note that strings in CQL are 0-based

CQL also supports regular expression matching and replacement

```cql
define "Matches":
  Matches('ABCD', 'AB.*')

define "ReplaceMatches":
  ReplaceMatches('ABCD', 'C', 'X')
```

> Note the specification is not prescriptive about regex dialect, but recommends the PCRE (Perl Compatible Regular Expressions) dialect


## Date and Time Comparison

Authors can compare `Date`, `DateTime` and `Time` values using the standard comparison operators: `=`, `!=`, `<=`, `>=`, `<`, and `>`.

```cql
define "Date Equal":
  @2014-01-15 = @2014-02-15

define "Date Less Than":
  @2014-01-15 < @2014-02-15

define "Date Less Or Equal":
  @2014-01-15 <= @2014-02-15
```

Authors can also perform precision-based comparisons using `same as`, `before`/`after` `of`, and `same or before`/`after`.

```cql
define "Same Year As":
  @2014-01-15 same year as @2014-02-15

define "Same Year Or Before":
  @2012-01-15 same year or before @2014-02-15

define "Before Year Of":
  @2012-01-15 before year of @2014-02-15
```

## Date and Time Arithmetic

CQL supports time-valued quantities with the name (singular or plural) of the precision as the unit.

```cql
define "Day Quantity":
  1 day

define "Years Quantity":
  2 years

define "Minutes Quantity":
  30 minutes
```

UCUM units can also be used (with quotes).

```cql
define "UCUM Days":
  1 'd'

define "UCUM Annum":
  2 'a'

define "UCUM Minutes":
  30 'min'
```

Durations can then be added to or subtracted from Date, DateTime, and Time values, with calendar semantics for durations with variable days such as years and months.

```cql
define "1 Year Ago":
  Today() - 1 year

define "Add 30 Minutes":
  @2014-02-01T14:30 + 30 minutes

define "Add 24 Months":
  @2014 + 24 months

define "Calendar Years Equivalent To UCUM Annum (a)":
  1 year ~ 1 'a'

define "Calendar Months Equivalent To UCUM Month (mo)":
  1 month ~ 1 'mo'

define "Calendar Weeks Equal To UCUM Weeks (wk)":
  1 week = 1 'wk'

define "Calendar Days Equal To UCUM Days (d)":
  1 day = 1 'd'

define "Calendar Hours Equal To UCUM Hours (h)":
  1 hour = 1 'h'

define "Calendar Minutes Equal To UCUM Minutes (min)":
  1 minute = 1 'min'

define "Calendar Seconds Equal To UCUM Seconds (s)":
  1 second = 1 's'

define "Calendar Milliseconds Equal To UCUM Milliseconds (ms)":
  1 millisecond = 1 'ms'
```

## Calendar Durations vs UCUM Units

|Calendar Duration|Unit Representation|Relation to Definite Duration UCUM Unit|
|----|----|----|
|`year`/`years`|`'year'`|`~ 1 'a'`|
|`month`/`months`|`'month'`|`~ 1 'mo'`|
|`week`/`weeks`|`'week'`|`= 1 'wk'`|
|`day`/`days`|`'day'`|`= 1 'd'`|
|`hour`/`hour`|`'hour'`|`= 1 'h'`|
|`minute`/`minutes`|`'minute'`|`= 1 'min'`|
|`second`/`seconds`|`'second'`|'= 1 's'`|
|`millisecond`/'milliseconds`|`'millisecond'`|'= 1 'ms'`|

## Duration and Difference

The `duration in..between` operator determines the number of whole periods between two `Date`, `DateTime`, or `Time` values.

```cql
define "Duration In Months Between":
  duration in months between @2014-01-31 and @2014-02-01
```

This expression returns `0` because there are no whole months between the two dates.

The `difference in..between` operator determines the number of boundaries crossed between two `Date`, `DateTime`, or `Time` values.

```cql
define "Difference In Months Between":
  difference in months between @2014-01-31 and @2014-02-01
```

This expression returns `1` because one month boundary was crossed between the two dates.

## Conditionals

CQL supports three _conditional_ operators:
* `if`
* selected `case`
* conditional `case`

`if` returns one value or another based on the condition

```cql
define strength:
  10.0 'mg/mL'

define "If Conditional":
  if strength.value < 0.1 then
    Quantity {
      value: strength.value * 1000,
      unit: 'mcg' + Substring(strength.unit, 2)
    }
  else
    strength
```

A selected `case` returns different values depending on each case:

```cql
define unit:
  'MG/ACTUAT'

define "Selected Case Conditional":
  case unit
    when 'MG' then 'mg'
    when 'MG/ACTUAT' then 'mg/{actuat}'
    when 'MG/HR' then 'mg/h'
    when 'MG/ML' then 'mg/mL'
    else '{' + unit + '}'
  end
```

And a conditional `case` defines a different condition for each case:

```cql
define doseFormCode:
  316897

define "Conditional Case":
  case
    when doseFormCode = 316897 then 12.6
    else 30
  end
```

> Note that `else` is always required for a conditional

## Operator Precedence

|Category|Operators|
|----|----|
|Primary|`.` `[]` `()`|
|Unary Arithmetic|unary `+` `-`|
|Exponent|`^`|
|Multiplicative|`*` `/` `div` `mod`|
|Additive|`+` `-`|
|Unary Logical|`not` `exists`|
|Comparison|`<=` `<` `>` `>=`|
|Equality|`=` `!=` `~` `!~`|
|Conjunction|`and`|
|Disjunction|`or` `xor`|

> NOTE: This is a simplified listing, see the CQL specification for a complete [precedence chart](https://cql.hl7.org/03-developersguide.html#operator-precedence).