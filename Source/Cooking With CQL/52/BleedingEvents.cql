library BleedingEvents

/*
The numerator definition is:

Encounters where bleeding events occurred during the encounter and within 5 days
following an anticoagulant medication administration for VTE prophylaxis during the same encounter.

A bleeding event is defined as the presence of one of the following three criteria:

Criterion A. Documented diagnosis of acute bleeding in/into a critical anatomic site

OR
Criterion B. Two evidence factors of a bleeding event, without a documented bleeding diagnosis.

Evidence of Criterion B bleeding event is determined by BOTH:

(1) An absolute decrease in hemoglobin results of 2 g/dL or more within a 48-hour period,
excluding the first 24 hours of arrival in the hospital (including the emergency department)

AND

(2) Transfusion of whole or red blood cells, excluding the first 48 hours of arrival
in the hospital (including the emergency department)

OR
Criterion C. One evidence factor of a bleeding event, with a documented diagnosis
of major bleeding at a non-critical anatomic site.

Evidence of Criterion C bleeding event is determined by EITHER:

(1) An absolute decrease in hemoglobin results of 2 g/dL or more within a 48-hour period,
excluding the first 24 hours of arrival in the hospital (including the emergency department);

OR

(2) Transfusion of whole or red blood cells, excluding the first 48 hours of arrival
in the hospital (including the emergency department)

The logic issue seems to be isolated to the Criterion B and C logic in situations
where a test with multiple encounters for the patient are created. Numerator tests
pass as expected when only a single encounter is created to test either Criterion B
or Criterion C, but the numerator tests fail when multiple encounters are created.

It appears Bonnie is looking ACROSS all encounters in the test case to determine if
Criterion B or C is met, instead of looking within each individual encounter in the
test case to see if it meets the numerator.

-----------------------------------------------------------------------------------------

Example Bonnie Test Case #1 – Two qualifying encounters:

First encounter had only the bolded criteria occurring in the encounter:

Criterion B. Two evidence factors of a bleeding event, **without a documented bleeding diagnosis**.

Evidence of Criterion B bleeding event is determined by BOTH:

**(1) An absolute decrease in hemoglobin results of 2 g/dL or more within a 48 hour period,
excluding the first 24 hours of arrival in the hospital (including the emergency department)**
AND
(2) Transfusion of whole or red blood cells, excluding the first 48 hours of arrival
in the hospital (including the emergency department)

Second encounter had only the bolded criteria:

Criterion B. Two evidence factors of a bleeding event, **without a documented bleeding diagnosis**.

Evidence of Criterion B bleeding event is determined by BOTH:

(1) An absolute decrease in hemoglobin results of 2 g/dL or more within a 48 hour period,
excluding the first 24 hours of arrival in the hospital (including the emergency department)
AND
**(2) Transfusion of whole or red blood cells, excluding the first 48 hours of arrival
in the hospital (including the emergency department)**

Bonnie Expected Results:
IPP/Denom = 2
Numerator = 0

Bonnie Calculated Results:
IPP/Denom = 2
Numerator = 1 (incorrect, should be 0)

Neither encounter meets the numerator criteria because without a bleeding diagnosis,
both the drop in Hgb AND a transfusion within the same encounter is needed to meet the numerator.
The separate encounters each only has one of the two necessary criteria.

---------------------------------------------------------------------------------------------

Example Bonnie Test Case #2 – Two qualifying encounters:

First encounter had the highlighted criteria occur in the encounter (which meets the Num criteria):

Criterion C. One evidence factor of a bleeding event, with a **documented diagnosis of
major bleeding at a non-critical anatomic site.**

Evidence of Criterion C bleeding event is determined by:
(1) An absolute decrease in hemoglobin results of 2 g/dL or more within a 48 hour period,
excluding the first 24 hours of arrival in the hospital (including the emergency department);
OR
**(2) Transfusion of whole or red blood cells, excluding the first 48 hours of arrival
in the hospital (including the emergency department)**

Second encounter only met the IPP/Denom criteria, and did not have a bleeding diagnosis, which is a condition for Criterion B:

Criterion B. Two evidence factors of a bleeding event, **without a documented bleeding diagnosis.**
Evidence of Criterion B bleeding event is determined by BOTH:
(1) An absolute decrease in hemoglobin results of 2 g/dL or more within a 48 hour period, excluding the first 24 hours of arrival in the hospital (including the emergency department)
AND
(2) Transfusion of whole or red blood cells, excluding the first 48 hours of arrival in the hospital (including the emergency department)

Bonnie Expected Results:
IPP/Denom = 2
Numerator = 1

Bonnie Calculated Results:
IPP/Denom = 2
Numerator = 2 (incorrect, should be 1)

----------------------------------------------------------------------------------------------

Our eCQM team has attempted a few revisions to the logic to try and address the
problem, to no avail. We’ve attached the MAT package and are hoping that you can
take a look to see if there is anything obvious in the logic that that is causing
this, and recommendations on how to revise the CQL to rectify the issue.
*/
