library BleedingEvents

using QDM version '5.5'

include MATGlobalCommonFunctions version '6.2.000' called Global

valueset "Blood Transfusion Administration": 'urn:oid:2.16.840.1.113762.1.4.1029.209'
valueset "Anticoagulants for VTE Prophylaxis": 'urn:oid:2.16.840.1.113762.1.4.1147.130'

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

/*
SOLUTION: The criteria need to be expressed in terms of a particular encounter. The problem
with the criteria as written was that it did not tie to specific encounters, so the criteria
were evaluating across encounters, and would end up returning true on all encounters,
rather than only on the particular encounters with bleeding events.

For example, consider the initial expression of "Blood Transfusion Indicative of Bleeding Event"
*/

define "Blood Transfusion Indicative of Bleeding Event":
  exists ( from
      ["Procedure, Performed": "Blood Transfusion Administration"] BloodTransfusion,
      ["Medication, Administered": "Anticoagulants for VTE Prophylaxis"] AnticoagulantMedication,
      "Qualifying Encounters" QualifyingEncounter
      where BloodTransfusion.relevantPeriod ends 120 hours or less after AnticoagulantMedication.relevantDatetime
        and BloodTransfusion.relevantPeriod during Global."HospitalizationWithObservation" ( QualifyingEncounter )
        and BloodTransfusion.relevantPeriod starts 48 hours or more after start of Global."HospitalizationWithObservation" ( QualifyingEncounter )
        and AnticoagulantMedication.relevantDatetime during Global."HospitalizationWithObservation" ( QualifyingEncounter )
  )

/*
This expression was then used in other criteria such as "Encounters With Two Bleeding Event Factors Without a Diagnosis of Bleeding":
*/

define "Encounters With Two Bleeding Event Factors Without a Diagnosis of Bleeding":
  from
    "Qualifying Encounters" QualifyingEncounter,
    "Blood Transfusion Indicative of Bleeding Event" BloodTransfusion,
    "Hemoglobin Lab Tests Indicative of Bleeding Event" HemoglobinDecrease
    where ( BloodTransfusion isTrue )
      and ( HemoglobinDecrease isTrue )
    return QualifyingEncounter

/*
Because there is no link between the "Blood Transfusion" procedure and the encounter under
consideration, it will return true for all encounters if there are any encounters meeting the
criteria.

To address this, the criteria for bleeding event factors can be rewritten to be encounter-focused:
*/

define "Encounters With Blood Transfusion Indicative of Bleeding Event":
  from
    ["Procedure, Performed": "Blood Transfusion Administration"] BloodTransfusion,
    ["Medication, Administered": "Anticoagulants for VTE Prophylaxis"] AnticoagulantMedication,
    "Qualifying Encounters" QualifyingEncounter
    let HospEncounter: Global."HospitalizationWithObservation" ( QualifyingEncounter )
    where BloodTransfusion.relevantPeriod during Interval[start of HospEncounter + 48 hours,
    end of HospEncounter]
      and BloodTransfusion.relevantPeriod ends 120 hours or less after AnticoagulantMedication.relevantDatetime
      and AnticoagulantMedication.relevantDatetime during HospEncounter
    return QualifyingEncounter

/*
This criteria returns encounters with bleeding events, which can then be correlated
with other encounter-based criteria:
*/

define "Encounters With Two Bleeding Event Factors Without a Diagnosis of Bleeding":
  "Encounters With Blood Transfusion Indicative of Bleeding Event"
    intersect "Encounters With Hemoglobin Lab Tests Indicative of Bleeding Event"
