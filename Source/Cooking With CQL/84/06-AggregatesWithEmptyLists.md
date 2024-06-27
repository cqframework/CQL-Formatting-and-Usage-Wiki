## Question:

I'm curious what the expected behavior for Sum({}) should be. 
The spec doesn't define any overloads here, so should that be an error? 
Intuitively I would think this should just return null, but since there 
isn't a spec definition perhaps this should be an error. 

## Answer:
The specification defines aggregate operators in general to return null 
on an empty list input (with the exception of Count, AllTrue, and AnyTrue, 
which return 0, true, and false, respectively). This is the same behavior 
that SQL defines for aggregate operators:

https://cql.hl7.org/02-authorsguide.html#aggregate-operators


For example:

```cql
define ListOfIntegers: { 1, 2, 3, 4, 5 }
define EmptyListOfIntegers: ListOfIntegers X where false
define EmptySum: Sum(EmptyListOfIntegers)
```

Output:
```
ListOfIntegers=[1, 2, 3, 4, 5]
EmptyListOfIntegers=[]
EmptySum=null
```

Note that because the empty list `{ }` is typed as `List<System.Any>`, the expression:

```cql
define EmptySum: Sum({ })
```

Results in an ambiguous call error, because there are multiple overloads of Sum (for Integer, Decimal, and Quantity) and the translator cannot resolve which overload to call. To address this, use a typed Literal:

```cql
define EmptySumLiteral: Sum(List<Integer>{ })
```

And for compleness, the results of Count and AllTrue, AnyTrue on empty lists:

```cql
define EmptyCount: Count(EmptyListOfIntegers)
```

Output:
```
EmptyCount=0
```

```cql
define ListOfBoolean: { true, false, true, false }
define EmptyListOfBoolean: ListOfBoolean X where false
define EmptyAllTrue: AllTrue(EmptyListOfBoolean)
define EmptyAnyTrue: AnyTrue(EmptyListOfBoolean)

define EmptyAllTrueLiteral: AllTrue(List<Boolean>{ })
```

Output:
```
ListOfBoolean=[true, false, true, false]
EmptyListOfBoolean=[]
EmptyAllTrue=true
EmptyAnyTrue=false
EmptyAllTrueLiteral=true
```

