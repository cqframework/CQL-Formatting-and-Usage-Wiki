To facilitate sharing clinical logic, the QICore 7.0.0 modelinfo, about to be published as part of the QICore STU7 publication will be a "derived" model info, rather than a "flattened" one as previous versions of QICore were.

The QICore STU7 publication updates QICore to the 7.0.0 version of USCore, as well as numerous updates to the profiles, including:

* Narrative summaries for each profile
* New "QI Elements" view of the profiles
* Indications of "primary code path" for each profile
* Updates to negation profiles across all activity types
* Derived ModelInfo, rather than Flattened

## Narrative Summaries

Similar to the way USCore profiles are described, each QICore profile now includes a narrative summary describing the main constraints for each profile. For example:

* [MedicationRequest](https://build.fhir.org/ig/HL7/fhir-qi-core/StructureDefinition-qicore-medicationrequest.html)

## QI Elements View

In addition to the profiles index, there is now a QI Elements view of the QICore profiles that provides a summary of the narratives for each profile, focused on "QI Elements", which are data elements that are known to be referenced by measures and/or decision support artifacts.

* [QI Elements](https://build.fhir.org/ig/HL7/fhir-qi-core/qi-elements.html)

## Negation Profiles

In QICore 6.0.0, profiles for requests and events were organized as "positive" and "negative" profiles:

* MedicationRequest
* MedicationNotRequested

However, this approach has some limitations:

1. Logic that does not involve positive/negative aspects cannot be reused, have to write each case independently.
2. Constraints that exist in both positive/negative profiles have to be restated

Based on this implementer and stakeholder feedback, the negation pattern has been expanded in QICore 7.0.0 to include a "general", "positive", and "negative" profile:

* MedicationRequest
  * MedicationRequested
  * MedicationProhibited

This allows constraints that are common to both the positive and negative cases to be expressed in the general profile, and also allows logic to be written at the general level.

In addition, the negation patterns in QICore 7.0.0 have been better aligned to support the various negation use cases:

1. Documentation that an activity was not performed for a reason (i.e. a "notDone" event)
2. Documentation that an activity should not performed for a reason (i.e. a "doNotPerform" request, or "Prohibited")
3. Documentation that a request was not performed for a reason (i.e. a taskRejected)

For more complete discussion, refer to the [Negation](https://build.fhir.org/ig/HL7/fhir-qi-core/negation.html) topic in QICore.

## Derived ModelInfo

From a CQL authoring perspective, one of the biggest changes in QICore 7.0.0 is that the ModelInfo is now Derived. For example, in QICore 6.0.0, observation profiles are used directly, so:

```cql
using QICore 6.0.0

...

define "Blood Pressure Observations":
  ["US Core Blood Pressure Profile"]
```

However, in 7.0.0, to reference USCore profiles, include the USCore model:

```cql
using QICore 7.0.0
using USCore 7.0.0

...

define "Blood Pressure Observations":
  ["Blood Pressure Profile"]
```

As pointed out in the discussion on derived model info earlier, this means in particular that logic can now be shared across different profiles of the same resource, and that retrieves can be performed at the base resource. For example, references to Condition resources in QICore 6 were split between EncounterDiagnosis and ProblemsHealthConcerns:

```cql
define function "GetCondition"(reference Reference):
  singleton from (
    ([ConditionEncounterDiagnosis] union [ConditionProblemsHealthConcerns]) C 
      where reference.references(C.id)
  )
```

This function can now be expressed directly against the Condition resource in the FHIR model instead:

```cql
define function "GetCondition"(reference Reference):
  singleton from (
    [Condition] C
      where reference.references(C.id)
  )
```

> NOTE: This is only a high-level "What's New" in QICore 7, for a complete list of changes, refer to the publication change logs for the USCore 7 and QICore 7.

