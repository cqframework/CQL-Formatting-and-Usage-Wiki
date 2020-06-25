library TroponinMeasureFollowup

/*
On last month's call, we reviewed a Troponin Measure. Based on that discussion,
the "Minutes between results and communication by id or timing" function was
incorporated into the measure logic:

define function "Minutes between results and communication by id or timing"(Encounter "Encounter, Performed"):
  Min(
    ["Laboratory Test, Performed": "Cardiac Troponin"] T
      let
        Communication: First(
          ["Communication, Performed": "Lab Communications"] C
            where C.sentDatetime during Encounter.relevantPeriod
              and C.sentDatetime after T.resultDatetime
              and (not exists (C.relatedTo) or C.relatedTo includes T.id)
            sort by sentDatetime
        )
      return minutes between T.resultDatetime and Communication.sentDatetime
  )

This logic is being tested with the following use cases:

# Use Case 1:
If encounter has multiple tests with 1 communication, it returns the time
interval between the test that the communication is “Related To”.
This is desired behavior:

Example 1:
Test #1 result dateTime:  5/29 0800
Test #2 result dateTime:  5/29 0900
Communication (relatedTo Test #1) sent dateTime: 5/29 1000
Time interval (Measure observation) = 120 minutes

Example 2:
Test #1 result dateTime:  5/29 0800
Test #2 result dateTime:  5/29 0900
Communication (relatedTo Test #2) sent dateTime: 5/29 1000
Time interval (Measure observation) = 60 minutes
_______________________________________

# Use Case 2:
If encounter has multiple 'Test + Communication' events (associated by "Related To"
element), it returns the time interval between the test and the communication
with the least amount (minimum number) of minutes, regardless of the sequence of
the 'Test + Communication' events.
This is desired behavior:

Example 1:
Test #1 result dateTime:  5/29 0800
Communication (relatedTo Test #1) sent dateTime: 5/29 0900
Test #2 result dateTime:  5/30 1100
Communication (relatedTo Test #2) sent dateTime: 5/30 1105
Time interval (Measure observation) = 5 minutes (vs. 60 minutes)

Example 2:
Test #1 result dateTime:  5/29 0830
Communication (relatedTo Test #1) sent dateTime: 5/29 0840
Test #2 result dateTime:  5/29 0900
Communication (relatedTo Test #2) sent dateTime: 5/29 1000
Time interval (Measure observation) = 10 minutes (vs. 60 minutes)
_______________________________________

# Use Case 3:
If encounter has 1 test with multiple communications, it returns the time
interval between the test and the first communication (i.e., the communication
which most immediately follows the test), even if not directly related to the
test (i.e., relate the communication to the test using the "Related To" attribute
in Bonnie).
This is not desired behavior:

Test result dateTime:  5/29 0800
Communication #1 (not relatedTo test) sent dateTime: 5/29 0900
Communication #2 (relatedTo Test) sent dateTime: 5/29 1000
Time interval (Measure observation) = 60 minutes

# Question:
Is there a way in the logic to require that the communication be "Related To"
the test when calculating the time interval between the two?
And, ideally, to do so while not impacting the behavior seen in Use Cases 1 and 2
above (which is desired behavior)? Say, having the "Related To" association between
test and communication take a priority over calculating the "min" time interval
between a test and communication in the Use Case 3 scenario?
*/

using QDM version '5.5'

valueset "Cardiac Troponin": 'TBD'
valueset "Lab Communications": 'TBD'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Qualifying Encounters":
  ["Encounter, Performed"]

define "Initial Population":
  "Qualifying Encounters" QualifyingEncounters
    with "Communication" CriticalValueCommunication
      such that CriticalValueCommunication.sentDatetime during QualifyingEncounters.relevantPeriod

define "Communication":
  ["Communication, Performed": "Lab Communications"] CritValueCommunication
    with "Laboratory Tests for Troponin I or T" TroponinLabTests
      such that TroponinLabTests.id in CritValueCommunication.relatedTo
        and CritValueCommunication.sentDatetime after TroponinLabTests.resultDatetime

define "Laboratory Tests for Troponin I or T":
  ["Laboratory Test, Performed": "Cardiac Troponin"]

/*
The following are the CQL functions used to calculate the Measure Observation:
*/

define function "Critical Value Communicated"(Encounter "Encounter, Performed"):
  /*Critical Value Communicated to Provider*/
  First(["Communication, Performed": "Lab Communications"] CritValueCommunication
      where CritValueCommunication.sentDatetime during Encounter.relevantPeriod
      sort by sentDatetime
  )

define function "Measure Observation"(Encounter "Encounter, Performed"):
  /* the duration from the Troponin test results to the critical value communication*/
  duration in minutes of Interval["Troponin Test Done"(Encounter).resultDatetime,
    "Critical Value Communicated"(Encounter).sentDatetime
  ]

define function "Troponin Test Done"(Encounter "Encounter, Performed"):
  /*Troponin Test performed with results*/
  First(["Laboratory Test, Performed": "Cardiac Troponin"] TroponinLabTest
      where TroponinLabTest.resultDatetime during Encounter.relevantPeriod
      sort by resultDatetime
  )

define function "Minutes between results and communication by id or timing"(Encounter "Encounter, Performed"):
  Min(
    ["Laboratory Test, Performed": "Cardiac Troponin"] T
      let
        Communication: First(
          ["Communication, Performed": "Lab Communications"] C
            where C.sentDatetime during Encounter.relevantPeriod
              and C.sentDatetime after T.resultDatetime
              and (not exists (C.relatedTo) or C.relatedTo includes T.id)
            sort by sentDatetime
        )
      return minutes between T.resultDatetime and Communication.sentDatetime
  )

/*
As illustrated by the Use Case 3, the issue is that the use of First here
selects the item that is not related prior to the one that is because it's only
sorting by the sentDatetime:

Test result dateTime:  5/29 0800
Communication #1 (not relatedTo test) sent dateTime: 5/29 0900
Communication #2 (relatedTo Test) sent dateTime: 5/29 1000

So what we need is to "prioritize" the communications that are known to be related to the test.
We can do this within CQL using a "calculated sort order"
Reference to the Sorting discussion in the CQL Author's Guide:
[Sorting](https://cql.hl7.org/02-authorsguide.html#sorting)
*/

define function "Minutes between results and communication by id THEN timing"(Encounter "Encounter, Performed"):
  Min(
    ["Laboratory Test, Performed": "Cardiac Troponin"] T
      let
        Communication: First(
          ["Communication, Performed": "Lab Communications"] C
            where C.sentDatetime during Encounter.relevantPeriod
              and C.sentDatetime after T.resultDatetime
              and (not exists (C.relatedTo) or C.relatedTo includes T.id)
            sort by if exists (relatedTo) then 0 else 1, sentDatetime
        )
      return minutes between T.resultDatetime and Communication.sentDatetime
  )

/*
What we want is for the communications that are related to the test to appear first in the list,
and we can accomplish this using an `if` expression to turn whether or not there are any
relatedTo elements for the communication into a value that will sort appropriately. This is
most easily done with an integer, 0 if it's a related timing, 1 if it's not:

`if exists (relatedTo) then 0 else 1`

Note that the where clause has already ensured that if there are relatedTo values for the
communication, then at least one of those relatedTo values includes the id of the test,
so we already know that it is a related communication.
*/
