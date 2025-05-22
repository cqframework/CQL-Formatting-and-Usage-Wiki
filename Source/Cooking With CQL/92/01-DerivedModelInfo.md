A [ModelInfo](https://hl7.org/fhir/uv/cql/using-modelinfo.html) in CQL describes the structures that available for accessing data in a CQL expression. To simplify the model presented to knowledge artifact authors, model info for FHIR-based models up to this point have been "flattened", meaning that when an artifact is written using QICore, all the types are flattened into one set of classes in QICore. For example, the following hierarchy illustrates the derivation of the [QICore SimpleObservation](https://hl7.org/fhir/us/qicore/StructureDefinition-qicore-simple-observation.html) profile:

```
FHIR.Observation
  |- USCore.SimpleObservation
      |- QICore.SimpleObservation
```

## Flattened Model Info

With "flattened" model info, the QICore model info only has one type, `QICore.SimpleObservation`.

However, this approach has several drawbacks:

1. It limits reuse of functions, because classes from different models are considered completely separate types.
2. It hinders use of multiple models, because each model re-declares types all the way down to the data types in FHIR. (e.g. a FHIR.Reference is a different class than a QICore.Reference)
3. It doesn't lend itself well to cases where types in a base model are not re-profiled in the derived model. For example, USCore 3 did not have a ServiceRequest profile, so without bringing in FHIR directly, there was no way to talk about ServiceRequests. Similarly, QICore does not re-declare the various vital-signs profiles in USCore, so these must be "flattened" into QICore by the tooling.
4. It leads to many more classes than necessary, because each model info is re-declaring types throughout FHIR.

## Derived Model Info

With "derived" model info, each model info only introduces types for the profiles defined in that "model" (i.e. implementation guide).

This approach addresses the drawbacks of the flattened approach:

### Function Re-use

In the flattened model infos (for USCore 6.1.0 and QICore 6.0.0), reuse of functions has to be accomplished by considering multiple choice types. For example:

```cql
define fluent function isActive(condition Choice<"ConditionEncounterDiagnosis", "ConditionProblemsHealthConcerns">):
  condition.clinicalStatus ~ "active"
    or condition.clinicalStatus ~ "recurrence"
    or condition.clinicalStatus ~ "relapse"
```

This approach works, but is cumbersome, and only works for enumerated implementation guides, it does not extend to new implementation guides.

By contrast, with derived model infos (for USCore 7.0.0 and QICore 7.0.0), this same function is written directly against the FHIR Condition:

```cql
define fluent function isActive(condition FHIR.Condition):
  condition.clinicalStatus ~ "active"
    or condition.clinicalStatus ~ "recurrence"
    or condition.clinicalStatus ~ "relapse"
```

Because the USCore and QICore condition profiles ultimately derive from the FHIR Condition resource, this function will work for all of them, as well as any profiles of condition introduced in other models (for example a CRD or DTR condition).

As a more dramatic example, consider the current USCoreCommon functions for determining status of an Observation:

```cql
define fluent function isResulted(observation Choice<
    FHIR.Observation, 
    "observation-bodyweight",
    "observation-bodyheight",
    "observation-bmi",
    "observation-bp",
    "PediatricBMIforAgeObservationProfile",
    "PediatricWeightForHeightObservationProfile",
    "PulseOximetryProfile",
    "SmokingStatusProfile",
    "observation-vitalspanel",
    "observation-resprate",
    "observation-heartrate",
    "observation-oxygensat",
    "observation-bodytemp",
    "observation-headcircum",
    "observation-bmi",
    LaboratoryResultObservationProfile
>):
  observation.status ~ "observation-final".code
    or observation.status ~ "observation-amended".code
    or observation.status ~ "observation-corrected".code
```

Because types are flattened, each of these types is effectively a separate class, when in reality they are all derived from Observation. With the derived approach, this function becomes:

```cql
define fluent function isResulted(observation FHIR.Observation):
  observation.status ~ "observation-final".code
    or observation.status ~ "observation-amended".code
    or observation.status ~ "observation-corrected".code
```

And as noted before, this re-use addresses the problem of multiple models as well, because any new model that profiles Observation will still be able to make use of this function without change.