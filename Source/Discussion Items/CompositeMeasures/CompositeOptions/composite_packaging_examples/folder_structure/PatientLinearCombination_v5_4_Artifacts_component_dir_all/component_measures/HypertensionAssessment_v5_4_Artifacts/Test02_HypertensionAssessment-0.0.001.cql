library Test02_HypertensionAssessment version '0.0.001'

using QDM version '5.3'

include AnnualWellness version '1.0.000' called AWV

valueset "Diastolic Blood Pressure": 'urn:oid:2.16.840.1.113883.3.526.3.1033'
valueset "Systolic Blood Pressure": 'urn:oid:2.16.840.1.113883.3.526.3.1032'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population":
	exists ( AWV."Annual Wellness Encounters" )

define "Denominator":
	"Initial Population"

define "Numerator":
	exists ( ["Physical Exam, Performed"] Exam
			with AWV."Annual Wellness Encounters" WellnessEncounter
				such that Exam.relevantPeriod during "Measurement Period"
			where exists ( Exam.components Systolic
					where Systolic.code in "Systolic Blood Pressure"
						and Systolic.result is not null
			)
				and exists ( Exam.components Diastolic
						where Diastolic.code in "Diastolic Blood Pressure"
							and Diastolic.result is not null
				)
	)
