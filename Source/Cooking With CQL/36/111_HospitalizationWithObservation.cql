library HospitalizationWithObservation version '0.0.000'

// This question was submitted in:
// [CQLIT-170](https://oncprojectracking.healthit.gov/support/browse/CQLIT-170) - Hospitalization with Observation
// And relates to CMS104v8 - Discharged on Antithrombotic Therapy

/*
1. Intervention comfort measure should be between start date of ED and end date of IP
2. Intervention comfort measure should be between start date of Observation Services and end date of IP
3. Intervention comfort measure should be between start date of IP and end date of IP
*/

using QDM version '5.4'

include MATGlobalCommonFunctions version '4.0.000' called Global

context Patient

define "Ischemic Stroke Encounter":
  ["Encounter, Performed"]

define "Intervention Comfort Measures":
	["Intervention, Order"]
		union ["Intervention, Performed"]

define "Comfort Measures during Hospitalization":
	"Ischemic Stroke Encounter" IschemicStrokeEncounter
		with "Intervention Comfort Measures" ComfortMeasure
			such that Coalesce(start of ComfortMeasure.relevantPeriod, ComfortMeasure.authorDatetime)
			  during Global."HospitalizationWithObservation"(IschemicStrokeEncounter)

// Looking at the HospitalizationWithObservation function:
/*Hospitalization with Observation returns the total interval from the start of any immediately prior emergency department visit through the observation visit to the discharge of the given encounter*/
define function "HospitalizationWithObservation"(Encounter "Encounter, Performed" ):
	Encounter Visit
		let ObsVisit: Last(["Encounter, Performed": "Observation Services"] LastObs
				where LastObs.relevantPeriod ends 1 hour or less on or before start of Visit.relevantPeriod
				sort by 
				end of relevantPeriod
		),
		VisitStart: Coalesce(start of ObsVisit.relevantPeriod, start of Visit.relevantPeriod),
		EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] LastED
				where LastED.relevantPeriod ends 1 hour or less on or before VisitStart
				sort by 
				end of relevantPeriod
		)
		return Interval[Coalesce(start of EDVisit.relevantPeriod, VisitStart), 
		end of Visit.relevantPeriod]

/*
1. Yes, if there is an emergency department visit, the intervention comfort measure 
should start between the start of the ED and the end of the IP.

2. Yes, if there is an observation (and no emergency department visit), the comfort 
measure should start between the start of the observation and the end of the IP.

3. Yes, if there is neither an emergency department nor an observation, the 
comfort measure should start between the start and end of the IP.
*/
