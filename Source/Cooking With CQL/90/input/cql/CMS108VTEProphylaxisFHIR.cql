library CMS108VTEProphylaxisFHIR version '0.3.000'

using QICore version '6.0.0'

include CQMCommon version '4.0.000' called CQMCommon
include QICoreCommon version '4.0.000' called QICoreCommon
include FHIRHelpers version '4.4.000' called FHIRHelpers
include SupplementalDataElements version '5.0.000' called SDE
include TJCOverall version '8.16.000' called TJC
include VTE version '8.13.000' called VTE

codesystem "LOINC": 'http://loinc.org'

code "Risk for venous thromboembolism": '72136-5' from "LOINC" display 'Risk for venous thromboembolism'

codesystem "Procedure Type": 'http://terminology.hl7.org/codesystem/ex-procedure-type'

code "Primary procedure": 'primary' from "Procedure Type"

valueset "Application of Graduated Compression Stockings": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.66'
valueset "Application of Intermittent Pneumatic Compression Devices": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.65'
valueset "Application of Venous Foot Pumps": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.64'
valueset "Atrial Fibrillation or Flutter": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.202'
valueset "Comfort Measures": 'http://cts.nlm.nih.gov/fhir/ValueSet/1.3.6.1.4.1.33895.1.3.0.45'
valueset "Direct Thrombin Inhibitor": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.205'
valueset "Emergency Department Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.292'
valueset "General or Neuraxial Anesthesia": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.1743'
valueset "General Surgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.255'
valueset "Glycoprotein IIb/IIIa Inhibitors": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1045.41'
valueset "Graduated compression stockings": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.256'
valueset "Gynecological Surgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.257'
valueset "Hemorrhagic Stroke": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.212'
valueset "Ischemic Stroke": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.247'
valueset "Hip Fracture Surgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.258'
valueset "Hip Replacement Surgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.259'
valueset "Injectable Factor Xa Inhibitor for VTE Prophylaxis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.211'
valueset "INR": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.213'
valueset "Intensive Care Unit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1029.206'
valueset "Intermittent pneumatic compression devices": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.214'
valueset "Intracranial Neurosurgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.260'
valueset "Intravenous route": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.222'
valueset "Knee Replacement Surgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.261'
valueset "Low Dose Unfractionated Heparin for VTE Prophylaxis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1045.39'
valueset "Low Molecular Weight Heparin for VTE Prophylaxis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.219'
valueset "Low Risk": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.400'
valueset "Medical Reason For Not Providing Treatment": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.473'
valueset "Mental Health Diagnoses": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.105.12.1004'
valueset "Obstetrical or Pregnancy Related Conditions": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.263'
valueset "Obstetrics VTE": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.264'
valueset "Oral Factor Xa Inhibitor for VTE Prophylaxis or VTE Treatment": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.134'
valueset "Patient Refusal": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.93'
valueset "Rivaroxaban for VTE Prophylaxis": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1110.50'
valueset "Subcutaneous route": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.223'
valueset "Unfractionated Heparin": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.218'
valueset "Urological Surgery": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.272'
valueset "Venous foot pumps": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.230'
valueset "Venous Thromboembolism": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.279'
valueset "Warfarin": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.232'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"

define "Initial Population":
  VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions"

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  "Encounter Less Than 2 Days"
    union "Encounter With ICU Location Stay 1 Day Or More"
    union "Encounter With Principal Diagnosis Of Mental Disorder Or Stroke"
    union "Encounter With Principal Procedure Of Selected Surgery"
    union "Encounter With Intervention Comfort Measures From Day Of Start Of Hospitalization To Day After Admission"
    union "Encounter With Intervention Comfort Measures On Day Of Or Day After Procedure"

define "Encounter Less Than 2 Days":
  VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter
    where QualifyingEncounter.period.lengthInDays ( ) < 2

