library THATKACommon

using QDM version '5.5'

include MATGlobalCommonFunctions version '5.0.000' called Global

codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'
codesystem "SNOMEDCT": 'urn:oid:2.16.840.1.113883.6.96'

valueset "Active Bleeding": 'urn:oid:2.16.840.1.113762.1.4.1029.211'
valueset "Anticoagulant Medications, Injection": 'urn:oid:2.16.840.1.113762.1.4.1206.21'
valueset "Anticoagulant Medications, Oral": 'urn:oid:2.16.840.1.113762.1.4.1206.20'
valueset "Atrial Fibrillation": 'urn:oid:2.16.840.1.113883.17.4077.3.1001'
valueset "Blood Transfusion Administration": 'urn:oid:2.16.840.1.113762.1.4.1029.209'
valueset "Cancer": 'urn:oid:2.16.840.1.113883.3.526.3.1010'
valueset "Coagulation Disorder Conditions": 'urn:oid:2.16.840.1.113762.1.4.1206.17'
valueset "Comorbidity Risk Factors": 'urn:oid:2.16.840.1.113762.1.4.1206.13'
valueset "Current Smoking Tobacco User": 'urn:oid:2.16.840.1.113762.1.4.1111.99'
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Fracture Exclusions For Hip And Knee Procedures": 'urn:oid:2.16.840.1.113762.1.4.1206.2'
valueset "General Major Bleeding Events": 'urn:oid:2.16.840.1.113762.1.4.1179.5'
valueset "General Surgery": 'urn:oid:2.16.840.1.113762.1.4.1206.15'
valueset "Left Against Medical Advice": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.308'
valueset "Malignant Neoplasm Complications Related To Hip and Knee Procedures": 'urn:oid:2.16.840.1.113762.1.4.1206.7'
valueset "Mechanical Complications Related To Hip and Knee Procedures": 'urn:oid:2.16.840.1.113762.1.4.1206.1'
valueset "Nonprimary Total Hip, Total Knee Replacement": 'urn:oid:2.16.840.1.113762.1.4.1206.5'
valueset "Postoperative Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1070'
valueset "Pulmonary Embolism or DVT": 'urn:oid:2.16.840.1.113883.17.4077.3.1036'
valueset "Renal insufficiency": 'urn:oid:2.16.840.1.113883.3.3157.1330'
valueset "Tobacco Use Screening": 'urn:oid:2.16.840.1.113883.3.526.3.1278'
valueset "Total Hip, Total Knee Replacement": 'urn:oid:2.16.840.1.113762.1.4.1029.96'
valueset "Transfer From Acute Care Hospital": 'urn:oid:2.16.840.1.113883.13.190.5.43'
valueset "Treatment of Hemorrhage or Hematoma": 'urn:oid:2.16.840.1.113762.1.4.1206.14'
valueset "Venous Thromboembolism": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.279'

code "Body mass index (BMI) [Ratio]": '39156-5' from "LOINC" display 'Body mass index (BMI) [Ratio]'
code "Hospital-based outpatient emergency care center (environment)": '73770003' from "SNOMEDCT" display 'Hospital-based outpatient emergency care center (environment)'
code "Outpatient surgery service (qualifier value)": '2621000175106' from "SNOMEDCT" display 'Outpatient surgery service (qualifier value)'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Diagnosed With Atrial Fibrillation 365 Days Prior To Procedure":
  ["Diagnosis": "Atrial Fibrillation"] AFDiagnosis
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QP
      such that AFDiagnosis.prevalencePeriod starts 365 days or less on or before start of QP.QProcedure.relevantPeriod

define "Diagnosed With Cancer 365 Days Prior To Procedure":
  ["Diagnosis": "Cancer"] CancerDiagnosis
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QP
      such that CancerDiagnosis.prevalencePeriod starts 365 days or less on or before start of QP.QProcedure.relevantPeriod

define "Diagnosed With Coagulation Disorder 365 Days Prior To Procedure":
  ["Diagnosis": "Coagulation Disorder Conditions"] CoagulationDisorderDiagnosis
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QP
      such that CoagulationDisorderDiagnosis.prevalencePeriod starts 365 days or less on or before start of QP.QProcedure.relevantPeriod

