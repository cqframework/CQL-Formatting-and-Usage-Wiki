library MATGlobalCommonFunctions version '3.0.000'

using QDM version '5.3'

// TODO: Given guidance from VSAC on not using versions, should these be versionless references to the code systems?
codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

// TODO: Location value sets for determining locations within a hospital system
// VSAC has the following relevant value sets already defined:
  // ICU Locations - 2.16.840.1.113883.3.666.5.2486 (SNOMED-CT (environment))
  // HealthCareServiceLocations - 2.16.840.1.113883.1.11.20275 (HL7 CDA R2.1 2017-06-09)
// In addition, HL7 V3/FHIR defines the following valueset:
  // http://build.fhir.org/v3/ServiceDeliveryLocationRoleType/vs.html
// TODO: These facility value sets should be compared/contrasted with 
// value sets such as Inpatient Encounter that are being used to determine location
// to ensure that measures will identify the appropriate set of encounters
valueset "Inpatient Facility": 'TBD'
valueset "Emergency Department": 'TBD'
valueset "Intensive Care Unit": 'TBD'

// TODO: This valueset currently contains a single code, should we use a direct-reference code instead?
// TODO: Need to reconcile with other emergency department visits
valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
CalendarAgeInYearsAt calculates the calendar age (meaning the age without
considering time components) in years.
*/

define function "CalendarAgeInYearsAt"(BirthDateTime DateTime, AsOf DateTime):
	years between ToDate(BirthDateTime)and ToDate(AsOf)

/*
CalendarAgeInMonthsAt calculates the calendar age (meaning the age without 
considering time components) in months.
*/

define function "CalendarAgeInMonthsAt"(BirthDateTime DateTime, AsOf DateTime):
	months between ToDate(BirthDateTime)and ToDate(AsOf)

/*
CalendarAgeInDaysAt calculates the calendar age (meaning the age without
considering time components) in days.
*/

define function "CalendarAgeInDaysAt"(BirthDateTime DateTime, AsOf DateTime):
	days between ToDate(BirthDateTime)and ToDate(AsOf)

/*
CalendarAgeInYears calculates the calendar age (meaning the age without
considering time components) in years as of today.
*/

define function "CalendarAgeInYears"(BirthDateTime DateTime):
	CalendarAgeInYearsAt(BirthDateTime, Today())

/*
CalendarAgeInMonths calculates the calendar age (meaning the age without
considering time components) in months as of today.
*/

define function "CalendarAgeInMonths"(BirthDateTime DateTime):
	CalendarAgeInMonthsAt(BirthDateTime, Today())

/*
CalendarAgeInDays calculates the calendar age (meaning the age without
considering time components) in days as of today.
*/

define function "CalendarAgeInDays"(BirthDateTime DateTime):
	CalendarAgeInDaysAt(BirthDateTime, Today())

/*
Hospitalization returns the total interval from admission to discharge for
the given encounter, or from the admission of any immediately prior emergency 
department visit to the discharge of the given encounter.

Note that if the data actually contain multiple encounters within 1 hour
before the start of the encounter, a run-time error will occur indicating
the hospitalization cannot be unambiguously determined.
*/

define function "Hospitalization"(Encounter "Encounter, Performed"):
	( singleton from ( ["Encounter, Performed": "Emergency Department Visit"] EDVisit
			where EDVisit.relevantPeriod ends 1 hour or less on or before start of Encounter.relevantPeriod
	) ) X
		return if X is null then Encounter.relevantPeriod else Interval[start of X.relevantPeriod, end of Encounter.relevantPeriod]
    
/*
Hospitalization Locations returns the list of all locations within an
encounter, including locations for any immediately prior emergency department
visit.

Note that if the data actually contain multiple encounters within 1 hour
before the start of the encounter, a run-time error will occur indicating
the hospitalization cannot be unambiguously determined.
*/

define function "Hospitalization Locations"(Encounter "Encounter, Performed"):
  ( singleton from ( ["Encounter, Performed": "Emergency Department Visit"] EDVisit
      where EDVisit.relevantPeriod ends 1 hour or less on or before start of Encounter.relevantPeriod
  ) ) X
    return if X is null then Encounter.facilityLocations else flatten { X.facilityLocations, Encounter.facilityLocations }

/*
ToDate takes a given DateTime value and returns a DateTime with the time 
components "zeroed", and the timezone of the input value. For example,
given the DateTime @2012-01-01T06:30:00.0Z, this function will return
@2012-01-01T00:00:00.0Z.

NOTE: This function is intended as a short-term solution to facilitate
calculations using only Dates in the absence of a first-class Date type in CQL.
Longer-term, the goal is to support first-class Dates within CQL, and
a medium-term solution to align the date from extractor with ToDate, with the
intention of changing both that construct and this function to return a Date
value once it is available.
*/

define function "ToDate"(Value DateTime):
	DateTime(year from Value, month from Value, day from Value, 0, 0, 0, 0, timezone from Value)
  
/*
LengthInDays returns the difference in calendar days between the start and end
of the given interval.
*/

define function "LengthInDays"(Value Interval<DateTime>):
	difference in days between start of Value and end of Value
  
