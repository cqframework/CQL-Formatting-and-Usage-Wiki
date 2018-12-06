/*
  ACO 38 - Risk-Standardized Acute Admission Rates for Patients With Multiple Chronic Conditions
  https://www.cms.gov/Medicare/Medicare-Fee-for-Service-Payment/sharedsavingsprogram/Downloads/ACO-38.pdf

  We would like to place a Count >=2 operation around the patient having a chronic condition from some menu.
  For each chronic condition, a patient might qualify through one of the following:

    Diagnosis: X starts before Measurement Period
    Count >=2 Encounter, Performed: Outpatient visit (diagnosis: X) during Measurement Period
    Count >=1 Encounter, Performed: Inpatient visit (principal diagnosis or diagnosis: x) during Measurement Period

*/

/* 
For counts of diagnoses, we want to count "diagnoses", but we want some flexibility on
what we consider a "diagnosis", over and above just a QDM diagnosis
*/

/*
The simplest case is just a diagnosis that starts before the Measurement Period:
*/

define "AMI Diagnosis Prior to Measurement Period":
  ["Diagnosis": "AMI"] D
    where D.prevalencePeriod starts before start of "Measurement Period"
    
/*
Let's consider the last case next, at least one inpatient visit where the diagnosis 
is either the principal diagnosis, or among the diagnoses on the encounter:
*/

define "Inpatient Visits With AMI Diagnosis":
  ["Encounter, Performed": "Inpatient"] I
    where I.relevantPeriod during "Measurement Period"
      and I.principalDiagnosis in "AMI"
      or exists (I.diagnoses D where D.code in "AMI")
      
define "First Inpatient Visit With AMI Diagnosis":
  "Inpatient Visits With AMI Diagnosis" D
    where D ~ First("Inpatient Visits With AMI Diagnosis")

/*
Now let's consider the final case, where we want at least two outpatient encounters
where the diagnosis is among the diagnoses on the encounter:
*/

define "Outpatient Visits With AMI Diagnosis":
  ["Encounter, Performed": "Outpatient"] O
    where O.relevantPeriod during "Measurement Period"
      and exists (O.diagnoses D where D.code in "AMI")
    
define "First Of At Least Two Outpatient Visits With AMI Diagnosis":
  "Outpatient Visits With AMI Diagnosis" O
    where O ~ First("Outpatient Visits With AMI Diagnosis")
      and Count("Outpatient Visits With AMI Diagnosis") >= 2
      
/*
Now these expressions can be used in a "diagnosis" union to describe "qualifying diagnoses":
*/

define "Qualifying Diagnoses":
  "AMI Diagnosis Prior To Measurement Period"
    union "First Inpatient Visit With AMI Diagnosis"
    union "First Of At Least Two Outpatient Visits With AMI Diagnosis"
    
define "Has At Least 2 Qualifying Diagnoses":
  Count("Qualifying Diagnoses") >= 2

/*
Applying these patterns to the below proposed QDM is left as an exercise for the reader:
*/

