## CQLIT-422

https://oncprojectracking.healthit.gov/support/projects/CQLIT/issues/CQLIT-422

CQLIT-422 CMS0137 v12 Bonnie unexpected coverage 99% QDM NCQA
Summary: equal vs equivalent for id
Description:  the revision from `!~` to `!=` did increase the Stratifications to 100% coverage

```cql
define "Treatment Initiation With Non Medication Intervention Dates":
  "Psychosocial Visit" PsychosocialVisit
    let treatmentDate: date from start of Global."NormalizeInterval" ( PsychosocialVisit.relevantDatetime, PsychosocialVisit.relevantPeriod )
    with "First SUD Episode During Measurement Period" FirstSUDEpisode
      such that treatmentDate during Interval[date from start of FirstSUDEpisode.relevantPeriod, date from start of FirstSUDEpisode.relevantPeriod + 14 days )
        // and PsychosocialVisit.id !~ FirstSUDEpisode.id
        
        and PsychosocialVisit.id != FirstSUDEpisode.id
    return all treatmentDate
```

The issue is that the use of the equivalent operator is output with different markers in the annotations that Bonnie is using for coverage calculation. Conceptually, the use of !~ should not be required, but it also should not negatively impact the logic in this case (the only difference in behavior is null-handling, and the id element should never be null, and case-sensitivity, which for an id comparison should not matter).

A correction for this issue is currently in review.