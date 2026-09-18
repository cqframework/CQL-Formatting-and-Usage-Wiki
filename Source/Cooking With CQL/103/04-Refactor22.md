# Refactoring CMS22

This topic discusses refactoring CMS22 - Blood Pressure Screening with Followup
to use US Quality Core from the QI Core version.

The process follows the US Quality Core Update Process documented in the CMS 
Quality Measure Development guidance, but focuses on the final steps of
refactoring to make use of common functions and elements available within the
Using FHIR With CQL, CQL US Common, and US Quality Core implementation guides.

The discussion begins with a version of CMS22 that has already been refactored 
through steps 1 to 4 of the US Quality Core Update process.

> NOTE: These are all proposed updates, identified to help improve the readability,
maintainability, and implementability of the measure specification. Any accepted 
changes will be applied by the appropriate measure developer.

## Consider .systolic() and .diastolic() functions

The logic contains this fragment, about 20 times:

```cql
(singleton from (EncounterLastBP.component C
    where C.code ~ "Systolic blood pressure"
)).value
```

Given that this is accessing elements within a single observation, it is a
prime candidate for a fluent function:

```cql
define fluent function systolic(bloodPressure FHIR.Observation):
  singleton from (bloodPressure.component C where C.code ~ "Systolic Blood Pressure")
```

Whenever defining a fluent function, make sure there is not an existing function
that could be used. In this case, there is, the `systolic()` and `diastolic()` functions
already exist in the `USCoreCommon` library.

## Consider extracting repeated Last(...) blood pressure

The following fragment is repeated as a let definition six times: five are verbatim, 
one with an additional year window:

```cql
    let EncounterLastBP: Last([USCore.BloodPressureProfile] BloodPressure
        where BloodPressure.effective.toInterval() ends during day of QualifyingEncounter.period
          and BloodPressure.status in { 'final', 'amended', 'corrected' }
        sort by start of effective.toInterval()
```

Defining this let as a fluent function within the inferences layer allows this definition to be reused:

```cql
define fluent function lastBloodPressureDuring(encounter Encounter):
  Last([USCore.BloodPressureProfile].isObservationBP() BloodPressure
    where BloodPressure.effective.toInterval() ends during day of encounter.period
    sort by start of effective.toInterval()
  )
```

## Consider naming the blood pressure categories

```cql
define "Encounter with Normal Blood Pressure Reading":
  "Qualifying Encounter during Measurement Period" QualifyingEncounter
    let EncounterLastBP: Last([USCore.BloodPressureProfile] BloodPressure
        where BloodPressure.effective.toInterval() ends during day of QualifyingEncounter.period
          and BloodPressure.status in { 'final', 'amended', 'corrected' }
        sort by start of effective.toInterval()
    )
    where ( singleton from ( EncounterLastBP.component C
          where C.code ~ "Systolic blood pressure"
      )
    ).value in Interval[1 'mm[Hg]', 120 'mm[Hg]' )
      and ( singleton from ( EncounterLastBP.component C
            where C.code ~ "Diastolic blood pressure"
        )
      ).value in Interval[1 'mm[Hg]', 80 'mm[Hg]' )
```

Accepting the previous two suggestions results in:

```cql
define "Encounter with Normal Blood Pressure Reading":
  "Qualifying Encounter during Measurement Period" QualifyingEncounter
    let EncounterLasBP: lastBloodPressureDuring(QualityingEncounter)
  where EncounterLastBP.systolic().value in Interval[1 'mm[Hg], 120 'mm[Hg]')
    and EncounterLastBP.diastolic().value in Interval[1 'mm[Hg], 80 'mm[Hg]')
```

However, the classification predicates can be refactored as well:

```cql
define fluent function hasReading(bp Observation):
  bp.systolic() > 0 'mm[Hg]' and bp.diastolic().value > 0 'mm[Hg]'

define fluent function isNormal(bp Observation):
  bp.systolic().value in Interval[1 'mm[Hg]', 120 'mm[Hg]')
    and bp.diastolic().value in Interval[1 'mm[Hg]', 80 'mm[Hg]')

define fluent function isStage2(bp Observation):
  bp.systolic().value >= 140 'mm[Hg]' or bp.diastolic().value >= 90 'mm[Hg]'

define fluent function isHypertensive(bp Observation):
  bp.systolic().value >= 130 'mm[Hg]' or bp.diastolic().value >= 80 'mm[Hg]'
```

