/*
Start with the type of measure, what are we counting?
If we are counting patients, then the criteria will all result in yes/no (or Boolean) values
For example,
*/

// This returns true or false for a patient (yes/no, or Boolean-valued)
define "In Demographic":
  AgeInYearsAt(start of "Measurement Period") >= 13

// This returns a list of encounters for a patient
define "Inpatient Encounters":
  ["Encounter, Performed": "Inpatient Encounter Codes"] Encounter
    where Encounter.relevantPeriod during "Measurement Period"

// So we use an exists to turn it in to a Boolean so we can combine it with "and"
define "Initial Population":
  "In Demographic"
    and exists ("Inpatient Encounters")

/*
However, if we are counting encounters (episode-of-care measure), the criteria will all
result in lists of encounters. For example:
*/

// Each of these return a list of encounters
define "Measurement Period Encounters":
  ["Encounter, Performed": "Ambulatory/ED Visit"] Encounter
    where Encounter.relevantPeriod during "Measurement Period"
      and "In Demographic"

define "Pharyngitis Encounters With Antibiotics":
  "Measurement Period Encounters" Encounter
    with "Pharyngitis" Pharyngitis
      such that Common."Includes Or Starts During"(Pharyngitis, Encounter)
    with "Antibiotics" Antibiotics
      such that Antibiotics.authorDatetime 3 days or less after start of Encounter.relevantPeriod

// Since the measure is counting encounters, we can return the list in the initial population
define "Initial Population":
  "Pharyngitis Encounters With Antibiotics"

// Where vs Such that

/*
For where versus such that, a where clause is only used as a direct clause in a query,
and a such that is only used in a with or without clause. That's actually why CQL uses a
different keyword, so that it would always be clear when you were providing a where clause,
or when you were defining the conditions for a with or without clause.
*/

/*
If you're familiar with SQL, you can think of a with as a subquery with an exists, for example:
*/

Encounters E with Medications M such that E.relevantPeriod includes M.relevantPeriod

/*
is equivalent to
*/

select *
  from Encounters E
  where exists (select * from Medications M where E.relevantPeriod includes M.relevantPeriod)

/*
(Assuming SQL had the same temporal operators as CQL).

Similarly, a without is like a subquery with a not exists:
*/

Encounters E without Medications M such that E.relevantPeriod includes M.relevantPeriod

/*
is equivalent to
*/

select *
  from Encounters E
  where not exists (select * from Medications M where E.relevantPeriod includes M.relevantPeriod)

// Combining With/without

/*
Because with and without apply to the whole query, you can't combine them optionally in
the same query. To do that, you can either:

1) Use a union to combine the results:
*/

EncountersWithComfortMeasures union EncountersWithASpecificDischarge

/*
2) Combine the logic within a single query using or:
*/

Encounters E
  where exists (ComfortMeasures C where C.relevantPeriod during E.relevantPeriod)
    or E.dischargeStatus in ExpectedDischargeStatuses


    ["Encounter, Performed": "Encounter Inpatient" ] Encounter
        where "Encounter.dischargeDisposition" in "Patient Expired"
          and (
            not "Newborn Hearing Screening Left"
              or not "Newborn Hearing Screening Right"
          )

    ["Encounter, Performed": "Encounter Inpatient" ] Encounter
        where ("Encounter.dischargeDisposition" in "Patient Expired"
          and not "Newborn Hearing Screening Left")
              or not "Newborn Hearing Screening Right"


    // behavior is additive
    ["Encounter, Performed": "Encounter Inpatient" ] Encounter
      without "Newborn Hearing Screening Left" Left such that Left.relevantPeriod during Encounter.relevantPeriod
      without "Newborn Hearing Screening Right" Right such that Right.relevantPeriod during Encounter.relevantPeriod
      where Encounter.dischargeDisposition in "Patient Expired"

    define "Encounters Without Left":
      ["Encounter, Performed": "Encounter Inpatient" ] Encounter
        without "Newborn Hearing Screening Left" Left such that Left.relevantPeriod during Encounter.relevantPeriod

    define "Encounters Without Right":
    ["Encounter, Performed": "Encounter Inpatient" ] Encounter
      without "Newborn Hearing Screening Right" Right such that Right.relevantPeriod during Encounter.relevantPeriod

    define "Encounters Without Screening":
      "Encounters Without Left" union "Encounters Without Right"
