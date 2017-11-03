library Test169 version '0.0.040'

// This example is an excerpt of CMS169
// Only the relevant logic is included

using QDM version '5.3'

valueset "BH Antidepressant Medication": 'urn:oid:2.16.840.1.113883.3.1257.1.972'
valueset "BH Assessment for Alcohol or Other Drugs": 'urn:oid:2.16.840.1.113883.3.1257.1.1604'
valueset "BH Condition Involving Bipolar Disorder": 'urn:oid:2.16.840.1.113883.3.1257.1.1504'
valueset "BH Condition Involving Unipolar Depression": 'urn:oid:2.16.840.1.113883.3.1257.1.1505'
valueset "BH Counseling for Depression": 'urn:oid:2.16.840.1.113883.3.1257.1.1616'
valueset "BH Electroconvulsive Therapy": 'urn:oid:2.16.840.1.113883.3.1257.1.1533'
valueset "BH Mood Stabilizer Medication": 'urn:oid:2.16.840.1.113883.3.1257.1.950'
valueset "BH Outpatient encounter": 'urn:oid:2.16.840.1.113883.3.464.1.49'
valueset "BH Outpatient Psychotherapy": 'urn:oid:2.16.840.1.113883.3.1257.1.973'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Bipolar Disorder Or Unipolar Depression":
	["Diagnosis": "BH Condition Involving Bipolar Disorder"]
		union ["Diagnosis": "BH Condition Involving Unipolar Depression"]
		
define "BH Outpatient Encounters":
	["Encounter, Performed": "BH Outpatient encounter"]
		union ["Encounter, Performed": "BH Outpatient Psychotherapy"]

// Use an expression for "BH Outpatient Encounters"
// It appears throughout the measure and would simplify many of the expressions
define "Diagnoses Start During Encounters":
	"Bipolar Disorder Or Unipolar Depression" Diagnoses
		with "BH Outpatient Encounters" Encounters
			such that Diagnoses.prevalencePeriod starts during Encounters.relevantPeriod
			
define "Index Behavioral Health Outpatient Encounter":
  "BH Outpatient Encounters" Encounter
		with "Bipolar Disorder Or Unipolar Depression" Diagnoses
		  such that Encounter.relevantPeriod overlaps before Diagnoses.prevalencePeriod
		where Encounter.relevantPeriod starts during Interval[start of "Measurement Period", start of "Measurement Period" + 323 days]

/*
define "Index Behavioral Health Outpatient Encounter":
	["Encounter, Performed": "BH Outpatient encounter"] Encounter
		with "Bipolar Disorder Or Unipolar Depression" Diagnoses
			such that Encounter.relevantPeriod overlaps before Diagnoses.prevalencePeriod
		where Encounter.relevantPeriod starts during Interval[start of "Measurement Period", start of "Measurement Period" + 323 days]

define "Index Behavioral Health Outpatient Psychotherapy":
	["Encounter, Performed": "BH Outpatient Psychotherapy"] Encounter
		with "Bipolar Disorder Or Unipolar Depression" Diagnoses
			such that Encounter.relevantPeriod overlaps before Diagnoses.prevalencePeriod
		where Encounter.relevantPeriod starts during Interval[start of "Measurement Period", start of "Measurement Period" + 323 days]
*/

