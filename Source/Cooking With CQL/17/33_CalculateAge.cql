library CalculateAge

using QDM version '5.0.2'

// This is a proposed resolution for BONNIE-310:
// https://oncprojectracking.healthit.gov/support/browse/BONNIE-310

// Age In CQL is currently calculated using "duration", which respects time components.
// This means that if a patient birth date has a time component, they have the potential
// to fall out of a measure expressed with CQL that they would have been in
// for QDM. For example, if the patient was born at 6:30AM on January 1st, the
// AgeInYearsAt calculation won't consider them as crossing the next age boundary
// until 6:30AM, where the intent of the measure is to consider their age based
// on the calendar date only.

// One approach would be to use a "date from" extractor, but the issue with that
// is that it would result in the "duration" calculation returning an uncertainty.
// Another approach is to define the Age calculation functions for years, months,
// and days as "zeroing" the time components.

parameter "Measurement Period" Interval<DateTime>

define "In Demographic":
  CalculateAgeInYearsAt(Patient.birthDatetime, start of "Measurement Period")
  
  AgeInYearsAt(start of "Measurement Period")
  
  Common.CalculateAgeInYearsAt(Patient.birthDatetime, start of "Measurement Period")

define function ToDate(dateTime DateTime):
  DateTime(year from dateTime, month from dateTime, day from dateTime, 0, 0, 0, 0, timezone from dateTime)
  
define function CalendarAgeInYearsAt(birthDateTime DateTime, asOf DateTime):
  years between ToDate(birthDateTime) and ToDate(asOf)
  
define function CalendarAgeInMonthsAt(birthDateTime DateTime, asOf DateTime):
  months between ToDate(birthDateTime) and ToDate(asOf)

define function CalendarAgeInDaysAt(birthDateTime DateTime, asOf DateTime):
  days between ToDate(birthDateTime) and ToDate(asOf)
  
  