library QICorePatterns

/*
This library reviews patterns included in the soon-to-be-published
QI Core version 4.0.0. The following link is to the continuous build:

http://build.fhir.org/ig/HL7/fhir-qi-core/index.html

Note that once published, this content will be available at the home link:

http://hl7.org/fhir/us/qicore
*/

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0'
include MATGlobalCommonFunctions_FHIR4 version '4.0.000' called Global

valueset "Device Application": 'http://example.org/fhir/ValueSet/device-application'
valueset "Venous foot pumps (VFP)": 'http://example.org/fhir/ValueSet/venous-foot-pumps'
valueset "Statin Allergen": 'http://example.org/fhir/ValueSet/statin-allergen'
valueset "Congenital absence of cervix (disorder)": 'http://example.org/fhir/ValueSet/congenital-absence-of-cervix'
valueset "Frailty Device": 'http://example.org/fhir/ValueSet/frailty-device'
valueset "Encounter Inpatient": 'http://example.org/fhir/ValueSet/encounter-inpatient'
valueset "Inactivated Polio Vaccine (IPV)": 'http://example.org/fhir/ValueSet/inactivated-polio-vaccine'
valueset "Low Dose Unfractionated Heparin for VTE Prophylaxis": 'http://example.org/fhir/ValueSet/low-dose-unfractionated-heparin-for-vte-prophylaxis'
valueset "Dementia Medications": 'http://example.org/fhir/ValueSet/dementia-medications'
valueset "Antithrombotic Therapy": 'http://example.org/fhir/ValueSet/antithrombotic-therapy'
valueset "Pap Test": 'http://example.org/fhir/ValueSet/pap-test'
valueset "Flexible Sigmoidoscopy": 'http://example.org/fhir/ValueSet/flexible-sigmoidoscopy'
valueset "Intermittent pneumatic compression devices (IPC)": 'http://example.org/fhir/ValueSet/intermittent-pneumatic-compression-devices'
valueset "Graduated compression stockings (GCS)": 'http://example.org/fhir/ValueSet/graduated-compression-stockings'
valueset "Comfort Measures": 'http://example.org/fhir/ValueSet/comfort-measures'
valueset "Medical Reason": 'http://example.org/fhir/ValueSet/medical-reason'
valueset "Patient Refusal": 'http://example.org/fhir/ValueSet/patient-refusal'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
Use of FHIR Primitives
http://hl7.org/fhir/datatypes.html#primitive
http://build.fhir.org/ig/HL7/fhir-qi-core/patterns.html#primitives
*/

/*
Primitive elements in FHIR, such as String, Integer, DateTime, and so on, may
have extensions, and so have more complex structure than primitive elements
typically have in other models. This means that when accessing a FHIR primitive
element directly, a .value accessor must be used to get at the CQL primitive value:
*/

define "Completed Encounter":
  ["Encounter"] E
    where E.status.value = 'finished'

/*
To avoid this need, a FHIRHelpers library has been defined (and is included by
default in the CQL-to-ELM translator). To use this library, add the following include:
*/

// include FHIRHelpers version '4.0.0'

/*
Note that the FHIRHelpers version must match the FHIR version being used.

With this include, the above simplifies to:
*/

define "Completed Encounter (2)":
  ["Encounter"] E
    where E.status = 'finished'

/*
Note that the additional .value is no longer required.
*/

/*
Extensions
http://hl7.org/fhir/extensibility.html
http://build.fhir.org/ig/HL7/fhir-qi-core/patterns.html#extensions
*/

/*
Extensions in FHIR provide a standard mechanism to describe additional content
that is not part of the base FHIR resources. By defining extensions in a uniform
way as part of the base specification, FHIR enables extension-based functionality
to be introduced through the use of profiles and implementation guidance. QI-Core,
for example, includes several extensions related to quality improvement applications.

The QUICK Logical Model and the QUICK Author-focused View are intended to provide
first-class access to extensions defined in the QI-Core profiles, but until these
mechanisms are fully available, several functions have been defined as useful
short-hands to support accessing extension data in FHIR. The following are
some examples of using one of these functions to access the 'qicore-recorded'
extension:

http://build.fhir.org/ig/HL7/fhir-qi-core/StructureDefinition-qicore-procedurenotdone.html#profile
*/

