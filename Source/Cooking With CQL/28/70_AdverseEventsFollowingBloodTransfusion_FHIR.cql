library AdverseEventsFollowingBloodTransfusion_FHIR

using FHIR version '3.0.0'

parameter "Measurement Period" Interval<DateTime>

/*
Blood transfusion event
*/

define "Blood Transfusion Procedure":
  ["Procedure": "Blood Transfusion"] P
    where P.performed ends during "Measurement Period"
      and P.status = 'completed'

/*
CHF Diagnosis
*/

define "CHF Diagnosis":
  ["Condition": "CHF"] C
    where C.clinicalStatus = 'active'
      and C.verificationStatus = 'confirmed'

/*
Chest X-ray
*/

define "Chest X-ray Procedure":
  ["Procedure": "Chest X-ray"] P
    where P.status = 'completed'

/*
Reduced pulse oximetry
*/

define "Reduced Pulse Oximetry":
  ["Observation": "Oxygen Saturation"] P // Using LOINC 59408-5 
    where P.status in { 'final', 'amended' }
      and P.value < 90 '%'

/*
Adverse event within 24 hours of blood transfusion
*/

define "Adverse Event within 24 Hours of Blood Transfusion":
  "Blood Transfusion Procedure" P
    with (
        "CHF Diagnosis"
          union "Chest X-ray Procedure"
          union "Reduced Pulse Oximetry"
    ) E
      such that E.onset starts 24 hours or less after end of P.relevantPeriod
        or E.effective starts 24 hours or less after end of P.relevantPeriod
        or E.performed starts 24 hours or less after end of P.relevantPeriod


