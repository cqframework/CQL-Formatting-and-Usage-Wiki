library QICoreCommonTests

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

include QICoreCommon called Common

codesystem "Marital Status Codes": 'http://terminology.hl7.org/CodeSystem/v3-MaritalStatus'
codesystem "CDC Race and Ethnicity Codes": 'urn:oid:2.16.840.1.113883.6.238'

valueset "Marital Status": 'http://hl7.org/fhir/ValueSet/marital-status'

code "Marital Status - Married": 'M' from "Marital Status Codes"
code "American Indian or Alaska Native": '1002-5' from "CDC Race and Ethnicity Codes"
code "Alaska Native": '1735-0' from "CDC Race and Ethnicity Codes"
code "Blood pressure": '85354-9' from Common."LOINC" display 'Blood pressure panel with all children optional'
code "Diastolic blood pressure": '8462-4' from Common."LOINC" display 'Diastolic blood pressure'
code "Systolic blood pressure": '8480-6' from Common."LOINC" display 'Systolic blood pressure'

context Patient

// QICoreAdverseEvent
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-adverseevent
define AdverseEvent:
  [AdverseEvent]

// QICoreAllergyIntolerance
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-allergyintolerance
define AllergyIntolerance:
  [AllergyIntolerance]

// QICoreBodyStructure
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-bodystructure
define BodyStructure:
  [BodyStructure]

// QICoreCarePlan
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-careplan
define CarePlan:
  [CarePlan]

// QICoreCareTeam
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-careteam
define CareTeam:
  [CareTeam]

// QICoreClaim
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-claim
define Claim:
  [Claim]

// QICoreCommunication
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-communication
define Communication:
  [Communication] C
    where C.status in { 'preparation', 'in-progress', 'on-hold', 'completed' }

// QICoreCommunicationNotDone
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-communicationnotdone
define CommunicationNotDone:
  [Communication] C
    where C.status = 'not-done'

// QICoreCommunicationRequest
// @profile: 	http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-communicationrequest
define CommunicationRequest:
  [CommunicationRequest]

// QICoreCondition
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-condition
define Condition:
  [Condition]

// QICoreCoverage
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-coverage
define Coverage:
  [Coverage]

// QICoreDevice
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-device
define Device:
  [Device]

// QICoreDeviceNotRequested
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-devicenotrequested
define DeviceNotRequested:
  [DeviceRequest] D
    where D.status = 'completed'
      and D.doNotPerform() is true

// QICoreDeviceRequest
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-devicerequest
define DeviceRequest:
  [DeviceRequest] D
    where D.status in { 'draft', 'active', 'on-hold', 'revoked', 'completed' }
      and D.doNotPerform() is not true

// QICoreDeviceUseStatement
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-deviceusestatement
define DeviceUseStatement:
  [DeviceUseStatement]

// QICoreDiagnosticReportLab
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-diagnosticreport-lab
define DiagnosticReportLab:
  [DiagnosticReport] D
    //where D.category ~ "http://terminology.hl7.org/CodeSystem/v2-0074#LAB"

// QICoreDiagnosticReportNote
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-diagnosticreport-note
define DiagnosticReportNote:
  [DiagnosticReport] D

// QICoreEncounter
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter
define Encounter:
  [Encounter]

define EncounterPerformed:
  Encounter E
    where E.status = 'finished'

// QICoreFamilyMemberHistory
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-familymemberhistory
define FamilyMemberHistory:
  [FamilyMemberHistory]

// QICoreFlag
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-flag
define Flag:
  [Flag]

// QICoreGoal
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-goal
define Goal:
  [Goal]

// QICoreImagingStudy
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-imagingstudy
define ImagingStudy:
  [ImagingStudy]

// QICoreImmunization
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-immunization
define Immunization:
  [Immunization] I
    where I.status = 'completed'

// QICoreImmunizationEvaluation
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-immunizationevaluation
define ImmunizationEvaluation:
  [ImmunizationEvaluation]

// QICoreImmunizationNotDone
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-immunizationnotdone
define ImmunizationNotDone:
  [Immunization] I
    where I.status = 'not-done'

// QICoreImmunizationRecommendation
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-immunizationrec
define ImmunizationRecommendation:
  [ImmunizationRecommendation]

// USCoreImplantableDevice
// @profile: http://hl7.org/fhir/us/core/StructureDefinition/us-core-implantable-device
define ImplantableDevice:
  [Device]

// QICoreLocation
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-location
define Location:
  [Location]

// QICoreMedication
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-medication
define Medication:
  [Medication]

// QICoreMedicationAdministration
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-medicationadministration
define MedicationAdministration:
  [MedicationAdministration] M
    where M.status in { 'in-progress', 'on-hold', 'completed' }

// QICoreMedicationAdministrationNotDone
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-mednotadministered
define MedicationAdministrationNotDone:
  [MedicationAdministration] M
    where M.status = 'not-done'

// QICoreMedicationDispense
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-medicationdispense
define MedicationDispense:
  [MedicationDispense] D
    where D.status in { 'preparation', 'in-progress', 'on-hold', 'completed' }

