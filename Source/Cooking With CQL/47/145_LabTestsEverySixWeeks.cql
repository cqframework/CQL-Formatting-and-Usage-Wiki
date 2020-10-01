library LabTestsEverySixWeeks

using QDM version '5.5'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
Problem Statement:

* Chemotherapy starts during Measurement Period
* Lab test should be performed every 6 weeks while the patient is on chemotherapy

First Lab should be 6 weeks after the start of the therapy
The next lab should be 6 weeks after the first lab or 12 weeks from the start of the therapy
If the patient is still on the therapy, there could be another lab and it should be 6 weeks after the second
and so on..
*/

/*
Current approach:
*/

define "Numerator":
  from
    "First Lab" Lab1,
    "Lab Test" PriorLab,
    "Last Lab" MostRecentLab
    where MostRecentLab.relevantDatetime 6 weeks or less after day of PriorLab.relevantDatetime
      and PriorLab.relevantDatetime 6 weeks or less after day of Lab1.relevantDatetime

define "Chemotherapy During Measurement Period":
  ["Medication, Active": "Chemotherapy for Advanced Cancer"] Chemotherapy
    where ( Chemotherapy.relevantPeriod starts during "Measurement Period"
        and Chemotherapy.relevantPeriod overlaps "Measurement Period"
    )

define "Lab Test":
  ["Laboratory Test, Performed": "Thyroxine (T4) free [Mass/volume] in Serum or Plasma"] LabTest
    with "Chemotherapy During Measurement Period" Therapy
      such that LabTest.relevantDatetime during Therapy.relevantPeriod
        and LabTest.result is not null
    sort by relevantDatetime

define "First Lab":
  ( First("Lab Test")) FirstLabTest1
    with "Chemotherapy During Measurement Period" Chemotherapy
      such that FirstLabTest1.relevantDatetime 6 weeks after start of Chemotherapy.relevantPeriod

define "Last Lab":
  Last("Lab Test")

/*
Proposed solution:
Do I understand correctly that the tests have to be six weeks apart, and
they have to happen every six weeks while the therapy is ongoing?

If the answer to those questions is yes, then the approach is definitely on
the right track with the Numerator definition, the problem is that by setting
up the First and Last labs as boundaries, the expression is always comparing
the Prior Lab to the First Lab and the Last Lab, so it's effectively limiting
the search to 3 labs, each six weeks apart.

An approach to address that would be to set up the following definition:
A lab test "counts" if
  it is six weeks after another lab test that is six weeks or more after the
    start of the chemotherapy,
  or if it is six weeks after the start of the chemotherapy
*/

define "Valid Lab Test": 
  "Lab Test" LT 
    where exists (   
      "Lab Test" PriorLT     
        where PriorLT.relevantDatetime 6 weeks or more after day of "Start of Chemotherapy During Measurement Period"       
          and LT.relevantDatetime 6 weeks after day of PriorLT.relevantDatetime 
    )   
      or LT.relevantDatetime 6 weeks after day of "Start of Chemotherapy During Measurement Period"

/*
Then you would need to count the Valid Lab Tests to make sure it was the
expected number (which would be the greater of 2 and the number of 6 week
periods in the therapy interval):
*/

Max({ 2, (weeks between "Start of Chemotherapy" and "End of Chemotherapy") div 6 })
