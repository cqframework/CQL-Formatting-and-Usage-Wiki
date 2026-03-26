This topic looks at making use of the shared artifacts in the [Common CQL Artifacts for FHIR (US-Based) Implementation Guide](https://build.fhir.org/ig/HL7/us-cql-ig) in the FHIR-based 2025 AU draft CMS measures.

For the purposes of this discussion, we will be focusing on the following 5 measures:

| Measure | QICore 6 | QICore 6-Derived |
|----|----|----|
| CMS2: Preventive Care and Screening: Depression Screening and Followup | [6.0.0](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/CMS2FHIRPCSDepScreenAndFollowUp.cql) | [6.0.0-derived](https://github.com/cqframework/dqm-content-cms-2025/blob/main/input/cql/CMS2FHIRPCSDepScreenAndFollowUp.cql) |
| CMS122: Diabetes: Glycemic Status Assessment | [6.0.0](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/CMS122FHIRDiabetesAssessGT9Pct.cql) | [6.0.0-derived](https://github.com/cqframework/dqm-content-cms-2025/blob/main/input/cql/CMS122FHIRDiabetesAssessGT9Pct.cql)* |
| CMS125: Breast Cancer Screening | [6.0.0](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/CMS125FHIRBreastCancerScreen.cql) | [6.0.0-derived](https://github.com/cqframework/dqm-content-cms-2025/blob/main/input/cql/CMS125FHIRBreastCancerScreen.cql) |
| CMS130: Colon Cancer Screening | [6.0.0](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/CMS130FHIRColorectalCancerScrn.cql) | [6.0.0-derived](https://github.com/cqframework/dqm-content-cms-2025/blob/main/input/cql/CMS130FHIRColorectalCancerScrn.cql)* |
| CMS165: Controlling High Blood Pressure | [6.0.0](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/CMS165FHIRControllingHighBP.cql) | [6.0.0-derived](https://github.com/cqframework/dqm-content-cms-2025/blob/main/input/cql/CMS165FHIRControllingHighBP.cql)* |

Note: Measures marked with an asterisk are still in progress

These are all EC measures that make use of the following shared libraries:

| Shared Library | QI Core 6 | QICore 6-Derived |
|----|----|----|
| AdultOutpatientEncounters | [6.0.0](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/AdultOutpatientEncounters.cql) | [6.0.0-derived](https://github.com/cqframework/dqm-content-cms-2025/blob/main/input/cql/AdultOutpatientEncounters.cql) |
| AdvancedIllnessandFrailty | [6.0.0](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/AdvancedIllnessandFrailty.cql) | [6.0.0-derived](https://github.com/cqframework/dqm-content-cms-2025/blob/main/input/cql/AdvancedIllnessandFrailty.cql) |
| CumulativeMedicationDuration | [6.0.0](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/CumulativeMedicationDuration.cql) | [6.0.0-derived](https://build.fhir.org/ig/HL7/us-cql-ig/en/Library-CumulativeMedicationDuration.html) |
| Hospice | [6.0.0](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/Hospice.cql) | [6.0.0-derived](https://github.com/cqframework/dqm-content-cms-2025/blob/main/input/cql/Hospice.cql) |
| PalliativeCare | [6.0.0](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/PalliativeCare.cql) | [6.0.0-derived](https://github.com/cqframework/dqm-content-cms-2025/blob/main/input/cql/PalliativeCare.cql) |
| QICoreCommon | [6.0.0](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/QICoreCommon.cql) | [6.0.0-derived](https://github.com/cqframework/dqm-content-cms-2025/blob/main/input/cql/QICoreCommon.cql) |
| Status | [6.0.0](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/Status.cql) | [6.0.0-derived](https://github.com/cqframework/dqm-content-cms-2025/blob/main/input/cql/Status.cql) |
| SupplementalDataElements | [6.0.0](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/SupplementalDataElements.cql) | [6.0.0-derived](https://github.com/cqframework/dqm-content-cms-2025/blob/main/input/cql/SupplementalDataElements.cql) |

These shared libraries had already been updated to use the QICore 7.0.0 (a derived model info) so these were just brought in and updated to use the 6.0.0-derived model instead, no other changes were required to the shared libraries.

> NOTE: Hospital measures and related shared libraries (CQMCommon, PCMaternal, TJCOverall, and others) are still in progress.

This topic will use CMS125: Breast Cancer Screening as a running example

### Step 1: Update Models

To facilitate reuse across models, the `QICore 6.0.0-derived` and `USCore 6.1.0-derived` models provide model information for CQL that provides a "derived" view of FHIR profiles.

For example, in `QICore 6.0.0`, a QICore Encounter is effectively a _base_ class. However, in `QICore 6.0.0-derived`, a QICore Encounter is a _derived_ class, derived from a US Core Encounter, which is in turn derived from a FHIR Encounter:

6.0.0:

```
Encounter
```

6.0.0-derived:

```
FHIR.Encounter
    |- USCore.Encounter
        |- QICore.Encounter
```

For almost all the measure logic, this change is transparent and the only thing that needs to happen is to change the version of the model being used:

6.0.0:

```cql
using QICore version '6.0.0'
```

6.0.0-derived:

```cql
using QICore version '6.0.0-derived'
using USCore version '6.1.0-derived'
using FHIR version '4.0.1'
```

### Step 2: Update Libraries

Once the models have been updated, we need to update the shared library references:

| Library | 6.0.0 version | 6.0.0-derived version |
|----|----|----|
| AdultOutpatientEncounters | 4.19.000 | 5.1.000 |
| AdvancedIllnessandFrailty | 1.27.000 | 2.1.000 |
| CumulativeMedicationDuration | 6.0.000 | hl7.fhir.us.cql.CumulativeMedicationDuration version 2.0.0-ballot |
| FHIRHelpers | 4.4.000 | hl7.fhir.uv.cql.FHIRHelpers version 4.0.1 |
| FHIRCommon | - | hl7.fhir.uv.cql.FHIRCommon version 2.0.0 |
| Hospice | 6.18.000 | 7.1.000 |
| PalliativeCare | 1.18.000 | 2.1.000 |
| QICoreCommon | 4.0.000 | 5.1.000 |
| Status | 1.15.000 | 2.1.000 |
| SupplementalDataElements | 5.1.000 | 6.1.000 |
| USCoreCommon | - | hl7.fhir.us.cql.USCoreCommon version 2.0.0-ballot |
| USCoreElements | - | hl7.fhir.us.cql.USCoreElements version 2.0.0-ballot |

For example, the following snippet is the includes section of the CMS125 6.0.0 Breast Cancer Screening measure:

```cql
include FHIRHelpers version '4.4.000' called FHIRHelpers
include SupplementalDataElements version '5.1.000' called SDE
include QICoreCommon version '4.0.000' called QICoreCommon
include AdultOutpatientEncounters version '4.19.000' called AdultOutpatientEncounters
include Hospice version '6.18.000' called Hospice
include Status version '1.15.000' called Status
include PalliativeCare version '1.18.000' called PalliativeCare
include AdvancedIllnessandFrailty version '1.27.000' called AIFrailLTCF
```

And the equivalent section for the CMS125 6.0.0-derived Breast Cancer Screening measure:

```cql
include hl7.fhir.uv.cql.FHIRHelpers version '4.0.1' called FHIRHelpers
include hl7.fhir.uv.cql.FHIRCommon version '2.0.0' called FHIRCommon
include hl7.fhir.us.cql.USCoreCommon version '2.0.0-ballot' called USCoreCommon
include hl7.fhir.us.cql.USCoreElements version '2.0.0-ballot' called USCoreElements

include QICoreCommon version '5.1.000' called QICoreCommon
include SupplementalDataElements version '6.1.000' called SDE
include Status version '2.1.000' called Status
include AdultOutpatientEncounters version '5.1.000' called AdultOutpatientEncounters
include AdvancedIllnessandFrailty version '2.1.000' called AIFrailLTCF
include Hospice version '7.1.000' called Hospice
include PalliativeCare version '2.1.000' called PalliativeCare
```

### Step 3: Update Types

When a CQL library includes multiple models, there is a possibility of having classes with the same name in each model. This will result in an "ambiguous type" error, where the translator cannot determine which model should be used.

6.0.0:

```cql
define "Bilateral Mastectomy Procedure":
  ( ( [Procedure: "Bilateral Mastectomy"] ).isProcedurePerformed ( ) ) BilateralMastectomyPerformed
    where BilateralMastectomyPerformed.performed.toInterval ( ) ends on or before end of "Measurement Period"
```

6.0.0-derived:

```cql
define "Bilateral Mastectomy Procedure":
  ( ( [QICore.Procedure: "Bilateral Mastectomy"] ).isProcedurePerformed ( ) ) BilateralMastectomyPerformed
    where BilateralMastectomyPerformed.performed.toInterval ( ) ends on or before end of "Measurement Period"
```

> DISCUSS: Should we propose that when using multiple models, type names SHALL be qualified

In addition, the possibility of derived profiles means that some logic can be simplified. For example, in QICore 6.0.0, ConditionEncounterDiagnosis and ConditionProblemHealthConcerns are separate types, whereas in QICore 6.0.0-derived, they both ultimately derive from Condition, allowing logic that needs to deal with both to be written at the Condition level, rather than the EncounterDiagnosis and ProblemHealthConcern level:

6.0.0:

```cql
define "Bilateral Mastectomy Diagnosis":
  ( ( [ConditionEncounterDiagnosis: "History of bilateral mastectomy"]
      union [ConditionProblemsHealthConcerns: "History of bilateral mastectomy"]
  ).verified ( ) ) BilateralMastectomyHistory
    where BilateralMastectomyHistory.prevalenceInterval ( ) starts on or before end of "Measurement Period"
```

6.0.0-derived:

```cql
define "Bilateral Mastectomy Diagnosis":
  ( ( [FHIR.Condition: "History of bilateral mastectomy"] ).verified ( ) ) BilateralMastectomyHistory
    where BilateralMastectomyHistory.prevalenceInterval ( ) starts on or before end of "Measurement Period"
```

### Step 3: Replace extension elements:

In the derived models, extensions and slices are no longer created as first-class elements, rather they are represented as fluent functions:

6.0.0:

```cql
    and Patient.sex = '248152002'
```

6.0.0-derived:

```cql
    and Patient.sex() = '248152002'
```

### Step 4: Consider Functions

6.0.0:

```cql
define "Initial Population":
  AgeInYearsAt(date from end of "Measurement Period") in Interval[42, 74]
```

6.0.0-derived:

```cql
define "Initial Population":
  Patient.ageInYearsAt(date from end of "Measurement Period") in Interval[42, 74]
```

### Step 5: Consider Elements and Patterns

And finally, consider whether the patterns documented in the CQL US Common IG can be applied to the measure logic. For example, the [Mammography](https://build.fhir.org/ig/HL7/us-cql-ig/en/patterns-service.html#mammography) pattern proposes that in addition to Observation resources, Mammographies may be represented in FHIR data as DiagnosticReport resources:

6.0.0:

```cql
define "Numerator":
  exists ( ( [ObservationClinicalResult: "Mammography"] ).isDiagnosticStudyPerformed ( ) ) Mammogram
    where Mammogram.effective.toInterval ( ) ends during day of Interval["October 1 Two Years Prior to the Measurement Period", end of "Measurement Period"]
```

6.0.0-derived:

```cql
define "Numerator":
  exists ( 
    ( ( [ObservationClinicalResult: "Mammography"] ).isDiagnosticStudyPerformed ( ) ) Mammogram
      where Mammogram.effective.toInterval ( ) ends during day of Interval["October 1 Two Years Prior to the Measurement Period", end of "Measurement Period"]
  ) or exists (
    ( ( [DiagnosticReportNote: "Mammography"] ).complete ( ) ) Mammogram
      where Mammogram.effective.toInterval ( ) ends during day of Interval["October 1 Two Years Prior to the Measurement Period", end of "Measurement Period"]
  )
```

