/*
@source: https://github.com/cqframework/ecqm-content-qicore-2024-subset/blob/main/input/cql/Status.cql
*/
library Status version '1.8.000'

using QICore version '4.1.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers

codesystem "ObservationCategoryCodes": 'http://terminology.hl7.org/CodeSystem/observation-category'

code "laboratory": 'laboratory' from "ObservationCategoryCodes" display 'laboratory'
code "exam": 'exam' from "ObservationCategoryCodes" display 'exam'
code "survey": 'survey' from "ObservationCategoryCodes" display 'survey'

context Patient

//This library contains functions that are based on QDM 5.6 to QICore 4.1.1 March 2023 (https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns---QICore-v4.1.1). The functions may appear similar to some QICoreCommon functions but different in that they have constraints that are relevant for measures authored by NCQA.

//Assessment, Performed
define fluent function isAssessmentPerformed(Obs List<Observation>):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
          and exists ( O.category ObservationCategory
          where ( ObservationCategory ) ~ "survey"
      )

//Device, Order - Personal Use Devices: active and completed only
define fluent function isDeviceOrder(DeviceRequest List<DeviceRequest>):
  DeviceRequest D
    where D.status in { 'active', 'completed' }
      and D.intent = 'order'

//Diagnostic Study, Order: active and completed only
define fluent function isDiagnosticStudyOrder(ServiceRequest List<ServiceRequest>):
  ServiceRequest S
    where S.status in { 'active', 'completed' }
      and S.intent = 'order'
      
//Intervention, Order: active and completed only    
define fluent function isInterventionOrder(ServiceRequest List<ServiceRequest>):
  ServiceRequest S
    where S.status in { 'active', 'completed' }
      and S.intent = 'order'    

//Laboratory Test, Order: active and completed only
define fluent function isLaboratoryTestOrder(ServiceRequest List<ServiceRequest>):
  ServiceRequest S
    where S.status in { 'active', 'completed' }
      and S.intent = 'order'        

//Diagnostic Study, Performed
define fluent function isDiagnosticStudyPerformed(Obs List<Observation>):
  Obs O
    where O.status in {'final', 'amended', 'corrected' }
    
//Encounter, Performed
//General usage unless required otherwise by measure intent (e.g., follow-up encounters)
define fluent function isEncounterPerformed(Enc List<Encounter>):
  Enc E
    where E.status in {'finished', 'arrived', 'triaged', 'in-progress', 'onleave'}

//Immunization, Administered: completed only
define fluent function isImmunizationAdministered(Immunization List<Immunization>):
  Immunization I
    where I.status ~ 'completed'

//Intervention, Performed
define fluent function isInterventionPerformed(Proc List<Procedure>):
  Proc P
    where P.status ~ 'completed'

//Procedure, Performed
define fluent function isProcedurePerformed(Proc List<Procedure>):
  Proc P
    where P.status ~ 'completed'

//Laboratory Test, Performed
define fluent function isLaboratoryTestPerformed(Obs List<Observation>):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
      and exists ( O.category ObservationCategory
          where ( ObservationCategory ) ~ "laboratory"
      )

//Medication, Active
define fluent function isMedicationActive(MedicationRequest List<MedicationRequest>):
  MedicationRequest M
    where M.status = 'active'
      and M.intent = 'order'

//Medication, Dispensed
define fluent function isMedicationDispensed(Med List<MedicationDispense>):
  Med M
    where M.status in { 'completed', 'in-progress', 'on-hold' }

//Medication, Order: active and completed only
define fluent function isMedicationOrder(MedicationRequest List<MedicationRequest>):
  MedicationRequest M
    where M.status in { 'active', 'completed' }
      and M.intent = 'order'

//Physical Exam, Performed
define fluent function isPhysicalExamPerformed(Obs List<Observation>):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
      and exists ( O.category ObservationCategory
          where ( ObservationCategory ) ~ "exam"
      )

//Observation Vital Signs
define fluent function isObservationBP(Obs List<"QICore.observation-bp">):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
      
define fluent function isObservationBodyHeight(Obs List<"QICore.observation-bodyheight">):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
      
define fluent function isObservationBodyWeight(Obs List<"QICore.observation-bodyweight">):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }
      
define fluent function isObservationBMI(Obs List<"QICore.observation-bmi">):
  Obs O
    where O.status in { 'final', 'amended', 'corrected' }

//Symptom
define fluent function isSymptom(Obs List<Observation>):
  Obs O
    where O.status in { 'preliminary', 'final', 'amended', 'corrected' }