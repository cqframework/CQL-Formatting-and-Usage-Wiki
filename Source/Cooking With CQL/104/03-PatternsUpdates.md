Main topic for today is a review of recent updates to the authoring patterns, including a fairly significant proposed update to the encounter processing for hospitalization logic.

As a reminder, since the availability of US Quality Core, the Authoring Patterns that were maintained in the CQL Formatting and Usage wiki have been refactored to the Authoring Patterns page here:

* [Authoring Patterns](https://build.fhir.org/ig/cqframework/cms-qmd/patterns.html)

In particular, this content includes the [US Quality Core Update Process](https://build.fhir.org/ig/cqframework/cms-qmd/usqc_update_process.html), a guide to refactoring QI Core-based content to use the new US Quality Core model, as well as a [Refactored Index](https://build.fhir.org/ig/cqframework/cms-qmd/refactored_index.html) that documents where QI Core-based shared logic has been refactored to, as well as the most current versions of shared logic libraries.

## Claim diagnoses

The [Claim](https://hl7.org/fhir/R4/claim.html) structure in FHIR is used to exchange the information related to provision of health care services. It represents the provider-side of this information where the provision is complete (a claim), proposed (a preauthorization), or being explored (a predetermination). In the context of quality improvement, we most often use see this information referenced as data elements on the provider-submitted claim information, such as present-on-admission or principal diagnosis.

However, the provider submitted claim information is also a potential source for diagnoses generally, so the authoring patterns have been updated to allow for this possiblity. A provider-submitted claim may be used to identify both _evidence of diagnosis during an encounter_ and _history of a condition_. As with the other diagnosis-related billing elements, these both make use of the `Claim Item Diagnosis` expression defined in `ClaimElements`.

### Evidence of diagnosis during an encounter

> This topic is a summary, see [Evidence of diagnosis during an encounter](https://build.fhir.org/ig/cqframework/cms-qmd/pattern_claim.html#evidence-of-diagnosis-on-an-encounter) for more detail.

For example, the following expression can be used to determine whether there is an Asthma diagnosis on any provider-submitted claim related to a given encounter:

```cql
define "Encounter With Asthma":
  [USQualityCore.Encounter] E
    with "Claim Item Diagnosis" D
      such that D.isRelatedTo(E)
        and D.diagnosis in "Asthma"
```

The `isRelatedTo()` function here tests whether the claim diagnosis information is related to an encounter based on:

* A direct reference to the Encounter record
* Whether the `serviced` date is during the Encounter `period`
* Whether the claim's `billablePeriod` is during the Encounter `period`

Depending on measure intent, this claim-related information can then be used as another potential source of information when searching for evidence of a diagnosis during an encounter. For example:

```cql
define "Encounter With Asthma":
  [USQualityCore.Encounter] E
    where E.reasonCode in "Asthma"
      or exists (
        [USQualityCore.ConditionEncounterDiagnosis: "Asthma"] C
          where C.encounter.references(E)
            or C.isReasonForVisit(E)
      )
      or exists (
        [USQualityCore.ConditionProblemsHealthConcerns: "Asthma"] C
          where C.prevalenceInterval() overlaps E.period
      )
      or exists (
        "Claim Item Diagnosis" CID
          where CID.isRelatedTo(E)
            and CID.diagnosis in "Asthma"
      )
```

This expression searches for evidence of an asthma diagnosis as:

* The reason for visit (expressed as a `reasonCode` on the encounter)
* The reason for visit (expressed as a Condition referenced by `reasonReference` on the encounter)
* An Encounter Diagnosis (expressed as Condition referencing the encounter)
* A Problem/Health Concern (expressed as a Condition with a prevalence interval overlapping the encounter period)
* A diagnosis code on Claim related to the encounter (using `isRelatedTo()` as discussed above)

Some considerations for evidence of diagnosis during an encounter:

1. **start timing** - How the prevalence interval is related, whether diagnosis should _overlap_ or _start during_ the encounter
2. **status vs prevalence** - Whether to use the _current status_ element as opposed to calculating the _prevalence interval_ for historical consideration, especially for conditions that are unlikely to resolve
3. **verification** - Whether and how stringently to test the verification status of the condition
4. **onset vs asserted vs recorded** - Whether and how to determine the _starting point_ for timing considerations

### History of condition

> This topic is a summary, see [History of a Condition](https://build.fhir.org/ig/cqframework/cms-qmd/pattern_claim.html#history-of-a-condition) for more detail.

As well, provider-submitted claims may be a source of historical claim information:

```cql
define "Claim-based History Of Diabetes":
  "Claim Item Diagnosis" D
    where D.diagnosis in "Diabetes"
```

This claim-based source can then be combined with potential sources in the clinical record:

```cql
define "Clinical History Of Diabetes":
  [FHIR.Condition: "Diabetes"] C
    where C.isVerified() // To ensure we are not looking at refuted

define "Has Clinical or Claim-based History of Diabetes":
  exists "Claim-based History Of Diabetes"
    or exists "Clinical History Of Diabetes"
```

As with evidence of diagnosis during an encounter, condierations for history of diagnosis include:

1. **start timing** - What the look-back period is and how the timing of the diagnosis relates to it
2. **status vs prevalence** - Whether to use the _current status_ element as opposed to calculating the _prevalence interval_, especially for conditions that are unlikely to resolve
3. **verification** - Whether and how stringently to test the verification status of the condition
4. **onset vs asserted vs recorded** - Whether and how to determine the _starting point_ for conderation

### Diagnosis date and relevantPeriod()

> This topic is proposed for inclusion in the Condition Authoring Patterns.

Because both _evidence of diagnosis during and encounter_ and _history of condition_ have similar considerations, it's worth discussing whether there are some additional patterns that can help facilitate consistent logic to address these considerations. 

First, the US Core Condition Encounter Diagnosis and Problem Health Concern profiles both have the [following language](https://hl7.org/fhir/us/core/STU6.1/StructureDefinition-us-core-condition-problems-health-concerns.html#mandatory-and-must-support-data-elements):

> There is no single element in Condition that represents the date of diagnosis. It may be the assertedDate Extension, Condition.onsetDateTime, or Condition.recordedDate.
Although all three are marked as Must Support, the server is not required to support all.
>    * A server SHALL support Condition.recordedDate.
>    * A server SHALL support at least one of assertedDate Extension and Condition.onsetDateTime. A server may support both, which means they support all 3 locations.
>    * The client application SHALL support all three elements.

To capture this, we can define a `diagnosisDate()` function on Conditions:

```cql
define fluent function diagnosisDate(condition FHIR.Condition):
  Coalesce(
    start of condition.onset.toInterval(),
    condition.assertedDate(),
    condition.recordedDate
  )
```

We can then use this function to define a `relevantPeriod`, similar to `prevalenceInterval`, but starting from `diagnosisDate()` instead:

```cql
define fluent function relevantPeriod(condition FHIR.Condition):
  Period(
    condition.diagnosisDate(),
    end of condition.abatementInterval(),
    condition.isActive()
  )
```

We can then substitute `relevantPeriod()` wherever `prevalencePeriod` is used, noting that:

* `prevalencePeriod` is used when logic should _only_ consider clinically recorded `onset` when determining whether a condition is present
* `relevantPeriod` is used when logic should _preferntially_ consider clinically recorded `onset`, but fallback to `assertedDate`, and then `recordedDate` as the starting point

## Known issues list

In addition to authoring patterns, we have added a [Known Issues List](https://build.fhir.org/ig/cqframework/cms-qmd/knownissues.html) to support visibility and management of known issues and their solutions. Several of the topics on this agenda are recent additions to the known issues list.

### Prevalence Interval Issue:

> This topic is a summary, see [Prevalence Interval Issue](https://build.fhir.org/ig/cqframework/cms-qmd/knownissues.html#prevalence-interval-issue) for more detail.

When an inactive condition does not have an abatement date, the prevalenceInterval function incorrectly returns `null`, rather than `Interval[onset, null)`. To address this issue, we are proposing: 

* Define a Period function that allows for the creation of a DateTime interval with an optionally closed ending boundary:

```cql
define function Period(start System.DateTime, end System.DateTime, endClosed System.Boolean):
  if endClosed or end is not null then
    Interval[start, end]
  else
    Interval[start, end)
```

* Define a prevlaencePeriod() function that makes use of this Period function:

```cql
define fluent function prevalencePeriod(condition Condition):
  Period(
    start of condition.onset.toInterval(), 
    end of condition.abatementInterval(), 
    condition.isActive()
  )
```

This change corrects the logic, and will be included in the next release of Using CQL With FHIR (STU 3). Until that release is available, this logic will be provided in the CQMConcepts library (version 0.4.000). This issue has been logged as a comment on the Using CQL With FHIR implementation guide: https://jira.hl7.org/browse/FHIR-59708 

### Qualifying type names

[Seemingly Ambiguous Type References Are Allowed](https://build.fhir.org/ig/cqframework/cms-qmd/knownissues.html#seemingly-ambiguous-type-references-are-allowed)

### Unspecified primary code paths

[Incorrect or Missing Primary Code Paths](https://build.fhir.org/ig/cqframework/cms-qmd/knownissues.html#incorrect-or-missing-primary-code-paths)

## Slice index

[Slice Index](https://build.fhir.org/ig/cqframework/cms-qmd/refactored_index.html#slice-index)

## Reason for visit

[Reason for visit](https://build.fhir.org/ig/cqframework/cms-qmd/pattern_encounters.html#reason-for-visit)

## Immunization recommendations

[Immunization Recommendations](https://build.fhir.org/ig/cqframework/cms-qmd/pattern_immunizations.html#immunization-recommendations)

## Nutrition orders

[Nutrition Orders](https://build.fhir.org/ig/cqframework/cms-qmd/pattern_procedures.html#nutrition-orders)

## Encounter priority and elective vs non-elective encounters

[Encounter Priority](https://build.fhir.org/ig/cqframework/cms-qmd/pattern_encounters.html#encounter-priority-and-elective-encounters)

## Procedure/order priority and elective vs non-elective procedures

[Procedure Priority](https://build.fhir.org/ig/cqframework/cms-qmd/pattern_procedures.html#procedure-priority)

## Encounter normalization logic

[Hospitalization](https://build.fhir.org/ig/cqframework/cms-qmd/pattern_encounters.html#hospitalization)

Considering a "Normalize Encounters" approach as well, which _constructs_ an Encounter that encompasses all the included encounters in a series, in addition to the current `includedEncounters()` approach.
