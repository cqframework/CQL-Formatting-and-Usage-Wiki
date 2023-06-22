library ZZ_AnnualWellnessAssessmentMeasure_AllOrNone version '0.0.001'

using QDM version '5.3'

include Test01_ScreeningForAlcoholMisuse version '1.1.000' called ScreeningForAlcoholMisuse
include Test02_HypertensionAssessment version '1.0.000' called HypertensionAssessment
include Test03_ScreeningForBreastCancer version '1.0.000' called ScreeningForBreastCancer
include Test04_ScreeningForColorectalCancer version '1.0.000' called ScreeningForColorectalCancer
include Test05_ScreeningForDepression version '1.0.000' called ScreeningForDepression

context Patient

/*True if any initial population is true*/

define "Initial Populaiton":
	ScreeningForAlcoholMisuse."Initial Population"
		or HypertensionAssessment."Initial Population"
		or ScreeningForBreastCancer."Initial Population"
		or ScreeningForColorectalCancer."Initial Population"
		or ScreeningForDepression."Initial Population"

/*True if and only if all numerators are true*/

define "Numerator":
	ScreeningForAlcoholMisuse."Numerator"
		and HypertensionAssessment."Numerator"
		and ScreeningForBreastCancer."Numerator"
		and ScreeningForColorectalCancer."Numerator"
		and ScreeningForDepression."Numerator"

/*True if any denominator is true and any related denominator exclusions is false*/

define "Denominator":
	( ScreeningForAlcoholMisuse."Denominator"
			and not ScreeningForAlcoholMisuse."Denominator Exclusions"
	)
		or HypertensionAssessment."Denominator"
		or ( ScreeningForBreastCancer."Denominator"
				and not ScreeningForBreastCancer."Denominator Exclusions"
		)
		or ( ScreeningForColorectalCancer."Denominator"
				and not ScreeningForColorectalCancer."Denominator Exclusions"
		)
		or ( ScreeningForDepression."Denominator"
				and not ScreeningForDepression."Denominator Exclusions"
		)