define "Diagnosed With Excluded Conditions Within 90 Days Prior To The Index Admission":
  ( ["Diagnosis": "Malignant Neoplasm Complications Related To Hip and Knee Procedures"]
    union ["Diagnosis": "Mechanical Complications Related To Hip and Knee Procedures"]
    union ["Diagnosis": "Fracture Exclusions For Hip And Knee Procedures"] ) ExistingConditions
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QE
      such that ExistingConditions.prevalencePeriod starts 90 days or less on or before start of QE.QEncounter.relevantPeriod

define "Diagnosed With Renal Insufficiency 365 Days Prior To Procedure":
  ["Diagnosis": "Renal insufficiency"] RenalDiagnosis
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QP
      such that RenalDiagnosis.prevalencePeriod starts 365 days or less on or before start of QP.QProcedure.relevantPeriod

define "Encounter Related To Elective Primary THA and TKA Procedures With Age":
  "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QE
    with ["Patient Characteristic Birthdate"] PatientBirthday
      such that Global."CalendarAgeInYearsAt" ( PatientBirthday.birthDatetime, start of QE.QEncounter.relevantPeriod ) >= 18

define "Had Additional Surgery Within 35 Days Post-Procedure":
  ["Procedure, Performed": "General Surgery"] AdditionalProcedure
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QP
      such that AdditionalProcedure.relevantPeriod starts 35 days or less on or after start of QP.QProcedure.relevantPeriod

define "Had More Than 2 THA_TKA Procedures Codes During The Index Admission":
  "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QE
    where Count(("Primary THA-TKA Procedures"
        union "Non-Primary THA_TKA Procedures")Procedures
        where Procedures.relevantPeriod starts during QE.QEncounter.relevantPeriod
    )> 2

define "Had Multiple Blood Transfusion Procedures During The Index Admission":
  "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QE
    where Count(["Procedure, Performed": "Blood Transfusion Administration"] BTProcedure
        where BTProcedure.relevantPeriod starts during QE.QEncounter.relevantPeriod
    )> 1

define "Had Treatment of Hemorrhage or Hematoma During The Index Admission":
  ["Procedure, Performed": "Treatment of Hemorrhage or Hematoma"] Treatment
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QE
      such that Treatment.relevantPeriod starts during QE.QEncounter.relevantPeriod

define "Has Normal BMI":
  "Most Recent Documented BMI" BMIValue
    where BMIValue.result included in Interval[18.5 'kg/m2', 25 'kg/m2' )

define "Most Recent Documented BMI":
  Last(["Physical Exam, Performed": "Body mass index (BMI) [Ratio]"] LastBMI
      with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QualifyingEncounter
        such that(LastBMI.relevantPeriod starts 12 months or less on or before start of QualifyingEncounter.QEncounter.relevantPeriod
            or LastBMI.relevantPeriod starts during QualifyingEncounter.QEncounter.relevantPeriod
        )
          and LastBMI.result is not null
      sort by authorDatetime
  )

define "Non-Primary THA_TKA Procedures":
  ["Procedure, Performed": "Nonprimary Total Hip, Total Knee Replacement"] NonPrimaryProcedures
    where NonPrimaryProcedures.relevantPeriod starts during "Measurement Period"

define "Patient Encounters":
  ( ["Encounter, Performed": "Encounter Inpatient"]
    union ["Encounter, Performed": "Outpatient surgery service (qualifier value)"] ) Encounter
    where Encounter.relevantPeriod starts during "Measurement Period"

define "Postoperative Encounter Related To Major Bleeding 35 Days After Surgery":
  "Postoperative Encounter Related To Major Bleeding" MBEncounter
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QualifyingProcedure
      such that MBEncounter.relevantPeriod starts 35 days or less after start of QualifyingProcedure.QProcedure.relevantPeriod

define "Postoperative Encounter Related To Treatment of Hemorrhage or Hematoma 35 Days After Surgery":
  "Postoperative Encounter Related To Treatment of Hemorrhage or Hematoma" HHEncounter
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QualifyingProcedure
      such that HHEncounter.relevantPeriod starts 35 days or less after start of QualifyingProcedure.QProcedure.relevantPeriod

define "Primary THA-TKA Procedures":
  ["Procedure, Performed": "Total Hip, Total Knee Replacement"] PrimaryProcedure
    where PrimaryProcedure.relevantPeriod starts during "Measurement Period"

