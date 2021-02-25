library CalculatingMonths

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

context Patient

/*
I recently came across an interesting observation while testing months calculation
and was wondering if this could be added to the agenda for this week’s session.
For one of my measures I am testing that the patient be 3 months of age or older
as of their episode date.

A patient who’s birthdate is on 3/30/2022 as of their episode date (06/30/2022)
should be exactly 3 months of age. When testing this in the CQL engine, the engine
displays that this patient is 2 months old. It seems that the engine is optimized
to ensure 2 months with the same date are always a whole number apart. For example,
January 15 to February 15 would be exactly one month. Below are a few more test
case examples testing this behavior.

Test cases examples:
*/

define Test: {
  Tuple {
    MarchToJune30: CalculateAgeInMonthsAt(Date(2022, 3, 31), Date(2022, 6, 30)),
    //MarchToJune31: CalculateAgeInMonthsAt(Date(2022, 3, 31), Date(2022, 6, 31)), // This is a run-time error, invalid date
    MarchToJuly1: CalculateAgeInMonthsAt(Date(2022, 3, 31), Date(2022, 7, 1)),
    MarchToJuly31: CalculateAgeInMonthsAt(Date(2022, 3, 31), Date(2022, 7, 31)),
    AprilToJune30: CalculateAgeInMonthsAt(Date(2022, 4, 30), Date(2022, 6, 30))//,
    //AprilToJune31: CalculateAgeInMonthsAt(Date(2022, 4, 30), Date(2022, 6, 31)) // This is a run-time error, invalid date
  }
}

/*
Test=[Tuple {
	"MarchToJune30": 2
	"MarchToJuly1": 3
	"MarchToJuly31": 4
	"AprilToJune30": 2
}]
*/

define Test2: {
  Tuple {
    MarchToJune30: duration in months between @2022-03-31 and @2022-06-30,
    MarchToJuly1: duration in months between @2022-03-31 and @2022-07-01,
    MarchToJuly31: duration in months between @2022-03-31 and @2022-07-31,
    AprilToJune30: duration in months between @2022-04-30 and @2022-06-30
  }
}
/*
Test2=[Tuple {
	"MarchToJune30": 2
	"MarchToJuly1": 3
	"MarchToJuly31": 2
	"AprilToJune30": 2
}]*/

/*
For the example 3/31/2022 - 6/30/2022, this is 2 because calendar duration calculation is
looking for the number of whole calendar months that have passed bewteen the two dates.

For the example 3/31/2022 - 7/1/2022, this is 3

Computing Durations and Differences:
https://cql.hl7.org/02-authorsguide.html#computing-durations-and-differences

Time Interval Calculation Examples:
https://cql.hl7.org/15-h-timeintervalcalculations.html
*/
