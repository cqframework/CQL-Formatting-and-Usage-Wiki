library QICorePatterns

using QICore version '4.1.1'

include FHIRHelpers version '4.1.000'

codesystem "Marital Status Codes": 'http://terminology.hl7.org/CodeSystem/v3-MaritalStatus'
codesystem "CDC Race and Ethnicity Codes": 'urn:oid:2.16.840.1.113883.6.238'
codesystem "CommunicationCategoryCodeSystem": 'http://terminology.hl7.org/CodeSystem/communication-category'
codesystem "SNOMED-CT": 'http://snomed.info/sct'
codesystem "CVX": 'http://hl7.org/fhir/sid/cvx'
codesystem "LOINC": 'http://loinc.org'
codesystem "TaskCodeSystem": 'http://hl7.org/fhir/CodeSystem/task-code'

valueset "Marital Status": 'http://hl7.org/fhir/ValueSet/marital-status'
valueset "CommunicationCodes": 'http://hl7.org/fhir/ValueSet/communication-category'
valueset "DeviceCodes": 'http://example.org/fhir/ValueSet/device-codes' // Random set of device codes from 'http://hl7.org/fhir/ValueSet/device-type'
valueset "Venous Foot Pumps (VFP)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.230'
valueset "ImmunizationCodes": 'http://example.org/fhir/ValueSet/immunization-codes' // Random set of immunization codes from 'http://hl7.org/fhir/us/core/ValueSet/us-core-vaccines-cvx'
valueset "MedicationCodes": 'http://example.org/fhir/ValueSet/medication-codes' // Random set of medication codes from 'http://hl7.org/fhir/ValueSet/medication-codes'
valueset "ObservationCodes": 'http://example.org/fhir/ValueSet/observation-codes' // Random set of observation codes from 'http://hl7.org/fhir/ValueSet/observation-codes'
valueset "ProcedureCodes": 'http://example.org/fhir/ValueSet/procedure-codes' // Random set of procedure codes from 'http://hl7.org/fhir/us/core/ValueSet/us-core-procedure-code'
valueset "Application of intermittent pneumatic compression devices (IPC)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.65'
valueset "TaskCodes": 'http://hl7.org/fhir/ValueSet/task-code'
valueset "NegationReasonCodes": 'http://hl7.org/fhir/us/qicore/ValueSet/qicore-negation-reason'

code "Marital Status - Married": 'M' from "Marital Status Codes"
code "American Indian or Alaska Native": '1002-5' from "CDC Race and Ethnicity Codes"
code "Alaska Native": '1735-0' from "CDC Race and Ethnicity Codes"
code "CommunicationCode": 'alert' from "CommunicationCategoryCodeSystem" display 'Alert'
code "DeviceCode": '156009' from "SNOMED-CT" display 'Spine board'
code "ImmunizationCode": '01' from "CVX" display 'diphtheria, tetanus toxoids and pertussis vaccine'
code "MedicationCode": '26100' from "SNOMED-CT" display 'Codeine phosphate'
code "ObservationCode": '1-8' from "LOINC" display 'Acyclovir [Susceptibility]'
code "ProcedureCode": '7138802' from "SNOMED-CT" display 'Procedure'
code "TaskCode": 'approve' from "TaskCodeSystem" display 'Activate/approve the focal resource'

context Patient

