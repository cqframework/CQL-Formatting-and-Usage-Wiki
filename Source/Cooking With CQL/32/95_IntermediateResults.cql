library IntermediateResults

/*
This example is based on CMS53v7 - Primary PCI Received Within 90 Minutes of Hospital Arrival
The example illustrates calculation of intermediate results within a query
*/

using QDM version '5.3'

include MATGlobalCommonFunctions version '2.0.000' called Global

codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'

valueset "Acute or Evolving MI": 'urn:oid:2.16.840.1.113883.3.666.5.3022'
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Fibrinolytic Therapy": 'urn:oid:2.16.840.1.113883.3.666.5.736'
valueset "PCI": 'urn:oid:2.16.840.1.113762.1.4.1045.67'
valueset "Electrocardiogram (ECG)": 'urn:oid:2.16.840.1.113883.3.666.5.735'

code "Birthdate": '21112-8' from "LOINC" display 'Birth date'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
	"Initial Population" QualifyingEncounter
		let FirstPCI: First("PCI Procedure" FirstPCI
				where FirstPCI.relevantPeriod starts on or after Global."Hospital Arrival Time"(QualifyingEncounter)
				sort by start of relevantPeriod
		)
		with "Diagnostic Electrocardiogram" ECG
			such that ECG.relevantPeriod starts during Global."Hospitalization"(QualifyingEncounter)
				or ECG.relevantPeriod starts 1 hour or less on or before Global."Hospital Arrival Time"(QualifyingEncounter)
		where FirstPCI.relevantPeriod starts 1440 minutes or less on or after Global."Hospital Arrival Time"(QualifyingEncounter)
			and not exists ( "Fibrinolytic" FibrinolyticTherapy
					where FibrinolyticTherapy.relevantPeriod starts after Global."Hospital Arrival Time"(QualifyingEncounter)
						and FibrinolyticTherapy.relevantPeriod starts before start of FirstPCI.relevantPeriod
			)

/*
NOTE: During the call the question was asked whether the ECG such that criteria 
that looks for events prior to hospital arrival is correct. We pursued this question 
with the measure developers and confirmed the measure intent is looking for ECGs that
may have occurred prior to Hospital Arrival:
https://oncprojectracking.healthit.gov/support/browse/CQM-3500
*/
      
define "Initial Population":
	"Inpatient Encounters"
		intersect "AMI Encounter"
    
define "Inpatient Encounters":
	["Encounter, Performed": "Encounter Inpatient"] Encounter
		where Global."LengthInDays"(Encounter.relevantPeriod)<= 120
			and Encounter.relevantPeriod ends during "Measurement Period"
      
define "AMI Encounter":
	["Encounter, Performed": "Encounter Inpatient"] Encounter
		with ["Patient Characteristic Birthdate": "Birthdate"] BirthDate
			such that Global.CalendarAgeInYearsAt(BirthDate.birthDatetime, start of Encounter.relevantPeriod)>= 18
				and Encounter.principalDiagnosis in "Acute or Evolving MI"
        
define "PCI Procedure":
	["Procedure, Performed": "PCI"]
  
define "Diagnostic Electrocardiogram":
	["Diagnostic Study, Performed": "Electrocardiogram (ECG)"]
  
define "Fibrinolytic":
	["Medication, Administered": "Fibrinolytic Therapy"]
