# Using With

For the following query:

```
define "Time PROMIS10 Total Assessment Completed":
  from
    ["Assessment, Performed": "PROMIS-10 Global Mental Health (GMH) score T-score"] PROMIS10MentalScore,
    ["Assessment, Performed": "PROMIS-10 Global Physical Health (GPH) score T-score"] PROMIS10PhysicalScore
    where PROMIS10MentalScore.relevantDatetime same day as PROMIS10PhysicalScore.relevantDatetime
      and PROMIS10PhysicalScore.result is not null
      and PROMIS10MentalScore.result is not null
    return Max({ PROMIS10MentalScore.relevantDatetime, PROMIS10PhyiscalScore.relevantDatetime })
```

**Q:** Could this have used a `with`? When is it appropriate to use `with` vs `from`?

**A:** No, because the `return` clause is referencing both `PROMIS10MentalScore` and `PROMIS10PhysicalScore`. A `with` can only be used when all that is being expressed is a filter by a relationship, and the _related_ source is only available within the `such that` clause of the `with` relationship. In this case, because the `Max` expression needs to consider the dates from both sources, a `from` is required to keep both sources in scope.
