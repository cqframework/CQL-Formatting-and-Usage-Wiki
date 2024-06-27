This topic discusses the concept of "nested queries" or "sub-queries" within CQL.

We'll start with a basic review of the CQL query construct.

The _query_ construct in CQL lets authors manipulate lists of values, as the
following simple examples demonstrate:

```cql
define ListOfIntegers: { 1, 2, 3, 4, 5 }

define SimpleWhereQuery:
  ListOfIntegers X
    where X > 1

define SimpleReturnQuery:
  ListOfIntegers X
    return X + 1
```

Output:
```
ListOfIntegers=[1, 2, 3, 4, 5]
SimpleWhereQuery=[2, 3, 4, 5]
SimpleReturnQuery=[2, 3, 4, 5, 6]
```

The _source_ list for the query can be a simple list like the previous examples,
but more commonly, it is a list of _structured values_ or _tuples_:

```cql
define ListOfTuples: {
  { id: 1, date: Date(2024, 01, 01), value: 5.0 },
  { id: 2, date: Date(2024, 01, 01), value: 6.0 },
  { id: 3, date: Date(2024, 01, 02), value: 9.0 },
  { id: 4, date: Date(2024, 01, 02), value: 3.0 },
  { id: 5, date: Date(2024, 01, 03), value: 1.0 }
}
```

Output:
```
ListOfTuples=[Tuple {
	"id": 1
	"date": 2024-01-01
	"value": 5.0
}, Tuple {
	"id": 2
	"date": 2024-01-01
	"value": 6.0
}, Tuple {
	"id": 3
	"date": 2024-01-02
	"value": 9.0
}, Tuple {
	"id": 4
	"date": 2024-01-02
	"value": 3.0
}, Tuple {
	"id": 5
	"date": 2024-01-03
	"value": 1.0
}]
```

And when retrieving FHIR data in particular, it is a list of resource instances:

```cql
define Observations:
  [Observation] O
```

Output:
```
Observations=[Observation(id=blood-glucose), Observation(id=blood-pressure), Observation(id=bmi), Observation(id=bp-data-absent), Observation(id=bun), Observation(id=erythrocytes), Observation(id=example), Observation(id=head-circumference), Observation(id=heart-rate), Observation(id=height), Observation(id=hemoglobin), Observation(id=length), Observation(id=mchc), Observation(id=negation-example), Observation(id=neutrophils), Observation(id=oxygen-saturation), Observation(id=pediatric-bmi-example), Observation(id=pediatric-wt-example), Observation(id=respiratory-rate), Observation(id=satO2-fiO2), Observation(id=serum-calcium), Observation(id=serum-chloride), Observation(id=serum-co2), Observation(id=serum-creatinine), Observation(id=serum-potassium), Observation(id=serum-sodium), Observation(id=serum-total-bilirubin), Observation(id=some-day-smoker), Observation(id=temperature), Observation(id=urine-bacteria), Observation(id=urine-bilirubin), Observation(id=urine-cells), Observation(id=urine-clarity), Observation(id=urine-color), Observation(id=urine-epi-cells), Observation(id=urine-glucose), Observation(id=urine-hemoglobin), Observation(id=urine-ketone), Observation(id=urine-leukocyte-esterase), Observation(id=urine-nitrite), Observation(id=urine-ph), Observation(id=urine-protein), Observation(id=urine-rbcs), Observation(id=urine-sediment), Observation(id=urine-wbcs), Observation(id=urobilinogen), Observation(id=usg), Observation(id=vitals-panel), Observation(id=weight)]
```

Note that the source list for the query can also be part of a larger structure. Consider
patient phone numbers:


```cql
define PatientPhoneNumbers:
  Patient.telecom T
    where T.system = 'phone'
```

Output:
```
PatientPhoneNumbers=[ContactPoint, ContactPoint, ContactPoint]
```

And because a _query_ is an _expression_ (in terms of CQL syntax), a query can
appear anywhere an expression can:

