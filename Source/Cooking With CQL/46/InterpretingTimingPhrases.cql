library InterpretingTimingPhrases

/*
* duration
* difference
* interval (when does a timing phrase result in a comparison vs an interval)
* precision
* years between
* difference in days
* a day or less before or on
* ends 1 hour or less on or before
* ends 1 day after day of
* 42 weeks or less before
*/

define OneHourOrLessOnOrBefore1: @2020-07-01T09:30:00.0 1 hour or less on or before @2020-07-01T10:30:00.0 // true
define OneHourOrLessOnOrBefore2: @2020-07-01T09:29:59.999 1 hour or less on or before @2020-07-01T10:30:00.0 // false
define OneHourOrLessOnOrBefore3: @2020-07-01T09:29:59.999 1 hour or less on or before hour of @2020-07-01T10:30:00.0 // true
define OneHourOrLessOnOrBefore4: @2020-07-01T08:31:00.0 1 hour or less on or before @2020-07-01T10:30:00.0 // false
define OneHourOrLessOnOrBefore5: hours between @2020-07-01T08:31:00.0 and @2020-07-01T10:30:00.0 <= 1 // true
define OneHourOrLessOnOrBefore6: difference in hours between @2020-07-01T08:31:00.0 and @2020-07-01T10:30:00.0 <= 1 // false
define OneDayAfterDayOf1: @2020-07-12T10:00:00.0 1 day after day of @2020-07-11T10:00:00.0 // true
define OneDayAfterDayOf2: @2020-07-11T23:59:59.999 1 day after day of @2020-07-11T10:00:00.0 // false
define OneDayAfterDayOf3: @2020-07-13T00:00:00.0 1 day after day of @2020-07-11T10:00:00.0 // false
define FortyTwoWeeksOrLessBefore1: @2019-09-23 42 weeks or less before @2020-07-13 // true
define FortyTwoWeeksOrLessBefore2: @2019-09-23T09:00:00.0 42 weeks or less before @2020-07-13T10:00:00.0 // false
define FortyTwoWeeksOrLessBefore3: @2019-09-23T09:00:00.0 42 weeks or less before day of @2020-07-13T10:00:00.0 // true
define FortyTwoWeeksOrLessBefore4: @2019-09-22T11:00:00.0 42 weeks or less before day of @2020-07-13T10:00:00.0 // false
