As part of measure review, a comment was provided regarding the use of filtering with a potentially null element:

```cql
define "Risk Variable Principal Procedure":
  from
    ["Procedure, Performed": "Major Surgical Procedure"] Procedure,
    "Initial Population" QualifyingEncounter
  where Procedure.rank = 1
    and Global."NormalizeInterval"(Procedure.relevantDateTime, Procedure.relevantPeriod) 
      starts during Global."HospitalizationWithObservationAndOutpatientSurgeryService"(QualifyingEncounter)
```

The measure reviewer noted that with the `Procedure.rank = 1` filter, because rank is potentially nullable, that this filter will exclude elements where the `rank` element is null, and suggests that it is a potential issue that can be addressed by ensuring that the `rank` is not null:

```cql
where Procedure.rank is not null and Procedure.rank = 1
```

And the question then is, if this is appropriate for this case, is it a general pattern?

1. From a purely formal perspective, the suggested change is equivalent (i.e. it will give you the same answer with or without the null test).
2. Adding the null test increases reading load, it's harder to think about the null test and then the rank filtering. This is especially true when the test is part of a larger expression.
3. From an implementation perspective, there is potentially an additional operation being performed, which from a formal perspective is unnecessary (i.e. an optimizing engine could optimize that null test away, but for an engine that didn't do that it represents an additional instruction).