And the resulting define becomes:

```cql
define "Encounter with Normal Blood Pressure Reading":
  "Qualifying Encounter during Measurement Period" QualifyingEncounter
    let EncounterLasBP: lastBloodPressureDuring(QualityingEncounter)
  where EncounterLastBP.isNormal()
```

As another example, the following expression in the current measure:

```cql
define "Encounter with Second Hypertensive Reading SBP Greater than or Equal to 140 OR DBP Greater than or Equal to 90":
  (( "Qualifying Encounter during Measurement Period" QualifyingEncounter
        let EncounterLastBP: Last([USCore.BloodPressureProfile] BloodPressure
            where BloodPressure.effective.toInterval() ends during day of QualifyingEncounter.period
              and BloodPressure.status in { 'final', 'amended', 'corrected' }
            sort by start of effective.toInterval()
        )
        where (( singleton from ( EncounterLastBP.component C
                where C.code ~ "Systolic blood pressure"
            )
          ).value > 0 'mm[Hg]'
            and ( singleton from ( EncounterLastBP.component C
                  where C.code ~ "Diastolic blood pressure"
              )
            ).value > 0 'mm[Hg]'
            and (( singleton from ( EncounterLastBP.component C
                    where C.code ~ "Systolic blood pressure"
                )
              ).value >= 140 'mm[Hg]'
                or ( singleton from ( EncounterLastBP.component C
                      where C.code ~ "Diastolic blood pressure"
                  )
                ).value >= 90 'mm[Hg]'
            )
        )
    )
      intersect "Encounter with Hypertensive Reading Within Year Prior"
  )
```

Becomes:

```cql
define "Encounter with Stage 2 Second Reading":
  ( "Qualifying Encounter during Measurement Period" QualifyingEncounter
      let EncounterLastBP: QualifyingEncounter.lastBloodPressureDuring()
      where EncounterLastBP.isStage2()
  )
    intersect "Encounter with Hypertensive Reading Within Year Prior"
```

Applied across all six blood pressure reading definitions, that section goes from ~150 lines to ~35, and the differences between the categories — which is what a reviewer is actually trying to see — become visible at a glance instead of buried in identical boilerplate.

## Consider status and intent functions

The following filters appear repeatedly throughout the logic:

| Filter | Appears |
|----|----|
| `intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }` | 6 times |
| `status in { 'active', 'completed', 'on-hold' }` | 6 times |
| `reasonCode in "Patient Declined"` | 6 times |

For the intent list, the `Status` library has `isInterventionOrder()` / `isLaboratoryTestOrder()` / `isDagnosticStudyOrder()`. Note that these functions also add `status in { 'active', 'completed' }`, so adopting these would be a semantic change and needs validation. They are the QDM-aligned pattern used elsewhere in CMS content, but if they do not align, define a local `isOrder()` with the exact semantics needed for the measure.

For the `reasonCode in "Patient Declined"` filter, consider a `declinedByPatient()` fluent function:

```cql
/*
A negated request the patient refused. The reason is read from the
doNotPerformReason extension via USQualityCoreCommon.reasonRefused() - on a
negation profile reasonCode would carry why the request would have been
placed, not why it was not.
*/
define fluent function declinedByPatient(Requests List<ServiceNotRequested>):
  Requests R
    where R.status in { 'active', 'completed', 'on-hold' }
      and R.reasonRefused() in Concepts."Patient Declined"
```

## Move single-source filters out of such that

Some of the expressions use single-source conditions inside the relationship clause:

```cql
[ServiceRequest: "Follow Up Within 4 Weeks"] FourWeekRescreen
  with "NonPharmacological Interventions" NonPharmInterventionsHTN
    such that FourWeekRescreen.authoredOn during day of "Measurement Period"
      and NonPharmInterventionsHTN.authoredOn during day of "Measurement Period"
      and FourWeekRescreen.intent in { ... }
```

