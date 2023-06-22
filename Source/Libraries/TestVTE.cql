library IntensiveCareUnitVenousThromboembolismProphylaxis version '6.1.004'

using QDM version '5.3'

include MATGlobalCommonFunctions version '2.0.000' called Global

include VTEICU version '1.1.000' called VTEICU

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1' 
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836' 
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837' 
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591' 
valueset "Atrial Fibrillation/Flutter": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.202' 
valueset "Comfort Measures": 'urn:oid:1.3.6.1.4.1.33895.1.3.0.45' 
valueset "Direct Thrombin Inhibitor": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.205' 
valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292' 
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307' 
valueset "General or Neuraxial Anesthesia": 'urn:oid:2.16.840.1.113883.3.666.5.1743' 
valueset "General Surgery": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.255' 
valueset "Glycoprotein IIb/IIIa Inhibitors": 'urn:oid:2.16.840.1.113762.1.4.1045.41' 
valueset "Graduated compression stockings (GCS)": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.256' 
valueset "Gynecological Surgery": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.257' 
valueset "Hip Fracture Surgery": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.258' 
valueset "Hip Replacement Surgery": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.259' 
valueset "Injectable Factor Xa Inhibitor for VTE Prophylaxis": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.211' 
valueset "INR": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.213' 
valueset "Intermittent pneumatic compression devices (IPC)": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.214' 
valueset "Intracranial Neurosurgery": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.260' 
valueset "Intravenous route": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.222' 
valueset "Knee Replacement Surgery": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.261' 
valueset "Low Dose Unfractionated Heparin for VTE Prophylaxis": 'urn:oid:2.16.840.1.113762.1.4.1045.39' 
valueset "Low Molecular Weight Heparin for VTE Prophylaxis": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.219' 
valueset "Low Risk": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.400' 
valueset "Medical Reason": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.473' 
valueset "Obstetrics": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.263' 
valueset "Obstetrics VTE": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.264' 
valueset "Oral Factor Xa Inhibitor for VTE Prophylaxis or VTE Treatment": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.134' 
valueset "Patient Refusal": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.93' 
valueset "Principal": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.14' 
valueset "Subcutaneous route": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.223' 
valueset "Unfractionated Heparin": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.218' 
valueset "Urological Surgery": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.272' 
valueset "Venous foot pumps (VFP)": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.230' 
valueset "Venous Thromboembolism": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.279' 
valueset "VTE Risk Assessment": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.357' 
valueset "Warfarin": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.232' 
valueset "ICU Admission or Transfer": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.305' 
valueset "Intensive Care Unit": 'urn:oid:2.16.840.1.113762.1.4.1110.23' 

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'

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

define "Encounter Age and No Diagnosis of VTE or Obstetrics":
	( "Inpatient Encounter" InaptientEncounter
			with ["Patient Characteristic Birthdate"] BirthDate
				such that Global."CalendarAgeInYearsAt"(BirthDate.birthDatetime, start of InaptientEncounter.relevantPeriod)>= 18
	)
		intersect "Admissions for Obstetrical Conditions with VTE"

define "Denominator":
	"Encounter with ICU Locations"

define "Admissions for Obstetrical Conditions with VTE":
	( "Inpatient Encounter" InpatientEncounter
			where not ( exists ( InpatientEncounter.diagnoses EncounterDiagnoses
						where ( EncounterDiagnoses in "Obstetrics"
								or EncounterDiagnoses in "Venous Thromboembolism"
								or EncounterDiagnoses in "Obstetrics VTE"
						)
				)
			)
	)
		intersect ( "Inpatient Encounter" InpatientEncounter
				without ( ["Diagnosis": "Obstetrics"]
					union ["Diagnosis": "Venous Thromboembolism"]
					union ["Diagnosis": "Obstetrics VTE"] ) Diagnosis
					such that Diagnosis.prevalencePeriod starts during Global."Hospitalization"(InpatientEncounter)
		)

define "Initial Population":
	"Encounter Age and No Diagnosis of VTE or Obstetrics"

define "Encounter Less Than 2 Days":
	"Encounter with ICU Locations" QualifyingEncounterICU
		where QualifyingEncounterICU.lengthOfStay < 2 days

