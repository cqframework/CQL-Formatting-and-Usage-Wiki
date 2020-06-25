## Coalesce

[CQM-4020](https://oncprojectracking.healthit.gov/support/browse/CQM-4020)
Relating to [CMS71v10](https://ecqi.healthit.gov/ecqm/eh/2021/cms071v10)
[CQL Style Guide](https://ecqi.healthit.gov/tool/cql-style-guide)

### Question:
Help us understand, with respect to the Encounter with Comfort Measure during Hospitalization,
should we be validating `relevantPeriod` for `"Intervention, Order": "Comfort Measures"` or only `authorDatetime`?

```
define "Encounter with Comfort Measures during Hospitalization":
  "Denominator" Encounter
  with TJC."Intervention Comfort Measures" ComfortMeasure
    such that Coalesce(start of ComfortMeasure.relevantPeriod, ComfortMeasure.authorDatetime) during Global."HospitalizationWithObservation" ( Encounter )
```

from the TJC library:
```
define "Intervention Comfort Measures":
  ["Intervention, Order": "Comfort Measures"]
    union ["Intervention, Performed": "Comfort Measures"]
```

As you have noted, per QDM 5.5 for `"Intervention, Order"` data type, the available timings provided only include `authorDatetime`, while for `"Intervention, Performed"` data type, the available timings include `relevantDatetime`, `relevantPeriod` and `authorDatetime`.

* Reference:  https://ecqi.healthit.gov/site/default/filses/QDM-5.5-Overview-Presentation-8-20-2019-508.pdf
* Reference Coalesce():  https://ecqi.healthit.gov/node/131101

The `"Encounter with Comfort Measures during Hospitalization"` definition starts with `"Denominator"` encounters related to the TJC library `"Intervention Comfort Measures"` definition, which will return `"Intervention, Order"` and `"Intervention, Performed"` for `"Comfort Measures"` which are linked to the associated hospitalization episode by the `Global."HospitalizationWithObservation"(Encounter)` function.

The magic lies within the `Coalesce(start of ComfortMeasure.relevantPeriod, ComfortMeasure.authorDatetime)` function which returns the first non null entry so that it captures the first `start of ComfortMeasure.relevantPeriod` or `ComfortMeasure.authorDatetime` that is present in the return from `"Intervention Comfort Measures"`.  Note that the `start of` effectively converts the `relevantPeriod` to a datetime, thus the `Coalesce` presents a datetime, if present, for the comparison to during the `"HospitalizationWithObservation".relevantPeriod`.  This comparison returns a boolean evaluation for the query’s such that clause.

Therefore, the answer to your question is:
The TJC library `"Intervention Comfort Measures"` would contain
`"Intervention, Order".authorDatetime` and `"Intervention, Performed".relevantPeriod`

The `"Encounter with Comfort Measures during Hospitalization"` would use
`"Intervention, Order".authorDatetime` and `start of ("Intervention, Performed".relevantPeriod)`
to determine whether the date (if present) was within the associated Hospitalization encounter period.
Also, the Hospitalization encounter period has already been restricted to the Measurement Period.
The `Coalesce()` function permits the use of different datatypes since it only looks for the first non null element within the function arguments. Note that the arguments are parsed in left to right order which permits assignment of argument priority as well.

Response by Peter Muir, MD