define TestAdverseEvent: ["AdverseEvent"]
define TestAllergyIntolerance: ["AllergyIntolerance"]
define TestBodyStructure: ["BodyStructure"]
define TestCarePlan: ["CarePlan"]
define TestCareTeam: ["CareTeam"]
define TestClaim: ["Claim"]
define TestCommunication: ["Communication"]
define TestCommunicationNotDone: ["CommunicationNotDone"]
define TestCommunicationRequest: ["CommunicationRequest"]
define TestCondition: ["Condition"]
define TestCoverage: ["Coverage"]
define TestDevice: ["Device"]
define TestDeviceNotRequested: ["DeviceNotRequested"]
define TestDeviceRequest: ["DeviceRequest"]
define TestDeviceUseStatement: ["DeviceUseStatement"]
define TestDiagnosticReportLab: ["DiagnosticReportLab"]
define TestDiagnosticReportNote: ["DiagnosticReportNote"]
define TestEncounter: ["Encounter"]
define TestFamilyMemberHistory: ["FamilyMemberHistory"]
define TestFlag: ["Flag"]
define TestGoal: ["Goal"]
define TestImagingStudy: ["ImagingStudy"]
define TestImmunization: ["Immunization"]
define TestImmunizationEvaluation: ["ImmunizationEvaluation"]
define TestImmunizationNotDone: ["ImmunizationNotDone"]
define TestImmunizationRecommendation: ["ImmunizationRecommendation"]
define TestLocation: ["Location"]
define TestMedication: ["Medication"]
define TestMedicationAdministration: ["MedicationAdministration"]
define TestMedicationAdministrationNotDone: ["MedicationAdministrationNotDone"]
define TestMedicationDispense: ["MedicationDispense"]
define TestMedicationDispenseNotDone: ["MedicationDispenseNotDone"]
define TestMedicationNotRequested: ["MedicationNotRequested"]
define TestMedicationRequest: ["MedicationRequest"]
define TestMedicationStatement: ["MedicationStatement"]
define TestObservation: ["Observation"]
define TestObservationNotDone: ["ObservationNotDone"]
define TestOrganization: ["Organization"]
define TestPatient: ["Patient"]
define TestVitalsPanel: ["observation-vitalspanel"]
define TestRespRate: ["observation-resprate"]
define TestHeartRate: ["observation-heartrate"]
define TestOxygenSat: ["observation-oxygensat"]
define TestBodyTemp: ["observation-bodytemp"]
define TestBodyHeight: ["observation-bodyheight"]
define TestHeadCircum: ["observation-headcircum"]
define TestBodyWeight: ["observation-bodyweight"]
define TestBMI: ["observation-bmi"]
define TestBP: ["observation-bp"]
define TestPractitioner: ["Practitioner"]
define TestPractitionerRole: ["PractitionerRole"]
define TestProcedure: ["Procedure"]
define TestProcedureNotDone: ["ProcedureNotDone"]
define TestRelatedPerson: ["RelatedPerson"]
define TestServiceNotRequested: ["ServiceNotRequested"]
define TestServiceRequest: ["ServiceRequest"]
define TestSpecimen: ["Specimen"]
define TestSubstsance: ["Substance"]
define TestTask: ["Task"]
define TestTaskNotDone: ["TaskNotDone"]
define TestUSCoreImplantableDevice: ["USCoreImplantableDeviceProfile"]
define TestUSCoreLaboratoryResult: ["USCoreLaboratoryResultObservationProfile"]
define TestUSCoreSmokingStatus: ["USCoreSmokingStatusProfile"]
define TestUSCorePulseOximetry: ["USCorePulseOximetryProfile"]
define TestUSCorePediatricBMIForAge: ["USCorePediatricBMIforAgeObservationProfile"]
define TestUSCorePediatricWeightForHeight: ["USCorePediatricWeightForHeightObservationProfile"]

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
  ["observation-bp"] BP
    where BP.SystolicBP.value < 140 'mm[Hg]'
      and BP.DiastolicBP.value < 90 'mm[Hg]'

define TestSimpleExtensions:
  Patient P
    where P.birthsex = 'M'

define TestComplexExtensions:
  Patient P
    where exists (P.race.ombCategory C where C ~ "American Indian or Alaska Native")
      and exists (P.race.detailed C where C ~ "Alaska Native")

// Validate Encounter.diagnosis cardinality
define TestEncounterDiagnosisCardinality:
    exists (First([Encounter] E where exists (E.diagnosis)).diagnosis)

// Validate ProcedureNotDone elements
define TestProcedureNotDoneElements:
    [ProcedureNotDone] P
      where P.performed is null
        and P.recorded on or before day of Today()
        //and exists (P.identifier)
        and P.status = 'not-done'
        and P.statusReason is not null
        //and P.category is not null
        and P.code is not null

// Validate NotDone...

/**
 * CommunicationNotDone
 */

