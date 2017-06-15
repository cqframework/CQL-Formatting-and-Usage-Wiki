/*
  ACO 38 - Risk-Standardized Acute Admission Rates for Patients With Multiple Chronic Conditions
  https://www.cms.gov/Medicare/Medicare-Fee-for-Service-Payment/sharedsavingsprogram/Downloads/ACO-38.pdf

  We would like to place a Count >=2 operation around the patient having a chronic condition from some menu.
  For each chronic condition, a patient might qualify through one of the following:

    Diagnosis: X starts before Measurement Period
    Count >=2 Encounter, Performed: Outpatient visit (diagnosis: X) during Measurement Period
    Count >=1 Encounter, Performed: Inpatient visit (principal diagnosis or diagnosis: x) during Measurement Period

  Similarly, we were hoping to model a measure that looks for a logical "AND" between elements
  that you can't do in today's MAT.  Risk adjustment variables cannot currently contain logical operations.
  So, as our example, we want to create a risk-adjustment variable that identifies whether the patient meets
  these criteria:

    <59 years old
    >=50 years old
    Female
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