define "Intervention Comfort Measures":
	["Intervention, Order": "Comfort Measures"]
		union ["Intervention, Performed": "Comfort Measures"]

define "Encounter with ICU Locations":
	"Encounter Age and No Diagnosis of VTE or Obstetrics" QualifyingEncounter
		with ( VTEICU."Hospitalization Locations"(QualifyingEncounter)) Location
			such that Location.code in "Intensive Care Unit"
				and Location.locationPeriod during QualifyingEncounter.relevantPeriod

define "First ICU with Principal Procedure of SCIP VTE selected Surgery":
	"Encounter with ICU Locations" QualifyingEncounterICU
		with ( ( ["Procedure, Performed": "General Surgery"]
			union ["Procedure, Performed": "Gynecological Surgery"]
			union ["Procedure, Performed": "Hip Fracture Surgery"]
			union ["Procedure, Performed": "Hip Replacement Surgery"]
			union ["Procedure, Performed": "Intracranial Neurosurgery"]
			union ["Procedure, Performed": "Knee Replacement Surgery"]
			union ["Procedure, Performed": "Urological Surgery"] ) Procedure
			where Procedure.ordinality in "Principal" ) SelectedProcedure
			such that SelectedProcedure.relevantPeriod ends 1 day or less on or after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
				and SelectedProcedure.relevantPeriod ends on or after VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)

define "ED Visit":
	["Encounter, Performed": "Emergency Department Visit"]

define "Intervention Comfort Measures Starts Day of or Day after First ICU":
	"Encounter with ICU Locations" QualifyingEncounterICU
		with "Intervention Comfort Measures" Intervention
			such that Coalesce(start of Intervention.relevantPeriod, Intervention.authorDatetime)1 day or less on or after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
				and Coalesce(start of Intervention.relevantPeriod, Intervention.authorDatetime)on or after VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)

define "Intervention Comfort Measures After Procedure":
	from
		"Encounter with ICU Locations" QualifyingEncounterICU,
		["Procedure, Performed": "General or Neuraxial Anesthesia"] Procedure,
		"Intervention Comfort Measures" Intervention
		where Procedure.relevantPeriod ends 1 day after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
			and Coalesce(start of Intervention.relevantPeriod, Intervention.authorDatetime)1 day or less on or after day of end of Procedure.relevantPeriod
			and Coalesce(start of Intervention.relevantPeriod, Intervention.authorDatetime)on or after end of Procedure.relevantPeriod
		return QualifyingEncounterICU

define "Denominator Exclusions":
	"Encounter Less Than 2 Days"
		union "First ICU with Principal Procedure of SCIP VTE selected Surgery"
		union "Intervention Comfort Measures During Hospitalization and Before First ICU"
		union "Intervention Comfort Measures Starts Day of or Day after First ICU"
		union "Intervention Comfort Measures After Procedure"

define "Medication Administered or Device Applied for VTE Prophylaxis":
	( ["Medication, Administered": "Low Dose Unfractionated Heparin for VTE Prophylaxis"] M
			where M.route in "Subcutaneous route"
	)
		union ["Medication, Administered": "Low Molecular Weight Heparin for VTE Prophylaxis"]
		union ["Medication, Administered": "Injectable Factor Xa Inhibitor for VTE Prophylaxis"]
		union ["Medication, Administered": "Warfarin"]
		union ["Device, Applied": "Intermittent pneumatic compression devices (IPC)"]
		union ["Device, Applied": "Venous foot pumps (VFP)"]
		union ["Device, Applied": "Graduated compression stockings (GCS)"]

define "VTE Prophylaxis Received on Day of or Day After First ICU or Procedure":
	( from
			"Encounter with ICU Locations" QualifyingEncounterICU,
			"Medication Administered or Device Applied for VTE Prophylaxis" VTEProphylaxis
			where VTEProphylaxis.relevantPeriod starts 1 day or less on or after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
				and VTEProphylaxis.relevantPeriod starts on or after VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
			return QualifyingEncounterICU
	)
		union ( from
				"Encounter with ICU Locations" QualifyingEncounterICU,
				["Procedure, Performed": "General or Neuraxial Anesthesia"] Procedure,
				"Medication Administered or Device Applied for VTE Prophylaxis" VTEProphylaxis
				where Procedure.relevantPeriod ends 1 day after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
					and VTEProphylaxis.relevantPeriod starts 1 day or less on or after day of end of Procedure.relevantPeriod
					and VTEProphylaxis.relevantPeriod starts on or after end of Procedure.relevantPeriod
				return QualifyingEncounterICU
		)

