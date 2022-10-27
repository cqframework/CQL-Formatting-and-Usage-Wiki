# Types and Values in Clinical Quality Language

## Definitions

A CQL library is a set of _definitions_:

```cql
library SimplifiedOutpatientEncounters version '3.0.000'

using FHIR version '4.0.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include MATGlobalCommonFunctionsFHIR4 version '7.0.000' called Global

valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Qualifying Encounters":
  [Encounter: "Office Visit"] ValidEncounter
	where ValidEncounter.status  = 'finished'
	  and Global."Normalize Interval"(ValidEncounter.period) during day of "Measurement Period"
```

Definitions can be _declarations_ or _statements_

### Declarations

_declarations_ establish things like terminology and parameters:

```cql
library SimplifiedOutpatientEncounters version '3.0.000'

using FHIR version '4.0.1'

include FHIRHelpers version '4.1.000' called FHIRHelpers
include MATGlobalCommonFunctionsFHIR4 version '7.0.000' called Global

valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001'

parameter "Measurement Period" Interval<DateTime>

context Patient
```

### Statements

_statements_ define _expressions_ and _functions_ available in the library:

```cql
define "Qualifying Encounters":
  [Encounter: "Office Visit"] ValidEncounter
	where ValidEncounter.status  = 'finished'
	  and Global."Normalize Interval"(ValidEncounter.period) during day of "Measurement Period"
```

## Expressions

* Every valid _expression_ can be _evaluated_ and either returns a _result_, or produces an _error_.
* Every _expression_ has a _type_ that can be determined at author-time (i.e. by analysis, as opposed to having to evaluate the expression).
* Every _result_ is either a _value_ or _null_
* Every _value_ is of some type, and the result of a successful evaluation of an expression is guaranteed to be of the _type_ determined at author-time.

## Types

CQL has 5 type _categories_:

1. Simple - Simple values such as strings, numbers, and dates
2. Structured - Values with named elements such as tuples and classes
3. Interval - Ranges of values
4. List - Ordered lists of values
5. Choice - Type defined as a set of possible types for the value

### Simple Types

Simple types are single values like the Integer 5, or the String 'Hello'

