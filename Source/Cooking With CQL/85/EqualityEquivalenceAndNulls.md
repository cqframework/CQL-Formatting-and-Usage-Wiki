# Equality, Equivalence, and Nulls, Oh My

Inspired by this thread:

https://chat.fhir.org/#narrow/stream/179220-cql/topic/Concept.20equivalence.20and.20null.20values


## Question:

https://cql.hl7.org/09-b-cqlreference.html#equivalent-3

> For Concept values, equivalence is defined as a non-empty intersection of the codes in each Concept

I'm curious how null values _should_ be treated here. For example:

```cql
null as Code ~ Concept { codes: { null as Code } } 
```

I'm also curious separately about this case:

```cql
null as Code ~ Concept { codes: { } } 
```

And what about this case:

```cql
null ~ ''
```

## Answer:

The expectation is that within an equivalence operator, equivalence semantics would also be used for evaluating nested operations. So for Concept equivalence, the equivalence operator would be used to determine membership for the intersection. There is actually an example of this in the spec:

```cql
define "Code1": Code { system: 'http://loinc.org', code: '8480-6', display: 'Systolic blood pressure' }
define "Concept1": Concept { codes: { Code1 }, display: 'Concepts' }
define "Concept2": Concept { codes: { null }, display: 'More Concepts' }
define "EquivalentIsTrue": Code1 ~ Code1
define "EquivalentIsAlsoTrue": Concept2 ~ Concept2
define "EquivalentIsFalse": Concept1 ~ Concept2
```

The example `Concept2 ~ Concept2` is exactly the case of a Concept with a null Code.

The example of a Concept with no codes, however:

```
null as Code ~ Concept { codes: { } }
```

Should evaluate to false because the intersection of the code lists is empty.

### Missing Information

```cql
null
1 = null // null
1 + null // null
null as Integer = null // null
null is null // true
```

A `null` represents unknown or missing information

`null` is not a _value_, it is the _absence_ of a value

This is why we are careful not to use the term `null value`, it's a contradiction in CQL terms

A `null` as the result of an expression can be read "I don't know"

Unless otherwise documented, comparisons to a `null` result in `null`

Unless otherwise documented, nulls _propagate_, meaning in general, expressions involving `null` result in `null`.

There are important exceptions, one of which is the _null test_ `is null` and `is not null`

Another important exception is the logical operations, which, like SQL, use 3-valued-logic:

```
true and true // true
true and false // false
false and null // false
true and null // null

true or false // true
true or null // true
false or false // false
false or null // null
```

For truth tables, see the [Logical Operators](https://cql.hl7.org/09-b-cqlreference.html#logical-operators-3) reference. The key point is that these semantics:

1. Follow from the "I don't know" semantic:
    1. `true and null` is `null` because the result could be true or false, depending on what the missing value is
    2. `false and null` is `false` because no matter what the missing value is, the result would still be `false`
2. Obey [DeMorgan's laws](https://en.wikipedia.org/wiki/De_Morgan%27s_laws), allowing for important optimization techniques to be applied by implementations

### Equivalent

Another important exception is the behavior of the Equivalence (`~`) operator. In general, nulls are considered _equivalent_:

```cql
null as Integer = null // null
null as Integer ~ null // true
```

> NOTE: A bare `null` is of type `System.Any`, so type casts are used in the above expressions so that the expression can resolve to a particular overload of the Equality and Equivalence operators. Without that cast, the compiler would complain that the call was ambiguous between the various overloads of these operators. When a `null` selector appears within an expression, it is implicitly cast to the appropriate type, so this cast is only necessary when the expected type of the `null` cannot be inferred by the context.

However, while the Equivalent operator considers `null` equivalent to `null`, that does not mean that `null` is equivalent to other values, such an empty empty string:

```cql
null ~ '' // false
```

### Equality vs Equivalence

In general, Equality propagates unknowns, Equivalent does not

For structured values, this means missing elements affect equality, but not equivalence.

> NOTE: Elements that are `null` in both inputs are ignored

```cql
define T1: { X: 1, Y: null }
define T2: { X: 1, Y: null }
define T3: { X: 1, Y: 2 }

define TEqual: T1 = T2 // true
define TEqualWithNull: T2 = T3 // null
define TEquivalent: T2 = T3 // false
```

For Code values in particular, Equivalence is defined in terms of the `code` and `system` elements _only_, `version` and `display` are ignored:

```cql
define C1: Code { code: 'ABC', display: 'Code ABC', system: 'http://example.com', version: '2017-01' }
define C2: Code { code: 'ABC', display: 'Variant Description", system: 'http://example.com', version: '2017-05' }

define CEqual: C1 = C2 // false
define CEquivalent: C1 ~ C2 // true
```

### Nulls and Membership

Another exception is that for the purposes of determining membership in a list, `null` elements are considered equal:

```cql
define ListHasNull: { 1, 2, 3, null } contains null // true
define ListIntersectNull: { 1, 2, 3, null } intersect { null } // { 1, 2, 3, null }
```

This behavior applies throughout the list operations, including `contains`, `distinct`, `equal`, `except`, `in`, `includes`, `included in`, `IndexOf`, `intersect`, `properly includes`, `properly included in`, and `union`.