None of the conditions in the such that are actually about the relationship (i.e. they only refer to one side or the other of the relationship, they do not establish a filter that requires data from both sides). This is an anti-pattern generally, since it is a potentially confusing use of the relationship.

Consider moving the conditions into inferences, built from elements:

```cql
// @element
define "Follow Up Service Request Within 4 Weeks":
  [ServiceRequest: "Follow Up Within 4 Weeks"] FourWeekRescreen
    where FourWeekRescreen.intent in { ... }

// @inference
define "Follow Up Service Request Within 4 Weeks During Measurement Period":
  "Follow Up Service Request Within 4 Weeks" FoorWeekRescreen
    where FourWeekRescreen.authoredOn during day of "Measurement Period"

// @inference
define "NonPharmacological Interventions During Measurement Period":
  "NonPharmacological Interventions" NonPharmInterventionsHTN
    where NonPharmInterventionsHTN.authoredOn during day of "Measurement Period"

// @inference
define "First Hypertensive Reading Interventions or Referral to Alternate Professional":
  (
    "Follow Up Service Request Within 4 Weeks" FourWeekRescreen
      where exists ("NonPharmacological Interventions During Measurement Period")
  )
    union "Referral to Alternate or Primary Healthcare Professional for Hypertensive Reading"
```
  
## Consider similar element refactoring

Along similar lines, many of the expression declarations within the measure logic can be refactored, using the following guidelines:

1. If it contains a retrieve, the retrieve should be in an _Element_ declaration
2. If it contains a status, intent, or similar, resource-specific, validity check, it should be included in the element declaration
3. If it contains clinical classification logic, or references context such as the measurement period, it should be in an _Inference_ declaration

Working through a similar example:

```cql
define "Second Hypertensive Reading SBP Greater than or Equal to 140 OR DBP Greater than or Equal to 90 Interventions":
  ([ServiceRequest: "Follow Up Within 4 Weeks"] WeeksRescreen
      with "Laboratory Test or ECG for Hypertension" ECGLabTest
        such that WeeksRescreen.authoredOn during day of "Measurement Period"
          and ECGLabTest.authoredOn during day of "Measurement Period"
          and WeeksRescreen.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }
          and ECGLabTest.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }
      with "NonPharmacological Interventions" HTNInterventions
        such that HTNInterventions.authoredOn during day of "Measurement Period"
      with ["MedicationRequest": "Pharmacologic Therapy for Hypertension"] Medications
        such that Medications.authoredOn during day of "Measurement Period"
          and Medications.status in { 'active', 'completed' }
  )
```

The Follow Up Within 4 Weeks is actually the same data element and inference from the above example "Follo Up Service Request Within 4 Weeks".

The Laboratory Test or ECG for Hypertension should be a separate inference:

```cql
define "Laboratory Test or ECG for Hypertension During Measurement Period":
  "Laboratory Test or ECG for Hypertension" ECGLabTestOrder
    where ECGLabTestOrder.authoredOn during day of "Measurement Period"
```

> NOTE: With this rewrite it is clear that the `ECGLabTest.intent in { ... }` filter in this is a repeat of the same test in the `"Laboratory Test or ECG for Hypertension"` data element.

The NonPharmacological Interventions is another inference from the above example.

And Pharmacologic Therapy should be a separate data element and inference:

```cql
// @element
define "Pharmacologic Therapy for Hypertension":
  ["MedicationRequest": "Pharmacologic Therapy for Hypertension"] HTNMedications
    where HTNMedications.isActive()
      and HTNMedications.isOrder()

// @inference
define "Pharmacologic Therapy for Hypertension During Measurement Period":
  "Pharmacologic Therapy for Hypertension" HTNMedications
    where HTNMedications.authoredOn during day of "Measurement Period"
```

Applying all these suggestions, the expression now becomes:

```cql
define "Second Reading Stage 2 Interventions":
  "Follow Up Service Request Within 4 Weeks" FourWeekRescreen
    where exists "Laboratory Test or ECG for Hypertension During Measurement Period"
      and exists "NonPharmacological Interventions During Measurement Period"
      and exists "Pharmacologic Therapy for Hypertension During Measurement Period"
```

