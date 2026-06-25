## Condition verificationStatus

The logic for EH measure CMS871 seeks to include encounters with an existing problem or diagnosis of Diabetes. The measure is also looking for specific verificationStatuses that are **not commonly documented/provided today**

Because the **verificationStatus is not commonly used** today, especially on Problems (it may be seen more frequently on a Diagnosis), we suggest the measure should look instead for either a clinical status of "Active", or that CMS should start to incorporate this requirement into dQMs at least 18 months prior to requiring it as part of any dQM in order to allow EHR vendors time to add this into workflows.

CMS 71, 72

```cql
TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
  with ["ConditionProblemsHealthConcerns": "History of Atrial Ablation"] AtrialAblationDiagnosis
    such that AtrialAblationDiagnosis.verificationStatus is not null implies 
      ( AtrialAblationDiagnosis.verificationStatus !~ Status."refuted" and AtrialAblationDiagnosis.verificationStatus !~ Status."entered-in-error" )
      and AtrialAblationDiagnosis.onset.toInterval ( ) starts before start of IschemicStrokeEncounter.period
```

The current pattern from UV CQL STU2:

```cql
define fluent function isVerified(condition FHIR.Condition):
  condition.verificationStatus is not null implies
    (condition.verificationStatus ~ "confirmed"
      or condition.verificationStatus ~ "unconfirmed"
      or condition.verificationStatus ~ "provisional"
      or condition.verificationStatus ~ "differential"
    )
```

Documentation of status and verification status elements from major vendors:

**Epic** <https://fhir.epic.com/Specifications?api=950>

The clinical status, which can be active, resolved, or inactive. if the encounter diagnosis is linked to a problem, it uses the clinical status of the linked problem. Only visit diagnoses can be linked to a problem

Admission and discharge diagnoses have a verificationStatus of "confirmed". Other visit diagnoses can be mapped by the organization to standard FHIR values found here. (<https://www.hl7.org/fhir/valueset-condition-ver-status.html>)

**Cerner** <https://docs.oracle.com/en/industries/health/millennium-platform-apis/mfrap/op-condition-post.html>

The clinical status of the condition.

Note:

* A clinicalStatus must always be provided while creating a condition.
* Only the active code is supported when the category is encounter-diagnosis.

The verification status to support or decline the clinical status of the condition or diagnosis.

Note: verificationStatus codes **of entered-in-error and refuted are not supported** when creating a condition.

### Analysis

The feedback that verification status is not commonly used is consistent with our understanding, and is the reason that we developed the patterns as they are. The logic that tests verificationStatus only applies if the verificationStatus is present. If no verificationStatus is present, the assumption is that the record is verified.