define "Encounter with Diagnosis of Atrial Fib or VTE":
	( "Encounter with ICU Locations" QualifyingEncounterICU
			with ["Diagnosis": "Atrial Fibrillation/Flutter"] Diagnosis
				such that Diagnosis.prevalencePeriod starts on or before end of QualifyingEncounterICU.relevantPeriod
	)
		union ( "Encounter with ICU Locations" QualifyingEncounterICU
				where exists ( QualifyingEncounterICU.diagnoses EncounterDiagnosis
						where EncounterDiagnosis in "Atrial Fibrillation/Flutter"
				)
		)
		union ( "Encounter with ICU Locations" QualifyingEncounterICU
				with ["Diagnosis": "Venous Thromboembolism"] Diagnosis
					such that Diagnosis.prevalencePeriod starts before start of QualifyingEncounterICU.relevantPeriod
		)

define "Medication Oral Factor Xa Inhibitor Administered on Day of or Day After First ICU or Procedure":
	( from
			"Encounter with ICU Locations" QualifyingEncounterICU,
			["Medication, Administered": "Oral Factor Xa Inhibitor for VTE Prophylaxis or VTE Treatment"] Medication
			where Medication.relevantPeriod starts 1 day or less on or after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
				and Medication.relevantPeriod starts on or after VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
			return QualifyingEncounterICU
	)
		union ( from
				"Encounter with ICU Locations" QualifyingEncounterICU,
				["Procedure, Performed": "General or Neuraxial Anesthesia"] Procedure,
				["Medication, Administered": "Oral Factor Xa Inhibitor for VTE Prophylaxis or VTE Treatment"] Medication
				where Procedure.relevantPeriod ends 1 day after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
					and Medication.relevantPeriod starts 1 day or less on or after day of end of Procedure.relevantPeriod
					and Medication.relevantPeriod starts on or after end of Procedure.relevantPeriod
				return QualifyingEncounterICU
		)

define "Encounter with Procedure of Hip or Knee Replacement Surgery":
	"Encounter with ICU Locations" QualifyingEncounterICU
		with ( ["Procedure, Performed": "Hip Replacement Surgery"]
			union ["Procedure, Performed": "Knee Replacement Surgery"] ) HipKeenProcedure
			such that HipKeenProcedure.relevantPeriod starts on or before end of QualifyingEncounterICU.relevantPeriod

/*
define "Low Risk for VTE or Anticoagulant Administered":
	( ["Assessment, Performed": "VTE Risk Assessment"] VTERiskAssessment
			where VTERiskAssessment.result as Code in "Low Risk"
	)
		union ( ["Laboratory Test, Performed": "INR"] LabTestINR
				where LabTestINR.result > 3.0
		)
		union ( ( ["Medication, Administered": "Unfractionated Heparin"] UnfractHeparin
					where UnfractHeparin.route in "Intravenous route"
			)
				union ["Medication, Administered": "Direct Thrombin Inhibitor"]
				union ["Medication, Administered": "Glycoprotein IIb/IIIa Inhibitors"]
		)
*/

define "Low Risk for VTE or Anticoagulant Administered":
	( ["Assessment, Performed": "VTE Risk Assessment"] VTERiskAssessment
			where VTERiskAssessment.result as Code in "Low Risk"
	)
		union ( ["Laboratory Test, Performed": "INR"] LabTestINR
				where LabTestINR.result > 3.0
				return "Assessment, Performed" { id: LabTestINR.id,	authorDatetime: LabTestINR.resultDatetime }
		)
		union ( ( ( ["Medication, Administered": "Unfractionated Heparin"] UnfractHeparin
						where UnfractHeparin.route in "Intravenous route"
				)
					union ["Medication, Administered": "Direct Thrombin Inhibitor"]
					union ["Medication, Administered": "Glycoprotein IIb/IIIa Inhibitors"]
			) AnticoagulantMedication
			return "Assessment, Performed" { id: AnticoagulantMedication.id, authorDatetime: start of AnticoagulantMedication.relevantPeriod }
		)


