## CQLIT-460

* [CQLIT-460](https://oncprojectracking.healthit.gov/support/browse/CQLIT-460)

### Question

The definition of "overlaps before" and the authors guidance seem to disagree with each other:

definition of "overlaps before" from https://cql.hl7.org/09-b-cqlreference.html#overlaps

"The operator overlaps before returns true if the first interval overlaps the second and starts before it..."
This to me reads as "start of First is strictly before start of Second"

Quote from Author's guide:

Section 5.5.2

https://cql.hl7.org/STU4/02-authorsguide.html#timing-and-interval-operators

The table indicates that the start of X and the start of Y can be equal, which disagrees with the CQL Reference.

An example patient for CMS996v4 entered in Bonnie agrees with the CQL References and not the Authors guide

### Answer

The table in the Author's Guide is providing the interpretation for the `overlaps` operator specifically, rather than the overlaps before or overlaps after. The language in the CQL Reference and in the Logical Specification are both more precise and consistent with each other:

**Overlaps**

> ... if the ending point of the first interval is greater than or equal to the starting point of the second interval, and the starting point of the first interval is less than or equal to the ending point of the second interval

X overlaps Y ::= end of X >= start of Y and start of X <= end of Y

**Overlaps Before**

> ... `overlaps before` returns true if the first interval overlaps the second and starts before it

X overlaps before Y ::= start of X < start of Y and end of X >= start of Y

**Overlaps After**

> ... `overlaps after` operator returns true if the first interval overlaps the second and ends after it

X overlaps after Y ::= end of X > end of Y and start of X <= end of Y

#### Examples

```cql
/*
    |-----|
       |-----|
*/
```

overlaps before is true
overlaps is true
overlaps after is false

```cql
/*
        |-----|
        |-----|    
*/
```

overlaps before is false
overlaps is true
overlaps after is false


```cql
/*
           |-----|
        |-----|    
*/
```

overlaps before is false
overlaps is true
overlaps after is true
