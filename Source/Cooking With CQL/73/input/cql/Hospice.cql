library Hospice version '6.4.000'

/*
This content is a work in progress and should not be considered a final specification
or recommendation for guidance. Tests are available for this content.
*/

using QICore version '4.1.1'

include FHIRHelpers version '4.2.000' called FHIRHelpers
include QICoreCommon version '1.3.000' called QICoreCommon
include CQMCommon version '1.1.000' called CQMCommon
include StatusFHIR version '1.0.0' called Status

codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMEDCT": 'http://snomed.info/sct'
codesystem "ObservationCategoryCodes": 'http://terminology.hl7.org/CodeSystem/observation-category'

valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'
valueset "Hospice Care Ambulatory": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1584' 
valueset "Hospice Encounter": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1003'

code "Discharge to healthcare facility for hospice care (procedure)": '428371000124100' from "SNOMEDCT" display 'Discharge to healthcare facility for hospice care (procedure)'
code "Discharge to home for hospice care (procedure)": '428361000124107' from "SNOMEDCT" display 'Discharge to home for hospice care (procedure)'
code "Hospice care [Minimum Data Set]": '45755-6' from "LOINC" display 'Hospice care [Minimum Data Set]'
code "Yes (qualifier value)": '373066001' from "SNOMEDCT" display 'Yes (qualifier value)'

parameter "Measurement Period" Interval<DateTime>
    default Interval[@2023-01-01T00:00:00.000Z, @2024-01-01T00:00:00.000Z) 

context Patient

define "Has Hospice Services":
exists ((Status."Finished Encounter"([Encounter: "Encounter Inpatient"])) InpatientEncounter
      where ( InpatientEncounter.hospitalization.dischargeDisposition ~ "Discharge to home for hospice care (procedure)"
            or InpatientEncounter.hospitalization.dischargeDisposition ~ "Discharge to healthcare facility for hospice care (procedure)"
        )
        and QICoreCommon."ToInterval"(InpatientEncounter.period) ends during day of "Measurement Period"
        )
    or exists ( (Status."Finished Encounter"([Encounter: "Hospice Encounter"])) HospiceEncounter
        where QICoreCommon."ToInterval"(HospiceEncounter.period) overlaps "Measurement Period" 
    )
    or exists ((Status."Final Survey Observation"([Observation: "Hospice care [Minimum Data Set]"])) HospiceAssessment
        where HospiceAssessment.value ~ "Yes (qualifier value)"
        and QICoreCommon."ToInterval" ( HospiceAssessment.effective ) overlaps "Measurement Period" 
    )
    or exists ( (Status."Completed or Ongoing Service Request"([ServiceRequest: "Hospice Care Ambulatory"])) HospiceOrder
        where QICoreCommon."ToInterval" ( HospiceOrder.authoredOn ) during day of "Measurement Period" 
    )    
    or exists ((Status."Completed Procedure"([Procedure: "Hospice Care Ambulatory"])) HospicePerformed
       where QICoreCommon."ToInterval"( HospicePerformed.performed ) overlaps "Measurement Period"
    )
