library RegionalAnesthesia version '0.1.002'

using QDM version '5.3'

include MATGlobalCommonFunctions version '2.0.000' called Global

include VTEICU version '2.4.000' called THKR

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'
codesystem "SNOMEDCT:2018-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2018-03'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1' 
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836' 
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837' 
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591' 
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307' 
valueset "Malignant Neoplasm of bone of lower Limb, pelvis, sacrum, coccyx": 'urn:oid:2.16.840.1.113762.1.4.1029.72' 
valueset "Mechanical Complications of hip and knee prosthetic devices": 'urn:oid:2.16.840.1.113762.1.4.1029.75' 
valueset "Regional Anesthesia": 'urn:oid:2.16.840.1.113762.1.4.1029.68' 
valueset "Partial hip and partial knee replacements": 'urn:oid:2.16.840.1.113762.1.4.1029.79' 
valueset "Patient Refusal": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.93' 
valueset "Principal": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.14' 
valueset "Removal of implanted device/prostheses from hip/knee": 'urn:oid:2.16.840.1.113762.1.4.1029.83' 
valueset "Revision and Resurfacing Procedures of Hip & Knee": 'urn:oid:2.16.840.1.113762.1.4.1029.87' 
valueset "Spinal Fusion": 'urn:oid:2.16.840.1.113762.1.4.1029.100' 
valueset "Medical Reason Excluding Clinical Trial": 'urn:oid:2.16.840.1.113762.1.4.1029.113' 
valueset "Total Hip Replacement": 'urn:oid:2.16.840.1.113762.1.4.1029.91' 
valueset "Total Hip, Total Knee Replacement": 'urn:oid:2.16.840.1.113762.1.4.1029.96' 
valueset "Total Knee Replacement": 'urn:oid:2.16.840.1.113762.1.4.1029.95' 

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'
code "Postoperative anesthesia care unit (environment)": '398161000' from "SNOMEDCT:2018-03" display 'Postoperative anesthesia care unit (environment)'
code "Principal (qualifier value)": '63161005' from "SNOMEDCT:2018-03" display 'Principal (qualifier value)'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity":
	["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer":
	["Patient Characteristic Payer": "Payer"]

define "SDE Race":
	["Patient Characteristic Race": "Race"]

define "SDE Sex":
	["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Total Replacements Without Malignancy Or Mechanical Complications Diagnoses":
	"Total Hip Total Knee Principal Procedure Ages Greater Than Or Equal To 18" QualifyingEncounters
		with QualifyingEncounters.diagnoses QualifyingEncountersDiagnosis
			such that QualifyingEncountersDiagnosis not in "Malignant Neoplasm of bone of lower Limb, pelvis, sacrum, coccyx"
				and QualifyingEncountersDiagnosis not in "Mechanical Complications of hip and knee prosthetic devices"

define "PACU Discharges":
	"Total Hip Total Knee Principal Procedure Ages Greater Than Or Equal To 18" QualifyingEncounters
		where exists ( QualifyingEncounters.facilityLocations Locations
				where Locations.code = "Postoperative anesthesia care unit (environment)"
					and Locations.locationPeriod during QualifyingEncounters.relevantPeriod
		)

define "No Regional Anesthesia Due to Patient Refusal or Medical Reason 2":
	["Procedure, Not Performed": "Regional Anesthesia"] NoRegionalAnesthesia
		where NoRegionalAnesthesia.negationRationale in "Patient Refusal"
			or NoRegionalAnesthesia.negationRationale in "Medical Reason Excluding Clinical Trial"

define "Numerator":
	"Regional Anesthesia 60 Minutes Prior To or During Total Hip Total Knee Replacement"

define "Denominator Exclusions":
	"History of Spinal Fusion"

define "Initial Population":
	"Total Hip Total Knee Replacements Without Concurrent Procedures or Malignancy or Mechanical Complications"

define "Denominator":
	"Initial Population"

define "Encounters Ages Greater Than Or Equal To 18":
	Global."Inpatient Encounter" InpatientEncounter
		with ["Patient Characteristic Birthdate"] BirthDate
			such that Global."CalendarAgeInYearsAt"(BirthDate.birthDatetime, start of InpatientEncounter.relevantPeriod)>= 18

define "Total Hip and Total Knee As Principal Procedure":
	["Procedure, Performed": "Total Hip, Total Knee Replacement"] TotalHipTotalKneeProcedures
		with "Encounters Ages Greater Than Or Equal To 18" QualifyingEncounters
			such that TotalHipTotalKneeProcedures.relevantPeriod starts during Interval[start of TotalHipTotalKneeProcedures.relevantPeriod - 48 hours, end of QualifyingEncounters.relevantPeriod]
		where TotalHipTotalKneeProcedures.ordinality = "Principal (qualifier value)"

define "Proposed Total Hip and Knee Procedure with Age 18":
	"Encounters Ages Greater Than Or Equal To 18" QualifyingEncounters
		let TotalHipTotalKneeProcedures: ( ["Procedure, Performed": "Total Hip, Total Knee Replacement"] TotalHipTotalKneeProcedures
				where TotalHipTotalKneeProcedures.relevantPeriod starts during Interval[start of QualifyingEncounters.relevantPeriod - 48 hours, end of QualifyingEncounters.relevantPeriod]
					and TotalHipTotalKneeProcedures.ordinality = "Principal (qualifier value)"
		)
		return {
			id: QualifyingEncounters.id,
			EncounterRelevantPeroid: QualifyingEncounters.relevantPeriod,
			ProcedureRelevantPeriod: TotalHipTotalKneeProcedures.relevantPeriod
		}

define "Total Hip Total Knee Replacements Without Concurrent Procedures or Malignancy or Mechanical Complications":
	"Total Replacements Where No Concurrent Procedures Performed"
		union "Total Replacements Without Malignancy Or Mechanical Complications Diagnoses"

define "Total Hip Total Knee Principal Procedure Ages Greater Than Or Equal To 18":
	"Encounters Ages Greater Than Or Equal To 18" QualifyingEncounters
		where "Total Hip Total Knee Procedure"(QualifyingEncounters).ordinality in "Principal"

define "Total Replacements Where No Concurrent Procedures Performed":
	"Total Hip Total Knee Principal Procedure Ages Greater Than Or Equal To 18" QualifyingEncounters
		without ( ["Procedure, Performed": "Partial hip and partial knee replacements"]
			union ["Procedure, Performed": "Removal of implanted device/prostheses from hip/knee"]
			union ["Procedure, Performed": "Revision and Resurfacing Procedures of Hip & Knee"] ) PartialOrRemovalProcedures
			such that PartialOrRemovalProcedures.relevantPeriod starts during Interval[start of QualifyingEncounters.relevantPeriod - 48 hours, end of QualifyingEncounters.relevantPeriod]

/*
This definition gives the following error:

Error: Interval type expected.
*/

/* define "History of Spinal Fusion":
	"Encounters Ages Greater Than Or Equal To 18" QualifyingEncounters
		let Procedure: "Total Hip Total Knee Procedure"(QualifyingEncounters)
		with ["Procedure, Performed": "Spinal Fusion"] HistoryOfSpinalFusion
			such that Procedure.ordinality in "Principal"
			  and HistoryOfSpinalFusion.relevantPeriod starts before start of Procedure.relevantPeriod */
				
/*
The problem is that the reference to Procedure.relevantPeriod doesn't work
because the function "Total Hip Total Knee Procedure" returns a list of procedures,
not a single procedure.
*/

/*
So the fix is to either:

1) change the function to return a single procedure (using First, Last, or SingletonFrom)
or
2) change the History of Spinal Fusion expression to consider the possibility of multiple procedures:
*/
			
define "History of Spinal Fusion":
  "Encounters Ages Greater Than Or Equal To 18" QualifyingEncounters
	  where exists (
			("Total Hip Total Knee Procedure"(QualifyingEncounters)) Procedure
			  with ["Procedure, Performed": "Spinal Fusion"] HistoryOfSpinalFusion
				  such that Procedure.ordinality in "Principal"
					  and HistoryOfSpinalFusion.relevantPeriod starts before start of Procedure.relevantPeriod
		)

define "Regional Anesthesia 60 Minutes Prior To or During Total Hip Total Knee Replacement":
	"Total Hip Total Knee Principal Procedure Ages Greater Than Or Equal To 18" TotalHipTotalKneeProcedures
		with ["Procedure, Performed": "Regional Anesthesia"] RegionalAnesthesia
			such that RegionalAnesthesia.relevantPeriod starts during Interval[start of TotalHipTotalKneeProcedures.relevantPeriod - 60 minutes, end of TotalHipTotalKneeProcedures.relevantPeriod]

define function "Total Hip Total Knee Procedure"(Encounter "Encounter, Performed" ):
	["Procedure, Performed": "Total Hip, Total Knee Replacement"] TotalHipTotalKneeProcedures
		with Encounter QualifyingEncounters
			such that TotalHipTotalKneeProcedures.relevantPeriod starts during Interval[start of QualifyingEncounters.relevantPeriod - 48 hours, end of QualifyingEncounters.relevantPeriod]