define "Qualifying Encounters Related To Elective Primary THA and TKA Procedures":
  from
    "Patient Encounters" Encounter,
    "Primary THA-TKA Procedures" Procedure
    where Procedure.relevantPeriod starts during Encounter.relevantPeriod
    return {
      QEncounter: Encounter,
      QProcedure: Procedure
    }

define "Transferred From Another Acute Care Facility or Discharged Against Medical Advice During Index Admission":
  "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QE
    where QE.QEncounter.admissionSource in "Transfer From Acute Care Hospital"
      or QE.QEncounter.dischargeDisposition in "Left Against Medical Advice"

define "Screened and Identified as Tobacco User":
  ( Last(["Assessment, Performed": "Tobacco Use Screening"] TobaccoUseScreening
      where TobaccoUseScreening.authorDatetime 24 months or less on or before
      end of "Measurement Period"
      sort by authorDatetime
  )) MostRecentTobaccoUseScreening
    where MostRecentTobaccoUseScreening.result in "Current Smoking Tobacco User"

define "Existing Comorbidities Prior To Surgery":
  ["Diagnosis": "Comorbidity Risk Factors"] Comorbidities
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QualifyingEncounter
      such that Comorbidities.prevalencePeriod starts 12 months or less on or before start of QualifyingEncounter.QEncounter.relevantPeriod

define "Reasonable Risk Factors":
  {
    AbnormalBMI: "Has Normal BMI" is null,
    TobacoUser: "Screened and Identified as Tobacco User" is not null,
    HadExistingComorbidities: "Existing Comorbidities Prior To Surgery"
  }

define "Postoperative Encounter Related To Major Bleeding":
  /***
  We only focus on postoperative follow-up visits to indicate that an evaluation and management service was performed during a postoperative period for a reason(s) related to the original procedure
  ***/
  ["Encounter, Performed": "Postoperative Visit"] PostoperativeEncounter
    with ( ["Diagnosis": "General Major Bleeding Events"]
      union ["Diagnosis": "Active Bleeding"] ) DiagnosisEvent
      such that DiagnosisEvent.prevalencePeriod starts during PostoperativeEncounter.relevantPeriod

define "Postoperative Encounter Related To Treatment of Hemorrhage or Hematoma":
  /***
  We only focus on postoperative follow-up visits to indicate that an evaluation and management service was performed during a postoperative period for a reason(s) related to the original procedure
  ***/
  ["Encounter, Performed": "Postoperative Visit"] PostoperativeEncounter
    with ["Procedure, Performed": "Treatment of Hemorrhage or Hematoma"] HHTreatment
      such that HHTreatment.relevantPeriod starts during PostoperativeEncounter.relevantPeriod

define "Received Anticoagulant Medication Injection Between 10-90 Days Prior To Surgery Date":
  ["Medication, Order": "Anticoagulant Medications, Injection"] AntiCoagulantMed
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QP
      such that AntiCoagulantMed.relevantPeriod starts during Interval[start of QP.QProcedure.relevantPeriod - 90 days, start of QP.QProcedure.relevantPeriod - 10 days]

define "Received Oral Anticoagulant Medications Between 10-90 Days Prior To Procedure":
  ["Medication, Order": "Anticoagulant Medications, Oral"] AntiCoagulantMed
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QP
      such that AntiCoagulantMed.relevantPeriod starts during Interval[start of QP.QProcedure.relevantPeriod - 90 days, start of QP.QProcedure.relevantPeriod - 10 days]
        and AntiCoagulantMed.supply.value > 1

define "Common Denominator Exclusions":
  exists "Transferred From Another Acute Care Facility or Discharged Against Medical Advice During Index Admission"
    or exists "Had More Than 2 THA_TKA Procedures Codes During The Index Admission"
    or exists "Diagnosed With Renal Insufficiency 365 Days Prior To Procedure"
    or exists "Diagnosed With Atrial Fibrillation 365 Days Prior To Procedure"
    or exists "Diagnosed With Cancer 365 Days Prior To Procedure"
    or exists "Received Anticoagulant Medication Injection Between 10-90 Days Prior To Surgery Date"
    or exists "Received Oral Anticoagulant Medications Between 10-90 Days Prior To Procedure"
    or exists "Diagnosed With Coagulation Disorder 365 Days Prior To Procedure"
    or exists "Diagnosed With Excluded Conditions Within 90 Days Prior To The Index Admission"
    or exists "Had Additional Surgery Within 35 Days Post-Procedure"

