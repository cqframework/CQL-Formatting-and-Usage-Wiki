library UsagePatterns

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

context Patient

// Profiles

// QICoreAdverseEvent

// QICoreAllergyIntolerance
// connectathon/fhir4/cql/EXM105_FHIR4-8.1.000.cql
define "Statin Allergy Intolerance":
  ["AllergyIntolerance": "Statin Allergen"] StatinAllergyIntolerance
    where StatinAllergyIntolerance.clinicalStatus is null or StatinAllergyIntolerance.clinicalStatus ~ Global."allergy-active"

// QICoreBodyStructure

// QICoreCarePlan

// QICoreCareTeam

// QICoreClaim

// QICoreCommunication

// QICoreCommunicationNotDone

// QICoreCommunicationRequest

// QICoreCondition
// draft-measures/pages/cql/in-progress/fhir4/EXM124-FHIR4-8.2.000.cql
define "Absence of Cervix":
	[Condition : "Congenital absence of cervix (disorder)"] NoCervixBirth
		where Global."Normalize Onset"(NoCervixBirth.onset) starts before end of "Measurement Period"
      and NoCervixBirth.clinicalStatus ~ ToConcept(Global."active")

// QICoreCoverage
// connectathon/fhir4/cql/SupplementalDataElements_FHIR4-1.0.0.cql
define "SDE Payer":
    [Coverage: type in "Payer"] Payer
      return {
        code: Payer.type,
         period: Payer.period
      }

// QICoreDevice

// QICoreDeviceNotRequested

// QICoreDeviceRequest
// connectathon/fhir4/cql/AdvancedIllnessandFrailtyExclusion_FHIR4-4.0.000.cql
define "Device Indicating Frailty":
  [DeviceRequest: "Frailty Device"] FrailtyDeviceOrder
    where FrailtyDeviceOrder.status in { 'active', 'on-hold', 'completed' }
      and FrailtyDeviceOrder.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }

// QICoreDeviceUseStatement

// QICoreDiagnosticReportLab

// QICoreDiagnosticReportNote

// QICoreEncounter
// connectathon/fhir4/cql/MATGlobalCommonFunctions_FHIR4-4.0.000.cql
define "Inpatient Encounter":
  [Encounter: "Encounter Inpatient"] EncounterInpatient
    where EncounterInpatient.status = 'finished'
      and "LengthInDays"(EncounterInpatient.period) <= 120
      and EncounterInpatient.period ends during "Measurement Period"

// QICoreFamilyMemberHistory

// QICoreFlag

// QICoreGoal

// QICoreImagingStudy

// QICoreImmunization
// connectathon/fhir3/cql/EXM117_FHIR3-1.0.1.cql
define "Polio Immunizations or Procedures":
 ( ["Immunization": "Inactivated Polio Vaccine (IPV)"] PolioVaccination
     where PolioVaccination.status = 'completed' )

// QICoreImmunizationEvaluation

// QICoreImmunizationNotDone

// QICoreImmunizationRecommendation

// USCoreImplantableDevice

// QICoreLocation
// connectathon/fhir4/cql/EXM108_FHIR4-8.2.000.cql
define "Encounter With ICU Location Stay 1 Day or More":
  "Encounter With Age Range and Without VTE Diagnosis or Obstetrical Conditions" QualifyingEncounter
    where exists ( QualifyingEncounter.location Location
      where Global.GetLocation(Location.location).type in "Intensive Care Unit"
        and Global."LengthInDays"(Location.period)>= 1
        and Location.period starts during TJC."CalendarDayOfOrDayAfter"(start of QualifyingEncounter.period)
   )

// QICoreMedication
// connectathon/fhir4/cql/MATGlobalCommonFunctions_FHIR4-4.0.000.cql
define function "GetMedicationCode"(request MedicationRequest):
  if request.medication is CodeableConcept then
    request.medication as CodeableConcept
  else
    (singleton from ([Medication] M where M.id = GetId((request.medication as Reference).reference))).code

// QICoreMedicationAdministration
// connectathon/fhir4/cql/EXM108_FHIR4-8.2.000.cql
define "Low Dose Unfractionated Heparin Administration":
  ["MedicationAdministration": medication in "Low Dose Unfractionated Heparin for VTE Prophylaxis"] VTEMedication
    where VTEMedication.status = 'completed'
      and VTEMedication.category ~ "Inpatient"

