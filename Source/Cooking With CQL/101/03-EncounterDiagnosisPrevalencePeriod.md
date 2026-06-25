## ConditionEncounterDiagnosis Inclusion in dQM

This topic discusses several measures where ConditionEncounterDiagnosis Inclusion in dQM when encounter.diagnosis was not included in the eCQM

ConditionEncounterDiagnosis Timing (prevalenceInterval)

* dQMs have incorporated ConditionEncounterDiagnosis when the eCQM version did not include encounter diagnoses.
* Abatement dates are rarely, if ever, documented for diagnoses associated to encounters.
* The capture of specific timing for a diagnosis onset has been a workflow issue across multiple EHR vendors for several years. Diagnosis required for the measure doesn't happen in real time (as the provider is managing an emergency and charting is completed later). In many cases, diagnoses are added to the chart much later by coders and coding interfaces which do not provide the onset and abatement dates.

The **QDM** does not prescribe the **source of diagnosis** data in the EHR. Diagnoses may be found in a patient's **problem list, encounter diagnosis list, claims data, or other sources** within the EHR.

The US Core **Condition Problems and Health Concerns Profile** defines constraints and extensions on the Condition resource for the minimal set of data to record, search, and fetch information about a condition, diagnosis, or other event, situation, issue, or clinical concept that is documented and categorized as a problem or health concern

Constrained Value: <http://terminology.hl7.org/CodeSystem/condition-category>: problem-list-item or health-concern

The **US Core Condition Encounter Diagnosis Profile** defines constraints and extensions on the Condition resource for the minimal set of data to record, search, and fetch information about an encounter diagnosis.

Fixed Value: <http://terminology.hl7.org/CodeSystem/condition-category>: encounter-diagnosis

### Examples

**CMS122v14 - Diabetes: Glycemic Status Assessment Greater Than 9%**

**eCQM**

```cql
define "Initial Population":
  AgeInYearsAt(date from end of "Measurement Period") in Interval[18, 75]
  and exists ( "Qualifying Encounters" )
  and exists ( 
    ["Diagnosis": "Diabetes"] DiabetesDiagnosis
      where DiabetesDiagnosis.prevalencePeriod overlaps day of "Measurement Period"
  )
```

**dQM**

```cql
define "Initial Population":
  AgeInYearsAt(date from end of "Measurement Period") in Interval[18, 75]
    and exists "Qualifying Encounters"
    and exists (
      (([ConditionEncounterDiagnosis: "Diabetes"]).verified()) DiabetesDiagnosis
        where DiabetesDiagnosis.prevalenceInterval() overlaps day of "Measurement Period"
    )
```

**CMS 69 Preventive Care and Screening: Body Mass Index (BMI) Screening and Follow Up Plan**

**eCQM**

```cql
define "Is Pregnant During Day Of Measurement Period":
  exists ( 
    ["Diagnosis": "Pregnancy"] PregnancyDiagnosis
      with "Qualifying Encounter During Day Of Measurement Period" QualifyingEncounter
        such that PregnancyDiagnosis.prevalencePeriod overlaps day of "Measurement Period"
  )
```

**dQM**

```cql
define "Is Pregnant During Measurement Period":
  exists ( 
    ([ConditionProblemsHealthConcerns: "Pregnancy or Other Related Diagnoses"]
      union [ConditionEncounterDiagnosis: "Pregnancy or Other Related Diagnoses"] 
    ) PregnancyDiagnosis
      where PregnancyDiagnosis.prevalenceInterval() overlaps day of "Measurement Period"
  )
    or exists ( 
      [USCoreObservationPregnancyStatusProfile] PregnantObservation
        where PregnantObservation.effective.toInterval() overlaps day of "Measurement Period"
          and PregnantObservation.status in { 'final', 'amended', 'corrected' }
          and PregnantObservation.value in "Pregnancy or Other Related Diagnoses"
    )
```

### Analysis

Table 3 Differences between ConditionEncounterDiagnosis and ConditionproblemHealthConcern

| **Profile**                         | **Primary Purpose**                                                                                      | **Time Scope**     | **Typical Use**                                                                                                                                            | **Example Diagnosis**                                                                                                                                                                                                                                  | **Conceptual distinction <br>Think of it this way:**                                                                                                                                 | **Good systems**                                                                                 |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------- | ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| **ConditionEncounterDiagnosis**     | Represents a diagnosis associated with a specific encounter.                                             | Encounter-specific | billing <br>claims <br>encounter documentation                                                                                                             | Strep throat (streptococcal pharyngitis) during an office visit <br>Pneumonia diagnosed during a hospitalization <br>Acute appendicitis during an ED visit <br><br/>These may not belong on the permanent problem list since they may resolve quickly. | "What conditions mattered during THIS VISIT?" <br><br/>example: <br>Chest pain <br>Rule out MI <br>Hypertension (addressed during visit) <br><br/>These are tied to the encounter.   | distinguish<br><br>transient encounter diagnoses <br>from <br>enduring problems/health concerns. |
| **ConditionProblemsHealthConcerns** | Represents a longitudinal problem or health concern tracked over time, regardless of a single encounter. | Longitudinal       | Focused on ongoing clinical chronic disease management <br>Often persists across multiple encounters <br>Supports care coordination and continuity of care | Type 2 diabetes <br>Hypertension <br>Chronic kidney disease <br><br/>These persist across encounters and are managed over time. <br><br/>A "health concern" may not be a formal diagnosis. <br>"Risk for falls", "Medication adherence concern"        | "What ongoing issues matter for this PATIENT over time?" <br><br/>example: <br>Coronary artery disease <br>Hypertension <br><br/>These become part of the longitudinal problem list. |