define "Device Not Applied":
  ["Procedure": "Device Application"] DeviceApplied
    where DeviceApplied.usedCode in "Venous foot pumps (VFP)"
      and  DeviceApplied.status = 'not-done'
      and Global.GetExtension(DeviceApplied, 'qicore-recorded').value during "Measurement Period"

/*
Use of AllergyIntolerance
*/

// connectathon/fhir4/cql/EXM105_FHIR4-8.1.000.cql
define "Statin Allergy":
  ["AllergyIntolerance": "Statin Allergen"] StatinAllergy
    where (StatinAllergy.clinicalStatus is null or FHIRHelpers.ToConcept(StatinAllergy.clinicalStatus) ~ Global."allergy-active")
      and FHIRHelpers.ToConcept(StatinAllergy.verificationStatus) in { Global."allergy-unconfirmed", Global."allergy-confirmed" }

/*
Use of Condition:
*/
// draft-measures/pages/cql/in-progress/fhir4/EXM124-FHIR4-8.2.000.cql
define "Absence of Cervix":
	[Condition : "Congenital absence of cervix (disorder)"] NoCervixBirth
		where Global."Normalize Onset"(NoCervixBirth.onset) starts before end of "Measurement Period"
      and NoCervixBirth.clinicalStatus ~ ToConcept(Global."active")

/*
Use of DeviceRequest
*/
// connectathon/fhir4/cql/AdvancedIllnessandFrailtyExclusion_FHIR4-4.0.000.cql
define "Device Indicating Frailty":
  [DeviceRequest: "Frailty Device"] FrailtyDeviceOrder
    where FrailtyDeviceOrder.status in { 'active', 'on-hold', 'completed' }
      and FrailtyDeviceOrder.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }

/*
Use of Encounter
*/
// connectathon/fhir4/cql/MATGlobalCommonFunctions_FHIR4-4.0.000.cql
define "Inpatient Encounter":
  [Encounter: "Encounter Inpatient"] EncounterInpatient
    where EncounterInpatient.status = 'finished'
      and Global."LengthInDays"(EncounterInpatient.period) <= 120
      and EncounterInpatient.period ends during "Measurement Period"

/*
Use of Immunization
*/
// connectathon/fhir3/cql/EXM117_FHIR3-1.0.1.cql
define "Polio Immunizations or Procedures":
 ( ["Immunization": "Inactivated Polio Vaccine (IPV)"] PolioVaccination
     where PolioVaccination.status = 'completed' )

/*
Use of MedicationAdministration
*/
// connectathon/fhir4/cql/EXM108_FHIR4-8.2.000.cql
define "Low Dose Unfractionated Heparin Administration":
  ["MedicationAdministration": "Low Dose Unfractionated Heparin for VTE Prophylaxis"] VTEMedication
    where VTEMedication.status = 'completed'
      and VTEMedication.category ~ Global."Inpatient"

/*
Use of MedicationAdministrationNotDone
*/
// connectathon/fhir4/cql/EXM108_FHIR4-8.2.000.cql
define "No Low Dose Unfractionated Heparin Administration":
  ["MedicationAdministration": "Low Dose Unfractionated Heparin for VTE Prophylaxis"] VTEMedication
    where VTEMedication.status = 'not-done'

/*
Use of MedicationDispense
*/
// connectathon/fhir4/cql/AdvancedIllnessandFrailtyExclusion_FHIR4-4.0.000.cql
define "Dementia Medications Dispensed":
  ["MedicationDispense": "Dementia Medications"] MedicationDispense
    where MedicationDispense.status in { 'active', 'completed', 'on-hold' }

