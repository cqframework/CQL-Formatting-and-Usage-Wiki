library ContraceptiveProvisionAccesstoLongActingReversibleContraceptiveMethod version '0.0.000'

using QDM version '5.3'

// Content snipped for brevity

parameter "Measurement Period" Interval<DateTime>

context Patient

// Content snipped for brevity

// NOTE: There is no need to restate the initial population criteria here, "Initial Population" can just be referenced
define "Denominator": 
	"Initial Population"

define "Numerator":
	exists ( "Long Acting Reversible Contraceptive (LARC) Methods" )

define "Initial Population":
	AgeInYearsAt(end of "Measurement Period")>= 15
		and AgeInYearsAt(end of "Measurement Period")<= 44
		and ( "IsFemale" )
		and exists ( "HasEncounterInMeasurementPeriod" )
		and exists ( "Not at risk for unintended pregnancy" )

