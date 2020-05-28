library TroponinMeasure

/*
Measure Description: Measure in minutes of the time interval between the time the
results for troponin tests are determined and when the troponin levels are reported
by the laboratory to the responsible provider. This measure uses a continuous variable.

Only the first troponin test followed by a communication during the encounter is
counted as the measure observation. The communication should be completed after
the test and should be related to the test for which it is attributed.

The issue is in trying to create the logic to relate the Communication to a
specific test when there are multiple Troponin tests during an encounter.
Using the following as an example, during an encounter we have two Troponin tests
and one Communication:

    The first Troponin test result date time: 2/12/2019 1100
    The second Troponin test result date time: 2/12/2019 1205
    The first Communication sent date time: 2/12/2019 1305

We want to have the ability to relate the Communication to the second Troponin test,
if we so desired (so that the measure observation = 60 minutes), but the logic is such
that the Communication is always related to the first Troponin test
(with the measure observation = 125 minutes). Our thought was that we could use the
attributes .id and .relatedTo to make the association between Communication and test,
but Bonnie tests are showing the Communication always relates to the first test in this
example even when “Related To” the second test.
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

/*
Two different approaches to finding "the communication for a particular result"
Also need to specify "which result"
*/

define "Minutes between results and communication by id":
  from
    "Qualifying Encounters" E,
    ["Laboratory Test, Performed": "Cardiac Troponin"] T,
    ["Communication, Performed": "Lab Communications"] C
  where T.resultDatetime during E.relevantPeriod
    and C.sentDatetime during E.relevantPeriod
    and C.relatedTo includes T.id
  return minutes between T.resultDatetime and C.sentDatetime

define "Minutes between results and communication by timing":
  from
    "Qualifying Encounters" E,
    ["Laboratory Test, Performed": "Cardiac Troponin"] T
  let
    Communications: First(
      ["Communication, Performed": "Lab Communications"] C
        where C.sentDatetime during E.relevantPeriod
          and C.sentDatetime after T.resultDatetime
        sort by sentDatetime
    )
  where T.resultDatetime during E.relevantPeriod

define function "Minutes between results and communication by id"(Encounter "Encounter, Performed"):
  Min(
    from
      ["Laboratory Test, Performed": "Cardiac Troponin"] T,
      ["Communication, Performed": "Lab Communications"] C
    where T.resultDatetime during Encounter.relevantPeriod
      and C.sentDatetime during Encounter.relevantPeriod
      and C.relatedTo includes T.id
    return minutes between T.resultDatetime and C.sentDatetime
  )

define function "Minutes between results and communication by timing"(Encounter "Encounter, Performed"):
  Min(
    ["Laboratory Test, Performed": "Cardiac Troponin"] T
      let
        Communication: First(
          ["Communication, Performed": "Lab Communications"] C
            where C.sentDatetime during Encounter.relevantPeriod
              and C.sentDatetime after T.resultDatetime
            sort by sentDatetime
        )
      return minutes between T.resultDatetime and Communication.sentDatetime
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
The first Troponin test result date time: 2/12/2019 1100
The second Troponin test result date time: 2/12/2019 1205
The first Communication sent date time: 2/12/2019 1305
*/

/*
{ 125, 60 }
*/

/*
60
*/