define "Low Risk for VTE or Anticoagulant Administered During ED Visit Before First ICU":
	from
		"Encounter with ICU Locations" QualifyingEncounterICU,
		"ED Visit" EDVisit,
		"Low Risk for VTE or Anticoagulant Administered" VTERiskAssessment
		where EDVisit.relevantPeriod ends 1 hour or less on or before VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
			and VTERiskAssessment.authorDatetime during EDVisit.relevantPeriod
		return QualifyingEncounterICU

define "Low Risk for VTE or Anticoagulant Administered on Day of or Day After First ICU":
	"Encounter with ICU Locations" QualifyingEncounterICU
		with "Low Risk for VTE or Anticoagulant Administered" VTERiskAssessment
			such that VTERiskAssessment.authorDatetime 1 day or less on or after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
				and VTERiskAssessment.authorDatetime on or after VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)

define "Low Risk for VTE or Anticoagulant Administered on Day of or Day After Procedure":
	from
		"Encounter with ICU Locations" QualifyingEncounterICU,
		["Procedure, Performed": "General or Neuraxial Anesthesia"] Procedure,
		"Low Risk for VTE or Anticoagulant Administered" VTERiskAssessment
		where Procedure.relevantPeriod ends 1 day after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
			and VTERiskAssessment.authorDatetime 1 day or less on or after day of end of Procedure.relevantPeriod
			and VTERiskAssessment.authorDatetime on or after end of Procedure.relevantPeriod
		return QualifyingEncounterICU

define "No Medication Administered or Ordered for VTE Prophylaxis":
	["Medication, Not Administered": "Low Dose Unfractionated Heparin for VTE Prophylaxis"]
		union ["Medication, Not Administered": "Low Molecular Weight Heparin for VTE Prophylaxis"]
		union ["Medication, Not Administered": "Injectable Factor Xa Inhibitor for VTE Prophylaxis"]
		union ["Medication, Not Administered": "Warfarin"]
		union ["Medication, Not Ordered": "Low Dose Unfractionated Heparin for VTE Prophylaxis"]
		union ["Medication, Not Ordered": "Low Molecular Weight Heparin for VTE Prophylaxis"]
		union ["Medication, Not Ordered": "Injectable Factor Xa Inhibitor for VTE Prophylaxis"]
		union ["Medication, Not Ordered": "Warfarin"]

define "No Medication VTE Prophylaxis Medical Reason During ED Visit Before First ICU":
	from
		"Encounter with ICU Locations" QualifyingEncounterICU,
		"ED Visit" EDVisit,
		"No Medication Administered or Ordered for VTE Prophylaxis" NoDeviceVTEProphylaxis
		where EDVisit.relevantPeriod ends 1 hour or less on or before VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
			and NoDeviceVTEProphylaxis.negationRationale in "Medical Reason"
			and NoDeviceVTEProphylaxis.authorDatetime during EDVisit.relevantPeriod
		return QualifyingEncounterICU

define "No Medication VTE Prophylaxis Medical Reason on Day of or Day After First ICU":
	from
		"Encounter with ICU Locations" QualifyingEncounterICU,
		"No Medication Administered or Ordered for VTE Prophylaxis" NoMediationVTEProphylaxis
		where NoMediationVTEProphylaxis.negationRationale in "Medical Reason"
			and NoMediationVTEProphylaxis.authorDatetime 1 day or less on or after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
			and NoMediationVTEProphylaxis.authorDatetime on or after VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
		return QualifyingEncounterICU