define "Encounter With ICU Location Stay 1 Day Or More":
  VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter
    where exists ( QualifyingEncounter.location Location
        where Location.location.getLocation ( ).type in "Intensive Care Unit"
          and Location.period.lengthInDays ( ) >= 1
          and Location.period starts on or after start of QualifyingEncounter.period
          and date from ( start of Location.period ) during ( start of QualifyingEncounter.period ).CalendarDayOfOrDayAfter ( )
    )

define "Encounter With Principal Diagnosis Of Mental Disorder Or Stroke":
  VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter
      // where QualifyingEncounter.principalDiagnosis().code in "Mental Health Diagnoses"
        //  or QualifyingEncounter.principalDiagnosis().code in "Hemorrhagic Stroke"
          //  or QualifyingEncounter.principalDiagnosis().code in "Ischemic Stroke"
    
    
    
    where QualifyingEncounter.principalDiagnosis ( ).code in "Ischemic Stroke"

 /*  Removed from QI-Core v6 due to Principal Px retrieved from Claim profile                   
define "Selected Surgery":
  (	["Procedure": "General Surgery"]
        union ["Procedure": "Gynecological Surgery"]
        union ["Procedure": "Hip Fracture Surgery"]
        union ["Procedure": "Hip Replacement Surgery"]
        union ["Procedure": "Intracranial Neurosurgery"]
        union ["Procedure": "Knee Replacement Surgery"]
        union ["Procedure": "Urological Surgery"] ) Procedure
        where Procedure.status = 'completed'
  
define "Encounter With Principal Procedure Of Selected Surgery":
    from
      VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter,
      "Selected Surgery" SelectedProcedure
      let 
        claim: [Claim] C where C.status = 'active' and C.use = 'claim' and exists (C.item I where I.encounter.references(QualifyingEncounter)),
        claimItem: claim.item I where I.encounter.references(QualifyingEncounter),
        claimProcedure: claim.procedure P where P.sequence in claimItem.procedureSequence
      where claimProcedure.type.includesCode("Primary procedure") 
     // where QualifyingEncounter.principalProcedure().id = SelectedProcedure.id
         and QualifyingEncounter.id = SelectedProcedure.id
        and end of SelectedProcedure.performed.toInterval () during QualifyingEncounter.period
      return QualifyingEncounter
*/
// QA: CQIT-217 will use principalProcedure() once it's finalized 



define "Encounter With Principal Procedure Of Selected Surgery":
  VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter
    let claim: [Claim] C
      where C.status = 'active'
        and C.use = 'claim'
        and exists ( C.item I
            where I.encounter.references ( QualifyingEncounter )
        ),
    claimItem: claim.item I
      where I.encounter.references ( QualifyingEncounter ),
    claimProcedure: claim.procedure P
      where P.sequence in claimItem.procedureSequence
    where claimProcedure.type.includesCode ( "Primary procedure" )
      and claimProcedure.procedure in "Hip Fracture Surgery"
      /*  and exists( claimProcedure.procedure P 
                 where P in "Gynecological Surgery"
                    or P in "Hip Fracture Surgery"
                    or P in "Hip Replacement Surgery"
                    or P in "Intracranial Neurosurgery"
                    or P in "Knee Replacement Surgery"
                    or P in "Urological Surgery"
                      ) */


define "Intervention Comfort Measures":
  ( ["ServiceRequest": "Comfort Measures"] InterventionRequest
      where InterventionRequest.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }
        and InterventionRequest.status in { 'active', 'on-hold', 'completed' }
        and InterventionRequest.doNotPerform is not true
  )
    union ( ["Procedure": "Comfort Measures"] InterventionPerformed
        where InterventionPerformed.status in { 'completed', 'in-progress' }
    )

