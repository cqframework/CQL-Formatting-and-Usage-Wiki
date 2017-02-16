// For each encounter, Hospitalization is the interval from hospital arrival to departure
// Multiple potential ways to express this
define "Hospitalization":
  "AMI Encounter" Encounter
    let RelatedEDVisit:
      singleton from (
        ["Encounter, Performed": "Emergency Department Visit SNOMEDCT Value Set"] EDVisit
          where EDVisit ends 1 hour or less before start of Encounter
      )
    return {
      id: Encounter.id,
      relevantPeriod:
        if RelatedEDVisit is null then Encounter.relevantPeriod
          else Interval[start of RelatedEDVisit.relevantPeriod, end of Encounter.relevantPeriod]
    }

define "Denominator":
  from
    "AMI Encounter" Encounter,
    "Hospitalization" Hospitalization
  where Encounter.id = Hospitalization.id
  return Encounter
