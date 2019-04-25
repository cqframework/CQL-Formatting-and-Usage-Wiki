
//[CQM-3552](https://oncprojectracking.healthit.gov/support/browse/CQM-3552)

/*
CMS159 calculates an interval using both “days” and “months” in the logic. 
The specific line of code in question is as follows: 
*/

return Interval[
  Global."ToDate"(FirstIndexAssessment.authorDatetime) + 12 months - 60 days, 
  Global."ToDate"(FirstIndexAssessment.authorDatetime) + 12 months + 60 days
]
    
// The CQL specifications provide the following equation for calculating duration in months:
// Duration (months) = (year (date 2) - year (date 1)) * 12 + (month (date 2) - month (date 1))
 
// Therefore, using the example given in the JIRA ticket (starting date 1/2/2018; ending date 2/1/2019)
// Duration (months) = (2019 – 2018) * 12 + (2 - 1)
// Duration (months) = 13 
 
// Instead, 1/2/2018 to 1/2/2019 would result in a calculation of 12 months.
// Duration (months) = (2019 – 2018) * 12 + (1 - 1)
// Duration (months) = 12
 
// We are looking into the implications of using the combination of “months” 
// and “days” to measure duration. For example, we see the posters point about 
// variation in number of days when using the combination of months and days, 
// as illustrated below:

// First Index Assessment 9/8/2011 1/2/2018 
// plus 12 months 9/8/2012 1/2/2019
// plus 60 days 11/7/2012 3/3/2019
// minus 60 days 7/10/2012 11/3/2018
// Number of days 426 425
 
// We want to pose this question to group to see if they have recommendations 
// for a better way to handle calculating this interval. 

// Recommendation is to use number of days if the intent is to avoid variability in the
// length of years and months, or to use years and months consistently if the intent
// is to allow for that variability.

/*
https://cql.hl7.org/15-h-timeintervalcalculations.html#examples-1

Note that there are two different formulas given in this section for calculating the number of months. The first formula is used if the day in the second date is greater than or equal to the day of the first date (including time components if present), and the second formula is used in if the day in the second date is less than the day of the first date.

So the issue is that the first formula was used here:

Therefore, using the example given in the JIRA ticket (starting date 1/2/2018; ending date 2/1/2019)
Duration (months) = (2019 – 2018)*12 + (2 -1)
Duration (months) = 13 

To get 13 months, but that formula can't be used because the day of the second date is less than the day of the first date. This is the part that's enforcing that duration returns whole calendar months, so we don't count a month until the whole month has passed.

Does that help?
*/

define Test1: @2011-09-08 + 12 months
define MonthsBetween1: months between @2011-09-08 and @2011-09-08 + 12 months
define DaysBetweenEnd1: days between @2011-09-08 and @2011-09-08 + 12 months + 60 days
define DaysBetweenStart1: days between @2011-09-08 and @2011-09-08 + 12 months - 60 days

define Test2: @2018-01-02 + 12 months
define MonthsBetween2: months between @2018-01-02 and @2018-01-02 + 12 months
define DaysBetweenEnd2: days between @2018-01-02 and @2018-01-02 + 12 months + 60 days
define DaysBetweenStart2: days between @2018-01-02 and @2018-01-02 + 12 months - 60 days

define MonthsBetween3: months between @2018-01-02 and @2019-02-01