/* Bleeding-specific */
define "Diagnosed With Major Bleeding 30 Days Prior To The Index Admission":
  ["Diagnosis": "General Major Bleeding Events"] GMBEDiagnosis
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QE
      such that GMBEDiagnosis.prevalencePeriod starts 30 days or less before start of QE.QEncounter.relevantPeriod

define "Diagnosed With Major Bleeding During The Index Admission":
  ( ["Diagnosis": "General Major Bleeding Events"]
    union ["Diagnosis": "Active Bleeding"] ) MBDiagnosis
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QE
      such that MBDiagnosis.prevalencePeriod starts during QE.QEncounter.relevantPeriod

define "Bleeding Rate Denominator Exclusions":
    exists "Diagnosed With Major Bleeding 30 Days Prior To The Index Admission"

define "Bleeding Rate Numerator":
  exists "Diagnosed With Major Bleeding During The Index Admission"
    or exists "Postoperative Encounter Related To Major Bleeding 35 Days After Surgery"
    or exists "Had Treatment of Hemorrhage or Hematoma During The Index Admission"
    or exists "Postoperative Encounter Related To Treatment of Hemorrhage or Hematoma 35 Days After Surgery"
    or exists "Had Multiple Blood Transfusion Procedures During The Index Admission"
/* End Bleeding-specific*/

/* VTE-specific */
define "Diagnosed With VTE or DVT 30 Days Prior To The Index Admission":
  ( ["Diagnosis": "Venous Thromboembolism"]
    union ["Diagnosis": "Pulmonary Embolism or DVT"] ) VTEDiagnosis
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QE
      such that VTEDiagnosis.prevalencePeriod starts 30 days or less before start of QE.QEncounter.relevantPeriod

define "Diagnosed With VTE or DVT During The Index Admission":
  ( ["Diagnosis": "Venous Thromboembolism"]
    union ["Diagnosis": "Pulmonary Embolism or DVT"] ) DVTDiagnosis
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QE
      such that DVTDiagnosis.prevalencePeriod starts during QE.QEncounter.relevantPeriod

define "Diagnosed With VTE or DVT in the ED Within 35 Days Of The Surgery":
  ( ["Diagnosis": "Venous Thromboembolism"]
    union ["Diagnosis": "Pulmonary Embolism or DVT"] ) VTEDiagnosis
    with "ED Visit Within 35 Days Of The Surgery" EDVisit
      such that VTEDiagnosis.prevalencePeriod starts during EDVisit.relevantPeriod

define "Had 2 or More VTE Diagnosis Codes During Outpatient Visit Within 35 Days Of The Surgery":
  "Outpatient Care Visit Within 35 Days Of the Surgery" OV
    where Count((["Diagnosis": "Venous Thromboembolism"]
        union ["Diagnosis": "Pulmonary Embolism or DVT"])VTEDiagnosis
        where VTEDiagnosis.prevalencePeriod starts during OV.relevantPeriod
    )>= 2

define "ED Visit Within 35 Days Of The Surgery":
  Global."ED Encounter" EDVisit
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QP
      such that EDVisit.relevantPeriod ends 35 days or less after start of QP.QProcedure.relevantPeriod

define "Outpatient Care Visit Within 35 Days Of the Surgery":
  ["Encounter, Performed": "Hospital-based outpatient emergency care center (environment)"] OutpatientVisit
    with "Qualifying Encounters Related To Elective Primary THA and TKA Procedures" QP
      such that OutpatientVisit.relevantPeriod starts 35 days or less after QP.QProcedure.relevantPeriod

define "VTE Rate Denominator Exclusions":
    exists "Diagnosed With VTE or DVT 30 Days Prior To The Index Admission"

define "VTE Numerator":
  exists "Diagnosed With VTE or DVT During The Index Admission"
    or exists "Diagnosed With VTE or DVT in the ED Within 35 Days Of The Surgery"
    or exists "Had 2 or More VTE Diagnosis Codes During Outpatient Visit Within 35 Days Of The Surgery"
/* End VTE-specific*/

define "Initial Population":
  exists "Encounter Related To Elective Primary THA and TKA Procedures With Age"

define "Denominator":
  "Initial Population"