This expression is more concise, but it also makes clear that the conditions are additive here, something that is also true of the original "with" representation, but may not be as clear in that form.

> NOTE: Is the intent for all of these interventions to be present? Or is measure intent that any of them would satisfy the intent? If it's the latter, these should be combined with `or` rather than `and`, and should prompt review of the other parts of the measure that use multiple `with` clauses to ensure the same pattern does not appear elsewhere.

## The Result

Applying all these suggestions across the measure, results in the following:

### Concepts Layer

```cql
codesystem "ActCode": 'http://terminology.hl7.org/CodeSystem/v3-ActCode'
codesystem "LOINC": 'http://loinc.org'

valueset "Diagnosis of Hypertension": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.263'
valueset "Dietary Recommendations": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1515'
valueset "Encounter to Screen for Blood Pressure": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1920'
valueset "Finding of Elevated Blood Pressure or Hypertension": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1047.514'
valueset "Follow Up Within 4 Weeks": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1578'
valueset "Follow Up Within 6 Months": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1108.125'
valueset "Laboratory Tests for Hypertension": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1482'
valueset "Lifestyle Recommendation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1581'
valueset "Medical Reason": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1007'
valueset "Patient Declined": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1582'
valueset "Pharmacologic Therapy for Hypertension": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.1577'
valueset "Recommendation to Increase Physical Activity": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1518'
valueset "Referral or Counseling for Alcohol Consumption": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1583'
valueset "Referral to Primary Care or Alternate Provider": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1580'
valueset "Weight Reduction Recommended": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1510'

code "Blood pressure panel with all children optional": '85354-9' from "LOINC" display 'Blood pressure panel with all children optional'
code "Diastolic blood pressure": '8462-4' from "LOINC" display 'Diastolic blood pressure'
code "12 lead EKG panel": '34534-8' from "LOINC" display 'EKG 12 channel panel'
code "EKG study": '11524-6' from "LOINC" display 'EKG study'
code "Systolic blood pressure": '8480-6' from "LOINC" display 'Systolic blood pressure'
code "virtual": 'VR' from "ActCode" display 'virtual'

context Patient

/*
The order intent set. Constrains intent only, matching the criteria the
current CMS22 library uses.

NOTE: Status.isInterventionOrder() / isLaboratoryTestOrder() apply the same
intent constraint and additionally require status in { 'active', 'completed' }.
Adopting those would align with the rest of the CMS content but changes which
requests qualify, so that decision is deliberately left open here.
*/
define fluent function isOrder(Requests List<FHIR.ServiceRequest>):
  Requests R
    where R.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }

/*
A negated request the patient refused. The reason is read from the
doNotPerformReason extension via USQualityCoreCommon.reasonRefused() - on a
negation profile reasonCode would carry why the request would have been
placed, not why it was not.
*/
define fluent function declinedByPatient(Requests List<ServiceNotRequested>):
  Requests R
    where R.status in { 'active', 'completed', 'on-hold' }
      and R.reasonRefused() in Concepts."Patient Declined"
```

### Elements Layer

#### Encounters

```cql
/*
In person encounters at which blood pressure screening is expected. Virtual
encounters are excluded on Encounter.class, which is where the modality
actually lives - matching on the primary code path would test Encounter.type
and silently never fire.
*/
define "Blood Pressure Screening Encounters":
  [Encounter: Concepts."Encounter to Screen for Blood Pressure"] ScreeningEncounter
    where ScreeningEncounter.status ~ 'finished'
      and ScreeningEncounter.class !~ Concepts."virtual"
```

#### Blood Pressure Readings:

```cql
// Resulted blood pressure panels. Component access and ordering are handled
// in CMS22Inferences via USCoreCommon.
define "Blood Pressure Readings":
  ([USCore.BloodPressureProfile]).isObservationBP()

// Blood pressure measurements that were not carried out. The reason is read
// in CMS22Inferences via the notDoneReason extension accessor.
define "Blood Pressure Measurements Not Done":
  [ObservationCancelled: code ~ Concepts."Blood pressure panel with all children optional"]
    union [ObservationCancelled: code ~ Concepts."Systolic blood pressure"]
    union [ObservationCancelled: code ~ Concepts."Diastolic blood pressure"]
```

