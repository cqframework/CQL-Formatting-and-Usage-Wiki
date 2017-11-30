library CQMCommon version '1.0.0'

using QDM version '5.0.2'

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'

context Patient

// ToDate takes a given DateTime value and returns a DateTime with the time
// components "zeroed", and the timezone of the input value. For example,
// given the DateTime @2012-01-01T06:30:00.0Z, this function will return
// @2012-01-01T00:00:00.0Z.
// NOTE: This function is intended as a short-term solution to facilitate
// calculations using only Dates in the absence of a first-class Date type in CQL.
// Longer-term, the goal is to support first-class Dates within CQL, and
// a medium-term solution to align the date from extractor with ToDate, with the
// intention of changing both that construct and this function to return a Date
// value once it is available.
define function ToDate(Value DateTime):
  DateTime(year from Value, month from Value, day from Value, 0, 0, 0, 0, timezone from Value)

// CalendarAgeInYearsAt calculates the calendar age (meaning the age without
// considering time components) in years.  
define function CalendarAgeInYearsAt(BirthDateTime DateTime, AsOf DateTime):
  years between ToDate(BirthDateTime) and ToDate(AsOf)

// CalendarAgeInMonthsAt calculates the calendar age (meaning the age without
// considering time components) in months.
define function CalendarAgeInMonthsAt(BirthDateTime DateTime, AsOf DateTime):
  months between ToDate(BirthDateTime) and ToDate(AsOf)

// CalendarAgeInDaysAt calculates the calendar age (meaning the age without
// considering time components) in days.
define function CalendarAgeInDaysAt(BirthDateTime DateTime, AsOf DateTime):
  days between ToDate(BirthDateTime) and ToDate(AsOf)

// CalendarAgeInYears calculates the calendar age (meaning the age without
// considering time components) in years as of today.  
define function CalendarAgeInYears(BirthDateTime DateTime):
  CalendarAgeInYearsAt(BirthDateTime, Today())
  
// CalendarAgeInMonths calculates the calendar age (meaning the age without
// considering time components) in months as of today.  
define function CalendarAgeInMonths(BirthDateTime DateTime):
  CalendarAgeInMonthsAt(BirthDateTime, Today())
  
// CalendarAgeInDays calculates the calendar age (meaning the age without
// considering time components) in days as of today.  
define function CalendarAgeInDays(BirthDateTime DateTime):
  CalendarAgeInDaysAt(BirthDateTime, Today())

// LengthInDays calculates the difference in calendar days between the
// start and end of the given interval.
define function LengthInDays(Value Interval<DateTime>):
  difference in days between start of Value and end of Value

// Hospitalization returns the total interval for admission to discharge for
// the given encounter, or for the admission of any immediately prior emergency 
// department visit to the discharge of the given encounter.
// Note that if the data actually contain multiple encounters within 1 hour
// before the start of the encounter, a run-time error will occur indicating
// the hospitalization cannot be unambiguously determined.
define function Hospitalization(Encounter "Encounter, Performed"): 
  (
    singleton from (
      ["Encounter, Performed": "Emergency Department Visit"] EDVisit
        where EDVisit.relevantPeriod ends 1 hour or less on or before start of Encounter.relevantPeriod
    )
  ) X
    return if X is null then Encounter.relevantPeriod
      else Interval[start of X.relevantPeriod, end of Encounter.relevantPeriod]

