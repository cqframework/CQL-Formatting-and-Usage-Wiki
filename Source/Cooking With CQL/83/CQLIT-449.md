## CQLIT-449

* [CQLIT-449](https://oncprojectracking.healthit.gov/support/browse/CQLIT-449)

The [QICore 4.1.1 Authoring Pattern - Medication ordered](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns---QICore-v4.1.1#medication-ordered) recommends the following pattern for retrieving MedicationRequest.medication (...medication in...) instead of the common pattern.

Best practice:

```cql
 ["MedicationRequest": medication in "Antithrombotic Therapy"] Antithrombotic 
```

versus:

```cql
 ["MedicationRequest": "Antithrombotic Therapy"] Antithrombotic 
```

Question: It seems either pattern cannot retrieve MedicationRequest.medication as Reference - both can retrieve MedicationRequest.medication as CodeableConcept, and the only difference the additional "medication in..." pattern would make is resolving the test case execution errors found in CQLIT-412 when test cases include MedicationRequest.medication as Reference. Is this correct? I'm trying to understand the difference between these two patterns.

Because the primary code path for the MedicationRequest (and the other Medication-related resources, MedicationAdministration, MedicationDispense, and MedicationStatement) is a choice of CodeableConcept | Reference, the translator is attempting to resolve on both possible representations for the element. However, because the Reference representation is not supported within the retrieve, the translator falls back to using the CodeableConcept and results in an extra retrieve in the resulting compiled ELM.

The use of the path `medication` in the retrieve ensures that the translator only tries to use the CodeableConcept, so this is the best practice recommendation for all the positive medication-related resources.

Note that because the negation profiles (MedicationNotRequested, MedicationNotAdministered, MedicationDispenseDeclined) exclude the Reference type as a choice for the `medication` element, stating the `medication` path is NOT recommended because it will prevent the translator from resolving for both the code and value set representations of the negation.