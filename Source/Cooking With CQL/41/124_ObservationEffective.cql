library ObservationEffective

/*
Based on EXM124
Illustrates Observation.effective
*/

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include MATGlobalCommonFunctions_FHIR4 version '4.0.000' called Global

valueset "Pap Test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1017'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2019-01-01T00:00:00.0, @2020-01-01T00:00:00.0)

context Patient

/*
Consider the Observation effective element
in STU3, it is a choice of dateTime|Period:
http://hl7.org/fhir/STU3/observation-definitions.html#Observation.effective_x_
So the "Normalize Interval(Choice<FHIR.dateTime, FHIR.Period>) function works"
*/

define "Pap Test with Results":
	[Observation: "Pap Test"] PapTest
		where PapTest.value is not null
			and PapTest.status in { 'final', 'amended', 'corrected', 'preliminary' }

define "Pap Test Within 3 Years":
	"Pap Test with Results" PapTest
		where Global."Normalize Interval"(PapTest.effective) ends 3 years or less before end of "Measurement Period"

/*
But in R4, the choices were expanded to include Timing and instant:
http://hl7.org/fhir/observation-definitions.html#Observation.effective_x_

So we define an additional "Normalize Interval", both functions work now
NOTE: QI-Core Observation is still constrained to the set of (dateTime|Period), but since we're using just FHIR, all the options are available
If the system provides a Timing, that's actually non-compliant with QI-Core, so we
are safe to throw an error for that case in this function:
*/

define function "Normalize Interval"(choice Choice<FHIR.dateTime, FHIR.Period, FHIR.Timing, FHIR.instant>):
  case
	  when choice is FHIR.dateTime then
    	Interval[FHIRHelpers.ToDateTime(choice as FHIR.dateTime), FHIRHelpers.ToDateTime(choice as FHIR.dateTime)]
		when choice is FHIR.Period then
  		FHIRHelpers.ToInterval(choice as FHIR.Period)
		when choice is FHIR.Timing then
		  Message(null as Interval<DateTime>, true, '1', 'Error', 'Cannot compute a single interval from a Timing type')
		else
		  Interval[FHIRHelpers.ToDateTime(choice as FHIR.instant), FHIRHelpers.ToDateTime(choice as FHIR.instant)]
	end
