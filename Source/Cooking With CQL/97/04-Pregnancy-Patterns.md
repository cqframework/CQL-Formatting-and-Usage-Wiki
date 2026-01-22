This topic documents proposed updates to the [Observation Patterns](https://build.fhir.org/ig/HL7/us-cql-ig/patterns-observation.html) page in the US CQL IG.

#### Pregnancy Status

US Core allows for the presence of pregnancy to be represented in multiple resources. The US Core profile [Pregnancy Status](https://hl7.org/fhir/us/core/STU7/StructureDefinition-us-core-observation-pregnancystatus.html) allows for the representation of pregnancy as an Observation. However, pregnancy information may also be represented in a laboratory test result, an encounter diagnosis, or a problem list item.

To determine if an individual is pregnant, the following approach may be used to consider all three approaches: 

```cql
valueset "Pregancy Condition Codes": 'TBD'
valueset "Pregnancy Test Codes": 'TBD'

codesystem "SNOMEDCT": 'http://snomed.info/sct'

code "Pregnant": '77386006' from "SNOMEDCT" display 'Pregnant (finding)'
code "Positive": 'positive' from "Interpretation Codes"
 
define "Positive Pregnancy Observation":
  ["Observation Pregnancy Status Profile"] PregnancyStatus
    where PregnancyStatus.status = 'final'
      and PregnancyStatus.value ~ "Pregnant" 
      and PregnancyStatus.effective.toInterval() overlaps "Measurement Period"

define "Positive Pregnancy Test Result":
  ["Laboratory Result Observation": "Pregnancy Test Codes"] PregnancyTest
    where PregnancyTest.status = 'final'
      and PregnancyTest.value ~ "Positive"
      and PregnancyTest.effective.toInterval() during "Measurement Period"
      
define "Pregnancy Encounter Diagnosis":
  [ConditionEncounterDiagnosis: "Pregnancy Condition Codes"] EncounterDiagnosis
    with "Encounters" Encounter
      such that EncounterDiagnosis.encounter.references(Encounter)
      
define "Pregnancy Condition":
  [ConditionProblemsHealthConcerns: "Pregnancy Condition Codes"] Condition
    where Condition.clinicalStatus ~  "active"
      and Condition.verificationStatus ~ "confirmed"
      and Condition.prevalenceInterval() starts during "Measurement Period"

define IsPregnant:
  exists "Positive Pregnancy Observation" 
    or exists "Positive Pregnancy Test"
    or exists "Pregnancy Condition"
    or exists "Pregnancy Encounter Diagnosis"
```

Note that the examples above assume the existence of a ValueSet "Pregnancy Condition Codes" containing codes pertaining to conditions while pregnant.

In addition, the "Pregnancy Encounter Diagnosis" criteria is assuming the existence of an "Encounters" expression that constrains the encounter diagnoses to measure intent as well as the measurement period.

If a use case requires the use of prevalence period (onset and/or abatement time for a condition), it will require the use of condition profiles because onset and/or abatement times are only available in the Condition resource.

##### Pregnancy Intent

The [Pregnancy Intent](https://hl7.org/fhir/us/core/STU7/StructureDefinition-us-core-observation-pregnancyintent.html) profile sets minimum expectations for the Observation resource to record, search, and retrieve the "patient's intent to become pregnant" over the next year.

```cql
codesystem "LOINC": 'http://loinc.org'

code "Pregnancy intention in the next year - Reported": '86645-9'
code "Yes, I want to become pregnant": 'LA26438-4'

define "Positive Pregnancy Intent":
  ["Observation Pregnancy Intent Profile"] PregnancyIntent
    where PregnancyIntent.effective.toInterval() during "Measurement Period"
      and PregnancyIntent.value ~ "Yes, I want to become pregnant"
```
    
> These changes are proposed for inclusion in the US CQL IG: (https://jira.hl7.org/browse/FHIR-53462)