/*
  Proposed QDM:

  Denominator
    AND: Initial Population
    AND: Count>= 2 : Union of:
      Intersection of:
        "Diagnosis: ACO 38 AMI" >= 1 year(s) starts before start of "Measurement Period"
        Union of:
          Count>= 1 : Union of:
            "Encounter, Performed: Encounter Inpatient (diagnosis: ACO 38 AMI)"
            "Encounter, Performed: Encounter Inpatient (principal diagnosis: ACO 38 AMI)"
            <= 1 year(s) starts before end of "Measurement Period"
      Intersection of:
        "Diagnosis: ACO 38 CKD" >= 2 year(s) starts before start of "Measurement Period"
        Union of:
          Count>= 1 : Union of:
            "Encounter, Performed: Encounter Inpatient (diagnosis: ACO 38 CKD)"
            "Encounter, Performed: Encounter Inpatient (principal diagnosis: ACO 38 CKD)"
            <= 1 year(s) starts before end of "Measurement Period"
          Count>= 2 : "Encounter, Performed: Adult Outpatient Visit (diagnosis: ACO 38 CKD)" <= 1 year(s) starts before end of "Measurement Period"
      Intersection of:
        "Diagnosis: ACO 38 Atrial Fibrillation" >= 1 year(s) starts before start of "Measurement Period"
        Union of:
          Count>= 1 : Union of:
            "Encounter, Performed: Encounter Inpatient (diagnosis: ACO 38 Atrial Fibrillation)"
            "Encounter, Performed: Encounter Inpatient (principal diagnosis: ACO 38 Atrial Fibrillation)"
            <= 1 year(s) starts before end of "Measurement Period"
          Count>= 2 : "Encounter, Performed: Adult Outpatient Visit (diagnosis: ACO 38 Atrial Fibrillation)" <= 1 year(s) starts before end of "Measurement Period"
      Intersection of:
        "Diagnosis: ACO 38 COPD and asthma" >= 1 year(s) starts before start of "Measurement Period"
        Union of:
          Count>= 1 : Union of:
            "Encounter, Performed: Encounter Inpatient (diagnosis: ACO 38 COPD and asthma)"
            "Encounter, Performed: Encounter Inpatient (principal diagnosis: ACO 38 COPD and asthma)"
            <= 1 year(s) starts before end of "Measurement Period"
          Count>= 2 : "Encounter, Performed: Adult Outpatient Visit (diagnosis: ACO 38 COPD and asthma)" <= 1 year(s) starts before end of "Measurement Period"
      Intersection of:
        "Diagnosis: ACO 38 Alzheimer's or senior dementia" >= 3 year(s) starts before start of "Measurement Period"
        Union of:
          Count>= 1 : Union of:
            "Encounter, Performed: Encounter Inpatient (diagnosis: ACO 38 Alzheimer's or senior dementia)"
            "Encounter, Performed: Encounter Inpatient (principal diagnosis: ACO 38 Alzheimer's or senior dementia)"
            "Encounter, Performed: Adult Outpatient Visit (diagnosis: ACO 38 Alzheimer's or senior dementia)"
            <= 1 year(s) starts before end of "Measurement Period"
      Intersection of:
        "Diagnosis: ACO 38 Depression" >= 1 year(s) starts before start of "Measurement Period"
        Union of:
          Count>= 1 : Union of:
            "Encounter, Performed: Encounter Inpatient (diagnosis: ACO 38 Depression)"
            "Encounter, Performed: Encounter Inpatient (principal diagnosis: ACO 38 Depression)"
            "Encounter, Performed: Adult Outpatient Visit (diagnosis: ACO 38 Depression)"
            <= 1 year(s) starts before end of "Measurement Period"
      Intersection of:
        "Diagnosis: ACO 38 Heart failure" >= 2 year(s) starts before start of "Measurement Period"
        Union of:
          Count>= 1 : Union of:
            "Encounter, Performed: Encounter Inpatient (diagnosis: ACO 38 Heart failure)"
            "Encounter, Performed: Encounter Inpatient (principal diagnosis: ACO 38 Heart failure)"
            "Encounter, Performed: Adult Outpatient Visit (diagnosis: ACO 38 Heart failure)"
            <= 1 year(s) starts before end of "Measurement Period"
      Intersection of:
        "Diagnosis: ACO 38 Stroke and transient ischemic attack" >= 1 year(s) starts before start of "Measurement Period"
        Union of:
          Count>= 1 : Union of:
            "Encounter, Performed: Encounter Inpatient (diagnosis: ACO 38 Stroke and transient ischemic attack)"
            "Encounter, Performed: Encounter Inpatient (principal diagnosis: ACO 38 Stroke and transient ischemic attack)"
            <= 1 year(s) starts before end of "Measurement Period"
          Count>= 2 : "Encounter, Performed: Adult Outpatient Visit (diagnosis: ACO 38 Stroke and transient ischemic attack)" <= 1 year(s) starts before end of "Measurement Period"
*/