/*
define TestSpecificCommunicationNotDone:
    ["CommunicationNotDone": CommunicationCode]

// TODO: Support this case, need to introduce a terminology contains operator
//define TestSpecificCommunicationNotDoneActual:
//    ["CommunicationNotDone": reasonCode ~ CommunicationCode]
//      union ["CommunicationNotDone": reasonCode contains CommunicationCode]

define TestSpecificCommunicationNotDoneExplicit:
    ["CommunicationNotDone"] C
      where C.reasonCode ~ CommunicationCode
        or CommunicationCode in C.reasonCode

// NOTE: Consider using topic rather than reasonCode as the negation focus?
//define TestSpecificCommunicationNotDoneExplicit:
//    [Communication] C
//      where (C.reasonCode ~ CommunicationCode
//          or CommunicationCode in ValueSet { id: C.reasonCode.extension("http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-notDoneValueSet").value as String }
//        )
//        and C.status = 'not-done'
//        and C.recorded on or before day of Today()
//        and C.statusReason in NegationReasonCodes

define TestGeneralCommunicationNotDone:
    ["CommunicationNotDone": CommunicationCodes]

define TestGeneralCommunicationNotDoneActual:
    ["CommunicationNotDone": reasonCode in CommunicationCodes]
      union ["CommunicationNotDone": reasonCode ~ CommunicationCodes]

// TODO: Fix CommunicationNotDone
    // Attempting to use results in "Could not resolve call to operator ''ToConcept(java.util.List)'' in library ''FHIRHelpers''"
    // This is because the underlying reasonCode element is 0..*, but the CommunicationNotDone profile constrains it to 1..1
    // So the ModelInfo presents it as a singular element, but is plural in the model
    // Not sure where best to address that discrepancy
define TestGeneralCommunicationNotDoneExplicit:
    ["CommunicationNotDone"] C
      where C.reasonCode in CommunicationCodes
        or C.reasonCode ~ CommunicationCodes

//define TestGeneralCommunicationNotDoneExplicit:
//    [Communication] C
//      where (C.reasonCode in CommunicationCodes
//          or CommunicationCodes ~ ValueSet { id: C.reasonCode.extension("http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-notDoneValueSet").value as String }
//        )
//        and C.status = 'not-done'
//        and C.recorded on or before day of Today()
//        and C.statusReason in NegationReasonCodes
*/

/**
 * DeviceNotRequested
 */

// TODO: Because DeviceRequest.code[x] is a choice, even though the DeviceNotRequested profile constraints out the reference choice type,
    // the underlying DeviceRequest instance may still have code represented as a reference, and the ToConcept invocation will fail...
    // Changed the DeviceRequest/example instance to have a codeCodeableConcept instead of a codeReference as a temporary work around
    // Note also that the inclusion of "trusted" profile filtering in the data access layer addresses this issue
//define TestSpecificDeviceNotRequested:
//    ["DeviceNotRequested": DeviceCode]

// TODO: Support this use case
//define TestSpecificDeviceNotRequestedActual:
//    ["DeviceNotRequested": code ~ DeviceCode]
//      union ["DeviceNotRequested": code contains DeviceCode]

define TestSpecificDeviceNotRequestedExplicit:
    [DeviceNotRequested] D
      where D.code ~ DeviceCode
        or DeviceCode in D.code

define TestGeneralDeviceNotRequested:
  ["DeviceNotRequested": "Venous Foot Pumps (VFP)"]

define TestGeneralDeviceNotRequestedCode:
    ["DeviceNotRequested": code in "Venous Foot Pumps (VFP)"]

define TestGeneralDeviceNotRequestedValueSet:
    ["DeviceNotRequested": code ~ "Venous Foot Pumps (VFP)"]

define TestGeneralDeviceNotRequestedActual:
    ["DeviceNotRequested": code in "Venous Foot Pumps (VFP)"]
      union ["DeviceNotRequested": code ~ "Venous Foot Pumps (VFP)"]

define TestGeneralDeviceNotRequestedExplicit:
    ["DeviceNotRequested"] D
      where D.code in "Venous Foot Pumps (VFP)"
        or D.code ~ "Venous Foot Pumps (VFP)"

define TestGeneralDeviceNotRequestedCodeExplicit:
    ["DeviceNotRequested"] D
      where D.code in "Venous Foot Pumps (VFP)"

define TestGeneralDeviceNotRequestedValueSetExplicit:
    ["DeviceNotRequested"] D
      where D.code ~ "Venous Foot Pumps (VFP)"

/**
 * ImmunizationNotDone
 */

//define TestSpecificImmunizationNotDone:
//    ["ImmunizationNotDone": ImmunizationCode]