define "Index Outpatient Encounter Before Treatment or Psychotherapy":
  (
	  "Index Behavioral Health Outpatient Encounter" Encounter
				with ["Encounter, Performed": "BH Outpatient Psychotherapy"] Psychotherapy
					such that Encounter.relevantPeriod starts 42 days or less before start of Psychotherapy.relevantPeriod
	)
		union ( "Index Behavioral Health Outpatient Encounter" Encounter
				with "Treatments" Treatment
					such that Encounter.relevantPeriod starts 42 days or less before Treatment.authorDatetime
	
/*
define "Index Outpatient Encounter Before Treatment or Psychotherapy":
	( "Index Behavioral Health Outpatient Encounter" Encounter
			with ["Encounter, Performed": "BH Outpatient Psychotherapy"] Psychotherapy
				such that Encounter.relevantPeriod starts 42 days or less before start of Psychotherapy.relevantPeriod
	)
		union ( "Index Behavioral Health Outpatient Encounter" Encounter
				with "Treatments" Treatment
					such that Encounter.relevantPeriod starts 42 days or less before Treatment.authorDatetime
		)

define "Index Behavioral Health Outpatient Psychotherapy Before Treatment or Psychotherapy":
	( "Index Behavioral Health Outpatient Psychotherapy" Encounter
			with ["Encounter, Performed": "BH Outpatient Psychotherapy"] OutpatientPsychotherapy
				such that Encounter.relevantPeriod starts 42 days or less before start of OutpatientPsychotherapy.relevantPeriod
	)
		union ( "Index Behavioral Health Outpatient Psychotherapy" IndexOutpatientPsychotherapyEncounter
				with "Treatments" Treatment
					such that IndexOutpatientPsychotherapyEncounter.relevantPeriod starts 42 days or less before Treatment.authorDatetime
		)
*/

define "Medications Active":
	["Medication, Active": "BH Antidepressant Medication"]
		union ["Medication, Active": "BH Mood Stabilizer Medication"]

define "Medication Active Or Diagnoses":
	( "Medications Active" MedicationActive
			union ( "Bipolar Disorder Or Unipolar Depression" Diagnoses
					return "Medication, Active" { relevantPeriod: Diagnoses.prevalencePeriod }
			)
	)
define "Outpatient Encounter During Diagnosis or Medication Active":
	["Encounter, Performed": "BH Outpatient encounter"] OutpatientEncounter
		with "Medication Active Or Diagnoses" MedicationDiagnosis
			such that OutpatientEncounter.relevantPeriod during MedicationDiagnosis.relevantPeriod

define "Outpatient Psychotherapy During Diagnoses":
	["Encounter, Performed": "BH Outpatient Psychotherapy"] OutpatientPsychotherapy
		with "Bipolar Disorder Or Unipolar Depression" Diagnoses
			such that OutpatientPsychotherapy.relevantPeriod during Diagnoses.prevalencePeriod

define "Outpatient Encounter 180 days after Encounter Diagnosis Treatment":
	( "Index Behavioral Health Outpatient Encounter" Encounter
			with ( "Outpatient Encounter During Diagnosis or Medication Active"
				union "Outpatient Psychotherapy During Diagnoses" ) PriorEncounter
				such that Encounter.relevantPeriod starts 180 days or less after start of PriorEncounter.relevantPeriod
	)
		union ( "Index Behavioral Health Outpatient Encounter" Encounter
				with "Diagnoses Start During Encounters" Diagnoses
					such that Encounter.relevantPeriod starts 180 days or less after Diagnoses.prevalencePeriod
		)
		union ( "Index Behavioral Health Outpatient Encounter" Encounter
				with "Treatments" Treatment
					such that Encounter.relevantPeriod starts 180 days or less after Treatment.authorDatetime
		)

define "Outpatient Psychotherapy 180 days after Encounter Diagnosis Treatment":
	( "Index Behavioral Health Outpatient Psychotherapy Before Treatment or Psychotherapy" Encounter
			with ( "Outpatient Encounter During Diagnosis or Medication Active"
				union "Outpatient Psychotherapy During Diagnoses" ) PriorEncounter
				such that Encounter.relevantPeriod starts 180 days or less after start of PriorEncounter.relevantPeriod
	)
		union ( "Index Behavioral Health Outpatient Psychotherapy Before Treatment or Psychotherapy" Encounter
				with "Diagnoses Start During Encounters" Diagnoses
					such that Encounter.relevantPeriod starts 180 days or less after Diagnoses.prevalencePeriod
		)
		union ( "Index Behavioral Health Outpatient Psychotherapy Before Treatment or Psychotherapy" Encounter
				with "Treatments" Treatment
					such that Encounter.relevantPeriod starts 180 days or less after Treatment.authorDatetime
		)

define "Qualifying.Encounters":
	( "Index Outpatient Encounter Before Treatment or Psychotherapy"
			except "Outpatient Encounter 180 days after Encounter Diagnosis Treatment"
	)
		union ( "Index Behavioral Health Outpatient Psychotherapy Before Treatment or Psychotherapy"
				except "Outpatient Psychotherapy 180 days after Encounter Diagnosis Treatment"
		)

define "Medications Ordered":
	["Medication, Order": "BH Antidepressant Medication"]
		union ["Medication, Order": "BH Mood Stabilizer Medication"]

define "Procedures Ordered":
	["Procedure, Order": "BH Electroconvulsive Therapy"]
		union ["Procedure, Order": "BH Counseling for Depression"]

define "Procedures Performed":
	["Procedure, Performed": "BH Electroconvulsive Therapy"]
		union ["Procedure, Performed": "BH Counseling for Depression"]

define "Treatments":
	( "Procedures Ordered" ProcedureOrdered
			union ( "Procedures Performed" ProceduresPerformed
					return "Procedure, Order" { authorDatetime: start of ProceduresPerformed.relevantPeriod }
			)
			union ( "Medications Ordered" MedicationsOrdered
					return "Procedure, Order" { authorDatetime: MedicationsOrdered.authorDatetime }
			)
	)


