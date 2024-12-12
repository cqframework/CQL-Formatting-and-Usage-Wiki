library ClaimDiagnosis

using FHIR version '4.0.1'

include FHIRHelpers version '4.1.0'
include FHIRCommon version '4.1.0'

codesystem "Diagnosis Type": 'http://terminology.hl7.org/CodeSystem/ex-diagnosistype'
codesystem "Present On Admission Indicators": 'https://www.cms.gov/Medicare/Medicare-Fee-for-Service-Payment/HospitalAcqCond/Coding'

valueset "Asthma": 'TBD'

code "Principal Diagnosis": 'principal' from "Diagnosis Type"

code "POA-Y": 'Y' from "Present On Admission Indicators"
code "POA-N": 'N' from "Present On Admission Indicators"
code "POA-W": 'W' from "Present On Admission Indicators"
code "POA-1": '1' from "Present On Admission Indicators"

context Patient

/*
@description: Returns diagnosis-related information from claims associated with the given encounter
@comment: Returns the `Claim.diagnosis` element associated with the given encounter of any active claim for the patient.
*/
define fluent function claimDiagnoses(encounter Encounter):
  encounter E
    let 
      claim: ([Claim] C where C.status = 'active' and C.use = 'claim' and exists (C.item I where I.encounter.references(E))),
      claimItem: (claim.item I where I.encounter.references(E))
    return claim.diagnosis D where D.sequence in claimItem.diagnosisSequence

define "Encounter With Asthma Present On Admission":
  [Encounter] E
    where exists (
      (E.claimDiagnoses()) D
        where D.diagnosis in "Asthma"
          and D.onAdmission ~ "POA-Y"
    )

define "Encounter With Principal Diagnosis Of Asthma":
  [Encounter] E
    where exists (
      (E.claimDiagnoses()) D
        where D.diagnosis in "Asthma"
          and D.type.includesCode("Principal Diagnosis")
    )