define "Encounter With Intervention Comfort Measures On Day Of Or Day After Procedure":
  from
    VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter,
    ["Procedure": "General or Neuraxial Anesthesia"] AnesthesiaProcedure,
    "Intervention Comfort Measures" ComfortMeasure
    where AnesthesiaProcedure.status = 'completed'
      and AnesthesiaProcedure.performed.toInterval ( ) ends 1 day after day of start of QualifyingEncounter.period
      and Coalesce(start of ComfortMeasure.performed.toInterval(), ComfortMeasure.authoredOn) during day of ( end of AnesthesiaProcedure.performed.toInterval ( ) ).CalendarDayOfOrDayAfter ( )
    return QualifyingEncounter

define "Encounter With Intervention Comfort Measures From Day Of Start Of Hospitalization To Day After Admission":
  VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter
    with "Intervention Comfort Measures" ComfortMeasure
      such that Coalesce(start of ComfortMeasure.performed.toInterval(), ComfortMeasure.authoredOn) during day of QualifyingEncounter.FromDayOfStartOfHospitalizationToDayAfterAdmission ( )

define "Numerator":
  "Encounter With VTE Prophylaxis Received From Day Of Start Of Hospitalization To Day After Admission Or Procedure"
    union ( "Encounter With Medication Oral Factor Xa Inhibitor Administered On Day Of Or Day After Admission Or Procedure"
        intersect ( "Encounter With Prior Or Present Diagnosis Of Atrial Fibrillation Or Prior Diagnosis Of VTE"
            union "Encounter With Prior Or Present Procedure Of Hip Or Knee Replacement Surgery"
        )
    )
    union "Encounter With Low Risk For VTE Or Anticoagulant Administered"
    union "Encounter With No VTE Prophylaxis Due To Medical Reason"
    union "Encounter With No VTE Prophylaxis Due To Patient Refusal"

define "Pharmacological or Mechanical VTE Prophylaxis Received":
  ( ["MedicationAdministration": medication in "Low Dose Unfractionated Heparin for VTE Prophylaxis"] VTEMedication
      where VTEMedication.status = 'completed'
        and VTEMedication.dosage.route in "Subcutaneous route"
  )
    union ( ["MedicationAdministration": medication in "Low Molecular Weight Heparin for VTE Prophylaxis"] LMWH
        where LMWH.status = 'completed'
    )
    union ( ["MedicationAdministration": medication in "Injectable Factor Xa Inhibitor for VTE Prophylaxis"] FactorXa
        where FactorXa.status = 'completed'
    )
    union ( ["MedicationAdministration": medication in "Warfarin"] WarfarinAdm
        where WarfarinAdm.status = 'completed'
    )
    union ( ["MedicationAdministration": medication in "Rivaroxaban for VTE Prophylaxis"] Rivaroxaban
        where Rivaroxaban.status = 'completed'
    )
    union ( ( ["Procedure": "Application of Intermittent Pneumatic Compression Devices"]
        union ["Procedure": "Application of Venous Foot Pumps"]
        union ["Procedure": "Application of Graduated Compression Stockings"] ) DeviceApplied
        where DeviceApplied.status = 'completed'
    )

define "Encounter With VTE Prophylaxis Received From Day Of Start Of Hospitalization To Day After Admission Or Procedure":
  ( from
      VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter,
      "Pharmacological or Mechanical VTE Prophylaxis Received" VTEProphylaxis
      where Coalesce(VTEProphylaxis.effective.toInterval(), VTEProphylaxis.performed.toInterval()) starts during day of QualifyingEncounter.FromDayOfStartOfHospitalizationToDayAfterAdmission ( )
      return QualifyingEncounter
  )
    union ( from
        VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter,
        ["Procedure": "General or Neuraxial Anesthesia"] AnesthesiaProcedure,
        "Pharmacological or Mechanical VTE Prophylaxis Received" VTEProphylaxis
        where AnesthesiaProcedure.status = 'completed'
          and AnesthesiaProcedure.performed.toInterval ( ) ends 1 day after day of start of QualifyingEncounter.period
          and Coalesce(VTEProphylaxis.effective.toInterval(), VTEProphylaxis.performed.toInterval()) starts during day of ( end of AnesthesiaProcedure.performed.toInterval ( ) ).CalendarDayOfOrDayAfter ( )
        return QualifyingEncounter
    )

