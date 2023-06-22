library Scratchpad

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

context Patient

define TestToDateTime: ToDateTime(@2021-01-01)

//define TestHoursBetween: hours between @2017-03-12T01:00:00-07:00 and @2017-03-12T03:00:00-06:00

define TestIntervalIntersectNull: Interval[1, 10] intersect Interval[5, null)

define TestOverlaps: Interval[1, 10] overlaps Interval[5, null)

define TestNullIncludes: { null } includes { null }

//Just to be sure we're on the same page though… If only one side has an uncertainty, and it is below the unit of duration, what then?  E.g., you're prosing that this is 1:

define TestHoursBetween: hours between @2017-03-12T01:00:00-07:00 and @2017-03-12T03:00:00-06:00

//But what about this (noting the 2nd DateTime has MS specified):

define TestHoursBetween2: hours between @2017-03-12T01:00:00-07:00 and @2017-03-12T03:00:00.0-06:00

define TestHoursBetweenA: hours between @2017-01-01T01:00:00 and @2017-01-01T02:00:00

define TestHoursBetweenB: hours between @2017-01-01T01:00:00 and @2017-01-01T02:00:00.0


define TestHoursBetweenX: hours between @2017-01-01T01:00:00.000 and @2017-01-01T02:00:00.000
define TestHoursBetweenY: hours between @2017-01-01T01:00:00.999 and @2017-01-01T02:00:00.000

define TestHoursBetweenC: hours between @2017-01-01T00:00:00 and @2017-01-01T01:00
define TestHoursBetweenD: hours between @2017-01-01T00:00:00 and @2017-01-01T01:00:00
define TestHoursBetweenE: hours between @2017-01-01T00:00:00 and @2017-01-01T01:00:59

define TestHoursBetweenF: hours between @2017-03-12T01:00-07:00 and @2017-03-12T03:00:00-06:00
define TestHoursBetweenG: hours between @2017-03-12T01:00:00-07:00 and @2017-03-12T03:00:00-06:00
define TestHoursBetweenH: hours between @2017-03-12T01:00:59-07:00 and @2017-03-12T03:00:00-06:00

define A: @2012-01
define B: @2012-02
define C: @2012-03

define DurationRangeFromAtoBorC:
  Interval[days between A and B, days between A and C]

define DurationNull:
  Interval[null as Integer, null as Integer]

define TestIntervalNull1: end of (Interval[1, 10] intersect Interval[5, null)) <= 10
define TestIntervalNull2: end of (Interval[1, 10] intersect Interval[5, null)) >= 5
define TestIntervalNull3: end of (Interval[1, 10] intersect Interval[5, null)) > 10
define TestIntervalNull4: end of (Interval[1, 10] intersect Interval[5, null)) < 5

define TestDaysBetween: days between A and B
define TestDaysBetweenMax: days between @2012-01-01 and @2012-02-29
define TestDaysBetweenMin: days between @2012-01-31 and @2012-02-01
define TestDaysBetweenTest1: TestDaysBetween < 1
define TestDaysBetweenTest2: TestDaysBetween = 1
define TestDaysBetweenTest3: TestDaysBetween > 59
define TestDaysBetweenTest4: TestDaysBetween = 59
define TestDaysBetweenTest5: TestDaysBetween = 0
define TestDaysBetweenTest6: TestDaysBetween = 60


define TestDaysBetweenTest7: days between Date(2014, 1, 15) and Date(2014, 2) > 2
define TestDaysBetweenTest8: days between Date(2014, 1, 15) and Date(2014, 2) > 50
define TestDaysBetweenTest9: days between Date(2014, 1, 15) and Date(2014, 2)
define TestDaysBetweenTest10: TestDaysBetweenTest9 > 2
define TestDaysBetweenTest11: TestDaysBetweenTest9 > 50

define TestSuccessor1: successor of 1 'mg'
define TestPredecessor1: predecessor of 1 'mg'
define TestSuccessor2: successor of 1.0
define TestPredecessor2: predecessor of 1.0
define TestMinimumQuantity1: minimum Quantity
define TestMaximumQuantity1: maximum Quantity

define TestContainsIsNull: { 1, 3, 5, 7 } contains null
//define TestAdd: Add(2, 2)
define TestEqual: Equal(2, 2)
define TestSource: ({4, 5, 1, 6, 2, 1}) sL sort asc

//define TestToString('12345')

// https://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#duration
// This returns 4, not 5, because the last day is not a whole day, it's 22 hours
// Other than that, the analysis is correct, and the result is { 1, 2, 3, 4 }
define Period: Interval[@2021-01-01T08, @2021-01-06T06]
define TestDaysBetween12: duration in days between start of Period and end of Period
define ExpandPeriod: expand { Period } per day
define ExpandPerInteger: expand { Interval[1, duration in days between start of Period and end of Period] } per 1


define TestList: { 1, 2, 3 }
define TestIndexOf: IndexOf(TestList, 1)
define TestIndexer: TestList[0]

define TestDummyInterval: Interval[1, 10]
define TestInterval: Interval[1, days between start of Period and end of Period]
define TestExpand:
(expand { TestInterval }
) DayExpand
  return
    end of DayExpand

define TestUseExpand:
  TestExpand DayNumber