/*
CalendarDayOfOrDayAfter returns an interval from the given DateTime to the end of
the following day of the given DateTime.

This function is intended to simplify the expression of the following two timing
phrases:
    A starts 1 day or less on or after day of start of B
      and A starts on or after start of B

The above can then be expressed with this function as:
    start of A during CalendarDayOfOrDayAfter(start of B)
    
And can be read: "A starts on the day of or day after but after B"      
*/

define function CalendarDayOfOrDayAfter(StartValue DateTime):
  Interval[StartValue, ToDate(StartValue + 2 days))

/*
Hospitalization Length of Stay returns the length of stay in days (i.e. the
number of days between admission and discharge) for the given
encounter, or from the admission of any immediately prior emergency
department visit to the discharge of the encounter.

Note that if the data actually contain multiple encounters within 1 hour
before the start of the encounter, a run-time error will occur indicating
the hospitalization cannot be unambiguously determined.
*/

define function "Hospitalization Length of Stay"(Encounter "Encounter, Performed"):
  LengthInDays("Hospitalization"(Encounter))
  
/*
Hospital Admission Time returns the admission time for an encounter,
or for an immediately prior emergency department visit.

Note that if the data actually contain multiple encounters within 1 hour
before the start of the encounter, a run-time error will occur indicating
the hospitalization cannot be unambiguously determined.
*/

define function "Hospital Admission Time"(Encounter "Encounter, Performed"):
  start of "Hospitalization"(Encounter)
  
/*
Hospital Discharge Time returns the discharge time for an encounter.
*/

define function "Hospital Discharge Time"(Encounter "Encounter, Performed"):
  end of Encounter.relevantPeriod
  
/*
Hospital Arrival Time returns the earliest arrival time for an encounter, 
including any immediately prior emergency department visit.

Note that if the data actually contain multiple encounters within 1 hour
before the start of the encounter, a run-time error will occur indicating
the hospitalization cannot be unambiguously determined.
*/

define function "Hospital Arrival Time"(Encounter "Encounter, Performed"):
  Coalesce("Emergency Department Arrival Time"(Encounter), start of Encounter.relevantPeriod)

/*
Hospital Departure Time returns the latest departure time for the given
encounter, including any immediately prior emergency department visit.

Note that if the data actually contain multiple encounters within 1 hour
before the start of the encounter, a run-time error will occur indicating
the hospitalization cannot be unambiguously determined.
*/

define function "Hospital Departure Time"(Encounter "Encounter, Performed"):
  end of Last(("Hospitalization Locations"(Encounter)) L
      sort by start of locationPeriod
  ).locationPeriod

/*
Emergency Department Arrival Time returns the arrival time in the emergency
department for the given encounter, including any immediately prior emergency
department visit.

Note that if the data actually contain multiple encounters within 1 hour
before the start of the encounter, or multiple emergency department locations
in the encounters, a run-time error will occur indicating the hospitalization
or location cannot be unambiguously determined.
*/

define function "Emergency Department Arrival Time"(Encounter "Encounter, Performed"):
  start of (singleton from (("Hospitalization Locations"(Encounter)) L
      where L.code in "Emergency Department"
  )).locationPeriod

/*
Emergency Department Departure Time returns the departure time from the 
emergency department for the given encounter, including any immediately
prior emergency department visit.

Note that if the data actually contain multiple encounters within 1 hour
before the start of the encounter, or multiple emergency department locations
in the encounters, a run-time error will occur indicating the hospitalization
or location cannot be unambiguously determined.
*/

define function "Emergency Department Departure Time"(Encounter "Encounter, Performed"):
  end of (singleton from (("Hospitalization Locations"(Encounter)) L
      where L.code in "Emergency Department"
  )).locationPeriod

/*
First Intensive Care Unit returns the first intensive care unit for the given
encounter, including any immediately prior emergency department visit.

Note that if the data actually contain multiple encounters within 1 hour
before the start of the encounter, a run-time error will occur indicating
the hospitalization cannot be unambiguously determined.
*/

define function "First Intensive Care Unit"(Encounter "Encounter, Performed"):
  First(("Hospitalization Locations"(Encounter)) L
      where L.code in "Intensive Care Unit"
      sort by start of locationPeriod
  )
	
/*
First Inpatient Intensive Care Unit returns the first intensive care unit for
the given encounter, without considering any immediately prior emergency
department visit.
*/

define function "First Inpatient Intensive Care Unit"(Encounter "Encounter, Performed"):
  First(Encounter.facilityLocations HospitalLocation
		where HospitalLocation.code in "Intensive Care Unit"
		  and HospitalLocation.locationPeriod during Encounter.relevantPeriod
		sort by start of locationPeriod
	)
  
/*
Hospitalization Arrival to Discharge returns the period from arrival in the
emergency department to discharge from the hospital for the given encounter. If
there was no emergency department visit or facility, then hospital admission
time is used as the best approximation for arrival time.

Note that if the data actually contain multiple encounters within 1 hour
before the start of the encounter, a run-time error will occur indicating 
the hospitalization cannot be unambiguously determined.

NOTE: This function is not included in the library due to the need to determine the
impact of the change on reporting.

define function "Hospitalization Arrival to Discharge"(Encounter "Encounter, Performed"):
  Interval["Hospital Arrival Time"(Encounter), end of Encounter.relevantPeriod]
*/

