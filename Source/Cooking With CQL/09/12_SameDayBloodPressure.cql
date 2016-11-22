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