```cql
define ObservationsWithDelta:
  Observations O
    where exists (
      O.extension E
        where E.url = 'http://hl7.org/fhir/StructureDefinition/observation-delta'
    )
```

Output:
```
ObservationsWithDelta=[Observation(id=example)]
```

This use of a query within a query is commonly referred to as a "nested query",
or a "sub-query", and these queries can be nested to any degree.

Since the sub-query is in the _scope_ of the containing query, the _aliases_
in any parent query can be referenced:

```cql
define DiagnosticReportsWithObservations:
  [DiagnosticReport] D
    where exists (
      Observations O
        where D.result.references(O)
    )
```

Output:
```
DiagnosticReportsWithObservations=[DiagnosticReport(id=cbc), DiagnosticReport(id=example), DiagnosticReport(id=metabolic-panel), DiagnosticReport(id=urinalysis)]
```

This is known as a "correlated sub-query", because the sub-query is
referencing values in the parent query

We can use this capability to perform what is commonly referred to as a "group-by" query
in SQL, where we want to compute aggregates based on groupings of data.

Returning to the simple "list of tuples" example:

```cql
define ListOfTuples2: {
  { id: 1, date: Date(2024, 01, 01), value: 5.0 },
  { id: 2, date: Date(2024, 01, 01), value: 6.0 },
  { id: 3, date: Date(2024, 01, 02), value: 9.0 },
  { id: 4, date: Date(2024, 01, 02), value: 3.0 },
  { id: 5, date: Date(2024, 01, 03), value: 1.0 }
}
```

Output:
```
ListOfTuples2=[Tuple {
	"id": 1
	"date": 2024-01-01
	"value": 5.0
}, Tuple {
	"id": 2
	"date": 2024-01-01
	"value": 6.0
}, Tuple {
	"id": 3
	"date": 2024-01-02
	"value": 9.0
}, Tuple {
	"id": 4
	"date": 2024-01-02
	"value": 3.0
}, Tuple {
	"id": 5
	"date": 2024-01-03
	"value": 1.0
}]
```

What if I want to find the sum of the values on each different day?

```cql
define DaysInList:
  ListOfTuples2 D
    return { date: D.date }
```

Output:
```
DaysInList=[Tuple {
	"date": 2024-01-01
}, Tuple {
	"date": 2024-01-02
}, Tuple {
	"date": 2024-01-03
}]
```

We start by finding the days, and note that this is _unique_ days, 
if we want all the days, with duplicates included, we have to include the `all` keyword.
In thise case, we want the distinct days, so this is the starting point

We then use a correlated sub-query to ask, for each date, what are the tuples that are on that date:

```cql
define DaysInListWithTuples:
  ListOfTuples2 D
    return {
      date: D.date,
      tuples: ListOfTuples2 SD where SD.date = D.date
    }
```

Output:
```
DaysInListWithTuples=[Tuple {
	"date": 2024-01-01
	"tuples": [Tuple {
	"id": 1
	"date": 2024-01-01
	"value": 5.0
}, Tuple {
	"id": 2
	"date": 2024-01-01
	"value": 6.0
}]
}, Tuple {
	"date": 2024-01-02
	"tuples": [Tuple {
	"id": 3
	"date": 2024-01-02
	"value": 9.0
}, Tuple {
	"id": 4
	"date": 2024-01-02
	"value": 3.0
}]
}, Tuple {
	"date": 2024-01-03
	"tuples": [Tuple {
	"id": 5
	"date": 2024-01-03
	"value": 1.0
}]
}]
```

Then we can simply sum the values for the tuples for each date:

```cql
define DaysInListWithSum:
  ListOfTuples2 D
    return {
      date: D.date,
      sum: Sum(ListOfTuples2 SD where SD.date = D.date return SD.value)
    }
```

Output:
```
DaysInListWithSum=[Tuple {
	"date": 2024-01-01
	"sum": 11.0
}, Tuple {
	"date": 2024-01-02
	"sum": 12.0
}, Tuple {
	"date": 2024-01-03
	"sum": 1.0
}]
```