/*
Use of MedicationNotDispensed
*/
define "Dementia Medications Not Dispensed":
  ["MedicationDispense": "Dementia Medications"] MedicationDispense
    where MedicationDispense.status = 'declined'

/*
Use of MedicationNotRequested
*/
// connectathon/fhir4/cql/EXM104_FHIR4-8.1.000.cql
define "Antithrombotic Not Given at Discharge":
	["MedicationRequest": "Antithrombotic Therapy"] NoAntithromboticDischarge
    where NoAntithromboticDischarge.doNotPerform is true
			and (NoAntithromboticDischarge.reasonCode in "Medical Reason"
				or NoAntithromboticDischarge.reasonCode in "Patient Refusal")
      and exists (NoAntithromboticDischarge.category C where FHIRHelpers.ToConcept(C) in { Global."Community", Global."Discharge" })
      and NoAntithromboticDischarge.status = 'completed'
      and NoAntithromboticDischarge.intent = 'order'

/*
Use of MedicationRequest
*/

// connectathon/fhir4/cql/EXM104_FHIR4-8.1.000.cql
define "Antithrombotic Therapy at Discharge":
  ["MedicationRequest": "Antithrombotic Therapy"] Antithrombotic
    where exists (Antithrombotic.category C where FHIRHelpers.ToConcept(C) in { Global."Community", Global."Discharge" })
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent = 'order'

/*
Use of Observation
*/
// connectathon/fhir4/cql/EXM124_FHIR4-8.2.000.cql
define "Pap Test with Results":
	[Observation: "Pap Test"] PapTest
		where PapTest.value is not null
			and PapTest.status in { 'final', 'amended', 'corrected', 'preliminary' }

/*
Use of Procedure
*/
define "Flexible Sigmoidoscopy Performed":
	[Procedure: "Flexible Sigmoidoscopy"] FlexibleSigmoidoscopy
		where FlexibleSigmoidoscopy.status = 'completed'
			and Global."Normalize Interval"(FlexibleSigmoidoscopy.performed) ends 5 years or less on or before end of "Measurement Period"

/*
Use of ProcedureNotDone
*/
define "No VTE Prophylaxis Device Applied":
  ["Procedure": "Device Application"] DeviceApplied
    let DeviceNotDoneTiming: Global.GetExtension(DeviceApplied, 'qicore-recorded').value
    where (DeviceApplied.usedCode in "Intermittent pneumatic compression devices (IPC)"
      or DeviceApplied.usedCode in "Venous foot pumps (VFP)"
      or DeviceApplied.usedCode in "Graduated compression stockings (GCS)"
    )
      and  DeviceApplied.status = 'not-done'
    return {id: DeviceApplied.id, requestStatusReason: DeviceApplied.statusReason, authoredOn: DeviceNotDoneTiming}

/*
Use of ServiceNotRequested
*/
define "No VTE Prophylaxis Device Order":
  (["ServiceRequest": "Venous foot pumps (VFP)"]
    union ["ServiceRequest": "Intermittent pneumatic compression devices (IPC)"]
    union ["ServiceRequest": "Graduated compression stockings (GCS)"]
  ) DeviceOrder
    where DeviceOrder.status = 'completed'
      and DeviceOrder.doNotPerform is true
/*
Use of ServiceRequest
*/
define "Intervention Comfort Measures":
  (["ServiceRequest": "Comfort Measures"] P
    where P.intent = 'order'
  )
    union (["Procedure": "Comfort Measures"] InterventionPerformed
      where InterventionPerformed.status in {'completed', 'in-progress'}
    )

/*
Use of Medication
*/
// connectathon/fhir4/cql/MATGlobalCommonFunctions_FHIR4-4.0.000.cql
define function "GetMedicationCode"(request MedicationRequest):
  if request.medication is CodeableConcept then
    request.medication as CodeableConcept
  else
    (singleton from ([Medication] M where M.id = Global.GetId((request.medication as Reference).reference))).code
