library MATGlobalCommonFunctions version '2.0.000'

using QDM version '5.3'

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*CalendarAgeInYearsAt calculates the calendar age (meaning the age without
considering time components) in years.*/

define function "CalendarAgeInYearsAt"(BirthDateTime DateTime, AsOf DateTime):
	years between ToDate(BirthDateTime)and ToDate(AsOf)

/*CalendarAgeInMonthsAt calculates the calendar age (meaning the age without considering time components) in months.*/

define function "CalendarAgeInMonthsAt"(BirthDateTime DateTime, AsOf DateTime):
	months between ToDate(BirthDateTime)and ToDate(AsOf)

/*CalendarAgeInDaysAt calculates the calendar age (meaning the age without
considering time components) in days.*/

define function "CalendarAgeInDaysAt"(BirthDateTime DateTime, AsOf DateTime):
	days between ToDate(BirthDateTime)and ToDate(AsOf)

/*CalendarAgeInYears calculates the calendar age (meaning the age without
considering time components) in years as of today.*/

define function "CalendarAgeInYears"(BirthDateTime DateTime):
	CalendarAgeInYearsAt(BirthDateTime, Today())

/*CalendarAgeInMonths calculates the calendar age (meaning the age without
considering time components) in months as of today.*/

define function "CalendarAgeInMonths"(BirthDateTime DateTime):
	CalendarAgeInMonthsAt(BirthDateTime, Today())

/*CalendarAgeInDays calculates the calendar age (meaning the age without
considering time components) in days as of today.*/

define function "CalendarAgeInDays"(BirthDateTime DateTime):
	CalendarAgeInDaysAt(BirthDateTime, Today())

/*TotalLengthOfStay calculates the difference in calendar days between the
start and end of the given stay interval.*/

define function "TotalLengthOfStay"(Stay Interval<DateTime>):
	difference in days between start of Stay and end of Stay

/*Hospitalization returns the total interval for admission to discharge for
the given encounter, or for the admission of any immediately prior emergency 
department visit to the discharge of the given encounter.*/

define function "Hospitalization"(Encounter "Encounter, Performed"):
	( singleton from ( ["Encounter, Performed": "Emergency Department Visit"] EDVisit
			where EDVisit.relevantPeriod ends 1 hour or less on or before start of Encounter.relevantPeriod
	) ) X
		return if X is null then Encounter.relevantPeriod else Interval[start of X.relevantPeriod, end of Encounter.relevantPeriod]

/*ToDate takes a given DateTime value and returns a DateTime with the time components "zeroed", and the timezone of the input value. For example,
given the DateTime @2012-01-01T06:30:00.0Z, this function will return
@2012-01-01T00:00:00.0Z.*/

define function "ToDate"(Value DateTime):
	DateTime(year from Value, month from Value, day from Value, 0, 0, 0, 0, timezone from Value)

/*calculates the difference in calendar days between the start and end of the given interval.*/

define function "LengthInDays"(Value Interval<DateTime>):
	difference in days between start of Value and end of Value