#### Conditions:

```cql
define "Hypertension Diagnoses":
  [ConditionProblemsHealthConcerns: Concepts."Diagnosis of Hypertension"] Hypertension
    where Hypertension.isVerified()
```

#### Follow Up Orders:

```cql
define "Six Month Rescreen Orders":
  [ServiceRequest: Concepts."Follow Up Within 6 Months"] Rescreen
    where Rescreen.intent ~ 'order'

define "Four Week Rescreen Orders":
  ([ServiceRequest: Concepts."Follow Up Within 4 Weeks"]).isOrder()

define "Lifestyle Counseling Orders":
  ([ServiceRequest: Concepts."Lifestyle Recommendation"]
    union [ServiceRequest: Concepts."Weight Reduction Recommended"]
    union [ServiceRequest: Concepts."Dietary Recommendations"]
    union [ServiceRequest: Concepts."Recommendation to Increase Physical Activity"]
    union [ServiceRequest: Concepts."Referral or Counseling for Alcohol Consumption"]).isOrder()

define "Hypertension Workup Orders":
  ([ServiceRequest: Concepts."12 lead EKG panel"]
    union [ServiceRequest: Concepts."EKG study"]
    union [ServiceRequest: Concepts."Laboratory Tests for Hypertension"]).isOrder()

define "Antihypertensive Medication Orders":
  [MedicationRequest: Concepts."Pharmacologic Therapy for Hypertension"] Medication
    where Medication.status in { 'active', 'completed' }

// A referral only counts as hypertension follow up when it was placed for a
// hypertensive finding.
define "Hypertension Referrals":
  (([ServiceRequest: Concepts."Referral to Primary Care or Alternate Provider"]).isOrder()) Referral
    where Referral.reasonCode in Concepts."Finding of Elevated Blood Pressure or Hypertension"
```

#### Follow Up Declined by the Patient:

```cql
define "Declined Six Month Rescreens":
  ([ServiceNotRequested: Concepts."Follow Up Within 6 Months"]).declinedByPatient()

define "Declined Four Week Rescreens":
  ([ServiceNotRequested: Concepts."Follow Up Within 4 Weeks"]).declinedByPatient()

define "Declined Primary Care Referrals":
  ([ServiceNotRequested: Concepts."Referral to Primary Care or Alternate Provider"]).declinedByPatient()

define "Declined Lifestyle Counseling":
  ([ServiceNotRequested: Concepts."Lifestyle Recommendation"]
    union [ServiceNotRequested: Concepts."Weight Reduction Recommended"]
    union [ServiceNotRequested: Concepts."Dietary Recommendations"]
    union [ServiceNotRequested: Concepts."Recommendation to Increase Physical Activity"]
    union [ServiceNotRequested: Concepts."Referral or Counseling for Alcohol Consumption"]).declinedByPatient()

define "Declined Hypertension Workup":
  ([ServiceNotRequested: code ~ Concepts."12 lead EKG panel"]
    union [ServiceNotRequested: code ~ Concepts."EKG study"]
    union [ServiceNotRequested: Concepts."Laboratory Tests for Hypertension"]).declinedByPatient()

define "Declined Antihypertensive Medications":
  [MedicationNotRequested: Concepts."Pharmacologic Therapy for Hypertension"] Medication
    where Medication.status in { 'active', 'completed' }
```

### Inferences Layer

#### Qualifying Encounters:

```cql
define "Qualifying Encounter":
  Elements."Blood Pressure Screening Encounters" ScreeningEncounter
    where ScreeningEncounter.period ends during day of "Measurement Period"

define "Qualifying Encounter for Adult":
  "Qualifying Encounter" QualifyingEncounter
    where AgeInYearsAt(date from start of "Measurement Period") >= 18

define "Encounter for Patient with Hypertension":
  "Qualifying Encounter" QualifyingEncounter
    with Elements."Hypertension Diagnoses" Hypertension
      such that Hypertension.prevalenceInterval() starts before or on day of QualifyingEncounter.period
```

#### Blood Pressure At the Encounter:

```cql
// --------------------------------------------------------------------
// Each definition classifies the LAST reading taken on the day of the
// encounter. Thresholds are named in the classification functions at the
// bottom of this library rather than repeated here.
// --------------------------------------------------------------------

define "Encounter with Normal Reading":
  "Qualifying Encounter" QualifyingEncounter
    let EncounterLastBP: QualifyingEncounter.lastBloodPressureDuring()
    where EncounterLastBP.isNormalReading()

define "Encounter with Elevated Reading":
  "Qualifying Encounter" QualifyingEncounter
    let EncounterLastBP: QualifyingEncounter.lastBloodPressureDuring()
    where EncounterLastBP.isElevatedReading()

define "Encounter with Hypertensive Reading":
  "Qualifying Encounter" QualifyingEncounter
    let EncounterLastBP: QualifyingEncounter.lastBloodPressureDuring()
    where EncounterLastBP.hasReading()
      and EncounterLastBP.isHypertensiveReading()

/*
The same hypertensive classification applied to the last reading in the year
leading up to the encounter. This is what makes a reading at the encounter a
"second" reading rather than a first.
*/
define "Encounter with Prior Year Hypertensive Reading":
  "Qualifying Encounter" QualifyingEncounter
    let PriorBP: QualifyingEncounter.lastBloodPressureWithinYearBefore()
    where PriorBP.hasReading()
      and PriorBP.isHypertensiveReading()

define "Encounter with First Hypertensive Reading":
  "Encounter with Hypertensive Reading"
    except "Encounter with Prior Year Hypertensive Reading"

define "Encounter with Stage 1 Second Reading":
  ( "Qualifying Encounter" QualifyingEncounter
      let EncounterLastBP: QualifyingEncounter.lastBloodPressureDuring()
      where EncounterLastBP.isStage1Reading()
        and not EncounterLastBP.isStage2Reading()
  )
    intersect "Encounter with Prior Year Hypertensive Reading"

define "Encounter with Stage 2 Second Reading":
  ( "Qualifying Encounter" QualifyingEncounter
      let EncounterLastBP: QualifyingEncounter.lastBloodPressureDuring()
      where EncounterLastBP.hasReading()
        and EncounterLastBP.isStage2Reading()
  )
    intersect "Encounter with Prior Year Hypertensive Reading"
```

#### Follow Up Delivered:

```cql
// --------------------------------------------------------------------
// Each reading category has its own required follow up, and in every case a
// referral to primary care for the hypertensive finding is an accepted
// alternative to the whole bundle. All orders must fall on the day of the
// encounter they are follow up for.
// --------------------------------------------------------------------

// Six month rescreen and lifestyle counseling, or a referral.
define "Encounter with Elevated Reading and Follow Up":
  ( "Encounter with Elevated Reading" ElevatedEncounter
      with Elements."Six Month Rescreen Orders" Rescreen
        such that Rescreen.authoredOn during day of ElevatedEncounter.period
      with Elements."Lifestyle Counseling Orders" Counseling
        such that Counseling.authoredOn during day of ElevatedEncounter.period
  )
    union ( "Encounter with Elevated Reading" ElevatedEncounter
        with Elements."Hypertension Referrals" Referral
          such that Referral.authoredOn during day of ElevatedEncounter.period
    )

// Four week rescreen and lifestyle counseling, or a referral.
define "Encounter with First Hypertensive Reading and Follow Up":
  ( "Encounter with First Hypertensive Reading" FirstHTNEncounter
      with Elements."Four Week Rescreen Orders" Rescreen
        such that Rescreen.authoredOn during day of FirstHTNEncounter.period
      with Elements."Lifestyle Counseling Orders" Counseling
        such that Counseling.authoredOn during day of FirstHTNEncounter.period
  )
    union ( "Encounter with First Hypertensive Reading" FirstHTNEncounter
        with Elements."Hypertension Referrals" Referral
          such that Referral.authoredOn during day of FirstHTNEncounter.period
    )

// Six month rescreen, workup and lifestyle counseling, or a referral.
define "Encounter with Stage 1 Second Reading and Follow Up":
  ( "Encounter with Stage 1 Second Reading" Stage1Encounter
      with Elements."Six Month Rescreen Orders" Rescreen
        such that Rescreen.authoredOn during day of Stage1Encounter.period
      with Elements."Hypertension Workup Orders" Workup
        such that Workup.authoredOn during day of Stage1Encounter.period
      with Elements."Lifestyle Counseling Orders" Counseling
        such that Counseling.authoredOn during day of Stage1Encounter.period
  )
    union ( "Encounter with Stage 1 Second Reading" Stage1Encounter
        with Elements."Hypertension Referrals" Referral
          such that Referral.authoredOn during day of Stage1Encounter.period
    )

// Four week rescreen, workup, lifestyle counseling and medication, or a referral.
define "Encounter with Stage 2 Second Reading and Follow Up":
  ( "Encounter with Stage 2 Second Reading" Stage2Encounter
      with Elements."Four Week Rescreen Orders" Rescreen
        such that Rescreen.authoredOn during day of Stage2Encounter.period
      with Elements."Hypertension Workup Orders" Workup
        such that Workup.authoredOn during day of Stage2Encounter.period
      with Elements."Lifestyle Counseling Orders" Counseling
        such that Counseling.authoredOn during day of Stage2Encounter.period
      with Elements."Antihypertensive Medication Orders" Medication
        such that Medication.authoredOn during day of Stage2Encounter.period
  )
    union ( "Encounter with Stage 2 Second Reading" Stage2Encounter
        with Elements."Hypertension Referrals" Referral
          such that Referral.authoredOn during day of Stage2Encounter.period
    )
```