[System-Defined Types](https://cql.hl7.org/03-developersguide.html#system-defined-types)

|Type|Example Values|
|----|----|
|Boolean|`true`, `false`|
|Integer|`16`, `-28`|
|Decimal|`100.015`|
|String|`pending`, `active`, `complete`|
|Date|`@2014-01-25`|
|DateTime|`@2014-01-25T`,`@2014-01-25T14:30:14.559`|
|Time|`@T12:00:00.0`,`@T14:30:14.559`|

### Structured Types

Structured types are values that contain _named elements_ (sometimes called attributes or properties).

Structured types can be _tuple types_ (meaning they don't have a name, they are just a set of named elements):

```cql
define Info: Tuple { name: 'Patrick', birthDate: @2014-01-01 }
```

or they can be _classes_, which are _named tuple types_

```cql
// NOTE: Simplified for display purposes
define PatientExpression: Patient { name: 'Patrick', birthDate: @2014-01-01 }
```

CQL also defines several structured types to facilitate representation and manipulation of clinical information: Code, Concept, Quantity and Ratio. 

As per the CQL Reference Appendix B, the Quantity type represents quantities with a specified unit within CQL. The unit must be a valid UCUM unit or CQL temporal keyword. UCUM units in CQL use the case-sensitive (c/s) form. When a quantity value has no unit specified, operations are performed with the default UCUM unit ('1'). The value element of a Quantity must be present. https://cql.hl7.org/09-b-cqlreference.html#quantity

### Interval Types

Interval types support ranges from a low value to a high value:

```cql
define IntegerInterval: Interval[3, 5)
define DateTimeInterval: Interval[@2014-01-01T00:00:00.0, @2015-01-01T00:00:00.0)
```

### List Types

11. List types support collections of values.

```cql
define IntegerList: { 1, 2, 3, 4, 5 }
define StringList: { 'a', 'b', 'c' }
```

### Choice Types

Choice types are used to indicate that a value may be one of any of a choice of types. For example, the Patient.deceased element in the FHIR model can be a Boolean, or a DateTime. This means that the value of the element at run-time (i.e. when the expression is being evaluated) can be either of those types.

```cql
parameter X Choice<Integer, Decimal, String, Quantity>

define TestXAsInteger: X = 1
define TestXAsDecimal: X = 1.0
define TestXAsString: X = 'ABC'
define TestXAsQuantity: X = 20 'mg'
define TestXAsBoolean: X = true
```

Choice types are often used in data models such as QDM and FHIR, especially when the type of data being modeled may be represented in multiple ways. For example, Observation values or Physical Exam, Performed values.

## Casting and Conversion

CQL supports operations for _casting_ and _converting_

Converting involves changing a value from one type to another:

```cql
// Explicit Conversions: https://cql.hl7.org/03-developersguide.html#explicit-conversion
define ConvertValues: convert '1' to Integer
define ConvertUnits: convert 5 'mg' to 'g'
define InvalidConvert: convert 'Foo' to Integer // Results in null
```

Conversions can be _implicit_ and _explicit_ Implicit conversion occurs when mixing types in operations, such as addition:

```cql
// Implicit Conversions: https://cql.hl7.org/03-developersguide.html#implicit-conversions
define ImplicitConversion: 2 + 2.0 // Evaluates as Decimal addition, the integer input is implicitly converted to a decimal
```

Casting involves treating a value at author-time as a more specific type that the value is expected to be at run-time:

```cql
define Procedures: [Procedure]
define ImagingProcedures: Procedures P where P is ImagingProcedure return P as ImagingProcedure
define ImagingProceduresOrError: Procedures P return cast P as ImagingProcedure
```

CQL supports type testing with the `is` operator, and type casting with the `as` and `cast`...`as` operators. 

* `is` will return true if the value at runtime is of the given type.
* `as` will return the value if it is of the given type, otherwise `null`
* `cast`...`as` will return the value if it is of the given type, otherwise an error will be raised

## Casting with Choice Types

In particular, casting can be used with choice types to treat values that may be represented as different types in different ways within the logic:

```cql
/*
@description: Returns the value, interpreted as an Integer
@comments: If the input is a Quantity, the result is the same as invoking `ToInteger(value as Quantity)`.
If the input is an Integer, the result is the same as invoking `value as Integer`
*/
define function ToInteger(value Choice<Integer, Quantity>):
  if value is Quantity then 
    ToInteger(value as Quantity)
  else 
    value as Integer
```

## Choice Types Revisited

It is important to understand the following statement regarding the potential impact on data capture:

> The semantics for casting will result in a null if the run-time value of the element is not of the appropriate type.

Thus, even if the query expression casts a broader net, the result will be constrained to data specified by the ‘as type’. For example:

* String data would not be returned if constrained ‘as Integer’ or ‘as Quantity’. 
* Integer data would not be returned if constrained ‘as Quantity’.
* Quantity data would not be returned if constrained ‘as Integer’.

Code systems, such as LOINC, may permit data in more than one type as specified within LOINC 2.73 code definition as Property, eg Num, and Scale, eg Qn where a Property category of Num indicates the result is a count that begins with a number.  If Scale is Quantitative (Qn) that indicates the result of the test is a numeric value that relates to a continuous scale reported either as an integer, a ratio, a real number, or a range. The test result value may optionally contain a relational operator from the set [<=,<,>,>=]. Valid values for a quantitative test are of the form "7", "-7", "7.4", "-7.4", "7.8912", "0.125", "<10", ">12000", 1-10, 1:256
Per QDM, LOINC and QRDA I specification, a numerical result could potentially be submitted as integer, decimal number or quantity.  For example, data submitted as a quantity for evaluation by the eCQM as Integer, or as lab results submitted as string for evaluation as Quantity or Quantity.value, would not be detected without further logic within the measure or receiving system. 

Takeaways:

* When evaluating a measure’s intent, one should assess the limits on data capture implied by use of ‘as type’ expression that further constrains the query expression.
* When evaluating data for submission, one should assess the data format vs schema vs eCQM specification to prevent unintended limits on data capture.
* To broaden data capture, potentially CQL logic could convert some data from one type to another. 

For example, appropriate data in Quantity.value where Quantity.unit = '1' might be converted to Integer by a CQL function:

```cql
/*
@description: Returns the value of the given Quantity, interpreted as an Integer if it is safe to do so.
@comments: A Quantity value can be safely interpreted as an integer if it has no decimal component (i.e. zeros after the decimal),
and it has the default UCUM unit of '1'
*/
define function ToInteger(value Quantity):
  case
    when Abs(value.value - Truncate(value.value)) > 0.00000001 then 
      Message(null, true, 'ToInteger.InvalidArgument', ErrorSeverity, 'The quantity has a non-zero decimal component and cannot be safely interpreted as an Integer')
    when value.unit != '1' then
      Message(null, true, 'ToInteger.InvalidUnit', ErrorSeverity, 'The quantity has non-default units specified and cannot be safely interpreted as an Integer')
    else
      Truncate(value.value)
  end
  ```

