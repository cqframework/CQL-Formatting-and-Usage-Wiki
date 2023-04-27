library StatusFHIR version '1.0.0'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance.
*/

/*
The purpose of these functions is to constrain FHIR resource elements for measures authored by NCQA, 
based on QICore to QDM Mapping (http://build.fhir.org/ig/HL7/fhir-qi-core/qdm-to-qicore.html).
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.2.000' called FHIRHelpers

codesystem "ObservationCategoryCodes": 'http://terminology.hl7.org/CodeSystem/observation-category'
codesystem "ConditionClinicalStatusCodes": 'http://terminology.hl7.org/CodeSystem/condition-clinical'

code "laboratory": 'laboratory' from "ObservationCategoryCodes" display 'laboratory'
code "exam": 'exam' from "ObservationCategoryCodes" display 'exam'
code "survey": 'survey' from "ObservationCategoryCodes" display 'survey'
code "vital-signs": 'vital-signs' from "ObservationCategoryCodes" display 'vital-signs'
code "active": 'active' from "ConditionClinicalStatusCodes"

context Patient

//Condition - Diagnosis
//Use this function when you need to constrain status to "active" only, otherwise when use in combination with QICoreCommon."ToPrevalenceInterval" where the defualt constraints are "active", "recurrence" and "relapse"
define function "Active Condition"(Condition List<Condition>):
  Condition C
    where C.clinicalStatus ~ "active"
       
//Encounter - Encounter, Performed
define function "Finished Encounter"(Enc List<Encounter>):
  Enc E
    where E.status ~ 'finished'

define function "Finished or Ongoing Encounter"(Enc List<Encounter>):
  Enc E
    where E.status in { 'finished', 'in-progress' }

//Immunization - Immunization, Administered
define function "Completed Immunization"(Immunization List<Immunization>):
  Immunization I
    where I.status ~ 'completed'

//MedicationDispense - Medication, Dispensed
define function "Dispensed Medication"(Med List<MedicationDispense>):
  Med M
    where M.status ~ 'completed'

//Observation - Symptom
define function "Initial or Final Observation"(Obs List<Observation>):
  Obs O
    where O.status in { 'preliminary', 'final', 'amended', 'corrected' }

//Observation - Diagnostic Study, Performed
define function "Final Observation"(Obs List<Observation>):
  Obs O
    where O.status in { 'preliminary', 'final', 'amended', 'corrected' }

//Observation - Laboratory Test, Performed
define function "Final Lab Observation"(Obs List<Observation>):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
    and exists ( O.category ObservationCategory
              where ( ObservationCategory ) ~ "laboratory"
          )

//Observation - Physical Exam, Performed
define function "Final Exam Observation"(Obs List<Observation>):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
    and exists ( O.category ObservationCategory
              where ( ObservationCategory ) ~ "exam"
          )     

//Observation - Assessment, Performed
define function "Final Survey Observation"(Obs List<Observation>):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
    and exists ( O.category ObservationCategory
              where ( ObservationCategory ) ~ "survey"
          )

//Procedure - Intervention, Performed; Procedure, Performed 
//No constraint on category to differentiate between intervention and procedure yet
define function "Completed Procedure"(Proc List<Procedure>):
  Proc P
    where P.status ~ 'completed'

//ServiceRequest - Intervention, Order; Diagnostic Study, Order; Laboratory Test, Order
define function "Completed or Ongoing Service Request"(ServiceRequest List<ServiceRequest>):
  ServiceRequest S
    where S.status in { 'active', 'completed'}
    and S.intent = 'order'

//DeviceRequest - Device, Order
define function "Completed or Ongoing Device Request"(DeviceRequest List<DeviceRequest>):
  DeviceRequest D
    where D.status in { 'active', 'completed'}
    and D.intent = 'order'

// MedicationRequest - Medication, Active
define function "Active Medication"(MedicationRequest List<MedicationRequest>):
  MedicationRequest M
    where M.status = 'active'
    and M.intent = 'order' or M.intent = 'plan'
    // No constraints on M.requester yet
    // No constraints on M.category yet
    // No constraints on M.reported yet

// MedicationRequest - Medication, Order
define function "Active or Completed Medication Request"(MedicationRequest List<MedicationRequest>):
  MedicationRequest M
    where M.status in { 'active', 'completed' }
    and M.intent = 'order'
    // No constraints on M.reported yet