define "No Medication VTE Prophylaxis Medical Reason on Day of or Day After Procedure":
	from
		"Encounter with ICU Locations" QualifyingEncounterICU,
		["Procedure, Performed": "General or Neuraxial Anesthesia"] Procedure,
		"No Medication Administered or Ordered for VTE Prophylaxis" NoMediationVTEProphylaxis
		where NoMediationVTEProphylaxis.negationRationale in "Medical Reason"
			and Procedure.relevantPeriod ends 1 day after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
			and NoMediationVTEProphylaxis.authorDatetime 1 day or less on or after day of end of Procedure.relevantPeriod
			and NoMediationVTEProphylaxis.authorDatetime on or after end of Procedure.relevantPeriod
		return QualifyingEncounterICU

define "No Device Applied or Ordered for VTE Prophylaxis":
	["Device, Not Applied": "Intermittent pneumatic compression devices (IPC)"]
		union ["Device, Not Applied": "Venous foot pumps (VFP)"]
		union ["Device, Not Applied": "Graduated compression stockings (GCS)"]
		union ["Device, Not Ordered": "Intermittent pneumatic compression devices (IPC)"]
		union ["Device, Not Ordered": "Venous foot pumps (VFP)"]
		union ["Device, Not Ordered": "Graduated compression stockings (GCS)"]

define "No Device VTE Prophylaxis Medical Reason During ED Visit Before First ICU":
	from
		"Encounter with ICU Locations" QualifyingEncounterICU,
		"ED Visit" EDVisit,
		"No Medication Administered or Ordered for VTE Prophylaxis" NoMediationVTEProphylaxis
		where EDVisit.relevantPeriod ends 1 hour or less on or before VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
			and NoMediationVTEProphylaxis.negationRationale in "Medical Reason"
			and NoMediationVTEProphylaxis.authorDatetime during EDVisit.relevantPeriod
		return QualifyingEncounterICU

define "No Device VTE Prophylaxis Medical Reason on Day of or Day After First ICU":
	from
		"Encounter with ICU Locations" QualifyingEncounterICU,
		"No Device Applied or Ordered for VTE Prophylaxis" NoDeviceVTEProphylaxis
		where NoDeviceVTEProphylaxis.negationRationale in "Medical Reason"
			and NoDeviceVTEProphylaxis.authorDatetime 1 day or less on or after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
			and NoDeviceVTEProphylaxis.authorDatetime on or after VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
		return QualifyingEncounterICU

define "No Device VTE Prophylaxis Medical Reason on Day of or Day After Procedure":
	from
		"Encounter with ICU Locations" QualifyingEncounterICU,
		["Procedure, Performed": "General or Neuraxial Anesthesia"] Procedure,
		"No Device Applied or Ordered for VTE Prophylaxis" NoDeviceVTEProphylaxis
		where NoDeviceVTEProphylaxis.negationRationale in "Medical Reason"
			and Procedure.relevantPeriod ends 1 day after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
			and NoDeviceVTEProphylaxis.authorDatetime 1 day or less on or after day of end of Procedure.relevantPeriod
			and NoDeviceVTEProphylaxis.authorDatetime on or after end of Procedure.relevantPeriod
		return QualifyingEncounterICU

define "No VTE Prophylaxis Patient Refusal":
	( "No Medication Administered or Ordered for VTE Prophylaxis"
		union "No Device Applied or Ordered for VTE Prophylaxis" ) NoVTEProphylaxis
		where NoVTEProphylaxis.negationRationale in "Patient Refusal"

define "No VTE Prophylaxis Patient Refusal During ED Visit Before First ICU":
	from
		"Encounter with ICU Locations" QualifyingEncounterICU,
		"ED Visit" EDVisit,
		"No VTE Prophylaxis Patient Refusal" NoVTEProphylaxisPatientRefusal
		where EDVisit.relevantPeriod ends 1 hour or less on or before VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
			and NoVTEProphylaxisPatientRefusal.authorDatetime during EDVisit.relevantPeriod
		return QualifyingEncounterICU

define "No VTE Prophylaxis Patient Refusal on Day of or Day After First ICU":
	from
		"Encounter with ICU Locations" QualifyingEncounterICU,
		"No VTE Prophylaxis Patient Refusal" NoVTEProphylaxisPatientRefusal
		where NoVTEProphylaxisPatientRefusal.authorDatetime 1 day or less on or after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
			and NoVTEProphylaxisPatientRefusal.authorDatetime on or after VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
		return QualifyingEncounterICU