define "Encounter With Medication Oral Factor Xa Inhibitor Administered On Day Of Or Day After Admission Or Procedure":
  ( from
      VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter,
      ["MedicationAdministration": medication in "Oral Factor Xa Inhibitor for VTE Prophylaxis or VTE Treatment"] FactorXaMedication
      where FactorXaMedication.status = 'completed'
        and FactorXaMedication.effective.toInterval ( ) starts during day of ( start of QualifyingEncounter.period ).CalendarDayOfOrDayAfter ( )
      return QualifyingEncounter
  )
    union ( from
        VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter,
        ["Procedure": "General or Neuraxial Anesthesia"] AnesthesiaProcedure,
        ["MedicationAdministration": medication in "Oral Factor Xa Inhibitor for VTE Prophylaxis or VTE Treatment"] FactorXaMedication
        where FactorXaMedication.status = 'completed'
          and AnesthesiaProcedure.status = 'completed'
          and AnesthesiaProcedure.performed.toInterval ( ) ends 1 day after day of start of QualifyingEncounter.period
          and FactorXaMedication.effective.toInterval ( ) starts during day of ( end of AnesthesiaProcedure.performed.toInterval ( ) ).CalendarDayOfOrDayAfter ( )
        return QualifyingEncounter
    )

define "Encounter With Prior Or Present Diagnosis Of Atrial Fibrillation Or Prior Diagnosis Of VTE":
  ( VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter
      with ["ConditionProblemsHealthConcerns": "Atrial Fibrillation or Flutter"] AtrialFibrillation
        such that AtrialFibrillation.isActive ( )
          and AtrialFibrillation.verificationStatus is not null
          and AtrialFibrillation.verificationStatus ~ QICoreCommon."confirmed"
          and AtrialFibrillation.onset.toInterval ( ) starts on or before end of QualifyingEncounter.period
  )
    union ( VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter
        where exists ( ( QualifyingEncounter.encounterDiagnosis ( ) ) EncDx
            where EncDx.code in "Atrial Fibrillation or Flutter"
        )
    )
    union ( VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter
        with ["ConditionProblemsHealthConcerns": "Venous Thromboembolism"] VTEDiagnosis
          such that ( VTEDiagnosis.clinicalStatus ~ QICoreCommon."inactive"
              or VTEDiagnosis.clinicalStatus ~ QICoreCommon."remission"
              or VTEDiagnosis.clinicalStatus ~ QICoreCommon."resolved"
          )
            and VTEDiagnosis.verificationStatus is not null
            and VTEDiagnosis.verificationStatus ~ QICoreCommon."confirmed"
            and VTEDiagnosis.onset.toInterval ( ) before start of QualifyingEncounter.period
    )

define "Encounter With Prior Or Present Procedure Of Hip Or Knee Replacement Surgery":
  VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter
    with ( ["Procedure": "Hip Replacement Surgery"]
      union ["Procedure": "Knee Replacement Surgery"] ) HipKneeProcedure
      such that HipKneeProcedure.status = 'completed'
        and HipKneeProcedure.performed.toInterval ( ) starts on or before end of QualifyingEncounter.period

define "Encounter With Low Risk For VTE Or Anticoagulant Administered":
  "Low Risk For VTE Or Anticoagulant Administered From Day Of Start Of Hospitalization To Day After Admission"
    union "Low Risk For VTE Or Anticoagulant Administered On Day Of Or Day After Procedure"

