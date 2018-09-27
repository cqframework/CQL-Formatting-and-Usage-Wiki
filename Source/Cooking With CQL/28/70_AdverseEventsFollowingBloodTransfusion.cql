library AdverseEventsFollowingBloodTransfusion

using QDM version '5.3'

parameter "Measurement Period" Interval<DateTime>

/*
Blood transfusion event
*/

define "Blood Transfusion Procedure":
  ["Procedure, Performed": "Blood Transfusion"] P
    where P.relevantPeriod ends during "Measurement Period"

/*
CHF Diagnosis
*/

define "CHF Diagnosis":
  ["Diagnosis": "CHF"]

/*
Chest X-ray
*/

define "Chest X-ray Procedure":
  ["Procedure, Performed": "Chest X-ray"]

/*
Reduced pulse oximetry
*/

define "Reduced Pulse Oximetry":
  ["Physical Exam, Performed": "Oxygen Saturation"] P
    where P.result < 90 '%'
    
/*
Adverse Events
Potentially could use adverse event, but there are terminology questions here
*/

define "Adverse Events":
  ["Adverse Event"]

/*
Adverse event within 24 hours of blood transfusion
*/

define "Indicators of an Adverse Event within 24 Hours of Blood Transfusion":
  "Blood Transfusion Procedure" P
    with (
        "CHF Diagnosis"
          union "Chest X-ray Procedure"
          union "Reduced Pulse Oximetry"
    ) E
      such that E.prevalencePeriod starts 24 hours or less after end of P.relevantPeriod
        or E.relevantPeriod starts 24 hours or less after end of P.relevantPeriod


