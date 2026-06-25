## Negation Recommendations to Replace ObservationCancelled

This topic reviews the use of the ObservationCancelled profile in FHIR-based measures:

CMS 2, CMS 22, CMS 69, CMS 143, CMS 149 use observationCancelled

Based on discussion with The ObservationCancelled profile is not recommended for use in the current authoring patterns.

### CMS2FHIRPCSDepScreenAndFollowUp

```cql
define "Medical or Patient Reason for Not Screening Adolescent for Depression":
  [USQualityCore.ObservationCancelled: code ~ "Adolescent depression screening assessment"] NoAdolescentScreen
    with "Qualifying Encounter During Measurement Period" QualifyingEncounter
      such that NoAdolescentScreen.issued during day of QualifyingEncounter.period
    where ( 
      NoAdolescentScreen.notDoneReason ~ "Depression screening declined (situation)"
        or NoAdolescentScreen.notDoneReason in "Medical Reason"
    )
```

Suggest one (possibly all) of the following representations:

* ServiceRejected - A proposal that is specifically rejected
* ServiceProhibited - An order specifically not to perform
* ProcedureNotDone - A record that the procedure was not performed

Are there any other possibilities for how this might be represented in the record?

##### ServiceRejected

ServiceRequest with intent of proposal and an associated TaskRejected (ServiceRejected)

```cql
define "Medical or Patient Reason for Not Screening Adolescent for Depression":
  [USQualityCore.ServiceRequest: code ~ "Adolescent depression screening assessment"] NoAdolescentScreen
    with "Qualifying Encounter During Measurement Period" QualifyingEncounter
      such that NoAdolescentScreen.occurrence.toInterval() starts during day of QualifyingEncounter.period
    with ["TaskRejected": Fulfill] Rejection
      such that Rejection.focus.references(NoAdolescentScreen)
        and Rejection.statusReason in "Negation Reason Codes"
    where NoAdolescentScreen.intent = "proposal"
      and NoAdolescentScreen.status = "active"
```

##### ServiceProhibited

ServiceNotRequested with intent of order and a doNotPerform (ServiceProhibited)

```cql
define "Medical or Patient Reason for Not Screening Adolescent for Depression":
  [USQualityCore.ServiceNotRequested: code ~ "Adolescent depression screening assessment"] NoAdolescentScreen
    with "Qualifying Encounter During Measurement Period" QualifyingEncounter
      such that NoAdolescentScreen.occurrence.toInterval() starts during day of QualifyingEncounter.period
    where NoAdolescentScreen.intent = "order"
      and NoAdolescentScreen.status in { "active", "completed" }
      and NoAdolescentScreen.reasonRefused() in "Negation Reason Codes"
```

##### ProcedureNotDone

Procedure with a status of not-done

```cql
define "Medical or Patient Reason for Not Screening Adolescent for Depression":
  [USQualityCore.ProcedureNotDone: code ~ "Adolescent depression screening assessment"] NoAdolescentScreen
    with "Qualifying Encounter During Measurement Period" QualifyingEncounter
      such that NoAdolescentScreen.recorded() during day of QualifyingEncounter.period
    where NoAdolescentScreen.statusReason in "Negation Reason Codes"
```

### CMS22FHIRPCSBPScreeningFollowUp

```cql
define "Encounter with Medical Reason for Not Obtaining or Patient Declined Blood Pressure Measurement":
  "Qualifying Encounter during Measurement Period" QualifyingEncounter
    with ( [ObservationCancelled: code ~ "Blood pressure panel with all children optional"]
      union [ObservationCancelled: code ~ "Systolic blood pressure"]
      union [ObservationCancelled: code ~ "Diastolic blood pressure"] ) NoBPScreen
      such that NoBPScreen.issued during day of QualifyingEncounter.period
        and ( NoBPScreen.notDoneReason () in "Patient Declined"
            or NoBPScreen.notDoneReason () in "Medical Reason"
        )
```

Is there any reasonable expectation that this would be recorded in any of the proposed patterns?

* ServiceRejected
* ServiceProhibited
* ProcedureNotDone

### CMS69FHIRPCSBMIScreenAndFollowUp

```cql
define "Medical Reason Or Patient Reason For Not Performing BMI Exam":
  [ObservationCancelled: "Body mass index (BMI) [Ratio]"] NoBMI
    with "Qualifying Encounter During Day Of Measurement Period" QualifyingEncounter
      such that NoBMI.effective.toInterval ( ) ends same day as start of QualifyingEncounter.period
    where ( NoBMI.notDoneReason ( ) in "Patient Declined"
        or NoBMI.notDoneReason ( ) in "Medical Reason"
    )
```

Is there any reasonable expectation that this would be recorded in any of the proposed patterns?

* ServiceRejected
* ServiceProhibited
* ProcedureNotDone

### CMS143FHIRPOAGOpticNerveEval

```cql
define "Medical Reason for Not Performing Cup to Disc Ratio":
  ["ObservationCancelled": "Cup to Disc Ratio"] CupToDiscExamNotPerformed
    with "Primary Open Angle Glaucoma Encounter" EncounterWithPOAG
      such that CupToDiscExamNotPerformed.issued during day of EncounterWithPOAG.period
    where CupToDiscExamNotPerformed.notDoneReason ( ) in "Medical Reason"

define "Medical Reason for Not Performing Optic Disc Exam":
  ["ObservationCancelled": "Optic Disc Exam for Structural Abnormalities"] OpticDiscExamNotPerformed
    with "Primary Open Angle Glaucoma Encounter" EncounterWithPOAG
      such that OpticDiscExamNotPerformed.issued during day of EncounterWithPOAG.period
    where OpticDiscExamNotPerformed.notDoneReason ( ) in "Medical Reason"
```

Is there any reasonable expectation that this would be recorded in any of the proposed patterns?

* ServiceRejected
* ServiceProhibited
* ProcedureNotDone

### CMS645FHIRBoneDensityPCADTherapy

```cql
define "No Bone Density Scan Performed Due to Patient Refusal":
  [ObservationCancelled: "DEXA Bone Density for Urology Care"] DEXANotPerformed
    with "Order for 12 Months of ADT in 3 Months Before to 9 Months After Start of Measurement Period" OrderTwelveMonthsADT
      such that DEXANotPerformed.issued 3 months or less on or after day of OrderTwelveMonthsADT.authoredOn
        and DEXANotPerformed.notDoneReason ( ) in "Patient Declined"
```

Is there any reasonable expectation that this would be recorded in any of the proposed patterns?

* ServiceRejected
* ServiceProhibited
* ProcedureNotDone