define "Low Risk Indicator For VTE":
  ( ["SimpleObservation": "Risk for venous thromboembolism"] VTERiskAssessment
      where VTERiskAssessment.value as Concept in "Low Risk"
        and VTERiskAssessment.status in { 'final', 'amended', 'corrected' }
      return {
        id: VTERiskAssessment.id,
        LowRiskDatetime: VTERiskAssessment.effective.earliest ( )
      }
  )
    union ( ["LaboratoryResultObservation": "INR"] INRLabTest
        where INRLabTest.value as Quantity > 3.0
          and INRLabTest.status in { 'final', 'amended', 'corrected' }
        return {
          id: INRLabTest.id,
          LowRiskDatetime: INRLabTest.issued
        }
    )
    union ( ( ( ["MedicationAdministration": medication in "Unfractionated Heparin"] UnfractionatedHeparin
          where UnfractionatedHeparin.dosage.route in "Intravenous route"
      )
        union ["MedicationAdministration": medication in "Direct Thrombin Inhibitor"]
        union ["MedicationAdministration": medication in "Glycoprotein IIb/IIIa Inhibitors"] ) AnticoagulantMedication
        where AnticoagulantMedication.status = 'completed'
        return {
          id: AnticoagulantMedication.id,
          LowRiskDatetime: start of AnticoagulantMedication.effective.toInterval ( )
        }
    )

define "Low Risk For VTE Or Anticoagulant Administered From Day Of Start Of Hospitalization To Day After Admission":
  VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter
    with "Low Risk Indicator For VTE" LowRiskForVTE
      such that LowRiskForVTE.LowRiskDatetime during day of QualifyingEncounter.FromDayOfStartOfHospitalizationToDayAfterAdmission ( )

define "Low Risk For VTE Or Anticoagulant Administered On Day Of Or Day After Procedure":
  from
    VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter,
    ["Procedure": "General or Neuraxial Anesthesia"] AnesthesiaProcedure,
    "Low Risk Indicator For VTE" LowRiskForVTE
    where AnesthesiaProcedure.status = 'completed'
      and AnesthesiaProcedure.performed.toInterval ( ) ends 1 day after day of start of QualifyingEncounter.period
      and LowRiskForVTE.LowRiskDatetime during day of ( end of AnesthesiaProcedure.performed.toInterval ( ) ).CalendarDayOfOrDayAfter ( )
    return QualifyingEncounter

define "Encounter With No VTE Prophylaxis Due To Medical Reason":
  ( "No VTE Prophylaxis Medication Due To Medical Reason From Day Of Start Of Hospitalization To Day After Admission"
      intersect "No Mechanical VTE Prophylaxis Due To Medical Reason From Day Of Start Of Hospitalization To Day After Admission"
  )
    union ( "No VTE Prophylaxis Medication Due To Medical Reason On Day Of Or Day After Procedure"
        intersect "No Mechanical VTE Prophylaxis Due To Medical Reason On Day Of Or Day After Procedure"
    )

define "No VTE Prophylaxis Medication Due To Medical Reason From Day Of Start Of Hospitalization To Day After Admission":
  VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter
    with "No VTE Prophylaxis Medication Administered Or Ordered" NoVTEMedication
      such that exists ( NoVTEMedication.MedicationStatusReason MedRsn
          where MedRsn in "Medical Reason For Not Providing Treatment"
      )
        and NoVTEMedication.authoredOn during day of QualifyingEncounter.FromDayOfStartOfHospitalizationToDayAfterAdmission ( )

define "No VTE Prophylaxis Medication Due To Medical Reason On Day Of Or Day After Procedure":
  from
    VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter,
    ["Procedure": "General or Neuraxial Anesthesia"] AnesthesiaProcedure,
    "No VTE Prophylaxis Medication Administered Or Ordered" NoVTEMedication
    where exists ( NoVTEMedication.MedicationStatusReason MedRsn
        where MedRsn in "Medical Reason For Not Providing Treatment"
    )
      and AnesthesiaProcedure.status = 'completed'
      and AnesthesiaProcedure.performed.toInterval ( ) ends 1 day after day of start of QualifyingEncounter.period
      and NoVTEMedication.authoredOn during day of ( end of AnesthesiaProcedure.performed.toInterval ( ) ).CalendarDayOfOrDayAfter ( )
    return QualifyingEncounter

