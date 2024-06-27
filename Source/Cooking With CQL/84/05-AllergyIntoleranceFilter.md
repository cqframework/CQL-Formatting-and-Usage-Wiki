## Question:

How do I test for medication category?

```cql
[AllergyIntolerance] A
   where A.category in { 'medication', 'food' }
```

I've tried using A.category.value, and type casting to System.String, all to no avail.

## Answer:

This is an interesting case, it's a multi-cardinality code-valued element with a required binding. 
Since it is required, it gets represented in client frameworks as a string value, rather than a terminology-valued element. 

As such, it's safe to use string comparison, but since it's multi-cardinality, it needs the exists pattern with a sub-query to test each element:

```cql
define "Medication Or Food Allergy Or Intolerance":
  [AllergyIntolerance] A
    where exists (
      A.category C where C in { 'food', 'medication' }
    )
```