// QICoreMedicationDispenseDeclined
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-medicationdispensedeclined
define MedicationDispenseDeclined:
  [MedicationDispense] D
    where D.status in { 'cancelled', 'declined' }

// QICoreMedicationNotRequested
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-mednotrequested
define MedicationNotRequested:
  [MedicationRequest] R
    where R.status = 'completed'
      and R.doNotPerform is true

/*
define "Antithrombotic Not Given at Discharge":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] NoAntithromboticDischarge
    where NoAntithromboticDischarge.doNotPerform is true
			and (NoAntithromboticDischarge.reasonCode in "Medical Reason"
				or NoAntithromboticDischarge.reasonCode in "Patient Refusal")
      and exists (NoAntithromboticDischarge.category C where FHIRHelpers.ToConcept(C) ~ FC."Community" or FHIRHelpers.ToConcept(C) ~ FC."Discharge")
      and NoAntithromboticDischarge.status = 'completed'
      and NoAntithromboticDischarge.intent = 'order'

define "Antithrombotic Not Given at Discharge":
  QICore.MedicationNotRequested NoAntithromboticDischarge
    where NoAntithromboticDischarge.medication in "Antithrombotic Therapy"
      and (NoAntithromboticDischarge.reasonCode in "Medical Reason"
        or NoAntithromboticDischarge.reasonCode in "Patient Refusal")
      and (NoAntithromboticDischarge.isCommunity() or NoAntithromboticDischarge.isDischarge())
      and NoAntithromboticDischarge.intent = 'order'

define "Antithrombotic Not Given at Discharge":
  ["MedicationNotRequested": medication in "Antithrombotic Therapy"] NoAntithromboticDischarge
    where (NoAntithromboticDischarge.reasonCode in "Medical Reason"
        or NoAntithromboticDischarge.reasonCode in "Patient Refusal")
      and (NoAntithromboticDischarge.isCommunity() or NoAntithromboticDischarge.isDischarge())
      and NoAntithromboticDischarge.intent = 'order'
*/

// QICoreMedicationRequest
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-medicationrequest
define MedicationRequest:
  [MedicationRequest] R
    where R.status in { 'active', 'on-hold', 'completed', 'draft' }
      and R.doNotPerform is not true

/*
define "Antithrombotic Therapy at Discharge":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] Antithrombotic
    where exists (Antithrombotic.category C where FHIRHelpers.ToConcept(C) in { Global."Community", Global."Discharge" })
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent.value = 'order'

define "Antithrombotic Therapy at Discharge":
  QICore.MedicationRequest Antithrombotic
    where Antithrombotic.medication in "Antithrombotic Therapy"
      and (Antithrombotic.isCommunity() or Antithrombotic.isDischarge())
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent = 'order'

define "Antithrombotic Therapy at Discharge":
  [MedicationRequest: medication in "Antithrombotic Therapy"] Antithrombotic
    where (Antithrombotic.isCommunity() or Antithrombotic.isDischarge())
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent = 'order'
*/

// QICoreMedicationStatement
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-medicationstatement
define MedicationStatement:
  [MedicationStatement]

// QICoreNutritionOrder
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-nutritionorder
define NutritionOrder:
  [NutritionOrder]

// QICoreObservation
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observation
define Observation:
  [Observation] O
    where O.status in { 'registered', 'preliminary', 'final', 'amended', 'corrected' }

// QICoreObservationCancelled
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observationcancelled
define ObservationCancelled:
  [Observation] O
    where O.status = 'cancelled'

// FHIR Vital Signs

// USCore Smoking Status

// USCore Laboratory Result

// USCore Pediatric BMI for Age

// USCore Pediatric Weight for Height

// USCore Pulse Oximetry

// QICoreOrganization
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-organization
define Organization:
  [Organization]

// QICorePatient
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-patient
//define Patient:
//  [Patient]

// QICorePractitioner
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-practitioner
define Practitioner:
  [Practitioner]

// QICorePractitionerRole
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-practitionerrole
define PractitionerRole:
  [PractitionerRole]

// QICoreProcedure
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-procedure
define Procedure:
  [Procedure] P
    where P.status in { 'preparation', 'in-progress', 'on-hold', 'completed' }

define ProcedurePerformed:
  Procedure P
    where P.status = 'completed'

/*
define "Flexible Sigmoidoscopy Performed":
 [Procedure: "Flexible Sigmoidoscopy"] FlexibleSigmoidoscopy
	 where FlexibleSigmoidoscopy.status = 'completed'
		 and Global."Normalize Interval"(FlexibleSigmoidoscopy.performed) ends 5 years or less on or before end of "Measurement Period"

define "Flexible Sigmoidoscopy Performed":
  QICore.ProcedurePerformed FlexibleSigmoidoscopy
    where FlexibleSigmoidoscopy.code in "Flexible Sigmoidoscopy"
      and FlexibleSigmoidoscopy.performed.toInterval() ends 5 years or less on or before end of "Measurement Period"
*/

// QICoreProcedureNotDone
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-procedurenotdone
define ProcedureNotDone:
  [Procedure] P
    where P.status = 'not-done'