define "No VTE Prophylaxis Medication Administered Or Ordered":
  ( ( [MedicationAdministrationNotDone: "Low Dose Unfractionated Heparin for VTE Prophylaxis"]
      union [MedicationAdministrationNotDone: "Low Molecular Weight Heparin for VTE Prophylaxis"]
      union [MedicationAdministrationNotDone: "Injectable Factor Xa Inhibitor for VTE Prophylaxis"]
      union [MedicationAdministrationNotDone: "Warfarin"]
      union [MedicationAdministrationNotDone: "Rivaroxaban for VTE Prophylaxis"] ) NoMedicationAdm
      return {
        id: NoMedicationAdm.id,
        MedicationStatusReason: NoMedicationAdm.statusReason,
        authoredOn: NoMedicationAdm.recorded
      }
  )
    union ( ( ["MedicationNotRequested": "Low Dose Unfractionated Heparin for VTE Prophylaxis"]
        union ["MedicationNotRequested": "Low Molecular Weight Heparin for VTE Prophylaxis"]
        union ["MedicationNotRequested": "Injectable Factor Xa Inhibitor for VTE Prophylaxis"]
        union ["MedicationNotRequested": "Warfarin"]
        union ["MedicationNotRequested": "Rivaroxaban for VTE Prophylaxis"] ) NoMedicationOrder
        where NoMedicationOrder.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }
        return {
          id: NoMedicationOrder.id,
          MedicationStatusReason: { NoMedicationOrder.reasonCode }, //CQLIT-521 
          
          authoredOn: NoMedicationOrder.authoredOn
        }
    )
    union ( from
        ( ["MedicationRequest": "Low Dose Unfractionated Heparin for VTE Prophylaxis"]
          union ["MedicationRequest": "Low Molecular Weight Heparin for VTE Prophylaxis"]
          union ["MedicationRequest": "Injectable Factor Xa Inhibitor for VTE Prophylaxis"]
          union ["MedicationRequest": "Warfarin"]
          union ["MedicationRequest": "Rivaroxaban for VTE Prophylaxis"] ) MedicationOrderReject,
        [TaskRejected] T
        where T.focus.references ( MedicationOrderReject )
          and T.code ~ QICoreCommon."Fulfill"
          and MedicationOrderReject.status = 'active'
        return {
          id: MedicationOrderReject.id,
          MedicationStatusReason: { T.statusReason },
          authoredOn: MedicationOrderReject.authoredOn
        }
    )

define "No Mechanical VTE Prophylaxis Due To Medical Reason From Day Of Start Of Hospitalization To Day After Admission":
  VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter
    with "No Mechanical VTE Prophylaxis Performed Or Ordered" NoVTEDevice
      such that NoVTEDevice.requestStatusReason in "Medical Reason For Not Providing Treatment"
        and NoVTEDevice.authoredOn during day of QualifyingEncounter.FromDayOfStartOfHospitalizationToDayAfterAdmission ( )

define "No Mechanical VTE Prophylaxis Due To Medical Reason On Day Of Or Day After Procedure":
  from
    VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter,
    ["Procedure": "General or Neuraxial Anesthesia"] AnesthesiaProcedure,
    "No Mechanical VTE Prophylaxis Performed Or Ordered" NoVTEDevice
    where NoVTEDevice.requestStatusReason in "Medical Reason For Not Providing Treatment"
      and AnesthesiaProcedure.status = 'completed'
      and AnesthesiaProcedure.performed.toInterval ( ) ends 1 day after day of start of QualifyingEncounter.period
      and NoVTEDevice.authoredOn during day of ( end of AnesthesiaProcedure.performed.toInterval ( ) ).CalendarDayOfOrDayAfter ( )
    return QualifyingEncounter