// TODO: Support this use case
//define TestSpecificImmunizationNotDoneActual:
//    ["ImmunizationNotDone": vaccineCode ~ ImmunizationCode]
//      union ["ImmunizationNotDone": vaccineCode contains ImmunizationCode]

define TestSpecificImmunizationNotDoneExplicit:
    ["ImmunizationNotDone"] I
      where I.vaccineCode ~ ImmunizationCode
        or ImmunizationCode in I.vaccineCode

define TestGeneralImmunizationNotDone:
    ["ImmunizationNotDone": ImmunizationCodes]

define TestGeneralImmunizationNotDoneActual:
    ["ImmunizationNotDone": vaccineCode in ImmunizationCodes]
      union ["ImmunizationNotDone": vaccineCode ~ ImmunizationCodes]

define TestGeneralImmunizationNotDoneExplicit:
    ["ImmunizationNotDone"] I
      where I.vaccineCode in ImmunizationCodes
        or I.vaccineCode ~ ImmunizationCodes

/**
 * MedicationAdministrationNotDone
 */

//define TestSpecificMedicationAdministrationNotDone:
//    ["MedicationAdministrationNotDone": MedicationCode]

// TODO: Support this use case
//define TestSpecificMedicationAdministrationNotDoneActual:
//    ["MedicationAdministrationNotDone": medication ~ MedicationCode]
//      union ["MedicationAdministrationNotDone": medication contains MedicationCode]

define TestSpecificMedicationAdministrationNotDoneExplicit:
    ["MedicationAdministrationNotDone"] I
      where I.medication ~ MedicationCode
        or MedicationCode in I.medication

define TestGeneralMedicationAdministrationNotDone:
    ["MedicationAdministrationNotDone": MedicationCodes]

define TestGeneralMedicationAdministrationNotDoneActual:
    ["MedicationAdministrationNotDone": medication in MedicationCodes]
      union ["MedicationAdministrationNotDone": medication ~ MedicationCodes]

define TestGeneralMedicationAdministrationNotDoneExplicit:
    ["MedicationAdministrationNotDone"] I
      where I.medication in MedicationCodes
        or I.medication ~ MedicationCodes


/**
 * MedicationDispenseNotDone
 */

/*
** Missing Valueset: http://cts.nlm.nih.gov/fhir/1.3.6.1.4.1.6997.4.1.2.268.13.35211.1.13.1.999.321 (Ophthalmic Antihistamines)

//define TestSpecificMedicationDispenseNotDone:
//    ["MedicationDispenseNotDone": MedicationCode]

// TODO: Support this use case
//define TestSpecificMedicationDispenseNotDoneActual:
//    ["MedicationDispenseNotDone": medication ~ MedicationCode]
//      union ["MedicationDispenseNotDone": medication contains MedicationCode]

define TestSpecificMedicationDispenseNotDoneExplicit:
    ["MedicationDispenseNotDone"] I
      where I.medication ~ MedicationCode
        or MedicationCode in I.medication

define TestGeneralMedicationDispenseNotDone:
    ["MedicationDispenseNotDone": MedicationCodes]

define TestGeneralMedicationDispenseNotDoneActual:
    ["MedicationDispenseNotDone": medication in MedicationCodes]
      union ["MedicationDispenseNotDone": medication ~ MedicationCodes]

define TestGeneralMedicationDispenseNotDoneExplicit:
    ["MedicationDispenseNotDone"] I
      where I.medication in MedicationCodes
        or I.medication ~ MedicationCodes
*/

/**
 * MedicationNotRequested
 */

//define TestSpecificMedicationNotRequested:
//    ["MedicationNotRequested": MedicationCode]

// TODO: Support this use case
//define TestSpecificMedicationNotRequestedActual:
//    ["MedicationNotRequested": medication ~ MedicationCode]
//      union ["MedicationNotRequested": medication contains MedicationCode]

define TestSpecificMedicationNotRequestedExplicit:
    ["MedicationNotRequested"] I
      where I.medication ~ MedicationCode
        or MedicationCode in I.medication

define TestGeneralMedicationNotRequested:
    ["MedicationNotRequested": MedicationCodes]

define TestGeneralMedicationNotRequestedActual:
    ["MedicationNotRequested": medication in MedicationCodes]
      union ["MedicationNotRequested": medication ~ MedicationCodes]

