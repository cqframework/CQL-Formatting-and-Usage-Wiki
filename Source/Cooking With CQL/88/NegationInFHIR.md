> NOTE: This is a summary-level review of the proposed [Negation in FHIR](https://build.fhir.org/ig/HL7/cql-ig/patterns.html#negation-in-fhir) topic in the January 2025 Using CQL With FHIR Ballot

Patterns for representing negation in FHIR:

* Events not done for a reason
* Requests not to perform an activity (i.e. prohibitions) for a reason
* Rejected proposals for a reason

#### Negation Rationale
{: #negation-rationale}

Evidence that "Antithrombotic Therapy" medication administration did not occur for an acceptable medical reason as
defined by a value set referenced by the clinical logic (i.e., negation rationale):

```cql
define "Antithrombotic Not Administered":
  [MedicationAdministration: "Antithrombotic Therapy"] NotAdministered
    where NotAdministered.status = 'not-done'
      and NotAdministered.statusReason in "Medical Reason"
```

In this example for negation rationale, the logic looks for a member of the value set "Medical Reason" as the rationale
for not administering any of the anticoagulant and antiplatelet medications specified in the "Antithrombotic Therapy"
value set.

As discussed in the [Activity Extent](#activity-extent) section, to represent Antithrombotic Therapy Not Administered, implementing systems reference the canonical of the "Antithrombotic
Therapy" value set using the ([codeOptions](https://build.fhir.org/ig/HL7/fhir-extensions/branches/br-48852-codeOptions-extension/StructureDefinition-codeOptions.html)) extension to indicate
providers did not administer any of the medications in the "Antithrombotic Therapy" value set. By referencing the value
set URI to negate the entire value set rather than a specific member code from the value set, clinicians are
not forced to arbitrarily select a specific medication from the "Antithrombotic Therapy" value set that they
did not administer in order to negate.

When this pattern is used in FHIR resources, the CQL needs to take this into account by looking for the `codeOptions` extension:

```cql
define "Antithrombotic Class Not Administered":
  [MedicationAdministration] NotAdministered
    where NotAdministered.medication.codeOptions() = "Antithrombotic Therapy".id
      and NotAdministered.status = 'not-done'
      and NotAdministered.statusReason in "Medical Reason"
```

To ensure both cases are accounted for, these two expressions would then be used together:

```cql
define "Antithrombotics Not Administered":
  "Antithrombotic Not Administered"
    union "Antithrombotic Class Not Administered"
```

This approach ensures that the logic will retrieve negated activities whether they are recorded as singular activities (i.e. with a code from the value set) or as indications that none of the activities were performed (i.e. with a reference to a value set).

> NOTE: Profile-informed authoring exposes elements that have a `codeOptions` extension using a Choice of CodeableConcept and ValueSet, which is then translated as a union, accounting for both cases as part of profile-informed authoring.

#### Prohibited Activities

Evidence that "Antithrombotic Therapy" medication was prohibited for an acceptable medical reason makes use of the appropriate `Request` resource:

```cql
define "Antithrombotic Therapy Prohibited":
  [MedicationRequest: "Antithrombotic Therapy"] Prohibited
    where Prohibited.status = 'active'
      and Prohibited.doNotPerform is true
      and Prohibited.statusReason in "Medical Reason"
```

This example retrieves `MedicationRequest` resources with a code in the `Antithrombotic Therapy` value set that have a status of `active`, a doNotPerform of `true`, and a statusReason in the `Medical Reason` value set.

As with negation of events, the extent of the activity can be accounted for by searching for instances that make use of the `codeOptions` extension.

#### Rejected Requests

A key aspect of representing negation is documenting a rejected proposal. This was previously modeled with the status of the Request resources, however, this modeling is not consistent with FHIR Workflow patterns, in particular because it conflates the status of the request with the status of the fulfillment of that request.

Specifically, the status of a Request resource reflects the status of the _authorization_ of the request, and typically, only the author of the request can update the status of the _authorization_.

For example, a decision support proposal to "Prescribe Aspirin" is 'active', regardless of whether or what activities have been taken to fulfill (i.e. what actions are being taken to act on that proposal).

To represent the activities that have been taken relative to that proposal, either subsequent activities (such as Plans, Orders, or Events) that indicate acceptance of the proposal, or a Task to indicate rejection of the proposal.

Evidence that a proposal to administer "Antithrombotic Therapy" was rejected for an acceptable medical reason makes use of the `Task` resource:

```cql
define "Antithrombotic Therapy Requested":
  [MedicationRequest: "Antithrombotic Therapy"] MR
    where MR.status = 'active'
      and MR.doNotPerform is not true

define "Antithrombotic Therapy Rejected":
  "Antithrombotic Therapy Requested" MR
    with [Task: Fulfill] T
      such that T.focus.references(MR)
        and T.status = 'rejected'
        and T.statusReason in "Medical Reason"
```

This example retrieves "Antithrombotic Therapy Requested" resources that have a fulfillment Task focused on the request, a status of `rejected`, and a statusReason in the `Medical Reason` value set.

As with negation of events, the extent of the activity can be accounted for by searching for request instances that make use of the `codeOptions` extension.

#### Exclusions

Putting it all together, when modeling exclusions in clinical logic, typically all 3 of these use cases need to be considered:

```cql
define "Antithrombotic Therapy Not Provided For A Reason":
  exists "Antithrombotic Therapy Not Administered"
    or exists "Antithrombotic Therapy Prohibited"
    or exists "Antithrombotic Therapy Rejected"
```
