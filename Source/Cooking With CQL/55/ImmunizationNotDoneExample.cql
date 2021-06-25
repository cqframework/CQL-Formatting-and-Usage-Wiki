library ImmunizationNotDoneExample

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include MATGlobalCommonFunctionsFHIR4 version '6.0.000' called Global

valueset "Influenza Vaccination Declined": 'urn:oid:2.16.840.1.113883.3.526.3.1255'
valueset "Influenza Vaccine": 'urn:oid:2.16.840.1.113883.3.526.3.1254'

valueset "Medical Reason": 'urn:oid:2.16.840.1.113883.3.526.3.1007'
valueset "Patient Reason": 'urn:oid:2.16.840.1.113883.3.526.3.1008'
valueset "System Reason": 'urn:oid:2.16.840.1.113883.3.526.3.1009'

/* Contains all codes in:
  http://cts.nlm.nih.gov/fhir/2.16.840.1.113762.1.4.1021.56
  http://cts.nlm.nih.gov/fhir/2.16.840.1.113762.1.4.1021.58
  http://cts.nlm.nih.gov/fhir/2.16.840.1.113883.3.526.3.1009
*/
valueset "Negation Reason Codes": 'http://hl7.org/fhir/us/qicore/ValueSet/qicore-negation-reason'

/*
2021 AU also has valueset "Medical Reason": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.473'
*/

parameter "Measurement Period" Interval<DateTime> default Interval[@2019-01-01T00:00:00.0, @2020-01-01T00:00:00.0)

context Patient

/*
CMS147 - Influenza Vaccination
QDM 5.5

define "Medical Patient or System Reason for Not Administering Influenza Vaccine":
  ["Immunization, Not Administered": "Influenza Vaccine"] NoFluVaccine
    where NoFluVaccine.authorDatetime during "Influenza Season Including August and September of the Prior Year"
      and ( NoFluVaccine.negationRationale in "Medical Reason"
          or NoFluVaccine.negationRationale in "Patient Reason"
          or NoFluVaccine.negationRationale in "System Reason"
          or NoFluVaccine.negationRationale in "Influenza Vaccination Declined"
      )

*/

/*
QDM-to-QICore Mapping
http://build.fhir.org/ig/HL7/fhir-qi-core/qdm-to-qicore.html#8131-immunization-administered
NOTE: This is referencing the CI build as this mapping has changes in the latest version
*/

/*
Negation in QI-Core
http://build.fhir.org/ig/HL7/fhir-qi-core/index.html#negation-in-qi-core

Two patterns:
* Absence of evidence for a particular event
* Documentation of an event not occurring, together with a specific reason

Immunization Not Done
http://build.fhir.org/ig/HL7/fhir-qi-core/StructureDefinition-qicore-immunizationnotdone.html

Following the negation rationale pattern:
*/

define "Medical Patient or System Reason for Not Administering Influenza Vaccine":
  [Immunization: "Influenza Vaccine"] NoFluVaccine
    where NoFluVaccine.recorded during "Influenza Season Including August and September of the Prior Year"
      and NoFluVaccine.status = 'not-done'
      and (
        NoFluVaccine.statusReason in "Medical Reason"
          or NoFluVaccine.statusReason in "Patient Reason"
          or NoFluVaccine.statusReason in "System Reason"
          or NoFluVaccine.statusReason in "Influenza Vaccination Declined"
      )

/*
What's happening underneath:
*/

define "Influenza Vaccine Not Administered":
  [Immunization] I
    where I.vaccineCode in "Influenza Vaccine"
      or ToValueSet(Global.GetBaseExtension(I.vaccineCode, 'valueset-reference').value as FHIR.uri) = "Influenza Vaccine"

define function ToValueSet(uri FHIR.uri):
  System.ValueSet { id: uri.value }


/*
CMS147 Supporting Definitions
*/

define "Influenza Season":
  Interval[start of "Measurement Period" - 3 months, start of "Measurement Period" + 3 months )

define "Influenza Season Including August and September of the Prior Year":
  Interval[start of "Measurement Period" - 5 months, start of "Measurement Period" + 3 months )
