library ChoiceUnionUseCases

using QDM version '5.0.2'

// "Choice" Union Use Cases

codesystem "SNOMED-CT": 'X.Y.Z'

valueset "Comfort Measures": 'TBD'
valueset "Inpatient": 'TBD'
valueset "Emergency Department Visit": 'TBD'

valueset "Antithrombotic Therapy": 'X.Y.Z'
valueset "Medical Reason": 'X.Y.Z'
valueset "Patient Refusal": 'X.Y.Z'

valueset "Unfractionated Heparin": 'X.Y.Z'
valueset "Intravenous route": 'X.Y.Z'
valueset "Direct Thrombin Inhibitor": 'X.Y.Z'
valueset "Glycoprotein IIb/IIIa Inhibitors": 'X.Y.Z'
valueset "VTE Risk Assessment": 'X.Y.Z'
valueset "INR": 'X.Y.Z'

code "Low Risk": 'XYZ' from "SNOMED-CT"

// Use Case 1: Union 2 different datatypes:

/*
QDM version:
  $InterventionComfortMeasures = 
    Union of: 
      "Intervention, Order: Comfort Measures" 
      "Intervention, Performed: Comfort Measures" 

  OR: $InterventionComfortMeasures starts during ("Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatientNonElective ) 
  OR: $InterventionComfortMeasures starts during Occurrence A of $EncounterInpatientNonElective 
*/  

/*
Current CQL Version:

define "Intervention Comfort Measures":
	distinct(["Intervention, Order": "Comfort Measures"]
			union(["Intervention, Performed": "Comfort Measures"] Intervention
					return "Intervention, Order" { 
            authorDatetime: start of Intervention.relevantPeriod, 
            reason: Intervention.reason 
          }
			)
	)
*/
  
/*
Rewrite using "Choice" union
*/

define "Intervention Comfort Measures":
  ["Intervention, Order": "Comfort Measures"]
    union ["Intervention, Performed": "Comfort Measures"]

// "Intervention Comfort Measures" now contains Interventions Ordered and Performed,
// when it's a Performed, we want to use the start of the relevant period, and when
// it's an Order, we want to use authorDatetime, so we use a Coalesce:
define "Encounters with Comfort Measures":
	"Encounter with Principal Diagnosis of Ischemic Stroke" NonElectiveEncounter
		with "Intervention Comfort Measures" ComfortMeasure
			such that Coalesce(start of ComfortMeasure.relevantPeriod, ComfortMeasure.authorDatetime) during NonElectiveEncounter.relevantPeriod

define "ED Encounters with Comfort Measures":
	["Encounter, Performed": "Emergency Department Visit"] EDEncounter
		with "Intervention Comfort Measures" ComfortMeasure
			such that Coalesce(start of ComfortMeasure.relevantPeriod, ComfortMeasure.authorDatetime) during EDEncounter.relevantPeriod

define "Encounters with Prior ED Encounters with Comfort Measures":
	"Encounter with Principal Diagnosis of Ischemic Stroke" NonElectiveEncounter
		with "ED Encounters with Comfort Measures" EDEncounter
			such that EDEncounter.relevantPeriod ends 1 hour or less before start of NonElectiveEncounter.relevantPeriod

/*
QDM Version:
  AND: Union of:
    "Medication, Order not done: Medical Reason" for "Antithrombotic Therapy"
    "Medication, Administered not done: Medical Reason" for "Antithrombotic Therapy"
    "Medication, Order not done: Patient Refusal" for "Antithrombotic Therapy"
    "Medication, Administered not done: Patient Refusal" for "Antithrombotic Therapy"
    <= 1 day(s) starts after start of "Occurrence A of Encounter, Performed: Emergency Department Visit"
*/

/*
Current CQL Version:
*/
define "Antithrombotic Not Ordered":
	["Medication, Not Ordered": "Antithrombotic Therapy"] Medication
		where Medication.negationRationale in "Medical Reason"
			or Medication.negationRationale in "Patient Refusal"

define "Antithrombotic Not Administered":
	["Medication, Not Administered": "Antithrombotic Therapy"] Medication
		where Medication.negationRationale in "Medical Reason"
			or Medication.negationRationale in "Patient Refusal"

