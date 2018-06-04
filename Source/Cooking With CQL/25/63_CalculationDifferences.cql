library CalculationDifferences

using QDM version '5.3'

context Patient

// Date/Time Calculation differences between QDM Logic and CQL

// CQL Time Interval Calculations Appendix, for reference:
// http://cql.hl7.org/15-h-timeintervalcalculations.html

// Date/Time Precision

// In QDM, when date/time values are not known to a specific precision, the
// guidance specifies that zeroes should be used

// In CQL, date/time values can be "partial", meaning that the value is only
// known to some specific precision such as to the day or to the minute.

// This results in different behavior for timing comparisons
// For example:

define Encounters: 
  ["Encounter, Performed"] E
    with ["Procedure, Performed"] P
      such that P starts before end of E
      
// In QDM, if the end date of the encounter is unknown, this would return false
// In CQL, the end date is unknown with a closed interval, meaning it continues to the end of time,
// which results in true

@2018-05-01 < null // null

@2018-05-01 in [@2018-01-01, null] // true
@2018-05-01 in [@2018-01-01, null) // null


// Comparisons when No Unit is Given

// In QDM, when no precision is given, guidance specifies that the minute precision is assumed
// This resulted in seconds being ignored if they are present
// In CQL, when no precision is specified, the comparison is performed to the millisecond
// If the comparison should be performed at a specific precision, CQL allows a precision to be specified

define Encounters:
  ["Encounter, Performed"] E
    with ["Procedure, Performed"] P
      such that P starts before end of minute of E

// Duration Calculations

// Calculating duration in years

// March 10th, 2012 to February 2nd, 2013
define YearsExample1: years between @2012-03-10T22:05:09 and @2013-02-18T19:10:03
// QDM Result: 0
// CQL Result: 0

// March 10th, 2012 at 10:05:09PM to March 10th 2013 at 8:01:59AM
define YearsExample2a: years between @2012-03-10T22:05:09 and @2013-03-10T08:01:59
// QDM Result: 1
// CQL Result: 0

// March 10th, 2012 at 10:05:09PM to March 10th 2013 at 10:05:09PM
define YearsExample2ai: years between @2012-03-10T22:05:09 and @2013-03-10T22:05:09
// QDM Result: 1
// CQL Result: 1

// March 10th, 2012 at 10:05:09PM to March 20th 2013 at 4:01:30AM
define YearsExample2b: years between @2012-03-10T22:05:09 and @2013-03-20T04:01:30
// QDM Result: 1
// CQL Result: 1

define YearsExample3a: years between @2012-02-29 and @2014-02-28
// QDM Result: 1
// CQL Result: 1

// NOTE: Because there is no Feburary 29th in 2014, the number of years can only 
// change when the date reaches March 1, the first date in 2014 that surpasses the
// month and day of date 1

define YearsExample4a: years between @2012-03-10T11:16:02 and @2013-08-15T21:34:16
// QDM Result: 1
// CQL Result: 1

define YearsExample4b: years between @2012-02-29T10:18:56 and @2014-03-01T19:02:34
// QDM Result: 2
// CQL Result: 2

// Calculating duration in months

define MonthsExample1a: months between @2012-03-01T14:05:45 and @2012-03-31T23:01:49
// QDM Result: 0
// CQL Result: 0

define MonthsExample1b: months between @2012-03-10T22:05:09 and @2013-06-30T13:00:23
// QDM Result: 15
// CQL Result: 15

define MonthsExample2: months between @2012-03-10T22:05:09 and @2013-01-09T07:19:33
// QDM Result: 9
// CQL Result: 9

// Calculating duration in weeks

define WeeksExample1: weeks between @2012-03-10T22:05:09 and @2012-03-20T07:19:33
// QDM Result: 1
// CQL Result: 1

// NOTE: As with the other precision, this operator only returns whole weeks, so even 
// though the difference in days is 10 days, the difference in weeks is the truncated 
// result, 1

// Calculating duration in days

define DaysExample1: days between @2012-01-31T12:30:00 and @2012-02-01T09:00:00
// QDM Result: 1
// CQL Result: 0

// NOTE: This is a different result because QDM's day calculation ignores time
// In CQL, the _difference_ operator can be used to count the number of boundaries
// crossed, as opposed to the _duration_ operator, which returns the number of whole
// days (i.e. 24 hour periods)

define DaysExample1a: difference in days between @2012-01-31T12:30:00 and @2012-02-01T09:00:00
define DaysExample1b: days between @2012-01-31T12:30:00 and @2012-02-01T12:30:00

define DaysExample2: days between @2012-01-31T12:30:00 and @2012-02-01T14:00:00
// QDM Result: 1
// CQL Result: 1

// Calculating duration in hours

define HoursExample1: hours between @2012-03-01T03:10 and @2012-03-01T05:09
// QDM Result: 1
// CQL Result: 1

define HoursExample1a: hours between @2012-03-01T03:10:30 and @2012-03-01T05:10:20
// QDM Result: 2
// CQL Result: 1

// NOTE: This is a different result because QDM hour duration calculations ignore seconds.

define HoursExample2: hours between @2012-02-29T23:10 and @2012-03-01T00:10
// QDM Result: 1
// CQL Result: 1

define HoursExample3: hours between @2012-03-01T03:10 and @2012-03-01T04:00
// QDM Result: 0
// CQL Result: 0

// Calculating duration in minutes

define MinutesExample1: minutes between @2012-03-01T03:10 and @2012-03-01T05:20
// QDM Result: 130
// CQL Result: 130


define MinutesExample2: minutes between @2012-02-29T23:10 and @2012-03-01T00:20
// QDM Result: 70
// CQL Result: 70
