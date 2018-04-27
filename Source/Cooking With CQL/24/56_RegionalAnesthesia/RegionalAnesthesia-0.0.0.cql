library RegionalAnesthesia version '0.1.002'

using QDM version '5.3'

include MATGlobalCommonFunctions version '2.0.000' called Global

include VTEICU version '2.4.000' called THKR

// Content snipped for brevity

parameter "Measurement Period" Interval<DateTime>

context Patient

// Content snipped for brevity

/*
This definition gives the following error:

Error: Interval type expected.
*/

define "History of Spinal Fusion":
	"Encounters Ages Greater Than Or Equal To 18" QualifyingEncounters
		let Procedure: "Total Hip Total Knee Procedure"(QualifyingEncounters)
		with ["Procedure, Performed": "Spinal Fusion"] HistoryOfSpinalFusion
			such that Procedure.ordinality in "Principal"
			  and HistoryOfSpinalFusion.relevantPeriod starts before start of Procedure.relevantPeriod

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

define function "Total Hip Total Knee Procedure"(Encounter "Encounter, Performed" ):
	["Procedure, Performed": "Total Hip, Total Knee Replacement"] TotalHipTotalKneeProcedures
		with Encounter QualifyingEncounters
			such that TotalHipTotalKneeProcedures.relevantPeriod starts during Interval[start of QualifyingEncounters.relevantPeriod - 48 hours, end of QualifyingEncounters.relevantPeriod]

