/*
https://oncprojectracking.healthit.gov/support/browse/CQLIT-146

*/

/*
One of the primary focuses of CQL was the ability to support more precise
temporal expressions. By default, CQL deals with data to the millisecond, and
measure authors can provide the expected precision for temporal comparisons in
the CQL itself. For example:
*/

define "Encounter with Antithrombotic Therapy":
	TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
		with ["Medication, Administered": "Antithrombotic Therapy"] Antithrombotic
			such that Antithrombotic.relevantPeriod 
        starts 1 day or less on or after day of start of Global."Hospitalization"(IschemicStrokeEncounter)
        
/*
The relationship of the Antithrombotic to the encounter is specified to occur
at the "day" precision, meaning the comparison will only proceed to the day.

Since the measures should be specifying desired precision, systems should provide
data with as much precision as they have, rather than truncating data.
*/

