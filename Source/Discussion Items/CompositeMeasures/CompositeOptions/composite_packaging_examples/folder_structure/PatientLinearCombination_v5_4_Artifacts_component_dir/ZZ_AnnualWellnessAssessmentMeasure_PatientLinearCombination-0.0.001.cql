library ZZ_AnnualWellnessAssessmentMeasure_PatientLinearCombination version '0.0.001'

using QDM version '5.3'

include Test01_ScreeningForAlcoholMisuse version '1.1.000' called ScreeningForAlcoholMisuse
include Test02_HypertensionAssessment version '1.0.000' called HypertensionAssessment
include Test03_ScreeningForBreastCancer version '1.0.000' called ScreeningForBreastCancer
include Test04_ScreeningForColorectalCancer version '1.0.000' called ScreeningForColorectalCancer
include Test05_ScreeningForDepression version '1.0.000' called ScreeningForDepression

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'

context Patient

define "SDE Ethnicity":
	["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer":
	["Patient Characteristic Payer": "Payer"]

define "SDE Race":
	["Patient Characteristic Race": "Race"]

define "SDE Sex":
	["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Denominator Score":
	if ScreeningForAlcoholMisuse."Initial Population"
		and ( ScreeningForAlcoholMisuse."Denominator"
				and not ScreeningForAlcoholMisuse."Denominator Exclusions"
		) then 1 else 0 + if HypertensionAssessment."Initial Population"
		and HypertensionAssessment."Denominator" then 1 else 0 + if ScreeningForBreastCancer."Initial Population"
		and ( ScreeningForBreastCancer."Denominator"
				and not ScreeningForBreastCancer."Denominator Exclusions"
		) then 1 else 0 + if ScreeningForColorectalCancer."Initial Population"
		and ( ScreeningForColorectalCancer."Denominator"
				and not ScreeningForColorectalCancer."Denominator Exclusions"
		) then 1 else 0 + if ScreeningForDepression."Initial Population"
		and ( ScreeningForDepression."Denominator"
				and not ScreeningForDepression."Denominator Exclusions"
		) then 1 else 0

define "Numerator Score":
	if ScreeningForAlcoholMisuse."Initial Population"
		and ( ScreeningForAlcoholMisuse."Denominator"
				and not ScreeningForAlcoholMisuse."Denominator Exclusions"
		)
		and ScreeningForAlcoholMisuse."Numerator" then 1 else 0 + if HypertensionAssessment."Initial Population"
		and HypertensionAssessment."Denominator"
		and HypertensionAssessment."Numerator" then 1 else 0 + if ScreeningForBreastCancer."Initial Population"
		and ( ScreeningForBreastCancer."Denominator"
				and not ScreeningForBreastCancer."Denominator Exclusions"
		)
		and ScreeningForBreastCancer."Numerator" then 1 else 0 + if ScreeningForColorectalCancer."Initial Population"
		and ( ScreeningForColorectalCancer."Denominator"
				and not ScreeningForColorectalCancer."Denominator Exclusions"
		)
		and ScreeningForColorectalCancer."Numerator" then 1 else 0 + if ScreeningForDepression."Initial Population"
		and ( ScreeningForDepression."Denominator"
				and not ScreeningForDepression."Denominator Exclusions"
		)
		and ScreeningForDepression."Numerator" then 1 else 0

define "Initial Population":
	["Patient Characteristic Birthdate"] P
		where ScreeningForAlcoholMisuse."Initial Population"
			or HypertensionAssessment."Initial Population"
			or ScreeningForBreastCancer."Initial Population"
			or ScreeningForColorectalCancer."Initial Population"
			or ScreeningForDepression."Initial Population"

/*True if any denominator is true and any related denominator exclusions is false*/

define "Measure Population":
	["Patient Characteristic Birthdate"] P
		where ( ScreeningForAlcoholMisuse."Denominator"
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

define function "Measure Observation"(PatientCharacteristic "Patient Characteristic Birthdate"):
	"Numerator Score" / "Denominator Score"
