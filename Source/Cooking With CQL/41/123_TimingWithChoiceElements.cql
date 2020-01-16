library TimingWithChoiceElements

/*
Based on EXM125, best-practices for resolving timings represented as choice-types
*/

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include MATGlobalCommonFunctions_FHIR4 version '4.0.000' called Global

valueset "Mammography": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2019-01-01T00:00:00.0, @2020-01-01T00:00:00.0)

context Patient

// Consider the effective element of DiagnosticReport
// http://hl7.org/fhir/diagnosticreport-definitions.html#DiagnosticReport.effective_x_

define "Numerator":
		exists (
				[DiagnosticReport: "Mammography"] Mammogram
						where ( Global."Normalize Interval"(Mammogram.effective) ends 27 months or less before day of end of "Measurement Period" )
								and Mammogram.status in { 'final', 'amended', 'corrected', 'appended' }
		)

/*
The "Normalize Interval" function accounts for the fact that the data may be provided with either a DateTime or an Interval:
*/

define function "Normalize Interval"(choice Choice<FHIR.dateTime, FHIR.Period>):
  if choice is FHIR.dateTime then
	  Interval[FHIRHelpers.ToDateTime(choice as FHIR.dateTime), FHIRHelpers.ToDateTime(choice as FHIR.dateTime)]
	else
	  FHIRHelpers.ToInterval(choice as FHIR.Period)