define "No VTE Prophylaxis Patient Refusal on Day of or Day After Procedure":
	from
		"Encounter with ICU Locations" QualifyingEncounterICU,
		["Procedure, Performed": "General or Neuraxial Anesthesia"] Procedure,
		"No VTE Prophylaxis Patient Refusal" NoVTEProphylaxisPatientRefusal
		where Procedure.relevantPeriod ends 1 day after day of VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)
			and NoVTEProphylaxisPatientRefusal.authorDatetime 1 day or less on or after day of end of Procedure.relevantPeriod
			and NoVTEProphylaxisPatientRefusal.authorDatetime on or after end of Procedure.relevantPeriod
		return QualifyingEncounterICU

define "Numerator":
	"VTE Prophylaxis Received on Day of or Day After First ICU or Procedure"
		union ( "Medication Oral Factor Xa Inhibitor Administered on Day of or Day After First ICU or Procedure"
				intersect ( "Encounter with Diagnosis of Atrial Fib or VTE"
						union "Encounter with Procedure of Hip or Knee Replacement Surgery"
				)
		)
		union "Low Risk for VTE or Anticoagulant Administered During ED Visit Before First ICU"
		union "No Device VTE Prophylaxis Medical Reason on Day of or Day After First ICU"
		union "Low Risk for VTE or Anticoagulant Administered on Day of or Day After Procedure"
		union ( "No Medication VTE Prophylaxis Medical Reason During ED Visit Before First ICU"
				intersect "No Device VTE Prophylaxis Medical Reason During ED Visit Before First ICU"
		)
		union ( "No Medication VTE Prophylaxis Medical Reason on Day of or Day After First ICU"
				intersect "No Device VTE Prophylaxis Medical Reason on Day of or Day After First ICU"
		)
		union ( "No Medication VTE Prophylaxis Medical Reason on Day of or Day After Procedure"
				intersect "No Device VTE Prophylaxis Medical Reason on Day of or Day After Procedure"
		)
		union "No VTE Prophylaxis Patient Refusal During ED Visit Before First ICU"
		union "No VTE Prophylaxis Patient Refusal on Day of or Day After First ICU"
		union "No Device VTE Prophylaxis Medical Reason on Day of or Day After Procedure"

define "Inpatient Encounter":
	["Encounter, Performed": "Encounter Inpatient"] EncounterInpatient
		where Global."LengthInDays"(EncounterInpatient.relevantPeriod)<= 120
			and EncounterInpatient.relevantPeriod ends during "Measurement Period"

define "x_First ICU LOS less than 1 day":
	"x_First ICU" FirstICU
		where Global."LengthInDays"(FirstICU.locationPeriod)< 1

define "Denominator Exception_1":
	"x_First ICU LOS less than 1 day"

define "Denominator Exception_2":
	"x_First ICU LOS less Than 1 Day_Function"

define "Intervention Comfort Measures During Hospitalization and Before First ICU":
	"Encounter with ICU Locations" QualifyingEncounterICU
		with "Intervention Comfort Measures" Intervention
			such that Coalesce(start of Intervention.relevantPeriod, Intervention.authorDatetime)1 day or less on or after day of start of Global."Hospitalization"(QualifyingEncounterICU)
				and Coalesce(start of Intervention.relevantPeriod, Intervention.authorDatetime)on or after start of Global."Hospitalization"(QualifyingEncounterICU)
				and Coalesce(start of Intervention.relevantPeriod, Intervention.authorDatetime)before VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)

define "x_First ICU LOS less Than 1 Day_Function":
	"Encounter with ICU Locations" QualifyingEncounterICU
		where difference in days between VTEICU."Earliest Intensive Care Unit Arrival Time"(QualifyingEncounterICU)and VTEICU."Earliest Intensive Care Unit Departure Time"(QualifyingEncounterICU)< 1

define "x_First ICU":
	"Encounter with ICU Locations" QualifyingEncounterICU
		return First((VTEICU."Hospitalization Locations"(QualifyingEncounterICU)) Location
				where Location.code in "Intensive Care Unit"
				sort by start of locationPeriod
		)
		
