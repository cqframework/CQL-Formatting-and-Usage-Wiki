library AggregatesWithEmptyLists

/*
I'm curious what the expected behavior for Sum({}) should be. 
The spec doesn't define any overloads here, so should that be an error? 
Intuitively I would think this should just return null, but since there 
isn't a spec definition perhaps this should be an error. 

Any clarity here would be appreciated!
*/

/*
The specification defines aggregate operators in general to return null 
on an empty list input (with the exception of Count, AllTrue, and AnyTrue, 
which return 0, true, and false, respectively). This is the same behavior 
that SQL defines for aggregate operators:

https://cql.hl7.org/02-authorsguide.html#aggregate-operators
*/

/*
For example:
*/

define ListOfIntegers: { 1, 2, 3, 4, 5 }
define EmptyListOfIntegers: ListOfIntegers X where false
define EmptySum: Sum(EmptyListOfIntegers)

define EmptySumLiteral: Sum(List<Integer>{ })

define EmptyCount: Count(EmptyListOfIntegers)

define ListOfBoolean: { true, false, true, false }
define EmptyListOfBoolean: ListOfBoolean X where false
define EmptyAllTrue: AllTrue(EmptyListOfBoolean)
define EmptyAnyTrue: AnyTrue(EmptyListOfBoolean)

define EmptyAllTrueLiteral: AllTrue(List<Boolean>{ })