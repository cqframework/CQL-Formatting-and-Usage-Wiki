library AnnualWellness version '1.0.000'

using QDM version '5.3'

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

valueset "Annual Wellness Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1063'

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Annual Wellness Encounters":
	["Encounter, Performed": "Annual Wellness Visit"] AWV
		with ["Patient Characteristic Birthdate": "Birthdate"] BirthDate
			such that "CalendarAgeInYearsAt"(BirthDate.birthDatetime, start of "Measurement Period")>= 65
				and AWV.relevantPeriod during "Measurement Period"

/*ToDate takes a given DateTime value and returns a DateTime with the time components "zeroed", and the timezone of the input value, for example, given the DateTime @2012-01-01T06:30:00.0Z, this function will return @2012-01-01T00:00:00.0Z.*/

define function "ToDate"(Value DateTime):
	DateTime(year from Value, month from Value, day from Value, 0, 0, 0, 0, timezone from Value)

/*CalendarAgeInYearsAt calculates the calendar age (meaning the age without considering time components) in years.*/

define function "CalendarAgeInYearsAt"(BirthDateTime DateTime, AsOf DateTime):
	years between ToDate(BirthDateTime)and ToDate(AsOf)
