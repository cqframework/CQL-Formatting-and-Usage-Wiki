# Test HIV Measure

This topic discusses a question from the CQL Zulip thread:

[CQL Coding](https://chat.fhir.org/#narrow/stream/179220-cql/topic/CQL.20Coding)

## Question

I have another question related to enumerating the number of HIV tests vs. the number of people tested. I am enumerating number of tests through this code:

```cql
define "HIV test during measurement period":
  exists(
    ([Observation] O
    where O.status ~ {'final', 'amended'}
    and O.code in "HIVtesttypeCodes"
    and O.issued during "Measurement Period")
    )
```

Which says find observations of a specific test type code within the measurement period. How do you suppose we would differentiate between this code which counts number of tests vs. number of people tested. I could think of two ways:

1) Could we just adjust context between unfiltered and patient? I am still unclear what this context specifies.
2) We adjust this code to look at unique linked patient resource through the subject variable in the observation resource?

## Discussion

### CQL vs Measure

The first part of the answer to this question is that CQL does not by itself define quality measures, it only defines the expressions for population criteria that can be used in quality measures. You need a higher-level mechanism to provide the measure structure. In FHIR, this is provided by the [Measure](http://hl7.org/fhir/measure.html) resource. Briefly, this resource defines a quality measure using a set of standardized scoring and criteria types that facilitate:

1. Authoring measures using standard, patient-focused constructs that support a broad range of quality measurement use cases, including proportion measures, continuous variable measures, ratios, and composites
2. Implementing measures by providing a standardized representation of the computable aspects of a quality measure, so implementations can support that range of use cases with the same infrastructure

To support those goals, quality measures make use of the [context](https://cql.hl7.org/02-authorsguide.html#context) feature of CQL, and more specifically, the `Patient` context defined as part of the FHIR model info. You can think of the `Patient` context in CQL as roughly equivalent to the `Patient` compartment of FHIR, in that it scopes the resources available to any given query to a particular patient.

Any [retrieve]() that is evaluated in the `Patient` context, will only return data related to that specific patient. In CQL, this is the [Retrieve Context](https://cql.hl7.org/02-authorsguide.html#retrieve-context).

CQL is written this way to make it easier to reason about the criteria related to a patient, eliminating the need for authors to express the relationship to the patient.

When CQL is evaluated, the implementation environment determines how to provide data to the engine, and for what context.

In the case of a decision support rule, there is typically only a single patient in context, and the CQL is evaluated for that context.

In the case of a quality measure, there is generally a population of patients being considered, and the CQL is either evaluated for each patient in that context, and the results aggregated, or the CQL is transformed in such a way that it can be applied to a entire data store, and the patient relationships are respected as part of that transformation.

Back to the original question, how can we count "Number of Tests" vs "Number of People Tested"

Both of these questions would typically be answered from the `Patient` context, but they represent two distinct "measures" using the same data point.

Let's start with the data point, the "HIV Test":

```cql
define "Resulted HIV Test":
  [Observation: "HIV Tests"] O
    where O.status in { 'final', 'amended' }
      and O.value is not null
```

We can then use this to define two different measures, both in the Patient context.

The first measure, "Number of HIV Tests" is a continuous variable measure where the "Measure Observation" is the number of tests:

```cql
define "Initial Population":
  exists (
    "Active HIV Diagnosis" D
      where D.prevalencePeriod() overlaps "Measurement Period"
  )

define "Measure Population":
  "Initial Population"

define "Measure Observation"(patient Patient):
  Count(
    "Resulted HIV Test" T
      where T.issued during "Measurement Period"
  )
```

The second measure, "Percentage of patients that were tested" is a proportion measure:

```cql
define "Initial Population":
  exists (
    "Active HIV Diagnosis" D
      where D.prevalencePeriod() overlaps "Measurement Period"
  )

define "Denominator":
  "Initial Population"

define "Numerator":
  exists (
    "Resulted HIV Test" T
      where T.issued during "Measurement Period"
  )
```