define TestGeneralMedicationNotRequestedExplicit:
    ["MedicationNotRequested"] I
      where I.medication in MedicationCodes
        or I.medication ~ MedicationCodes

/**
 * ObservationNotDone
 */

//define TestSpecificObservationNotDone:
//    ["ObservationNotDone": ObservationCode]

// TODO: Support this use case
//define TestSpecificObservationNotDoneActual:
//    ["ObservationNotDone": code ~ ObservationCode]
//      union ["ObservationNotDone": code contains ObservationCode]

define TestSpecificObservationNotDoneExplicit:
    ["ObservationNotDone"] I
      where I.code ~ ObservationCode
        or ObservationCode in I.code

define TestGeneralObservationNotDone:
    ["ObservationNotDone": ObservationCodes]

define TestGeneralObservationNotDoneActual:
    ["ObservationNotDone": code in ObservationCodes]
      union ["ObservationNotDone": code ~ ObservationCodes]

define TestGeneralObservationNotDoneExplicit:
    ["ObservationNotDone"] I
      where I.code in ObservationCodes
        or I.code ~ ObservationCodes

/**
 * ProcedureNotDone
 */

//define TestSpecificProcedureNotDone:
//    ["ProcedureNotDone": ProcedureCode]

// TODO: Support this use case
//define TestSpecificProcedureNotDoneActual:
//    ["ProcedureNotDone": code ~ ProcedureCode]
//      union ["ProcedureNotDone": code contains ProcedureCode]

define TestSpecificProcedureNotDoneExplicit:
    ["ProcedureNotDone"] I
      where I.code ~ ProcedureCode
        or ProcedureCode in I.code

define TestGeneralProcedureNotDone:
    ["ProcedureNotDone": "Application of intermittent pneumatic compression devices (IPC)"]

define TestGeneralProcedureNotDoneActual:
    ["ProcedureNotDone": code in "Application of intermittent pneumatic compression devices (IPC)"]
      union ["ProcedureNotDone": code ~ "Application of intermittent pneumatic compression devices (IPC)"]

define TestGeneralProcedureNotDoneExplicit:
    ["ProcedureNotDone"] I
      where I.code as Concept in "Application of intermittent pneumatic compression devices (IPC)"
        or I.code as ValueSet ~ "Application of intermittent pneumatic compression devices (IPC)"

/**
 * ServiceNotRequested
 */

//define TestSpecificServiceNotRequested:
//    ["ServiceNotRequested": ProcedureCode]

// TODO: Support this use case
//define TestSpecificServiceNotRequestedActual:
//    ["ServiceNotRequested": code ~ ProcedureCode]
//      union ["ServiceNotRequested": code contains ProcedureCode]

define TestSpecificServiceNotRequestedExplicit:
    ["ServiceNotRequested"] I
      where I.code ~ ProcedureCode
        or ProcedureCode in I.code

define TestGeneralServiceNotRequested:
    ["ServiceNotRequested": "Application of intermittent pneumatic compression devices (IPC)"]

define TestGeneralServiceNotRequestedActual:
    ["ServiceNotRequested": code in "Application of intermittent pneumatic compression devices (IPC)"]
      union ["ServiceNotRequested": code ~ "Application of intermittent pneumatic compression devices (IPC)"]

define TestGeneralServiceNotRequestedExplicit:
    ["ServiceNotRequested"] I
      where I.code in "Application of intermittent pneumatic compression devices (IPC)"
        or I.code ~ "Application of intermittent pneumatic compression devices (IPC)"

/**
 * TaskNotDone
 */

//define TestSpecificTaskNotDone:
//    ["TaskNotDone": TaskCode]

// TODO: Support this use case
//define TestSpecificTaskNotDoneActual:
//    ["TaskNotDone": code ~ TaskCode]
//      union ["TaskNotDone": code contains TaskCode]

define TestSpecificTaskNotDoneExplicit:
    ["TaskNotDone"] I
      where I.code ~ TaskCode
        or TaskCode in I.code

define TestGeneralTaskNotDone:
    ["TaskNotDone": TaskCodes]

define TestGeneralTaskNotDoneActual:
    ["TaskNotDone": code in TaskCodes]
      union ["TaskNotDone": code ~ TaskCodes]

define TestGeneralTaskNotDoneExplicit:
    ["TaskNotDone"] I
      where I.code in TaskCodes
        or I.code ~ TaskCodes




