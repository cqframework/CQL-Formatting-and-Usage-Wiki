# Authoring Patterns

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

> NOTE: The information in this page is specifically using the [4.1.1](https://hl7.org/fhir/us/qicore/STU4.1.1/) version of QICore, which depends on the [3.1.1](https://hl7.org/fhir/us/core/STU3.1.1) version of USCore, and both of which are based on the [R4](https://hl7.org/fhir/R4) version 4.0.1 of FHIR. As of this writing (2023-01-26) QICore 5.0.0 is currently in ballot reconciliation and is expected to be published soon. A 5.0.0 version of this page will be produced once that publication is finalized.

The following sections provide specific examples of best practices for accessing information in each of these high-level areas.

### Patient

QICore defines a [QICore Patient](https://hl7.org/fhir/us/qicore/STU4.1.1/StructureDefinition-qicore-patient.html) profile that extends the USCore patient.

#### Patient age

Patient information includes the birth date, and CQL provides a built-in function to calculate the age of a patient, either current age (i.e. as of now), or as of a particular date. In quality improvement artifacts, age is typically calculated as of a particular date such as the start of the measurement period:

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

> NOTE: Terminology-valued elements in FHIR resources are _bound_ to _value sets_. The gender element is an example of a _required_ binding, which means that only the codes in that binding are allowed to be used. This is why the logic here can be specific about comparing to the actual string `'male'`. In general, terminology-valued elements should be compared using terminology operators. For more information see the [Using Terminology](https://hl7.org/fhir/us/cqfmeasures/using-cql.html#use-of-terminologies) topic in the Quality Measure IG.

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

Encounters in QICore model any encounter between a patient and any number of providers in any setting, including virtual.

#### Completed encounters in a period

```cql
define "Completed Encounters During the Measurement Period":
  [Encounter: "Office Visit"] OfficeVisit
    where OfficeVisit.status = 'finished'
      and OfficeVisit.period during "Measurement Period"
```

#### Encounters less than a certain length

```cql
define "Non-Elective Inpatient Encounter Less Than 120 Days":
  ["Encounter": "Non-Elective Inpatient Encounter"] NonElectiveEncounter
		where NonElectiveEncounter.period.lengthInDays() <= 120
```

#### Hospitalization

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

#### Active conditions

```cql
define "Active Condition":
  [Condition] Condition
    where (Condition.isProblemListItem() or Condition.isHealthConcern())
      and Condition.isActive()
```

#### Conditions indicated during an encounter

```cql
define "Conditions Indicated during an Encounter":
  [Condition] Condition
    where Condition.isEncounterDiagnosis()
```

#### Conditions present on admission

```cql
define "Encounter With Diabetes Diagnosis Present on Admission":
  "Non-Elective Inpatient Encounter Less Than 120 Days" IPEncounter
    where exists (IPEncounter.diagnosis D
      where D.condition.getCondition().code in "Diabetes"
        and D.diagnosisPresentOnAdmission in "Present on Admission or Clinically Undetermined"
    )
```

### Observations

#### Vital Signs

```cql
// Respiratory rate - 9279-1
// @profile: http://hl7.org/fhir/StructureDefinition/resprate
define RespiratoryRate:
  ["observation-resprate"] O

// Heart rate - 8867-4
// @profile: http://hl7.org/fhir/StructureDefinition/heartrate
define HeartRate:
  ["observation-heartrate"] O

// Oxygen saturation - 2708-6
// @profile: http://hl7.org/fhir/StructureDefinition/oxygensat
define OxygenSaturation:
  ["observation-oxygensat"] O

// Body temperature - 8310-5
// @profile: http://hl7.org/fhir/StructureDefinition/bodytemp
define BodyTemperature:
  ["observation-bodytemp"] O

// Body height - 8302-2
// @profile: http://hl7.org/fhir/StructureDefinition/bodyheight
define BodyHeight:
  ["observation-bodyheight"] O

// Head circumference - 9843-4
// @profile: http://hl7.org/fhir/StructureDefinition/headcircum
define HeadCircumference:
  ["observation-headcircum"] O

// Body weight - 29463-7
// @profile: http://hl7.org/fhir/StructureDefinition/bodyweight
define BodyWeight:
  ["observation-bodyweight"] O

// Body mass index - 39156-5
// @profile: http://hl7.org/fhir/StructureDefinition/bmi
define BodyMassIndex:
  ["observation-bmi"] O

// Blood pressure systolic and diastolic - 85354-9
// Systolic blood pressure - 8480-6
// Diastolic blood pressure - 8462-4
// @profile: http://hl7.org/fhir/StructureDefinition/bp
define "BloodPressure less than 140 over 90":
  ["observation-bp"] BP
    where BP.SystolicBP.value < 140 'mm[Hg]'
      and BP.DiastolicBP.value < 90 'mm[Hg]'

// USCore Pediatric BMI for Age - 59576-9
// @profile: http://hl7.org/fhir/us/core/StructureDefinition/pediatric-bmi-for-age
define PediatricBMIForAge:
  [USCorePediatricBMIforAgeObservationProfile]

// USCore Pediatric Weight for Height - 77606-2
// @profile: http://hl7.org/fhir/us/core/StructureDefinition/pediatric-weight-for-height
define PediatricWeightForHeight:
  [USCorePediatricWeightForHeightObservationProfile]

// USCore Pulse Oximetry - 59408-5
// @profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-pulse-oximetry
define PulseOximetry:
  [USCorePulseOximetryProfile]
```

#### Smoking Status

```cql
// USCore Smoking Status
// @profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-smokingstatus
define SmokingStatus:
  ["USCoreSmokingStatusProfile"] O
```

#### Laboratory Result

```cql
// USCore Laboratory Result
// @profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-observation-lab
define LaboratoryResult:
  [USCoreLaboratoryResultObservationProfile] O

```

#### Other Observations

```cql
define "Pap Test with Results":
	[Observation: "Pap Test"] PapTest
		where PapTest.value is not null
			and PapTest.status in { 'final', 'amended', 'corrected', 'preliminary' }
```

#### Observations not done

```cql
define TestGeneralObservationNotDone:
    ["ObservationNotDone": ObservationCodes]
```

### Medications

#### Medication ordered

```cql
```

#### Medication not ordered

```cql
define TestGeneralMedicationNotRequested:
    ["MedicationNotRequested": MedicationCodes]
```

#### Medication administered

```cql
define "Low Dose Unfractionated Heparin Administration":
  ["MedicationAdministration": medication in "Low Dose Unfractionated Heparin for VTE Prophylaxis"] VTEMedication
    where VTEMedication.status = 'completed'
      and VTEMedication.category ~ QICoreCommon."Inpatient"
```

#### Medication not administered

```cql
define "Low Dose Unfractionated Heparin for VTE Prophylaxis Not Administered":
    ["MedicationAdministrationNotDone": "Low Dose Unfractionated Heparin for VTE Prophylaxis"] VTEMedication
      where VTEMedication.category ~ QICoreCommon."Inpatient"
        and (VTEMedication.reasonCode in "Medical Reason" or VTEMedication.reasonCode in "Patient Refusal")
```

#### Medication dispensed

```cql
define "Dementia Medication Dispensed":
  ["MedicationDispense": "Dementia Medications"] MedicationDispense
    where MedicationDispense.status in { 'active', 'completed', 'on-hold' }
```

#### Medication not dispensed

```cql
define "Dementia Medication Not Dispensed":
    ["MedicationDispenseNotDone": "Dementia Medications"] MedicationDispense
      where MedicationDispense.statusReason in "Medical Reason"
        or MedicationDispense.statusReason in "Patient Refusal"
```

#### Medication in use

```cql
```

### Procedures

#### Procedure performed

```cql
```

#### Procedure not done

```cql
define TestGeneralProcedureNotDone:
    ["ProcedureNotDone": "Application of intermittent pneumatic compression devices (IPC)"]
```

#### Procedure ordered

```cql
```

#### Procedure not ordered

```cql
define TestGeneralServiceNotRequested:
    ["ServiceNotRequested": "Application of intermittent pneumatic compression devices (IPC)"]
```

### Devices

#### Device ordered

```cql
define "Device Indicating Frailty":
  [DeviceRequest: "Frailty Device"] FrailtyDeviceOrder
    where FrailtyDeviceOrder.status in { 'active', 'on-hold', 'completed' }
      and FrailtyDeviceOrder.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }
```

#### Device not ordered

```cql
define TestGeneralDeviceNotRequestedCode:
    ["DeviceNotRequested": code in "Venous Foot Pumps (VFP)"]
```

#### Device in use

```cql
```

### Allergies

#### Current allergies

```cql
define "Statin Allergy Intolerance":
  ["AllergyIntolerance": "Statin Allergen"] StatinAllergyIntolerance
    where StatinAllergyIntolerance.clinicalStatus is null or StatinAllergyIntolerance.clinicalStatus ~ QICoreCommon."allergy-active"
```

#### No known allergies

```cql
```

#### No evidence of a particular allergy

```cql
```

### Immunizations

> NOTE: The Immunization resources are reflective of immunization information as recorded
in an Immunization Information System. For immunizations as part of clinical workflow, the 
medication resources should be used?

#### Immunization performed

```cql
define "Polio Immunizations":
  ["Immunization": "Inactivated Polio Vaccine (IPV)"] PolioVaccination
    where PolioVaccination.status = 'completed'
```

#### Immunization not performed

```cql
```

#### Immunization recommended

```cql
```

