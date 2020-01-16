library MedicationsNotDocumented

/*
EXM68 - Medications Not Documented
*/

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0'
include MATGlobalCommonFunctions_FHIR4 version '4.0.000' called Global

codesystem "LOINC": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.6.1'
codesystem "SNOMEDCT": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.6.96'

valueset "Ethnicity": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.837'
valueset "Medical or Other reason not done": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1.1502'
valueset "Medications Encounter Code Set": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.600.1.1834'
valueset "ONC Administrative Sex": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1'
valueset "Payer": 'http://cts.nlm.nih.gov/fhir/ValueSet/oid:2.16.840.1.114222.4.11.3591'
valueset "Race": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.836'

code "Birth date": '21112-8' from "LOINC" display 'Birth date'
code "Documentation of current medications (procedure)": '428191000124101' from "SNOMEDCT" display 'Documentation of current medications (procedure)'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
In STU3, the Procedure resource has a notDone element, this should be used in STU3.
In R4, the Procedure resource has a status of not-done, and you would use the statusReason as the "not done reason"
*/

define "Medications Not Documented for Medical Reason - STU3":
	["Procedure": "Documentation of current medications (procedure)"] DocumentationNotPerformed
		where DocumentationNotPerformed.status = 'completed'
      and DocumentationNotPerformed.notDone is true
  		and DocumentationNotPerformed.notDoneReason in "Medical or Other reason not done"

define "Medications Not Documented for Medical Reason - R4":
	["Procedure": "Documentation of current medications (procedure)"] DocumentationNotPerformed
		where DocumentationNotPerformed.status = 'not-done'
      and DocumentationNotPerformed.statusReason in "Medical or Other reason not done"

/*
In STU3, there is no base element to establish when the procedure not done was documented.
In R4, the extension qicore-recorded is introduced and used on the QICoreProcedureNotDone profile.
This extension would need to be added for STU3 if we need to support this.
The alternative is to use the FHIR Provenance, but that would look like:
Global.GetProvenance(MedicationsNotDocumented).recorded
*/

define "Denominator Exceptions":
	"Qualifying Encounters During Measurement Period" EncounterDuringMeasurementPeriod
		with "Medications Not Documented for Medical Reason - R4" MedicationsNotDocumented
      such that Global.GetExtension(MedicationsNotDocumented, 'qicore-recorded').value during EncounterDuringMeasurementPeriod.period
			//such that MedicationsNotDocumented.FHIR.provenance.recorded during EncounterDuringMeasurementPeriod.period
  			//unsure what attribute should be used to incorporate timing of negation to reflect it occurred during the Encoutner.
  			//FHIR.provenance.recorded is what's listed in the table on http://hl7.org/fhir/us/qicore/Procedure.html//

// NOTE: Testing use only
define "Qualifying Encounters During Measurement Period":
  ["Encounter"]