define "No Mechanical VTE Prophylaxis Performed Or Ordered":
  ( ( [ServiceNotRequested: "Venous foot pumps"]
      union [ServiceNotRequested: "Intermittent pneumatic compression devices"]
      union [ServiceNotRequested: "Graduated compression stockings"] ) DeviceNotOrder
      where DeviceNotOrder.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }
      return {
        id: DeviceNotOrder.id,
        requestStatusReason: DeviceNotOrder.reasonRefused,
        authoredOn: DeviceNotOrder.authoredOn
      }
  )
    union ( from
        ( [ServiceRequest: "Venous foot pumps"]
          union [ServiceRequest: "Intermittent pneumatic compression devices"]
          union [ServiceRequest: "Graduated compression stockings"] ) DeviceOrderReject,
        [TaskRejected] T
        where DeviceOrderReject.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }
          and DeviceOrderReject.status = 'active'
          and T.focus.references ( DeviceOrderReject )
          and T.code ~ QICoreCommon."Fulfill"
        return {
          id: DeviceOrderReject.id,
          requestStatusReason: T.statusReason,
          authoredOn: DeviceOrderReject.authoredOn
        }
    )
    union ( ( [ProcedureNotDone: "Application of Intermittent Pneumatic Compression Devices"]
        union [ProcedureNotDone: "Application of Venous Foot Pumps"]
        union [ProcedureNotDone: "Application of Graduated Compression Stockings"] ) DeviceNotApplied
        let DeviceNotDoneTiming: DeviceNotApplied.recorded
        return {
          id: DeviceNotApplied.id,
          requestStatusReason: DeviceNotApplied.statusReason,
          authoredOn: DeviceNotDoneTiming
        }
    )

define "Encounter With No VTE Prophylaxis Due To Patient Refusal":
  "No VTE Prophylaxis Due To Patient Refusal From Day Of Start Of Hospitalization To Day After Admission"
    union "No VTE Prophylaxis Due To Patient Refusal On Day Of Or Day After Procedure"

define "No VTE Prophylaxis Due To Patient Refusal From Day Of Start Of Hospitalization To Day After Admission":
  VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter
    with "No Mechanical or Pharmacological VTE Prophylaxis Due To Patient Refusal" PatientRefusal
      such that PatientRefusal.authoredOn during day of QualifyingEncounter.FromDayOfStartOfHospitalizationToDayAfterAdmission ( )

define "No Mechanical or Pharmacological VTE Prophylaxis Due To Patient Refusal":
  ( "No VTE Prophylaxis Medication Administered Or Ordered" NoVTEMedication
      where exists ( NoVTEMedication.MedicationStatusReason MedRsn
          where MedRsn in "Patient Refusal"
      )
  )
    union ( "No Mechanical VTE Prophylaxis Performed Or Ordered" NoVTEDevice
        where NoVTEDevice.requestStatusReason in "Patient Refusal"
    )

define "No VTE Prophylaxis Due To Patient Refusal On Day Of Or Day After Procedure":
  from
    VTE."Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions" QualifyingEncounter,
    ["Procedure": "General or Neuraxial Anesthesia"] AnesthesiaProcedure,
    "No Mechanical or Pharmacological VTE Prophylaxis Due To Patient Refusal" PatientRefusal
    where AnesthesiaProcedure.status = 'completed'
      and QICoreCommon."ToInterval" ( AnesthesiaProcedure.performed ) ends 1 day after day of start of QualifyingEncounter.period
      and PatientRefusal.authoredOn during day of ( end of AnesthesiaProcedure.performed.toInterval ( ) ).CalendarDayOfOrDayAfter ( )
    return QualifyingEncounter

define fluent function "FromDayOfStartOfHospitalizationToDayAfterAdmission"(Encounter Encounter):
  Interval[date from ( start of Encounter.hospitalizationWithObservation ( ) ), date from ( start of Encounter.period ) + 1 days]