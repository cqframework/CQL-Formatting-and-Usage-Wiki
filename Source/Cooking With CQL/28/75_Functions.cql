library Functions

using QDM version '5.3'

context Patient

/*
Functions are "expressions" that take "arguments"
*/

define "Inpatient Encounters":
  ["Encounter, Performed": "Inpatient"]

/*calculates the difference in calendar days between the start and end of the given interval.*/
define function "LengthInDays"(Value Interval<DateTime> ):
	difference in days between start of Value and end of Value

define "Inpatient Encounters Less Than 120 Days":
  "Inpatient Encounters" InpatientEncounter
    where "LengthInDays"(InpatientEncounter.relevantPeriod) < 120
    
define function "Hospitalization"(Encounter "Encounter, Performed"):
  Encounter E
    let
      EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] ED
          where ED.relevantPeriod ends 1 hour or less on or before start of E.relevantPeriod
            sort by end of relevantPeriod
        )
    return Interval[Coalesce(start of EDVisit.relevantPeriod, start of E.relevantPeriod), end of E.relevantPeriod]

define "Inpatient Encounters Less Than 120 Days":
  "Inpatient Encounters" InpatientEncounter
    where "LengthInDays"("Hospitalization"(InpatientEncounter)) < 120
    
