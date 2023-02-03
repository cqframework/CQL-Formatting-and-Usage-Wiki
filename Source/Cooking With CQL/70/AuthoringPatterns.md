# Authoring Patterns (QICore v4.1.1)

This page provides discussion and best-practice recommendations for authoring patterns for accessing patient information in FHIR and CQL. For general conventions and guidance regarding the use of FHIR and CQL, refer to the [Using CQL](https://hl7.org/fhir/us/cqfmeasures/using-cql.html) topic in the Quality Measure IG.

## QICore Information Model Overview

[HL7 Fast Healthcare Interoperability Resources (FHIR)](https://hl7.org/fhir/R4) is a platform specification for exchanging healthcare data. FHIR defines a core information model that can be profiled for use in a variety of applications across the healthcare industry. These profiles are defined in Implementation Guides that provide constraints on the ways that FHIR resources can be used in to support interoperability (i.e. the ability of both sides of an interaction to correctly interpret the information being exchanged).

In the United States, the [US Core](http://hl7.org/fhir/us/core/STU3.1.1/) Implementation Guide defines a floor for that interoperability, enabling a broad range of clinical and administrative use cases. For quality improvement use cases, such as decision support and quality measurement, the [QI Core](https://hl7.org/fhir/us/qicore/STU4.1.1/) Implementation Guide extends US Core to support additional information used for quality improvement. For the most part, US Core covers the data required, but some use cases, such as documentation of events that did not occur, require additional profiles.

[Clinical Quality Language(CQL)](https://cql.hl7.org/N1) is high-level, domain-specific language focused on clinical quality and targeted at measure and decision support artifact authors.

To simplify the expression of logic in quality improvement artifacts, CQL can be authored directly against the information model defined by the QI Core profiles. In the simplest terms, that information model provides:

1. [Patient](#patient) - Representation of patient demographic and basic characteristics
2. [Encounters](#encounters) - Encounters between a patient and healthcare providers, typically taking place at a facility or virtually
3. [Observations](#observations) - Facts about the patient such as lab results, vital signs, social history, etc.
4. [Conditions](#conditions) - Conditions the patient has (or does not have)
5. [Allergies](#allergies) - Allergies and intolerances the patient has (or does not have)
6. [Medications](#medications) - Information related to medications the patient is prescribed and/or using
7. [Procedures](#procedures) - Information related to procedures ordered and/or performed for the patient
8. [Devices](#devices) - Information related to devices the patient is using and/or has been prescribed
9. [Immunizations](#immunizations) - Information related to immunizations the patient has received or been recommended
10. [Communication](#communications) - Information related to communications with or about the patient

> NOTE: The information in this page specifically uses the [4.1.1](https://hl7.org/fhir/us/qicore/STU4.1.1/) version of QICore, which depends on the [3.1.1](https://hl7.org/fhir/us/core/STU3.1.1) version of USCore, and both of which are based on the [R4](https://hl7.org/fhir/R4) version 4.0.1 of FHIR. As of this writing (2023-01-26) QICore 5.0.0 is currently in ballot reconciliation and is expected to be published soon. A 5.0.0 version of this page will be produced once that publication is finalized.

The following sections provide specific examples of best practices for accessing information in each of these high-level areas.

### Patient

QICore defines a [QICore Patient](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-patient.html) profile that extends the USCore patient.

#### Patient age

Patient information includes the birth date, and CQL provides a built-in function to calculate the age of a patient, either current age (i.e. as of now), or _as of_ a particular date. In quality improvement artifacts, age is typically calculated _as of_ a particular date such as the start of the measurement period:

```cql
define "Patient Age Between 50 and 75":
  AgeInYearsAt(start of "Measurement Period") between 50 and 75
```

> NOTE: The [AgeInYearsAt](https://cql.hl7.org/09-b-cqlreference.html#ageat) function in CQL uses the data model (QICore in this case) to understand how to access the patient's birth date information.

#### Patient gender

Patient gender in FHIR is represented using codes from the [AdministrativeGender](https://hl7.org/fhir/R4/codesystem-administrative-gender.html) code system:

```cql
define "Patient Is Male":
  Patient.gender = 'male'
```

> NOTE: Terminology-valued elements in FHIR resources are _bound_ to _value sets_. The gender element is an example of a _required_ binding, which means that only the codes in the bound value set are allowed to be used. This allows the logic in this example to compare using the actual string `'male'`. In general, terminology-valued elements should be compared using terminology operators. For more information, see the [Using Terminology](https://hl7.org/fhir/us/cqfmeasures/using-cql.html#use-of-terminologies) topic in the Quality Measure IG.

#### Patient race and ethnicity

US Core defines extensions for representing the race and ethnicity of a patient using the CDC's race and ethnicity codes. When authoring using QICore, these extensions can be accessed directly on the patient using the "slice name" of the extension:

```cql
define "Patient Race Includes Alaska Native":
  Patient P
    where exists (P.race.ombCategory C where C ~ "American Indian or Alaska Native")
      and exists (P.race.detailed C where C ~ "Alaska Native")
```

> NOTE: CQL uses the data model (QICore in this case) to understand how to access patient information using the `Patient` definition. This definition is available in `Patient` contexts.

### Encounters

QICore defines an [Encounter](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-encounter.html) profile to model any encounter between a patient and any number of providers in any setting, including virtual.

> NOTE: For background information on accessing clinical information with CQL, see the [Retrieve](https://cql.hl7.org/02-authorsguide.html#retrieve) topic in the CQL specification.

#### Office visit encounters

By default, encounters in QICore are characterized by the `type` element, which is typically associated with a value set to limit the set of encounters returned to those with a code in the given value set. For example:

```cql
define "Office Visit Encounters":
  [Encounter: "Office Visit"]
```

#### Encounters by class

The QICore profile also supports characterizing encounters by the `class` element, which is used to categorize encounters more broadly than the `type` element, using the [ActEncounterCode](https://terminology.hl7.org/3.1.0/ValueSet-v3-ActEncounterCode.html) value set. For example:

```cql
define "Virtual Encounters":
  [Encounter: class ~ QICoreCommon."virtual"]
```

#### Completed encounters in a period

Encounters often need to be filtered based on `status` and `period`, for example:

```cql
define "Completed Encounters During the Measurement Period":
  [Encounter: "Office Visit"] OfficeVisit
    where OfficeVisit.status = 'finished'
      and OfficeVisit.period during "Measurement Period"
```

#### Encounters with a certain length

The [CQMCommon](input/cql/CQMCommon.cql) library defines a `lengthInDays()` function that calculates the difference in days between the start and end of a period. For example, to filter encounters by the duration of stay:

```cql
define "Non-Elective Inpatient Encounter Less Than 120 Days":
  ["Encounter": "Non-Elective Inpatient Encounter"] NonElectiveEncounter
    where NonElectiveEncounter.period.lengthInDays() <= 120
```

Other durations can also be calculated, for example:

```cql
define "Non-Elective Inpatient Encounter Over 24 Hours":
  ["Encounter": "Non-Elective Inpatient Encounter"] NonElectiveEncounter
    where duration in hours of NonElectiveEncounter.period >= 24
```

> NOTE: For ongoing encounters, the end of the period is often not specified, which will typically be interpreted in CQL as an ongoing period, resulting in large duration values.

#### Hospitalization

For inpatient encounters, measures and rules often need to consider total hospitalization period, including any immediately prior emergency department and/or observation status encounters. To facilitate this, the CQMCommon library defines a `hospitalizationWithObservation()` function that returns the total duration from admission to the emergency department or observation to the end of the inpatient encounter. For example:

```cql
define "Comfort Measures Performed":
  ["Procedure": "Comfort Measures"] InterventionPerformed
    where InterventionPerformed.status in { 'completed', 'in-progress' }

define "Encounter with Comfort Measures Performed during Hospitalization":
  "Non-Elective Inpatient Encounter Less Than 120 Days" Encounter
    with "Comfort Measures Performed" ComfortMeasure
      such that start of ComfortMeasure.performed.toInterval() during Encounter.hospitalizationWithObservation()
```

### Conditions

QICore defines the [Condition](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-condition.html) profile to represent information about patient problems, health concerns, and diagnoses.

As an aside, whether expressions in general should use the various elements of a profile depends entirely on measure or rule intent. However, there are some general guidelines that should be followed to ensure correct expression and evaluation of CQL. 

To begin with, all elements in FHIR profiles have a _cardinality_ that determines whether and how many values may appear in that element. Cardinality is expressed as a range, typically from 0 or 1 to 1 or \*. A cardinality of 0..1 means the element is optional. A cardinality of 1..1 means the element is required. A cardinality of 0..\* means the element may appear any number of times, and a cardinality of 1..\* means the element must appear at least once, but may appear multiple times. Although other cardinalities are possible, those described above are the most common.

> NOTE: Cardinality determines whether and how many values may appear for a given element, but the fact that an element is specified as required (e.g. 1..1) does not mean that expressions using that profile must use that element.

In addition, elements in FHIR profiles may be marked _must support_, meaning that implementations are required to provide values for the element if they are present in the system. To ensure expression logic can be evaluated correctly, expressions must only use elements that are marked must support. For a complete discussion of this aspect, refer to the [MustSupport Flag](https://hl7.org/fhir/us/qicore/STU4.1.1/#mustsupport-flag) topic in the QICore Implementation Guide.

And finally, elements in FHIR profiles may be marked as _modifier elements_, meaning that the value of the element may change the overall meaning of the resource. For example, the _clinicalStatus_ element of a Condition is a modifier element because the value determines whether the Condition overall represents the _presence_ or _absence_ of a condition. As a result, for each modifier element, authors must carefully consider whether each possible value would impact the intent of the expression.

To summarize, cardinality determines whether data will be present at all, must support determines whether the element can be used in an expression, and modifier elements must always be considered to determine the impact of possible values of the element on the result of the expression. End of aside.

#### Active conditions

By default, Condition resources are characterized by the `code` element which is typically associated with a value set of diagnosis codes.

Many clinical systems make a distinction between the active conditions for a patient (i.e. the problem list or health concerns) and the diagnoses associated with an encounter. Problem list items and health concerns are typically documented with additional information about the condition such as prevalence period and clinical status, while encounter diagnoses typically have less information, usually only the diagnosis code as part of the encounter information. Within FHIR, both these types of data are represented using the Condition resource. The `category` element is used to indicate which kind of data the Condition represents, a problem list item, a health concern, or an encounter diagnosis. 

Depending on measure intent, different approaches may be needed to access condition data. In particular, clinical status and prevalence period would only be expected to be present on problem list items and health concerns:

```cql
define "Active Diabetes Conditions":
  [Condition: Diabetes] Condition
    where (Condition.isProblemListItem() or Condition.isHealthConcern())
      and Condition.isActive()
```

The [QICoreCommon](input/cql/QICoreCommon.cql) library defines `isProblemListItem()` and `isHealthConcern()` functions to facilitate identifying the category of a Condition, as well as an `isActive()` function to facilitate determining whether the Condition indicates the presence of a particular diagnosis for the patient. The `isActive()` function is equivalent to testing the `clinicalStatus` element for the `active`, `recurrence`, and `relapse` values.

#### Conditions indicated during an encounter

For encounter diagnoses, QICoreCommon defines an `isEncounterDiagnosis()` function to facilitate identifying encounter diagnoses:

```cql
define "Diabetes Conditions Indicated during an Encounter":
  [Condition: Diabetes] Condition
    where Condition.isEncounterDiagnosis()
```

Note the absence of testing for the clinical status of the condition.

#### Onset, abatement, and prevalence period

The Condition profiles defines onset and abatement elements that specify the prevalence period of the condition. The elements can be specified as choices of various types to allow systems flexibility in the way that information is represented. The QICore profile for Condition constrains those choices to only those that support actual computation of a prevalence period, and the QICoreCommon library defines `abatementInterval` and `prevalenceInterval` functions to facilitate accessing this information:

```cql
define "Active Diabetes Conditions Onset During the Measurement Period":
  "Active Diabetes Conditions" Diabetes
    where Diabetes.prevalenceInterval() starts during "Measurement Period"
```

#### Conditions present on admission

The QICore Condition profile also defines a `diagnosisPresentOnAdmission` indicator to allow systems to indicate whether a particular diagnosis was present on admission for an encounter:

```cql
define "Encounter With Diabetes Diagnosis Present on Admission":
  "Non-Elective Inpatient Encounter Less Than 120 Days" IPEncounter
    where exists (IPEncounter.diagnosis D
      where D.condition.getCondition().code in "Diabetes"
        and D.diagnosisPresentOnAdmission in "Present on Admission or Clinically Undetermined"
    )
```

Note that this expression is using the condition reference from the Encounter to retrieve the specific encounter diagnosis. This is done using the `getCondition()` function defined in QICoreCommon, as opposed to retrieving the Condition resources directly as in the previous examples.

### Observations

QICore defines a variety of profiles for use in accessing observations for a patient. Specifically, QICore includes the Vital Signs profiles defined in the base FHIR specification, as well as several additional Vital Signs profiles defined in USCore such as Pediatric BMI.

In general, these profiles do not constrain the value of the `status` element, meaning that retrieves of these profiles will return observations in any status. As a modifier element, authors must consider the possible values of the observation status when determining how to filter the results of a retrieve of these profiles.

#### Vital Signs

When using QICore to access profiled resources, the result of the retrieve will only include resources that conform to that profile. This means that the retrieve is effectively a `filter by conformance`, meaning that the expression does not need to provide filters for values that are _fixed_ by the profile definition. When retrieving Respiratory rate, for example, this means that the expression does not need to test that the `code` of the Observation is the LOINC code for respiratory rate (9279-1), the retrieve will only result in observations that already have that code:

```cql
// Respiratory rate - 9279-1
// @profile: http://hl7.org/fhir/StructureDefinition/resprate
define RespiratoryRate:
  ["observation-resprate"] O
    where O.status in { 'final', 'amended', 'corrected' }
```

As a rule of thumb, if a profile definition defines a fixed value constraint for an element, then the expression does not need to use that element.

```cql
// Heart rate - 8867-4
// @profile: http://hl7.org/fhir/StructureDefinition/heartrate
define HeartRate:
  ["observation-heartrate"] O
    where O.status in { 'final', 'amended', 'corrected' }

// Oxygen saturation - 2708-6
// @profile: http://hl7.org/fhir/StructureDefinition/oxygensat
define OxygenSaturation:
  ["observation-oxygensat"] O
    where O.status in { 'final', 'amended', 'corrected' }

// Body temperature - 8310-5
// @profile: http://hl7.org/fhir/StructureDefinition/bodytemp
define BodyTemperature:
  ["observation-bodytemp"] O
    where O.status in { 'final', 'amended', 'corrected' }

// Body height - 8302-2
// @profile: http://hl7.org/fhir/StructureDefinition/bodyheight
define BodyHeight:
  ["observation-bodyheight"] O
    where O.status in { 'final', 'amended', 'corrected' }

// Head circumference - 9843-4
// @profile: http://hl7.org/fhir/StructureDefinition/headcircum
define HeadCircumference:
  ["observation-headcircum"] O
    where O.status in { 'final', 'amended', 'corrected' }

// Body weight - 29463-7
// @profile: http://hl7.org/fhir/StructureDefinition/bodyweight
define BodyWeight:
  ["observation-bodyweight"] O
    where O.status in { 'final', 'amended', 'corrected' }

// Body mass index - 39156-5
// @profile: http://hl7.org/fhir/StructureDefinition/bmi
define BodyMassIndex:
  ["observation-bmi"] O
    where O.status in { 'final', 'amended', 'corrected' }

// Blood pressure systolic and diastolic - 85354-9
// Systolic blood pressure - 8480-6
// Diastolic blood pressure - 8462-4
// @profile: http://hl7.org/fhir/StructureDefinition/bp
define "BloodPressure less than 140 over 90":
  ["observation-bp"] BP
    where BP.status in { 'final', 'amended', 'corrected' }
      and BP.SystolicBP.value < 140 'mm[Hg]'
      and BP.DiastolicBP.value < 90 'mm[Hg]'

// USCore Pediatric BMI for Age - 59576-9
// @profile: http://hl7.org/fhir/us/core/StructureDefinition/pediatric-bmi-for-age
define PediatricBMIForAge:
  [USCorePediatricBMIforAgeObservationProfile] O
    where O.status in { 'final', 'amended', 'corrected' }

// USCore Pediatric Weight for Height - 77606-2
// @profile: http://hl7.org/fhir/us/core/StructureDefinition/pediatric-weight-for-height
define PediatricWeightForHeight:
  [USCorePediatricWeightForHeightObservationProfile] O
    where O.status in { 'final', 'amended', 'corrected' }

// USCore Pulse Oximetry - 59408-5
// @profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-pulse-oximetry
define PulseOximetry:
  [USCorePulseOximetryProfile] O
    where O.status in { 'final', 'amended', 'corrected' }
```

#### Smoking Status

QICore includes the USCore Smoking Status profile:

```cql
// USCore Smoking Status
// @profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-smokingstatus
define SmokingStatus:
  ["USCoreSmokingStatusProfile"] O
    where O.status in { 'final', 'amended', 'corrected' }
```

#### Laboratory Result

Laboratory results in QICore use the [USCoreLaboratoryResultObservationProfile](https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-observation-lab.html). Laboratory results in QICore are characterized by the `code` element.

```cql
// @profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-observation-lab
define LaboratoryResult:
  [USCoreLaboratoryResultObservationProfile] O
    where O.status in { 'final', 'amended', 'corrected' }
```

#### Other Observations

In addition, QICore defines a general [Observation](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-observation.html) profile for use when accessing observations that are not covered by the specific profiles defined in FHIR and US Core. Observations in QICore are characterized by the `code` element, which is typically filtered to a particular value set:

```cql
define "Pap Test with Results":
  [Observation: "Pap Test"] PapTest
    where PapTest.value is not null
      and PapTest.status in { 'final', 'amended', 'corrected', 'preliminary' }
```

> NOTE: As with the other observation profiles, the status of a QICore Observation must be considered in order to ensure that the results of the expression will match measure intent. This typically means that the status element will be used in the expression as in the prior example.

#### Observations not done

And finally, QICore defines an [ObservationNotDone](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-observationnotdone.html) profile to support identifying observations that were not performed for a particular reason:

```cql
define "Pap Test Refused":
  ["ObservationNotDone": "Pap Test"] PapTest
    where PapTest.notDoneReason in "Patient Refusal"
```

### Medications

FHIR defines several medication-related resources that are profiled for use in the US by USCore, and then by QICore for use in quality improvement artifacts. For background on the FHIR medication resources, see the [Medications Module](https://hl7.org/fhir/medications-module.html) in the base FHIR specification. Additional guidance on how medication information is profiled within US Core can be found in the [Medication List Guidance](https://hl7.org/fhir/us/core/STU3.1.1/all-meds.html) topic in the US Core implementation guide.

#### Medication ordered

QICore defines the [MedicationRequest](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-medicationrequest.html) profile to represent medication proposals, plans, and orders, as well as self-reported medications. The following example illustrates an order for Antithrombotic Therapy to be taken by the patient once discharged. MedicationRequest resources in QICore are characterized by the `medication` element which can be represented as a code or a reference.


```cql
define "Antithrombotic Therapy at Discharge":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] Antithrombotic
    where (Antithrombotic.isCommunity() or Antithrombotic.isDischarge())
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent = 'order'
      and Antithrombotic.doNotPerform is not true
```

> NOTE: Because the `status` element is a modifier that is not constrained by the profile to a specific value or value set, authors must consider all the possible values of the status to ensure the expression matches measure intent. In this case the statuses of `active` and `completed` indicate active or filled prescriptions for medications in the Antithrombotic Therapy value set.

> NOTE: Because the MedicationRequest profile does not fix the value of the `doNotPerform` element, authors must consider the value of this element to ensure the expression matches measure intent. In this case, the `doNotPerform` element is tested to ensure it `is not true`. This phrasing is important in that it captures both the case that there is no value for the `doNotPerform` element, as well as when the value is specified as `false`.


#### Medication not ordered

QICore defines the [MedicationNotRequested](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-mednotrequested.html) profile to represent documentation of the reason for not ordering a particular medication or class of medications. By default, MedicationNotRequested resources in QICore are characterized by the `medication` element which can be represented as a code or a reference.

```cql
define "Reason for Not Ordering Antithrombotic":
  ["MedicationNotRequested": "Antithrombotic Therapy"] NoAntithromboticDischarge
    where (NoAntithromboticDischarge.reasonCode in "Medical Reason"
      or NoAntithromboticDischarge.reasonCode in "Patient Refusal")
      and (NoAntithromboticDischarge.isCommunity() or NoAntithromboticDischarge.isDischarge())
      and NoAntithromboticDischarge.intent = 'order'
```

> NOTE: Because the MedicationNotRequested profile fixes the value of `doNotPerform` to true, that element does not need to be tested in the expression.

#### Medication administered

QICore defines the [MedicationAdministration](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-medicationadministration.html) profile to represent the administration of a medication to a patient. By default, MedicationAdministration resources in QICore are characterized by the `medication` element, which can be represented as a code or a reference.

```cql
define "Low Dose Unfractionated Heparin Administration":
  ["MedicationAdministration": medication in "Low Dose Unfractionated Heparin for VTE Prophylaxis"] VTEMedication
    where VTEMedication.status = 'completed'
      and VTEMedication.category ~ QICoreCommon."Inpatient"
```

> NOTE: Because the MedicationAdministration profile does not fix the value of the `status` element, authors must consider all the possible values of the element to ensure the expression matches measure intent. In this case, the `completed` status indicates the only completed medication administrations should be returned.

#### Medication not administered

QICore defines the [MedicationAdministrationNotDone](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-mednotadministered.html) profile to represent documentation of the reason a medication administration did not occur. By default, MedicationAdministrationNotDone resources in QICore are characterized by the `medication` element, which can be represented as a code or a reference.

```cql
define "Low Dose Unfractionated Heparin for VTE Prophylaxis Not Administered":
  ["MedicationAdministrationNotDone": "Low Dose Unfractionated Heparin for VTE Prophylaxis"] VTEMedication
    where VTEMedication.category ~ QICoreCommon."Inpatient"
      and (VTEMedication.reasonCode in "Medical Reason" or VTEMedication.reasonCode in "Patient Refusal")
```

> NOTE: Because the MedicationAdministrationNotDone profile fixes the value of `status` to `not-done`, that element does not need to be tested in the expression.

#### Medication dispensed

QICore defines the [MedicationDispense](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-medicationdispense.html) profile to represent the fulfillment of a medication request, either in a hospital or community pharmacy. By default, MedicationDispense resources in QICore are charaacterized by the `medication` element, which can be represented as a code or a reference.

```cql
define "Dementia Medication Dispensed":
  ["MedicationDispense": "Dementia Medications"] MedicationDispense
    where MedicationDispense.status in { 'active', 'completed', 'on-hold' }
```

> NOTE: Because the MedicationDispense profile does not fix the value of the `status` element, authors must consider all the possible values of the element to ensure the expression matches measure intent. In this case, the `active`, `completed`, and `on-hold` statuses are used to retrieve any positive dispensing event.

#### Medication not dispensed

QICore defines the [MedicationDispenseNotDone](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-mednotdispensed.html) profile to represent documentation of the reason that a dispense did not occur. By default, MedicationDispenseNotDone resources in QICore are characterized by the `medication` element, which can be represented as a code or a reference.

```cql
define "Dementia Medication Not Dispensed":
    ["MedicationDispenseNotDone": "Dementia Medications"] MedicationDispense
      where MedicationDispense.statusReason in "Medical Reason"
        or MedicationDispense.statusReason in "Patient Refusal"
```

> NOTE: Because the MedicationDispenseNotDone profile fixes the value of the `status` element to `declined`, that element does not need to be tested in the expression.

#### Medication in use

TODO

```cql
```

### Procedures

FHIR defines several procedure-related resources to support representing the proposal, planning, ordering, and performance of services and procedures for a patient.

#### Procedure performed

QICore defines the [Procedure](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-procedure.html) profile to represent an in-progress or complete procedure for a patient. By default, Procedure resources in QICore are characterized by the `code` element.

```cql
define "Application of Intermittent Pneumatic Compression Devices":
  ["Procedure": "Application of Intermittent Pneumatic Compression Devices (IPC)"] DeviceApplied
    where DeviceApplied.status = 'completed'
```

> NOTE: Because the Procedure profile does not fix the value of the `status` element, authors must consider all the possible values of the element to ensure the expression meets measure intent. In this case, `completed` status is used to indicate that only completed procedures should be returned.

#### Procedure not done

QICore defines the [ProcedureNotDone](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-procedurenotdone.html) profile to represent documentation of the reason a particular procedure, or class of procedures, was not performed. By default, ProcedureNotDone resources in QICore are characterized by the `code` element.

```cql
define "Intermittent Pneumatic Compression Devices Not Applied":
  [ProcedureNotDone: "Application of Intermittent Pneumatic Compression Devices (IPC)"] DeviceNotApplied
    where DeviceNotApplied.statusReason in "Medical Reason" 
      or DeviceNotApplied.statusReason in "Patient Refusal"
```

> NOTE: Because the ProcedureNotDone profile fixes the value of the status element to `not-done`, that element does not need to be tested in the expression.

#### Procedure ordered

QICore defines the [ServiceRequest](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-servicerequest.html) profile to represent the proposal, planning, or ordering of a particular service. By default, ServiceRequest resources in QICore are characterized by the `code` element.

```cql
define "Intermittent Pneumatic Compression Devices Ordered":
  ["ServiceRequest": "Application of intermittent pneumatic compression devices (IPC)"] DeviceOrdered
    where DeviceOrdered.status in { 'active', 'completed', 'on-hold' }
      and DeviceOrdered.doNotPerform is not true
```

> NOTE: Because the ServiceRequest profile does not fix the value of the `status` element, authors must consider all the possible values of the element to ensure the expression matches measure intent. In this case, the `active`, `completed`, and `on-hold` statuses are used to ensure a positive order.

> NOTE: Because the ServiceRequest profile does not fix the value of the `doNotPerform` element, authors must consider the value of this element to ensure the expression matches measure intent. In this case, the `doNotPerform` element is tested to ensure it `is not true`. This phrasing is important in that it captures both the case that there is no value for the `doNotPerform` element, as well as when the value is specified as `false`.

#### Procedure not ordered

QICore defines the [ServiceNotRequested](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-servicenotrequested.html) profile to represent documentation of the reason a particular service or class of services was not ordered. By default, ServiceNotRequested resources in QICore are characterized by the `code` element.

```cql
define "Intermittent Pneumatic Compression Devices Not Ordered":
  ["ServiceNotRequested": "Application of intermittent pneumatic compression devices (IPC)"] DeviceNotOrdered
    where DeviceNotOrdered.reasonRefused in "Medical Reason"
      or DeviceNotOrdered.reasonRefused in "Patient Refusal"
```

> NOTE: Because the ServiceNotRequested profile fixes the value of `doNotPerform` to `true`, that element does not need to be tested in the expression.

### Devices

FHIR defines several resources related to the tracking and management of devices used by patients, including [Device](http://hl7.org/fhir/device.html) and [DeviceRequest](http://hl7.org/fhir/devicerequest.html).

#### Device ordered

QICore defines the [DeviceRequest](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-devicerequest.html) profile to represent proposals, planning, and ordering of devices for a patient. By default, DeviceRequest resources in QICore are characterized by the `code` element, which can be represented as a code or a reference.

```cql
define "Device Indicating Frailty":
  [DeviceRequest: "Frailty Device"] FrailtyDeviceOrder
    where FrailtyDeviceOrder.status in { 'active', 'on-hold', 'completed' }
      and FrailtyDeviceOrder.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }
      and FrailtyDeviceOrder.doNotPerform() is not true
```

> NOTE: Because the DeviceRequest profile does not fix the value of the `status` element, authors must consider all the possible values of the element to ensure the expression matches measure intent. In this case the `active`, `completed` and `on-hold` statuses are used to ensure a positive device order.

> NOTE: Because the DeviceRequest profile does not fix the value of the `doNotPerform` element, authors must consider the value of this element to ensure the expression matches measure intent. In this case, the `doNotPerform` element is tested to ensure it `is not true`. This phrasing is important in that it captures both the case that there is no value for the `doNotPerform` element, as well as when the value is specified as `false`.

> NOTE: The 4.1.1 version of this profile does not define doNotPerform as an allowable extension, so the QICoreCommon library includes a `doNotPerform()` function that accesses the modifier extension if it is present in the instance.

#### Device not ordered

QICore defines the [DeviceNotRequested](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-devicenotrequested.html) profile to represent documentation of the reason for not ordering a particular device, or class of devices. By default, DeviceNotRequested resources in QICore are characterized by the `code` element, which can be represented as a code or a reference.

```cql
define "Venous Foot Pumps Not Ordered":
  ["DeviceNotRequested": "Venous Foot Pumps (VFP)"] DeviceNotOrdered
    where DeviceNotOrdered.doNotPerformReason in "Medical Reason"
      or DeviceNotOrdered.doNotPerformReason in "Patient Refusal"
```

> NOTE: Because the DeviceNotRequested profile fixes the value of `doNotPerform` to true, this element does not need to be tested in the expression.

#### Device in use

TODO

```cql
```

### Allergies

FHIR defines the [AllergyIntolerance](http://hl7.org/fhir/allergyintolerance.html) resource to represent allergies and intolerances for a patient.

#### Current allergies

QICore defines the [AllergyIntolerance](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-allergyintolerance.html) profile to represent allergies and intolerances for a patient. By default, AllergyIntolerance resources in QICore are characterized by the `code` element.

```cql
define "Statin Allergy Intolerance":
  ["AllergyIntolerance": "Statin Allergen"] StatinAllergyIntolerance
    where StatinAllergyIntolerance.clinicalStatus is null 
      or StatinAllergyIntolerance.clinicalStatus ~ QICoreCommon."allergy-active"
```

> NOTE: Because the AllergyIntolerance profile does not constrain the values of the `clinicalStatus` or `verificationStatus` elements of the resource, authors must consider the possible values of these elements to ensure the expression matches measure intent. In this case, the `clinicalStatus`, if present, must be `"allergy-active"`.

#### No known allergies

TODO

```cql
```

#### No evidence of a particular allergy

TODO

```cql
```

### Immunizations

FHIR defines several immunization-related resources to track and manage the immunization information for a patient, including [Immunization](http://hl7.org/fhir/immunization.html) and [ImmunizationRecommendation](http://hl7.org/fhir/immunizationrecommendation.html). 

> NOTE: The Immunization resources are reflective of immunization information as recorded
in an Immunization Information System. For immunizations as part of clinical workflow, the 
medication resources should be used?

#### Immunization performed

QICore defines the [Immunization](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-immunization.html) profile to represent immunization information for a patient. By default, Immunization resources in QICore are characterized by the `vaccineCode` element.

```cql
define "Polio Immunizations":
  ["Immunization": "Inactivated Polio Vaccine (IPV)"] PolioVaccination
    where PolioVaccination.status = 'completed'
```

> NOTE: Because the Immunization profile does not fix the value of the `status` element, authors must consider all the possible values for the element to ensure the expression meets measure intent.

#### Immunization not performed

QICore defines the [ImmunizationNotDone](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-immunizationnotdone.html) profile to represent documentation of the reason an immunization was not performed. By default, ImmunizationNotDone resources in QICore are characterized by the `vaccineCode` element.

```cql
define "Reason for No Polio Immunization":
  ["ImmunizationNotDone": "Inactivated Polio Vaccine (IPV)"] PolioVaccination
    where PolioVaccination.statusReason in "Medical Reason"
      or PolioVaccination.statusReason in "Patient Refusal"
```

> NOTE: Because the ImmunizationNotDone profile fixes the value of the `status` element to `not-done`, this element does not need to be tested in the expression.

#### Immunization recommended

TODO

```cql
```

### Communications

#### Communication

QICore defines the [Communication](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-communication.html) profile to represent communications with or about the patient. By default, Communication resources in QICore are characterized by the `reasonCode` element.


```cql
define "Macular Edema Absence Communicated":
  ["Communication": "Macular edema absent (situation)"] MacularEdemaAbsentCommunicated
    with "Office Visit Encounters" EncounterDiabeticRetinopathy
      such that MacularEdemaAbsentCommunicated.sent after start of EncounterDiabeticRetinopathy.period
    where MacularEdemaAbsentCommunication.status = 'completed'
```

> NOTE: Because the Communication profile does not fix the value of the `status` element, authors must consider all the possible values for the element to ensure the expression meets measure intent.

> NOTE: This expression uses a _direct-reference code_ of "Macular edema absent (situation)" (i.e. referencing a specific code from a code system, rather than a value set consisting of multiple codes). For more information on using direct-reference codes in CQL expressions, refer to the [Codes](https://hl7.org/fhir/us/cqfmeasures/using-cql.html#codes) topic in the Quality Measure IG.

#### Communication not done

QICore defines the [CommunicationNotDone](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-communicationnotdone.html) to represent documentation of the reason a communication was not done. By default, CommunicationNotDone resources in QICore are characterized by the `reasonCode` element.

```cql
define "Reason for Macular Edema Absent Not Communicated":
  ["CommunicationNotDone": "Macular Edema Absent Findings"] MacularEdemaAbsentNotCommunicated
    with "Office Visit Encounters" EncounterDiabeticRetinopathy
      such that MacularEdemaAbsentNotCommunicated.sent during EncounterDiabeticRetinopathy.period
    where MacularEdemaAbsentNotCommunicated.statusReason in "Medical Reason"
        or MacularEdemaAbsentNotCommunicated.statusReason in "Patient Refusal"
```

> NOTE: Because the CommunicationNotDone profile fixes the value of the `status` element to `not-done`, this element does not need to be tested in the expression.

> NOTE: The positive counterpart for this statement (Macular Edema Absence Communicated) uses a direct-reference code, and ideally the negative statement would as well. However, at this time, direct-reference codes cannot be used as the terminology target of a retrieve of a negation profile. Available workarounds for this issue are to either create a value set with the single required code as in the prior example, or to use the long-hand expression of the negation statement, as shown in the following example:

```cql
define "Reason for Macular Edema Absent Not Communicated (Explicit Test)":
  ["CommunicationNotDone"] MacularEdemaAbsentNotCommunicated
    with "Office Visit Encounters" EncounterDiabeticRetinopathy
      such that MacularEdemaAbsentNotCommunicated.sent during EncounterDiabeticRetinopathy.period
    where (MacularEdemaAbsentNotCommunicated.reasonCode ~ "Macular edema absent (situation)"
        or "Macular edema absent (situation)" in MacularEdemaAbsentNotCommunicated.reasonCode
      )
      and (MacularEdemaAbsentNotCommunicated.statusReason in "Medical Reason"
        or MacularEdemaAbsentNotCommunicated.statusReason in "Patient Refusal"
      )
```

#### Communication ordered

```cql
```