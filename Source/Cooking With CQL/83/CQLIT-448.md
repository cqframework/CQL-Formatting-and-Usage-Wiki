## CQLIT-448

* [CQLIT-448](https://oncprojectracking.healthit.gov/support/browse/CQLIT-448)

[QICore 4.1.1 Condition.bodySite](http://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-condition-definitions.html#Condition.bodySite) is a CodeableConcept with a 0..* cardinality. We are having trouble (i.e., not meeting 100% test case coverage in MADiE v1.3.1) accessing Condition.bodySite with a direct reference code using the following CQL pattern:

```cql
define "Right Mastectomy Diagnosis":
  ( ["Condition": "Status Post Right Mastectomy"] RightMastectomyProcedure
    union ( ["Condition": "Unilateral Mastectomy, Unspecified Laterality"] UnilateralMastectomyDiagnosis
        where "Right (qualifier value)" in UnilateralMastectomyDiagnosis.bodySite
    ) ) RightMastectomy...
```

The workaround (i.e., for meeting 100% test case coverage in MADiE) is to use the following pattern:

```cql
define "Right Mastectomy Diagnosis":
  ( ["Condition": "Status Post Right Mastectomy"] RightMastectomyProcedure
    union ( ["Condition": "Unilateral Mastectomy, Unspecified Laterality"] UnilateralMastectomyDiagnosis
        where exists (UnilateralMastectomyDiagnosis.bodySite S where S ~ "Right (qualifier value)")
    ) ) RightMastectomy... 
```

Question: Is there an explanation to this? Is this in any way related to the translator issue explored for Encounter.type per [QICore 4.1.1 Authoring Patterns - Accessing Encounters with a Direct-reference code](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns---QICore-v4.1.1#accessing-encounters-with-a-direct-reference-code)?

> NOTE: The example above is using a _qualifier_ as a bodySite, which is an inappropriate code for use in comparison to a "body site" element. As such, the discussion here is using "Right Breast" as a placeholder to illustrate the terminology comparison question:

The relevant portion of the filter criteria is the `bodySite` comparison:

```cql
  where "Right Breast" in UnilateralMastectomyDiagnosis.bodySite
```

Because bodySite is a `List<CodeableConcept>`, this is resolving as list membership (`in`), rather than terminology membership (`inValueSet`) and because this is a terminology-valued element, this will result in strict equality comparison, rather than the expected equivalent comparison that should be used for terminology.

Best practice is to ensure that terminology-valued elements are tested using terminology comparison, and because there is no value set involved, this means we need to use the equivalent (`~`) operator, as is done in the second query:

```cql
  where exists (UnliateralMastectomyDiagnosis.bodySite S where S ~ "Right Breast")
```

This approach ensures that each bodySite value in the list is compared to the direct-reference code `"Right Breast"` using terminology comparison (i.e. only the `code` and `system` elements are tested, the `display` and `version` elements are ignored).

More generally, if an element is a CodeableConcept and multi-cardinality, terminology comparisons should use one of the following patterns:

If the comparison is to a direct-reference code, use an `exists` to perform the comparison using the equivalent (`~`) operator for each CodeableConcept in the list:

```cql
  exists (UnliateralMastectomyDiagnosis.bodySite S where S ~ "Right Breast")
```

If the comparison is to a value set, use the `in` operator:

```cql
  UnilateralMastectomyDiagnosis.bodySite in "Right Breast Codes"
```

To address this guidance generally, the following section was added to the Authoring Patterns page:

https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns---QICore-v4.1.1#use-of-terminologies

And finally, note that as asked in the ticket, this is related to the pattern for Encounter filtering with a direct-reference code:

https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns---QICore-v4.1.1#accessing-encounters-with-a-direct-reference-code

Because the `Encounter.type` element is multi-cardinality, using a direct-reference code in the retrieve is not directly supported, and best practice is to use a value set, rather than a direct-reference code to support that case.