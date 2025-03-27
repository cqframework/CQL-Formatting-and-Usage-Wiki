library VTE version '8.13.000'


using QICore version '6.0.0'

include FHIRHelpers version '4.4.000' called FHIRHelpers
include CQMCommon version '4.0.000' called CQMCommon

valueset "Obstetrical or Pregnancy Related Conditions": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.263' 
valueset "Obstetrics VTE": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.264'
valueset "Venous Thromboembolism": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.279' 

parameter "Measurement Period" Interval<DateTime>

context Patient

  
define "Initial Population":
"Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions"

define "Admission Without VTE Or Obstetrical Conditions":
  CQMCommon."Inpatient Encounter" InpatientEncounter
   where not (exists ((InpatientEncounter.encounterDiagnosis()) EncDx 
                    where ( EncDx.code in "Obstetrical or Pregnancy Related Conditions"
                         or EncDx.code in "Venous Thromboembolism"
                         or EncDx.code in "Obstetrics VTE")
                    )
            )


define "Encounter With Age Range And Without VTE Diagnosis Or Obstetrical Conditions":
 ( CQMCommon."Inpatient Encounter" InpatientEncounter
     where AgeInYearsAt(date from start of InpatientEncounter.period) >= 18 )
    intersect "Admission Without VTE Or Obstetrical Conditions"