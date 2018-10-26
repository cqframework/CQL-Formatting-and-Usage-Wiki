library HospitalizationAdmissionSource version '7.3.012'

/*
This example is drawn from an adjusted version of AMI8a/CMS53
For more discussion see [CQLIT-136](https://oncprojectracking.healthit.gov/support/browse/CQLIT-136)
*/

using QDM version '5.4'

include MATGlobalCommonFunctions version '3.0.000' called Global

valueset "Acute or Evolving MI": 'urn:oid:2.16.840.1.113883.3.666.5.3022'
valueset "Ambulatory surgical center": 'urn:oid:2.16.840.1.113883.3.666.5.687'
valueset "Aortic balloon pump insertion": 'urn:oid:2.16.840.1.113883.3.666.5.1151'
valueset "Cardiopulmonary arrest": 'urn:oid:2.16.840.1.113883.3.666.5.748'
valueset "Electrocardiogram (ECG)": 'urn:oid:2.16.840.1.113883.3.666.5.735'
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Endotracheal Intubation": 'urn:oid:2.16.840.1.113762.1.4.1045.69'
valueset "Fibrinolytic Therapy": 'urn:oid:2.16.840.1.113883.3.666.5.736'
valueset "PCI": 'urn:oid:2.16.840.1.113762.1.4.1045.67'
valueset "Transfer From Emergency Department (ED) Locations": 'urn:oid:2.16.840.1.113883.3.666.5.3006'
valueset "Transfer From Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.3013'
valueset "Transfer From Outpatient": 'urn:oid:2.16.840.1.113883.3.67.1.101.950'
valueset "Ventricular Assist Device placement": 'urn:oid:2.16.840.1.113883.3.666.5.3015'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
The current definition for Denominator Exclusions considers admission source 
from the Denominator encounter
*/

define "Denominator Exclusions":
	"Denominator" DenominatorEncounter
		where DenominatorEncounter.admissionSource in "Ambulatory surgical center"
			or DenominatorEncounter.admissionSource in "Transfer From Outpatient"
			or DenominatorEncounter.admissionSource in "Transfer From Emergency Department (ED) Locations"
			or DenominatorEncounter.admissionSource in "Transfer From Inpatient"


/*
Because the admissionSource attribute is checked on the Inpatient Encounter, the
exclusions do not consider admissionSource coming from the Emergency Department Visit
but the measure intent was that those should count as an exclusion as well.

One approach to this is to define a RelatedEDVisit, similar to other measures that
use this, and then use a local definition to test for the exclusion criteria in
either the Inpatient Encounter, or the Related ED Visit:
*/
define "Denominator Exclusions":
	"Denominator" Encounter
		let EDVisit: RelatedEDVisit(Encounter)
		where Encounter.admissionSource in "Ambulatory surgical center"
			or Encounter.admissionSource in "Transfer From Outpatient"
			or Encounter.admissionSource in "Transfer From Emergency Department (ED) Locations"
			or Encounter.admissionSource in "Transfer From Inpatient"
			or EDVisit.admissionSource in "Ambulatory surgical center"
			or EDVisit.admissionSource in "Transfer From Outpatient"
			or EDVisit.admissionSource in "Transfer From Emergency Department (ED) Locations"
			or EDVisit.admissionSource in "Transfer From Inpatient"
			
define function RelatedEDVisit(Encounter "Encounter, Performed"):
	Last(["Encounter, Performed": "Emergency Department Visit"] ED
		where ED.relevantPeriod ends 1 hour or less on or before start of E.relevantPeriod
		sort by end of relevantPeriod
	)

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

define "Initial Population":
	"Inpatient Encounters"
		intersect "AMI Encounter"

define "Inpatient Encounters":
	["Encounter, Performed": "Encounter Inpatient"] Encounter
		where Global."LengthInDays"(Encounter.relevantPeriod)<= 120
			and Encounter.relevantPeriod ends during "Measurement Period"

define "AMI Encounter":
	["Encounter, Performed": "Encounter Inpatient"] Encounter
		where AgeInYearsAt(start of Encounter.relevantPeriod) >= 18
			and Encounter.principalDiagnosis in "Acute or Evolving MI"

define "Exception Procedures":
	( ["Procedure, Performed": "Endotracheal Intubation"]
			union ["Procedure, Performed": "Aortic balloon pump insertion"]
			union ["Procedure, Performed": "Ventricular Assist Device placement"]
	)

define "Denominator Exceptions":
	( "Procedure Exceptions Within 90 Minutes of Arrival"
			union "Diagnosis Exception"
	)

define "Diagnostic Electrocardiogram":
	["Diagnostic Study, Performed": "Electrocardiogram (ECG)"]

define "Fibrinolytic":
	["Medication, Administered": "Fibrinolytic Therapy"]

define "PCI Procedure":
	["Procedure, Performed": "PCI"]

define "Diagnosis Exception":
	"Inpatient Encounters" Encounter
		with ["Diagnosis": "Cardiopulmonary arrest"] CardiacArrest
			such that CardiacArrest.prevalencePeriod starts 90 minutes or less on or after start of Global.Hospitalization(Encounter)

define "Numerator":
	"Initial Population" QualifyingEncounter
		with "PCI Procedure" PCI
			such that PCI.relevantPeriod starts 90 minutes or less on or after Global."Hospital Arrival Time"(QualifyingEncounter)

define "Procedure Exceptions Within 90 Minutes of Arrival":
	"Inpatient Encounters" Encounter
		with "Exception Procedures" ExceptionProcedures
			such that ExceptionProcedures.relevantPeriod starts 90 minutes or less on or after Global."Hospital Arrival Time"(Encounter)

