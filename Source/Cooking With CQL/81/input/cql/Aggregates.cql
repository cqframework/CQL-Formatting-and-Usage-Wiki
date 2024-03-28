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

// Count(argument List<T>) Integer
// https://cql.hl7.org/09-b-cqlreference.html#count

define "Count5": Count({ 1, 2, 3, 4, 5 }) // 5
define "Count0": Count({ null, null, null }) // 0
define "CountNull0": Count(null as List<Decimal>) // 0

// AllTrue(argument List<Boolean>): Boolean
// https://cql.hl7.org/09-b-cqlreference.html#alltrue

define "AllTrueIsTrue": AllTrue({ true, true })
define "AllTrueIsFalse": AllTrue({ true, false })

// AnyTrue(argument List<Boolean>) Boolean
// https://cql.hl7.org/09-b-cqlreference.html#anytrue

define "AnyTrueIsTrue": AnyTrue({ true, false })
define "AnyTrueIsFalse": AnyTrue({ false, false })

// Sum(argument List<Integer>) Integer
// Sum(argument List<Long>) Long
// Sum(argument List<Decimal>) Decimal
// Sum(argument List<Quantity>) Quantity
// https://cql.hl7.org/09-b-cqlreference.html#sum

define "DecimalSum": Sum({ 1.0, 2.0, 3.0, 4.0, 5.0 }) // 15.0
define "QuantitySum": Sum({ 1.0 'mg', 2.0 'mg', 3.0 'mg', 4.0 'mg', 5.0 'mg' }) // 15.0 'mg'

// Min(argument List<Integer>) Integer
// Min(argument List<Long>) Long
// Min(argument List<Decimal>) Decimal
// Min(argument List<Quantity>) Quantity
// Min(argument List<Date>) Date
// Min(argument List<DateTime>) DateTime
// Min(argument List<Time>) Time
// Min(argument List<String>) String
// https://cql.hl7.org/09-b-cqlreference.html#min

define "IntegerMin": Min({ 2, 4, 8, 6 }) // 2
define "LongMin": Min({ 2L, 4L, 8L, 6L }) // 2L
define "DateMin": Min({ @2012-12-31, @2013-01-01, @2012-01-01 }) // @2012-01-01

// Max(argument List<Integer>) Integer
// Max(argument List<Long>) Long
// Max(argument List<Decimal>) Decimal
// Max(argument List<Quantity>) Quantity
// Max(argument List<Date>) Date
// Max(argument List<DateTime>) DateTime
// Max(argument List<Time>) Time
// Max(argument List<String>) String
// https://cql.hl7.org/09-b-cqlreference.html#max

define "IntegerMax": Max({ 2, 4, 8, 6 }) // 8
define "LongMax": Max({ 2L, 4L, 8L, 6L }) // 8L
define "DateMax": Max({ @2012-12-31, @2013-01-01, @2012-01-01 }) // @2013-01-01

// Avg(argument List<Decimal>) Decimal
// Avg(argument List<Quantity>) Quantity
// https://cql.hl7.org/09-b-cqlreference.html#avg

define "DecimalAvg": Avg({ 5.5, 4.7, 4.8 }) // 5.0
define "QuantityAvg": Avg({ 5.5 'cm', 4.7 'cm', 4.8 'cm' }) // 5.0 'cm'

// Median(argument List<Decimal>) Decimal
// Median(argument List<Quantity>) Quantity
// https://cql.hl7.org/09-b-cqlreference.html#median

define "DecimalMedian": Median({ 2.0, 4.0, 8.0, 6.0 }) // 5.0
define "QuantityMedian": Median({ 1.0 'mg', 2.0 'mg', 3.0 'mg' }) // 2.0 'mg'

// Mode(argument List<T>) T
// https://cql.hl7.org/09-b-cqlreference.html#mode

define "DecimalMode": Mode({ 2.0, 2.0, 8.0, 6.0, 8.0, 8.0 }) // 8.0
define "QuantityMode": Mode({ 1.0 'mg', 2.0 'mg', 3.0 'mg', 2.0 'mg' }) // 2.0 'mg'

// Product(argument List<Integer>) Integer
// Product(argument List<Long>) Long
// Product(argument List<Decimal>) Decimal
// Product(argument List<Quantity>) Quantity
// https://cql.hl7.org/09-b-cqlreference.html#product

define "DecimalProduct": Product({ 1.0, 2.0, 3.0, 4.0 }) // 24.0
define "QuantityProduct": Product({ 1.0 'mg', 2.0 'mg', 3.0 'mg', 4.0 'mg' }) // 24.0 'mg'

// GeometricMean(argument List<Decimal>) Decimal
// https://cql.hl7.org/09-b-cqlreference.html#geometricmean

define "GeometricMean4": GeometricMean({ 2.0, 8.0 }) // 4.0

// StdDev(argument List<Decimal>) Decimal
// StdDev(argument List<Quantity>) Quantity
// https://cql.hl7.org/09-b-cqlreference.html#stddev

define "DecimalStdDev": StdDev({ 1.0, 2.0, 3.0, 4.0, 5.0 }) // 1.58113883
define "QuantityStdDev": StdDev({ 1.0 'mg', 2.0 'mg', 3.0 'mg', 4.0 'mg', 5.0 'mg' }) // 1.58113883 'mg'

// Variance(argument List<Decimal>) Decimal
// Variance(argument List<Quantity>) Quantity
// https://cql.hl7.org/09-b-cqlreference.html#variance

define "DecimalVariance": Variance({ 1.0, 2.0, 3.0, 4.0, 5.0 }) // 2.5
define "QuantityVariance": Variance({ 1.0 'mg', 2.0 'mg', 3.0 'mg', 4.0 'mg', 5.0 'mg' }) // 2.5 'mg'

// PopulationStdDev(argument List<Decimal>) Decimal
// PopulationStdDev(argument List<Quantity>) Quantity
// https://cql.hl7.org/09-b-cqlreference.html#population-stddev

define "DecimalPopulationStdDev": PopulationStdDev({ 1.0, 2.0, 3.0, 4.0, 5.0 }) // 1.41421356
define "QuantityPopulationStdDev": PopulationStdDev({ 1.0 'mg', 2.0 'mg', 3.0 'mg', 4.0 'mg', 5.0 'mg' }) // 1.41421356 'mg'

// PopulationVariance(argument List<Decimal>) Decimal
// PopulationVariance(argument List<Quantity>) Quantity
// https://cql.hl7.org/09-b-cqlreference.html#population-variance

define "DecimalPopulationVariance": PopulationVariance({ 1.0, 2.0, 3.0, 4.0, 5.0 }) // 2.0
define "QuantityPopulationVariance": PopulationVariance({ 1.0 'mg', 2.0 'mg', 3.0 'mg', 4.0 'mg', 5.0 'mg' }) // 2.0 'mg'

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
