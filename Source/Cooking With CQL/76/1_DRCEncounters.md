# Direct-reference Code Encounters

The `type` element of [Encounters](http://hl7.org/fhir/us/qicore/StructureDefinition-qicore-encounter-definitions.html#key_Encounter.type) is plural (or multi-cardinality), meaning that a given Encounter may have multiple types associated with it:

```json
{
  "resourceType" : "Encounter",
  "id" : "example",
  "meta" : {
    "profile" : ["http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter"]
  },
  "status" : "in-progress",
  "class" : {
    "system" : "http://terminology.hl7.org/CodeSystem/v3-ActCode",
    "code" : "IMP",
    "display" : "inpatient encounter"
  },
  "type" : [{
    "coding" : [{
      "system" : "http://www.ama-assn.org/go/cpt",
      "code" : "99223",
      "display" : "Inpatient Hospital Care"
    }, {
      "system": "http://snomed.info/sct",
      "code": "32485007",
      "display": "Hospital admission (procedure)"
    }]
  }, {
    "coding": [{
      "system": "http://www.ama-assn.org/go/cpt",
      "code": "44970",
      "display": "Laprascopy, surgical, appendectomy"
  }],
  "subject" : {
    "reference" : "Patient/example"
  },
  "diagnosis" : [{
    "extension" : [{
      "url" : "http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter-diagnosisPresentOnAdmission",
      "valueCodeableConcept" : {
        "coding" : [{
          "system" : "https://www.cms.gov/Medicare/Medicare-Fee-for-Service-Payment/HospitalAcqCond/Coding",
          "code" : "Y"
        }]
      }
    }],
    "condition" : {
      "reference" : "Condition/appendicitis-example"
    }
  }]
}
```

> NOTE: The above example is contrived in that the code for appendectomy is probably a procedure code and would not be likely to appear in this element, but this is an example for illustration purposes.

Because `type` is the _primary code path_ for the QICore Encounter profile, a default retrieve using a value set will return Encounters matching the QICore Encounter profile that have a `type` element with a code in the given value set:

```cql
define "Office Visit Encounters":
  [Encounter: "Office Visit"]
```

When using value sets such as the `"Office Visit"` example above, the retrieve resolves using the `List<Concept>` overload of the [`in(ValueSet)`](https://cql.hl7.org/09-b-cqlreference.html#in-valueset) operator in CQL. 

```cql
Encounter.type in "Office Visit"
```

This overload returns `true` if any code in the list of codes is in the given value set.

However, when attempting to use a direct-reference code, there is no overload of the [Equivalent (`~`)](https://cql.hl7.org/09-b-cqlreference.html#equivalent) operator to support the comparison:

```cql
Encounter.type ~ "Office Visit"
```

This expression is invalid because the Equivalent (`~`) operation is only defined for Codes and Concepts.

This issue is being reviewed and may result in a specification or tooling change to support this use case (see [Translator Issue 1181](https://github.com/cqframework/clinical_quality_language/issues/1181)). However, at this time there are two possible workarounds:

1. Define a value set containing the required code and use that value set to perform the retrieve
2. Use an equivalent `where` clause with an `exists` to retrieve the expected results, as shown in the below example:

```cql
define "Office Visit Encounters By Code":
  [Encounter] E
    where exists ((E.type) T where T ~ "Office Visit Code")
```

Note that this latter workaround will typically result in an unrestricted data requirement for Encounters.

## See Also:
* [CQLIT-368](https://oncprojectracking.healthit.gov/support/browse/CQLIT-368)
* [Translator Issue #1181](https://github.com/cqframework/clinical_quality_language/issues/1181)
* [Encounter Authoring Patterns](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns---QICore-v4.1.1#accessing-encounters-with-a-direct-reference-code)

