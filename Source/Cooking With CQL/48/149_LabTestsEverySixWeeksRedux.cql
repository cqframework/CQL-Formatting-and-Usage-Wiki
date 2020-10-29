library LabTestsEverySixWeeksRedux

using QDM version '5.5'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
Building on the LabTestsEverySixWeeks example from last session (#47):

How about if the tests have to be six weeks or LESS apart, and they have to
happen every six weeks or LESS while the therapy is ongoing? Meaning, first lab
test can be 1 week or so after the start of the therapy; the next lab can be 2
weeks or so from the first lab?

Problem Statement:

* Chemotherapy starts during Measurement Period
* Lab test should be performed continuously while the patient is on chemotherapy,
with no more than six weeks between tests, and at least 2 tests.
*/

/*
Starting with the measure as stated from last example:
*/

define "Chemotherapy During Measurement Period":
  ["Medication, Active": "Chemotherapy for Advanced Cancer"] Chemotherapy
    where ( Chemotherapy.relevantPeriod starts 1 year or less before start "Measurement Period"
        //and Chemotherapy.relevantPeriod overlaps "Measurement Period"
    )

/*
   2019/11/01
      |--------------|----------------|----------------|--------------|
                |----------------------------------|
              2020/01/01                        2020/12/31
                                            |--------------|----------|
                                        2020/11/01
*/

define "Start of Chemotherapy During Measurement Period":
  Min("Chemotherapy During Measurement Period" Chemotherapy
    return start of Chemotherapy.relevantPeriod
  )

define "End of Chemotherapy During Measurement Period":
  Min({
    end of "Measurement Period",
    "Start of Chemotherapy During Measurement Period" + 1 year,
    Max("Chemotherapy During Measurement Period" Chemotherapy
      return end of Chemotherapy.relevantPeriod )
  })

define "Lab Test":
  ["Laboratory Test, Performed": "Thyroxine (T4) free [Mass/volume] in Serum or Plasma"] LabTest
    with "Chemotherapy During Measurement Period" Therapy
      such that LabTest.relevantDatetime during Therapy.relevantPeriod
        and LabTest.result is not null
    sort by relevantDatetime

define "Valid Lab Test": 
  "Lab Test" LT 
    where exists (   
      "Lab Test" PriorLT     
        where PriorLT.relevantDatetime 6 weeks or more after day of "Start of Chemotherapy During Measurement Period"       
          and LT.relevantDatetime 6 weeks after day of PriorLT.relevantDatetime 
    )   
      or LT.relevantDatetime 6 weeks after day of "Start of Chemotherapy During Measurement Period"

// This expression requires at least 2, as well as one exactly every six weeks, during the therapy
define "Numerator":
  Max({ 2, (weeks between "Start of Chemotherapy" and "End of Chemotherapy") div 6 })

/*
Proposed Solution:
If we say that we want the tests to be no more than six weeks apart, we are asking for
the period between each test, as well as the period between the start of the therapy
and the first test, and the end of the therapy and the last test:

Therapy:
    |------------------------------------|

Tests:   ^    ^      ^          ^   ^
Intervals Between:
    |----|----|------|----------|---|----|

Questions:

Does there have to be a lab after the chemotherapy ends?
Some timeframe after the chemotherapy ends?
What if the chemotherapy is still active at the end of the measurement period?

Basically, we take a similar approach, but change two things:
1) Instead of saying the lab test must be `6 weeks after day of` the prior lab
test, we say `6 weeks or less after day of` the prior lab test, and
2) We are not going to look for intervals, so we return the interval between the
prior lab test and the current lab test, using a "let":
*/

define "Valid Lab Test Intervals": 
  (
    "Lab Test" LT 
      let PriorLT:
        First(
          "Lab Test" PriorLT     
            where PriorLT.relevantDatetime after day of "Start of Chemotherapy During Measurement Period"       
              and LT.relevantDatetime 6 weeks or less after day of PriorLT.relevantDatetime 
            sort by LT.relevantDatetime descending
        )
      where LT.relevantDatetime after day of "Start of Chemotherapy During Measurement Period"
      return
        Interval[
          Coalesce(PriorLT.relevantDatetime, "Start of Chemotherapy During Measurement Period"),
          LT.relevantDatetime
        ]
  )
    union {
      Interval[Max("Lab Test" LT return LT.relevantDatetime), "End of Chemotherapy During Measurement Period"]
    }

/*
Now, we can look for any "gap between tests" that is bigger than six weeks (using 42 days so that we don't
get tests in the seventh week):
*/

define "Has Lab Test Intervals More Than Six Weeks":
  "Valid Lab Test Intervals" LTI
    where duration in days of LTI > 42

define "Numerator":
  Count("Valid Lab Test Intervals") >= 2
    and not exists "Has Lab Test Intervals More Than Six Weeks"
