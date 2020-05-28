library QueryReturnTypes

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include TJCOverall version '5.0.000' called TJC
include MATGlobalCommonFunctions version '5.0.000' called Global

codesystem "LOINC": 'http://loinc.org'

valueset "Pap Test": 'TBD'
valueset "Antithrombotic Therapy": 'TBD'
valueset "Medical Reason": 'TBD'
valueset "Patient Refusal": 'TBD'

code "Blood pressure": '85354-9' from "LOINC" display 'blood pressure'
code "Diastolic blood pressure": '8462-4' from "LOINC" display 'Diastolic blood pressure'
code "Systolic blood pressure": '8480-6' from "LOINC" display 'Systolic blood pressure'

context Patient

// Single source query for a list of structured values
// Return type: List<FHIR.Observation>
// Note that the where clause does not impact the return type of the query
define "Cervical Cytology Observations":
	[Observation: "Pap Test"] CervicalCytology
		where CervicalCytology.value is not null
			and CervicalCytology.status in { 'final', 'amended', 'corrected', 'preliminary' }

// With and without do not impact the return type of the query
// Return type: List<FHIR.Encounter>, same as the "Ischemic Stroke Encounter" source
define "Encounter With No Antithrombotic At Discharge":
	TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
		with "Antithrombotic Not Given at Discharge" NoDischargeAntithrombotic
			such that NoDischargeAntithrombotic.authoredOn during IschemicStrokeEncounter.period

// Let does not impact the return type of the query
// Return type: List<FHIR.Observation>
define TestSlices:
  [Observation: "Blood pressure"] BP
    let
      SystolicBP: singleton from (BP.component C where C.code ~ "Systolic blood pressure"),
      DiastolicBP: singleton from (BP.component C where C.code ~ "Diastolic blood pressure")
    where SystolicBP.value < 140 'mm[Hg]'
      and DiastolicBP.value < 90 'mm[Hg]'

// Only the return clause impacts the return type
// Return type: List<Choice<FHIR.Quantity, FHIR.String...>>
define "Diastolic Reading":
	[Observation: "Blood pressure"] BP
		let
			DiastolicBP: singleton from (BP.component C where C.code ~ "Diastolic blood pressure")
		return DiastolicBP.value

// Use casting to narrow a choice:
// Return type: List<FHIR.Quantity>
define "Diastolic Reading (refined)":
	[Observation: "Blood pressure"] BP
		let
			DiastolicBP: singleton from (BP.component C where C.code ~ "Diastolic blood pressure")
		return DiastolicBP.value as FHIR.Quantity

// Doesn't have to be a list of structured values, can be primitives
// Return type: List<System.Integer>
define "Query Of List Of Primitives":
  ({ 1, 2, 3, 4, 5 }) X
	  where X > 1

// Doesn't have to be plural, can be a singular source query
// Return type: Choice<FHIR.Quantity, FHIR.String, ...>
define "Singular Source Query":
  "Most Recent Blood Pressure Observation" BP
		let
			DiastolicBP: singleton from (BP.component C where C.code ~ "Diastolic blood pressure")
		return DiastolicBP.value

// Can be a multi-source query
// Return type: Tuple{BP1:FHIR.Observation, BP2:FHIR.Observation}
define "Multi-source Query":
	from
	  "Most Recent Blood Pressure Observation" BP1,
		"Most Recent Blood Pressure Observation" BP2

// Use a return to shape the results of a multi-source query
// Return type: Tuple{BP1Value:FHIR.Quantity, BP2Value: FHIR.Quantity}
define "Multi-source Query (shaped result)":
	from
	  "Most Recent Blood Pressure Observation" BP1,
		"Most Recent Blood Pressure Observation" BP2
  return Tuple { BP1Value: BP1.value as FHIR.Quantity, BP2Value: BP2.value as FHIR.Quantity }

////////////////////////////////////////////////////////////////////////////////
// Supplemental defines to support the above examples

define "Antithrombotic Not Given at Discharge":
	["MedicationRequest": medication in "Antithrombotic Therapy"] NoAntithromboticDischarge
    where NoAntithromboticDischarge.doNotPerform is true
			and (NoAntithromboticDischarge.reasonCode in "Medical Reason"
				or NoAntithromboticDischarge.reasonCode in "Patient Refusal")
      //Note: expressed as an or with equivalence semantics pending resolution of potential CQL issue.
      and exists (
        NoAntithromboticDischarge.category C
          where C ~ Global."Community"
            or C ~ Global."Discharge"
      )
      and NoAntithromboticDischarge.status = 'completed'
      and NoAntithromboticDischarge.intent = 'order'


define "Most Recent Blood Pressure Observation":
  Last(
	  [Observation: "Blood pressure"] BP
		  sort by start of effective
	)