#### Follow Up Declined and Screening Not Performed

```cql
// --------------------------------------------------------------------
// For each reading category, ANY one of that category's follow up components
// being declined on the day of the encounter excepts the encounter.
// --------------------------------------------------------------------

define "Encounter with Blood Pressure Not Measured for Reason":
  "Qualifying Encounter" QualifyingEncounter
    with Elements."Blood Pressure Measurements Not Done" NotDone
      such that NotDone.issued during day of QualifyingEncounter.period
        and ( NotDone.notDoneReason() in Concepts."Patient Declined"
            or NotDone.notDoneReason() in Concepts."Medical Reason"
        )

define "Encounter with Elevated Reading Follow Up Declined":
  "Encounter with Elevated Reading" ElevatedEncounter
    with ( Elements."Declined Six Month Rescreens"
      union Elements."Declined Primary Care Referrals"
      union Elements."Declined Lifestyle Counseling" ) Declined
      such that Declined.authoredOn during day of ElevatedEncounter.period

define "Encounter with First Hypertensive Reading Follow Up Declined":
  "Encounter with First Hypertensive Reading" FirstHTNEncounter
    with ( Elements."Declined Four Week Rescreens"
      union Elements."Declined Primary Care Referrals"
      union Elements."Declined Lifestyle Counseling" ) Declined
      such that Declined.authoredOn during day of FirstHTNEncounter.period

define "Encounter with Stage 1 Second Reading Follow Up Declined":
  "Encounter with Stage 1 Second Reading" Stage1Encounter
    with ( Elements."Declined Six Month Rescreens"
      union Elements."Declined Primary Care Referrals"
      union Elements."Declined Hypertension Workup"
      union Elements."Declined Lifestyle Counseling" ) Declined
      such that Declined.authoredOn during day of Stage1Encounter.period

/*
Declined medications are carried on MedicationNotRequested rather than
ServiceNotRequested, so they cannot join the union above and are unioned as a
separate encounter branch.
*/
define "Encounter with Stage 2 Second Reading Follow Up Declined":
  ( "Encounter with Stage 2 Second Reading" Stage2Encounter
      with ( Elements."Declined Four Week Rescreens"
        union Elements."Declined Primary Care Referrals"
        union Elements."Declined Hypertension Workup"
        union Elements."Declined Lifestyle Counseling" ) Declined
        such that Declined.authoredOn during day of Stage2Encounter.period
  )
    union ( "Encounter with Stage 2 Second Reading" Stage2Encounter
        with Elements."Declined Antihypertensive Medications" DeclinedMedication
          such that DeclinedMedication.authoredOn during day of Stage2Encounter.period
    )

define "Encounter with Follow Up Declined":
  "Encounter with Elevated Reading Follow Up Declined"
    union "Encounter with First Hypertensive Reading Follow Up Declined"
    union "Encounter with Stage 1 Second Reading Follow Up Declined"
    union "Encounter with Stage 2 Second Reading Follow Up Declined"
```

