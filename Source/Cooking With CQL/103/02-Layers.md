This topic discusses principles for organizing logic into layers in order to maximize readability, maintainability, and implementability of artifact logic.

### The Four Layers

Split logic into four layers, each focused on answering a specific question:

| Layer | Answers | Contains | Must not contain |
|---|---|---|---|
| Concepts | What do we mean? | `valueset`, `code`, `codesystem`, accessor functions | Any expression |
| Elements | Which records count? | Retrieves plus status / intent / validity filters | Thresholds, encounters, populations |
| Inferences | What do the records mean? | Clinical classification, correlation, temporal scoping | Population criteria |
| Measure | Who is in which population? | Population criteria, SDEs | Anything else |

> Although presented from the perspective of quality measure logic, these layers can be applied to help organize any CQL-based artifacts, including decision support rules, public health reporting specifications, etc. by generalizing the last level to Artifacts.

#### Concepts Layer

The Concepts layer is focused on identifying and supporting access to the semantics used in artifact logic, i.e. What do we mean? The Concepts layer is identified separately to support:

* Review and maintenance: Keeping the terminology declarations used throughout the logic in a centrally managed location facilitates terminology review and maintenance
* Depencency management: Dependencies can be managed cleanly, always pointing towards terminology, and concepts depends on nothing

#### Elements Layer

The Elements layer is focused on identifying context-independent data elements (i.e. building blocks) of data, answering the question Which records count? These elements are then used to construct inferences and artifact logic by subsequent layers.

The elements layer focuses on data retrieves as well as status, intent, and validity filters. This layer should not be concerned with calculation, inferences, or other logic, its focus is to ensure all and only the data needed for calculation is available, not to establish the calculation itself.

Keeping this layer separate has several advantages:

* Simplifies the expression of downstream logic by allowing it to be expressed independently of status, intent, or validity checks.
* Maximizes re-use of data elements; many different inferences can be performed with the same building blocks
* Facilitates data requirements analysis; by keeping all retrieves in the elements layer, implementers can more easily access, analyze, and understand the data requirements of the logic

#### Inferences Layer

The Inferences layer is focused on using the building blocks available in the Elements layer to build up clinical inferences, such as clinical classification, correlation, and establishing temporal relationships. This layer answers the question What do the records mean?

#### Measure Layer

The Measure layer is focused on the actual expressions referenced by the measure, i.e. it is all and only the population, stratifier, and supplemental data criteria.

The population criteria are the measure's contract. If they are readable at a glance, a clinical reviewer can check the measure's *shape* without reading any computation.

### Choosing the Layer

The following guidelines can help establish which layer a given expression should live in:

1. If it contains a retrieve, the retrieve should be in an _Element_ declaration
2. If it contains a status, intent, or similar resource-specific validity check, it should be included in the _Element_ declaration
3. If it contains clinical classification logic, or references context such as the measurement period, it should be in an _Inference_ declaration
4. If it contains any of the above constructs, it should _not_ be in a Measure/Criteria definition

### Library Organization

Although these layers provide a natural way to organize artifact logic into libraries, it is not necessarily required; logic can still be separated into layers within the same library.

When this is done, it can be helpful to group expressions from different layers into the same area of the library source.

The important aspect of the layering is to ensure that references to declarations are in the right direction. Higher layers always reference lower layers, never the other way around:

```
Concepts
    ^
  Elements
      ^
    Inferences
        ^
      Criteria
```

### CQMCommon - Inpatient Encounters

As a simple example of applying these considerations, the current CQMCommon library has the following expression and supporting declarations:

```cql
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2026-01-01T00:00:00.000Z, @2027-01-01T00:00:00.000Z)

context Patient

define "Inpatient Encounter":
  [Encounter: "Encounter Inpatient"] EncounterInpatient
    where EncounterInpatient.status = 'finished'
      and EncounterInpatient.period ends during day of "Measurement Period"
```

Following the principles would result in:

**CQMConcepts**

```cql
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'
```

**CQMElements**

```cql
include CQMConcepts version '0.1.000'

context Patient

define "Inpatient Encounter":
  [Encounter: CQMConcepts."Encounter Inpatient"] EncounterInpatient
    where EncounterInpatient.status = 'finished'
```

**CQMInferences**

```cql
include CQMElements version '0.1.000' called CQMElements

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2026-01-01T00:00:00.000Z, @2027-01-01T00:00:00.000Z)

context Patient

define "Inpatient Encounter During Measurement Period":
  CQMElements."Inpatient Encounter" EncounterInpatient
    where EncounterInpatient.period ends during day of "Measurement Period"
```