/*
define "Antithrombotic Not Done":
	distinct("Antithrombotic Not Ordered"
			union("Antithrombotic Not Administered" M
					return "Medication, Not Ordered" { 
            id: M.id, 
            code: M.code, 
            patientId: M.patientId, 
            reporter: M.reporter, 
            recorder: M.recorder, 
            authorDatetime: start of M.relevantPeriod 
          }
			)
	)
*/

/*
Rewrite using Choice unions
*/
  
define "Antithrombotic Not Done":
  "Antithrombotic Not Ordered"
    union "Antithrombotic Not Administered"

// Again, because only the authorDatetime attribute is referenced, no changes
// are required to use the new expression
define "Antithrombotic Not Done During ED":
	from
		"Encounter with Principal Diagnosis of Ischemic Stroke" E,
		"ED Visit" ED
		where ED.relevantPeriod ends 1 hour or less before start of E.relevantPeriod
			and exists ( "Antithrombotic Not Done" M
					where M.authorDatetime 1 day or less after start of ED.relevantPeriod
			)
		return E

/*
Union 3 different datatypes:
QDM version:
  OR: Union of:
    "Assessment, Performed: VTE Risk Assessment (result: Low Risk)"
    "Laboratory Test, Performed: INR (result > 3.0 )"
    "Medication, Administered: Unfractionated Heparin (route: Intravenous route)"
    "Medication, Administered: Direct Thrombin Inhibitor"
    "Medication, Administered: Glycoprotein IIb/IIIa Inhibitors"
    starts during ("Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient )
*/

/*
Current CQL version:
*/
define "Reasons of Med":
	( ["Medication, Administered": "Unfractionated Heparin"] U
			where U.route in "Intravenous route"
	)
		union ["Medication, Administered": "Direct Thrombin Inhibitor"]
		union ["Medication, Administered": "Glycoprotein IIb/IIIa Inhibitors"]

/*
define "Reasons of Assessment_Lab_Med":
	( ["Assessment, Performed": "VTE Risk Assessment"] A
			where A.result = "Low Risk"
	)
		union ( ["Laboratory Test, Performed": "INR"] L
				where L.result > 3.0
				return "Assessment, Performed" { authorDatetime: L.resultDatetime }
		)
		union "Reasons of Med" M
			return "Assessment, Performed" { 
        authorDatetime: Coalesce(start of M.relevantPeriod, M.authorDatetime)
      }

define "Reasons of Assessment_Lab_Med in ED":
	"Encounter with ED" ED
		with "Reasons of Assessment_Lab_Med" R
			such that R.authorDatetime during ED.relevantPeriod

define "Reasons of Assessment_Lab_Med in Encounter":
	["Encounter, Performed": "Inpatient"] E
		with "Reasons of Assessment_Lab_Med" R
			such that R.authorDatetime 1 day or less after start of E.relevantPeriod
*/

/*
Rewrite using Choice union
*/

define "Reasons of Assessment_Lab_Med":
  (["Assessment, Performed": "VTE Risk Assessment"] A
    where A.result = "Low Risk"
  )
  union (
    ["Laboratory Test, Performed": "INR"] L
      where L.result > 3.0
  )
  union "Reasons of Med" M

/*
In this case, the rewrite means that the authorDatetime, resultDatetime, or 
start of relevantPeriod attributes all need to be checked to cover the possible 
types in the choice union.
*/
define "Reasons of Assessment_Lab_Med in ED":
	"Encounter with ED" ED
		with "Reasons of Assessment_Lab_Med" R
      such that Coalesce(start of R.relevantPeriod, R.authorDatetime, R.resultDatetime) during ED.relevantPeriod

define "Reasons of Assessment_Lab_Med in Encounter":
	["Encounter, Performed": "Inpatient"] E
		with "Reasons of Assessment_Lab_Med" R
			such that Coalesce(start of R.relevantPeriod, R.resultDatetime, R.authorDatetime) 1 day or less after start of E.relevantPeriod

/*
  Secondary definitions, for illustration only
*/
define "Encounter with Principal Diagnosis of Ischemic Stroke":
  ["Encounter, Performed": "Inpatient"]
  
define "ED Visit":
  ["Encounter, Performed": "Emergency Department Visit"]
  
define "Encounter with ED":
  ["Encounter, Performed": "Inpatient"]
