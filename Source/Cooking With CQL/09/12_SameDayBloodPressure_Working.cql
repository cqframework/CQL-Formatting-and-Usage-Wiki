library SameDayBloodPressure

using QDM version '5.0.2'

valueset "HTN 2 SYSTOLIC_CODE": 'HTN 2 SYSTOLIC_CODE'
valueset "HTN 2 DIASTOLIC_CODE": 'HTN 2 DIASTOLIC_CODE'

parameter "Measurement Period" Interval<DateTime>

/*
In the measure ACO 28 (HTN-2), the spec states that the most recent blood pressure must be used.
It also states, “If there are multiple BPs on the same date of service, use the lowest systolic
and lowest diastolic BP on that date as the representative BP”.

How do you suggest we model this using QDM?

Our current Human Readable does this:

    Numerator =
        AND: Occurrence A of $HtnBpSystolic overlaps Occurrence A of $HtnBpDiastolic

And the variables are defined as such:

    $HtnBpSystolic =
        "Physical Exam, Performed: HTN 2 SYSTOLIC_CODE" satisfies all:
            (Most Recent: ) during "Measurement Period"
            (result <= 140 mmHg)

    $HtnBpDiastolic =
        "Physical Exam, Performed: HTN 2 DIASTOLIC_CODE" satisfies all:
            (Most Recent: ) during "Measurement Period"
            (result <= 90 mmHg)

However I can’t think of a way to have it look for the lowest on a certain day.
*/

// Assuming it is really the case that we want the lowest diastolic and lowest systolic:

define "Htn Bp Systolic":
  ["Physical Exam, Performed": "HTN 2 SYSTOLIC_CODE"] Systolic
    where Systolic.relevantPeriod during "Measurement Period"
      and Systolic.result as Quantity <= 140 'mmHg'

define "Most Recent Systolic By Date":
  Last("Htn Bp Systolic" Systolic sort by start of Systolic.relevantPeriod)

define "Most Recent Systolics On Same Day":
  "Htn Bp Systolic" Systolic
    with "Most Recent Systolic By Date" MostRecentSystolic
      such that Systolic.relevantPeriod starts same day as start of MostRecentSystolic.relevantPeriod

define "Lowest Most Recent Systolic":
  First("Most Recent Systolics On Same Day" Systolic sort by (Systolic.result as Quantity))

define "Htn Bp Diastolic":
  ["Physical Exam, Performed": "HTN 2 DIASTOLIC_CODE"] Diastolic
    where Diastolic.relevantPeriod during "Measurement Period"
      and Diastolic.result as Quantity <= 90 'mmHg'

define "Most Recent Diastolic By Date":
  Last("Htn Bp Diastolic" Diastolic sort by start of Diastolic.relevantPeriod)

define "Most Recent Diastolics On Same Day":
  "Htn Bp Diastolic" Diastolic
    with "Most Recent Diastolic By Date" MostRecentDiastolic
      such that Diastolic.relevantPeriod starts same day as start of MostRecentDiastolic.relevantPeriod

define "Lowest Most Recent Diastolic":
  First("Most Recent Diastolics On Same Day" Diastolic sort by (Diastolic.result as Quantity))

// NOTE: It's possible that this logic would select measurements from different readings
// Based on a reading of the guideline on which this measure is based, that's acceptable
