library Test03_ScreeningForBreastCancer version '0.0.001'

using QDM version '5.3'

include AnnualWellness version '1.0.000' called AWV
include MATGlobalCommonFunctions version '2.0.000' called Global

codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'

valueset "Mammography": 'urn:oid:2.16.840.1.113883.3.464.1003.108.12.1018'
valueset "Female": 'urn:oid:2.16.840.1.113883.3.560.100.2'
valueset "Bilateral Mastectomy": 'urn:oid:2.16.840.1.113883.3.464.1003.198.12.1005'
valueset "Unilateral Mastectomy": 'urn:oid:2.16.840.1.113883.3.464.1003.198.12.1020'

code "Birth date": '21112-8' from "LOINC" display 'Birthdate'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population":
	exists ( AWV."Annual Wellness Encounters" )

define "Denominator":
	exists ( ["Patient Characteristic Birthdate": "Birthdate"] BirthDate
			where Global."CalendarAgeInYearsAt"(BirthDate.birthDatetime, start of "Measurement Period")< 75
				and exists ( ["Patient Characteristic Sex": "Female"] )
	)

define "Numerator":
	exists ( ["Diagnostic Study, Performed": "Mammography"] Mammogram
			where Mammogram.result is not null
				and Mammogram.relevantPeriod ends 26 months or less on or before 
				end of "Measurement Period"
	)

define "Denominator Exclusions":
	exists ( ["Procedure, Performed": "Bilateral Mastectomy"] Bilateral
			where Bilateral.relevantPeriod ends on or before 
			end of "Measurement Period"
	)
		or Count(["Procedure, Performed": "Unilateral Mastectomy"] Unilateral
				where Unilateral.relevantPeriod ends on or before 
				end of "Measurement Period"
		)= 2
