/*
From [QDM-229](https://oncprojectracking.healthit.gov/support/browse/QDM-229) - Duration with partials

*/

/*
The following example is provided in QDM documentation to illustrate 
Cumulative Medication Duration calculation:

Ibuprofen 800 mg every 12 hours , dispense 14 written at 17:00 on August 7 would
include start dateTime as 201708071700 and the end dateTime as 20170814. For this
example, the calculated result is August 14 minus August 7 = 7 days.
*/

// CQL for this is:

/*
When the duration calculation is at a precision below the specified precision 
of one of the inputs, the result is an uncertainty:
https://cql.hl7.org/09-b-cqlreference.html#duration
*/

define UncertainDurationInMonths: months between @2012-01-02 and @2012 // [0, 10]

/*
In addition, the duration calculation is described in terms of whole calendar periods, so
any fractional periods are dropped from the result
*/

/*
https://cql.hl7.org/15-h-timeintervalcalculations.html#definition-3
The duration in days between two dates will generally be given by subtracting 
the start calendar date from the end calendar date, respecting the time of day 
between the two dates.
*/

define DurationInDays: days between @2017-08-07T17:00 and @2017-08-14T00:00 // 6 days
define DurationInDays: days between @2017-08-07T17:00 and @2017-08-14T17:00 // 7 days

define DifferenceInDays: difference in days between @2017-01-01T22:00:00 and @2017-01-02T02:00:00 // 1
define DifferenceInDays: duration in days between @2017-01-01T22:00:00 and @2017-01-02T02:00:00 // 0

/*
When the duration calculation is above the precision of one of the inputs, the
result will take the uncertainty into account, so this could be 6, but could be 7.
*/
define DurationInDays: days between @2017-08-07T17:00 and @2017-08-14T // [6, 7]
define DurationInDays: days between @2017-08-07T and @2017-08-14T17:00 // [6, 7]

/*
The specification could be more clear on this, so a comment is being submitted to add
this clarification.
*/