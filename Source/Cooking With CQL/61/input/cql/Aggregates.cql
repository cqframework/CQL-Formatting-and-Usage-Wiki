library Aggregates

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

context Patient

/*
Aggregate functions in CQL allow calculations to be performed on collections of
values such as Sum, Min, Max, and Avg. CQL also includes several statistical aggregate
functions such as StdDev and PopulationVariance.

In general, these aggregate functions operate on collections of _values_, in
particular, ignoring null elements in the input. For example:
*/

define ListOfIntegers: { 1, 1, 3, 5, null, 8 }

define SumOfListOfIntegers: Sum(ListOfIntegers)

/*
If the list of elements contains no values (i.e. is empty or has all null elements), the result
is null:
*/

define EmptyList: List<Integer> { }
define ListOfNulls: { null as Integer, null, null }

define SumOfEmptyList: Sum(EmptyList)
define SumOfListOfNulls: Sum(ListOfNulls)

/*
An exception to this rule is the Count function, which will return 0 in this case:
*/

define CountOfEmptyList: Count(EmptyList)
define CountOfListOfIntegers: Count(ListOfIntegers)
define CountOfListOfNulls: Count(ListOfNulls)

/*
This is the key difference between the Count function and the Length function for lists.
Length counts all the elements, regardless of whether they are null, where Count
behaves like the other aggregates and ignores nulls:
*/

define LengthOfEmptyList: Length(EmptyList)
define LengthOfListOfIntegers: Length(ListOfIntegers)
define LengthOfListOfNulls: Length(ListOfNulls)

/*
The other exceptions to this rule (that the result of  aggregate calculations
on empty lists are null) are the AllTrue and AnyTrue boolean aggregates. AllTrue
returns `true` when invoked on an empty list, and AnyTrue returns `false`.
*/

/*
See also the Aggregate Functions topic in the CQL Author's Guide:
https://cql.hl7.org/02-authorsguide.html#aggregate-operators

For a complete reference of the aggregate functions available in CQL, see:
https://cql.hl7.org/09-b-cqlreference.html#aggregate-functions
*/

/*
WARNING: These examples are for demonstration purposes only to illustrate the
behavior of aggregate operations in CQL. They are not clinically validated and
should not be used directly as models for production calculations.
*/

/*
1. How many observations does this patient have?
2. How many observations have an encounter?
3. How many different kinds of observations does this patient have?
4. How many of each kind of observation does this patient have?
5. Which kinds of observations have more than one observation?
6. How many kinds of observations have more than one observation?
7. For each kind of observation with more than one observation, what is the date and result of the most recent observation?
*/

/*
http://hl7.org/fhir/observation.html
*/