/*
define "No VTE Prophylaxis Device Applied":
  ["Procedure": "Device Application"] DeviceApplied
    let DeviceNotDoneTiming: Global.GetExtension(DeviceApplied, 'qicore-recorded').value
    where (DeviceApplied.usedCode in "Intermittent pneumatic compression devices (IPC)"
      or DeviceApplied.usedCode in "Venous foot pumps (VFP)"
      or DeviceApplied.usedCode in "Graduated compression stockings (GCS)"
    )
      and  DeviceApplied.status = 'not-done'
    return {id: DeviceApplied.id, requestStatusReason: DeviceApplied.statusReason, authoredOn: DeviceNotDoneTiming}

define "No VTE Prophylaxis Device Applied":
  QICore.ProcedureNotDone DeviceApplied
    where DeviceApplied.code in "Device Application"
      and (DeviceApplied.usedCode in "Intermittent pneumatic compression devices (IPC)"
        or DeviceApplied.usedCode in "Venous foot pumps (VFP)"
        or DeviceApplied.usedCode in "Graduated compression stockings (GCS)")
    return {
      id: DeviceApplied.id,
      requestStatusReason: DeviceApplied.statusReason,
      authoredOn: DeviceApplied.recorded()
    }

*/

// QICoreRelatedPerson
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-relatedperson
define RelatedPerson:
  [RelatedPerson]

// QICoreServiceNotRequested
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-servicenotrequested
define ServiceNotRequested:
  [ServiceRequest] SR
    where SR.status = 'completed'
      and SR.doNotPerform is true

/*
define "No VTE Prophylaxis Device Order":
  (["ServiceRequest": "Venous foot pumps (VFP)"]
    union ["ServiceRequest": "Intermittent pneumatic compression devices (IPC)"]
    union ["ServiceRequest": "Graduated compression stockings (GCS)"]
  ) DeviceOrder
    where DeviceOrder.status = 'completed'
      and DeviceOrder.doNotPerform is true

define "No VTE Prophylaxis Device Order":
  QICore.ServiceNotRequested DeviceOrder
    where DeviceOrder.code in "Venous foot pumps (VFP)"
      or DeviceOrder.code in "Intermittent pneumatic compression devices (IPC)"
      or DeviceOrder.code in "Graduated compression stockings (GCS)"
*/

// QICoreServiceRequest
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-servicerequest
define ServiceRequest:
  [ServiceRequest] SR
    where SR.status in { 'draft', 'active', 'on-hold', 'completed' }
      and SR.doNotPerform is not true

/*
define "Intervention Comfort Measures":
  (["ServiceRequest": "Comfort Measures"] P
    where P.intent = 'order'
  )
    union (["Procedure": "Comfort Measures"] InterventionPerformed
      where InterventionPerformed.status in {'completed', 'in-progress'}
    )

define "Intervention Comfort Measures":
  (QICore.ServiceRequest SR
    where SR.code in "Comfort Measures"
      and SR.intent = 'order'
  )
    union (
      QICore.Procedure InterventionPerformed
        where InterventionPerformed.code in "Comfort Measures"
          and InterventionPerformed.status in { 'completed', 'in-progress' }
    )
*/

// QICoreSpecimen
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-specimen
define Specimen:
  [Specimen]

// QICoreSubstance
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-substance
define Substance:
  [Substance]

// QICoreTask
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-task
define Task:
  [Task] T
    where T.status in { 'draft', 'requested', 'received', 'accepted', 'ready', 'in-progress', 'on-hold', 'completed' }

// QICoreTaskRejected
// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-taskrejected
// TODO: What about cancelled and failed?
define TaskRejected:
  [Task] T
    where T.status = 'rejected'

define TestPatientGender:
  Patient P
    where P.gender = 'male'

define TestPatientActive:
  Patient P
    where P.active is true

define TestPatientBirthDate:
  Patient P
    where P.birthDate before Today()

define TestPatientMaritalStatusMembership:
  Patient P
    where P.maritalStatus in "Marital Status"

define TestPatientMartialStatusComparison:
  Patient P
    where P.maritalStatus ~ "Marital Status - Married"

define TestPatientDeceasedAsBoolean:
  Patient P
    where P.deceased is false

define TestPatientDeceasedAsDateTime:
  Patient P
    where P.deceased before Today()

define TestSlices:
  [Observation: "Blood pressure"] O
    let
      systolicBP: singleton from (O.component SBP where SBP.code ~ "Systolic blood pressure"),
      diastolicBP: singleton from (O.component DBP where DBP.code ~ "Diastolic blood pressure")
    where O.status in { 'registered', 'preliminary', 'final', 'amended', 'corrected' }
      and systolicBP.value < 140 'mm[Hg]'
      and diastolicBP.value < 90 'mm[Hg]'

define TestSimpleExtensions:
  Patient P
    where P.birthsex() = 'M'

define TestComplexExtensions:
  Patient P
    where exists ((P.race().ombCategory) C where C ~ "American Indian or Alaska Native")
      and exists ((P.race().detailed) C where C ~ "Alaska Native")