#### Blood Pressure Retrieval

```cql
// --------------------------------------------------------------------
// The measure always evaluates the most recent qualifying reading, either on
// the day of the encounter or in the year leading up to it. Ordering is
// delegated to USCoreCommon.chronologically(), which sorts by start of
// effective.toInterval().
//
// NOTE: do not substitute FHIRCommon.mostRecent() here - its Observation
// overload sorts by issued.value (when the result was released) rather than
// by effective (when the reading was taken).
// --------------------------------------------------------------------

define fluent function lastBloodPressureDuring(TheEncounter Encounter):
  Last(
    ( Elements."Blood Pressure Readings" BloodPressure
        where BloodPressure.effective.toInterval() ends during day of TheEncounter.period
    ).chronologically()
  )

define fluent function lastBloodPressureWithinYearBefore(TheEncounter Encounter):
  Last(
    ( Elements."Blood Pressure Readings" BloodPressure
        where BloodPressure.effective.toInterval() ends 1 year or less before or on start of TheEncounter.period
    ).chronologically()
  )
```

#### Blood Pressure Classification

```cql
// --------------------------------------------------------------------
// hasReading() is applied separately rather than folded in, because the
// criteria differ in whether they need it: normal, elevated and stage 1 are
// bounded below by their own ranges, while hypertensive and stage 2 are
// open ended above.
// --------------------------------------------------------------------

define fluent function hasReading(BloodPressure FHIR.Observation):
  BloodPressure.systolic().value > 0 'mm[Hg]'
    and BloodPressure.diastolic().value > 0 'mm[Hg]'

// SBP 1 to 119 AND DBP 1 to 79
define fluent function isNormalReading(BloodPressure FHIR.Observation):
  BloodPressure.systolic().value in Interval[1 'mm[Hg]', 120 'mm[Hg]' )
    and BloodPressure.diastolic().value in Interval[1 'mm[Hg]', 80 'mm[Hg]' )

// SBP 120 to 129 AND DBP 1 to 79
define fluent function isElevatedReading(BloodPressure FHIR.Observation):
  BloodPressure.systolic().value in Interval[120 'mm[Hg]', 129 'mm[Hg]']
    and BloodPressure.diastolic().value in Interval[1 'mm[Hg]', 80 'mm[Hg]' )

// SBP >= 130 OR DBP >= 80
define fluent function isHypertensiveReading(BloodPressure FHIR.Observation):
  BloodPressure.systolic().value >= 130 'mm[Hg]'
    or BloodPressure.diastolic().value >= 80 'mm[Hg]'

// SBP 130 to 139 OR DBP 80 to 89
define fluent function isStage1Reading(BloodPressure FHIR.Observation):
  BloodPressure.systolic().value in Interval[130 'mm[Hg]', 139 'mm[Hg]']
    or BloodPressure.diastolic().value in Interval[80 'mm[Hg]', 89 'mm[Hg]']

// SBP >= 140 OR DBP >= 90
define fluent function isStage2Reading(BloodPressure FHIR.Observation):
  BloodPressure.systolic().value >= 140 'mm[Hg]'
    or BloodPressure.diastolic().value >= 90 'mm[Hg]'
```

### Measure Layer

```cql
define "Initial Population":
  Inferences."Qualifying Encounter for Adult"

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  Inferences."Encounter for Patient with Hypertension"

define "Numerator":
  Inferences."Encounter with Normal Reading"
    union Inferences."Encounter with Elevated Reading and Follow Up"
    union Inferences."Encounter with First Hypertensive Reading and Follow Up"
    union Inferences."Encounter with Stage 1 Second Reading and Follow Up"
    union Inferences."Encounter with Stage 2 Second Reading and Follow Up"

define "Denominator Exceptions":
  Inferences."Encounter with Blood Pressure Not Measured for Reason"
    union Inferences."Encounter with Follow Up Declined"

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"
```



