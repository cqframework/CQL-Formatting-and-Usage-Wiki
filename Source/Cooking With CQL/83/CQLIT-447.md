## CQLIT-447

* [CQLIT-447](https://oncprojectracking.healthit.gov/support/browse/CQLIT-447)

The [Medication ordered](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns---QICore-v4.1.1#medication-ordered) authoring pattern for QICore STU4.1.1 was updated based on feedback to ensure that the doNotPerform element was tested, and incorrectly indicated that the profile did not fix the value of the element.

Following this guidance resulted in the inability to pass test case coverage, because if the CQL includes the test for the element, then test cases cannot be provided that meet both sides of that test, because the profile validation requires the value to be fixed to false.

This guidance was corrected to align with the published profile, which does fix the value of the doNotPerform element to false. Because the profile does this checking, it is not necessary to test this element in the CQL.

Specifically, the pattern was updated to remove the `doNotPerform` test:

```cql
define "Antithrombotic Therapy at Discharge":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] Antithrombotic
    where (Antithrombotic.isCommunity() or Antithrombotic.isDischarge())
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }
```

And the guidance for the `doNotPerform` element was corrected to align with the published profile:

> NOTE: Because the MedicationRequest profile fixes the value of the doNotPerform element to false, the expression does not need to test this element.

