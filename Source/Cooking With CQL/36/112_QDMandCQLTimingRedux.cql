library QDMAndCQLTimingRedux

/*
There are numerous uses of the timing phrase "ends 1 hour or less on or before start of"
to identify an emergency department visit immediately prior to an inpatient encounter.
One such example is from CMS111 - Median Admit Decision Time to ED Departure Time for Admitted Patients
*/

using QDM version '5.4'

context Patient

define "Inpatient Encounter":
  ["Encounter, Performed"]
	
define "ED Visit with Admit Order":
  ["Encounter, Performed"]

/*
// CQL (CMS111v8)
*/
define "Initial Population":
	/*Emergency Department visit with a Decision to Admit inpatient followed by an Inpatient encounter within or at an hour of the ED Visit*/
	"Inpatient Encounter" Encounter
		with "ED Visit with Admit Order" EDAdmitOrder
			such that EDAdmitOrder.relevantPeriod ends 1 hour or less before or on start of Encounter.relevantPeriod

/*
QDM (CMS111v6)
AND: 
  "Occurrence A of Encounter, Performed: Emergency Department Visit" 
		<= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient 
*/

/*
In QDM, this comparison is performed by calculating the difference between the end of the
emergency department visit and the start of the inpatient encounter, and comparing that
to the quantity in the timing phrase. Since the duration calculation rounds, this results in
durations of 1 hour and 59 minutes still being considered "1 hour".
*/

/*
In CQL, the timing phrase "ends 1 hour or less before or on start of" is evaluated using
an interval calculation:

relevantPeriod.end in Interval[start - 1 hour, start]

So the comparison occurs at the millisecond, rather than at the hour as in QDM.

You can still achieve the same behavior in CQL by specifying the comparison precision:

"ends 1 hour or less before or on hour of start of"
*/

define "Initial Population 2":
	/*Emergency Department visit with a Decision to Admit inpatient followed by an Inpatient encounter within or at an hour of the ED Visit*/
	"Inpatient Encounter" Encounter
		with "ED Visit with Admit Order" EDAdmitOrder
			such that EDAdmitOrder.relevantPeriod ends 1 hour or less before or on hour of start of Encounter.relevantPeriod

/*
This "hour of" says that not only is the quantity an hour, but the comparison should be performed
at the "hour" precision. This will produce the same behavior as QDM, allowing anything up to
an hour and 59 minutes to be considered "1 hour"

Basically, QDM used the precision of the quantity to do the comparison, whereas CQL
supports identifying both the precision of the quantity
*/

/*
There is a general discussion of using timing relationships in CQL from an author's perspective here:
https://cql.hl7.org/02-authorsguide.html#timing-relationships

The detailed specification for how timing phrases are interpreted is part of the
CQL specification here:

https://cql.hl7.org/05-languagesemantics.html#timing-phrases

There is an exhaustive set of examples for calculating durations here:

https://cql.hl7.org/15-h-timeintervalcalculations.html

Would it be useful to have a worked out set of examples like this for timing phrases specifically?
*/