// QICoreMedicationAdministrationNotDone
// connectathon/fhir4/cql/EXM108_FHIR4-8.2.000.cql
define "No Low Dose Unfractionated Heparin Administration":
  ["MedicationAdministration": medication in "Low Dose Unfractionated Heparin for VTE Prophylaxis"] VTEMedication
    where VTEMedication.status = 'not-done'

// QICoreMedicationDispense
// connectathon/fhir4/cql/AdvancedIllnessandFrailtyExclusion_FHIR4-4.0.000.cql
define "Dementia Medications Dispensed":
  ["MedicationDispense": "Dementia Medications"] MedicationDispense
    where MedicationDispense.status in { 'active', 'completed', 'on-hold' }

// QICoreMedicationDispenseDeclined
define "Dementia Medications Not Dispensed":
  ["MedicationDispense": "Dementia Medications"] MedicationDispense
    where MedicationDispense.status = 'declined'

// QICoreMedicationNotRequested
// connectathon/fhir4/cql/EXM104_FHIR4-8.1.000.cql
define "Antithrombotic Not Given at Discharge":
	["MedicationRequest": medication in "Antithrombotic Therapy"] NoAntithromboticDischarge
    where NoAntithromboticDischarge.doNotPerform is true
			and (NoAntithromboticDischarge.reasonCode in "Medical Reason"
				or NoAntithromboticDischarge.reasonCode in "Patient Refusal")
      and exists (NoAntithromboticDischarge.category C where FHIRHelpers.ToConcept(C) in { Global."Community", Global."Discharge" })
      and NoAntithromboticDischarge.status = 'completed'
      and NoAntithromboticDischarge.intent = 'order'


// QICoreMedicationRequest
// connectathon/fhir4/cql/EXM104_FHIR4-8.1.000.cql
define "Antithrombotic Therapy at Discharge":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] Antithrombotic
    where exists (Antithrombotic.category C where FHIRHelpers.ToConcept(C) in { Global."Community", Global."Discharge" })
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent = 'order'

// QICoreMedicationStatement

// QICoreNutritionOrder

// QICoreObservation
// connectathon/fhir4/cql/EXM124_FHIR4-8.2.000.cql
define "Pap Test with Results":
	[Observation: "Pap Test"] PapTest
		where PapTest.value is not null
			and PapTest.status in { 'final', 'amended', 'corrected', 'preliminary' }

// QICoreObservationCancelled

// FHIR Vital Signs

// USCore Smoking Status

// USCore Laboratory Result

// USCore Pediatric BMI for Age

// USCore Pediatric Weight for Height

// USCore Pulse Oximetry

// QICoreOrganization

// QICorePatient

// QICorePractitioner

// QICorePractitionerRole

// QICoreProcedure
define "Flexible Sigmoidoscopy Performed":
	[Procedure: "Flexible Sigmoidoscopy"] FlexibleSigmoidoscopy
		where FlexibleSigmoidoscopy.status = 'completed'
			and Global."Normalize Interval"(FlexibleSigmoidoscopy.performed) ends 5 years or less on or before end of "Measurement Period"

// QICoreProcedureNotDone
define "No VTE Prophylaxis Device Applied":
  ["Procedure": "Device Application"] DeviceApplied
    let DeviceNotDoneTiming: Global.GetExtension(DeviceApplied, 'qicore-recorded').value
    where (DeviceApplied.usedCode in "Intermittent pneumatic compression devices (IPC)"
      or DeviceApplied.usedCode in "Venous foot pumps (VFP)"
      or DeviceApplied.usedCode in "Graduated compression stockings (GCS)"
    )
      and  DeviceApplied.status = 'not-done'
    return {id: DeviceApplied.id, requestStatusReason: DeviceApplied.statusReason, authoredOn: DeviceNotDoneTiming}

// QICoreRelatedPerson

// QICoreServiceNotRequested
define "No VTE Prophylaxis Device Order":
  (["ServiceRequest": "Venous foot pumps (VFP)"]
    union ["ServiceRequest": "Intermittent pneumatic compression devices (IPC)"]
    union ["ServiceRequest": "Graduated compression stockings (GCS)"]
  ) DeviceOrder
    where DeviceOrder.status = 'completed'
      and DeviceOrder.doNotPerform is true

// QICoreServiceRequest
// connectathon/fhir4/cql/EXM108_FHIR4-8.2.000.cql
define "Intervention Comfort Measures":
  (["ServiceRequest": "Comfort Measures"] P
    where P.intent = 'order'
  )
    union (["Procedure": "Comfort Measures"] InterventionPerformed
      where InterventionPerformed.status in {'completed', 'in-progress'}
    )

// QICoreSpecimen

// QICoreSubstance

// QICoreTask
