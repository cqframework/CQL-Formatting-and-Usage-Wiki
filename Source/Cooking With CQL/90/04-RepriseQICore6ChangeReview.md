This topic is a review/summary of the more detailed QICore6 Change Review presentation from session 89:

* [Uplift Guide for QICore 6.0.0](https://docs.google.com/presentation/d/15B-2ZfdpcfMQb3X2nRBIBIhYKeTS7QROKX7oU9n3cn4/edit#slide=id.p2)

[QICore version 6.0.0](http://hl7.org/fhir/us/qicore/STU6) was published in March of 2024. This new version of QICore is based on [US Core version 6.1.0](http://hl7.org/fhir/us/core/STU6.1).

Major changes to QICore 6.0.0 include:

* Identification of "QI Core" elements (similar to US Core 6 identification of "US CDI" elements)
* Removal of Must Support flags throughout and change of Must Support meaning
* Condition Changes
* Observation Changes

### QI Core Elements and Must Support Changes

Consider the 4.1.1 and 6.0.0 QI Core MedicationRequest profiles:

* https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-medicationrequest.html
* https://hl7.org/fhir/us/qicore/STU6/StructureDefinition-qicore-medicationrequest.html

In 4.1.1, Must Support was used to try to help indicate the likelihood of data being available in an element, and guidance was that clinical logic could only reference elements that were marked as must support. However, this approach did not align well across the multiple use cases that QICore (and USCore from which it is derived) is intended to support.

In addition, one of the major changes introduced in US Core 6.0.0 is the identification of particular elements as "US CDI", meaning that the element is supporting a specific US CDI data requirement.

As a result, QICore 6.0.0 changed all Must Support indicators to instead define them as QI Core Elements with an indicator `(QI Core)` that appears in the definition of elements.

This indicator means that the quality improvement community has identified the element as significant to express the full intent of measures or decision support artifacts.

Note that this indicator is for general implementation of QI Core. Measure and decision support specifications make use of the [DataRequirement](https://hl7.org/fhir/uv/cql/conformance.html#parameters-and-data-requirements) structure to communicate the specific data requirements for an artifact.

### Condition Changes

One of the most impactful changes is the split of the [Condition](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-condition.html) profile in 4.1.1 to [ConditionEncounterDiagnosis](https://hl7.org/fhir/us/qicore/STU6/StructureDefinition-qicore-condition-encounter-diagnosis.html) and [ConditionProblemsHealthConcerns](https://hl7.org/fhir/us/qicore/STU6/StructureDefinition-qicore-condition-problems-health-concerns.html) in 6.0.0

This split aligns generally with the way that EHR systems typically represent condition information, and has always been present in the Condition resource through the use of the `category` element. This split just means that in QICore 6.0.0, all access to conditions must go through these split profiles now. So effectively:

```cql
define "All Conditions":
  [Condition]
```

becomes:

```cql
define "All Conditions":
  [ConditionEncounterDiagnosis]
    union [ConditionProblemsHealthConcerns]
```

More details in the Uplift presentation as well as the [Conditions](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns-QICore-v6.0.0#conditions) topic in the Authoring Patterns page.

### Observation Changes

Another impactful change is the refinement of the Observation profiles. In particular:

1. Computable name changes (e.g. `"observation-bp"` is now `USCoreBloodPressureProfile`) see [Slide 5](https://docs.google.com/presentation/d/15B-2ZfdpcfMQb3X2nRBIBIhYKeTS7QROKX7oU9n3cn4/edit#slide=id.g32e29c00f25_0_55) for more
2. [Observation](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-observation.html) in 4.1.1 is now split into:
    * [Laboratory Result Observation](https://hl7.org/fhir/us/qicore/STU6/StructureDefinition-qicore-observation-lab.html)
    * [Clinical Result Observation](https://hl7.org/fhir/us/qicore/STU6/StructureDefinition-qicore-observation-clinical-result.html)
    * [Screening Assessment Observation](https://hl7.org/fhir/us/qicore/STU6/StructureDefinition-qicore-observation-screening-assessment.html)
    * [Simple Observation](https://hl7.org/fhir/us/qicore/STU6/StructureDefinition-qicore-simple-observation.html)
3. Additional Observation Profiles added from USCore 6

More details in the Uplift presentation as well as the [Observations](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns-QICore-v6.0.0#observations) topic in the Authoring Patterns page.