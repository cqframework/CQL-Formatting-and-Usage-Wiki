library CMS146 version '3'

/*
This document is a walk-through for developing the CQL by translating from the QDM version of a measure.
As such, it contains re-definitions of several expressions as they are modified during the walk-though,
so the library as it is will not compile (duplicate expressions).

The final version of the measure is in the CMS146.cql document, and the Test146_v5_1_Artifacts folder
contains the HQMF output of the measure package from the Measure Authoring Tool.
*/

/*
This example is a work in progress and should not be considered a final specification
or recommendation for guidance. This example will help guide and direct the process
of finding conventions and usage patterns that meet the needs of the various stakeholders
in the measure development community.
*/

using QDM version '5.0.2'

valueset "Acute Pharyngitis": 'urn:oid:2.16.840.1.113883.3.464.1003.102.12.1011'
valueset "Acute Tonsillitis": 'urn:oid:2.16.840.1.113883.3.464.1003.102.12.1012'
valueset "Ambulatory/ED Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1061'
valueset "Antibiotic Medications": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1001'
valueset "Group A Streptococcus Test": 'urn:oid:2.16.840.1.113883.3.464.1003.198.12.1012'

parameter MeasurementPeriod Interval<DateTime>

context Patient

/*
    Data Criteria =
        "Diagnosis: Acute Pharyngitis" using "Acute Pharyngitis Grouping Value Set (2.16.840.1.113883.3.464.1003.102.12.1011)"
        "Diagnosis: Acute Tonsillitis" using "Acute Tonsillitis Grouping Value Set (2.16.840.1.113883.3.464.1003.102.12.1012)"
        "Encounter, Performed: Ambulatory/ED Visit" using "Ambulatory/ED Visit Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1061)"
        "Laboratory Test, Performed: Group A Streptococcus Test" using "Group A Streptococcus Test Grouping Value Set (2.16.840.1.113883.3.464.1003.198.12.1012)"
        "Medication, Active: Antibiotic Medications for Pharyngitis" using "Antibiotic Medications for Pharyngitis Grouping Value Set (2.16.840.1.113883.3.464.1003.196.12.1001)"
        "Medication, Order: Antibiotic Medications for Pharyngitis" using "Antibiotic Medications for Pharyngitis Grouping Value Set (2.16.840.1.113883.3.464.1003.196.12.1001)"
*/

/*
First we'll define expressions for all the data criteria, so we can reference them directly:
*/

define "Diagnosis: Acute Pharyngitis":
  ["Diagnosis": "Acute Pharyngitis"]

define "Diagnosis: Acute Tonsillitis":
  ["Diagnosis": "Acute Tonsillitis"]

define "Encounter, Performed: Ambulatory or ED Visit":
  ["Encounter, Performed": "Ambulatory/ED Visit"]

define "Laboratory Test, Performed: Group A Streptococcus Test":
  ["Laboratory Test, Performed": "Group A Streptococcus Test"]

define "Medication, Active: Antibiotic Medications for Pharyngitis":
  ["Medication, Active": "Antibiotic Medications for Pharyngitis"]

define "Medication, Order: Antibiotic Medications for Pharyngitis":
  ["Medication, Order": "Antibiotic Medications for Pharyngitis"]

/*
    Item Count: "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"

    Initial Population =
        AND: Age>= 3 year(s) at: "Measurement Period"
        AND: Age< 18 year(s) at: "Measurement Period"
        AND: "Occurrence A of Encounter, Performed: Ambulatory/ED Visit" during "Measurement Period"
        AND: "Medication, Order: Antibiotic Medications for Pharyngitis" <= 3 day(s) starts after start of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
        AND: Union of:
            "Occurrence A of Diagnosis: Acute Pharyngitis" satisfies any:
                starts during "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
                satisfies all:
                    starts before or concurrent with start of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
                    ends after or concurrent with end of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
            "Occurrence A of Diagnosis: Acute Tonsillitis" satisfies any:
                starts during "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
                satisfies all:
                    starts before or concurrent with start of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
                    ends after or concurrent with end of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
*/

/*
This is an encounter-based measure, so the population criteria expressions will need to return lists of Encounters
So we'll start by identifying the set of encounters that form the initial population
*/

/* This initial step identifies the encounters that were performed during the measurement period and where the patient was the appropriate age */
define "Initial Population":
  "Encounter, Performed: Ambulatory or ED Visit" E
    where E.relevantPeriod during "Measurement Period"
      and AgeInYearsAt(start of "Measurement Period") >= 3
      and AgeInYearsAt(start of "Measurement Period") < 18

/* The next step is to add the relationship to medication orders
  AND: "Medication, Order: Antibiotic Medications for Pharyngitis" <= 3 day(s) starts after start of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"

  The medication order is related to "Occurrence A" of the encounter
  So far "Occurrence A" means "encounters during the measurement period and related to the medication"
  So we can express this using a "with" to define the relationship to the medication:
*/

define "Initial Population":
  "Encounter, Performed: Ambulatory or ED Visit" E
    with "Medication, Order: Antibiotic Medications for Pharyngitis" M
      such that M.activeDatetime 3 days or less after start of E.relevantPeriod
    where E.relevantPeriod during "Measurement Period"
      and AgeInYearsAt(start of "Measurement Period") >= 3
      and AgeInYearsAt(start of "Measurement Period") < 18

/* The next step is to add the relationship to the diagnoses
AND: Union of:
    "Occurrence A of Diagnosis: Acute Pharyngitis" satisfies any:
        starts during "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
        satisfies all:
            starts before or concurrent with start of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
            ends after or concurrent with end of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
    "Occurrence A of Diagnosis: Acute Tonsillitis" satisfies any:
        starts during "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
        satisfies all:
            starts before or concurrent with start of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
            ends after or concurrent with end of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
*/

/* So, in this expression we are looking for diagnoses of pharyngitis or
tonstillitis that started during or overlapped with "Occurrence A" of encounter performed

So to express this, we need to be able to talk about "Occurrence A" of the encounter,
so we'll define an expression that allows us to reference the "Occurrence":
*/

define "Occurrence A of Encounter, Performed: Ambulatory or ED Visit":
  "Encounter, Performed: Ambulatory or ED Visit" E
    with "Medication, Order: Antibiotic Medications for Pharyngitis" M
      such that M.activeDatetime 3 days or less after start of E.relevantPeriod
    where E.relevantPeriod during "Measurement Period"

/*
  And then we'll rewrite the "Initial Population" to use this new "Occurrence A" expression
*/

define "Initial Population":
  "Occurrence A of Encounter, Performed: Ambulatory or ED Visit" E
    where AgeInYearsAt(start of "Measurement Period") >= 3
      and AgeInYearsAt(start of "Measurement Period") < 18

/*
Now we can use the same "Occurrence A" expression to define the diagnoses. We'll start with Pharyngitis:

"Occurrence A of Diagnosis: Acute Pharyngitis" satisfies any:
    starts during "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
    satisfies all:
        starts before or concurrent with start of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
        ends after or concurrent with end of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"

*/

/*
Note that this is also labeled as an occurrence and that's so that we can reference
it as part of the denominator exclusions, so we'll anticipate that and label the expression
as an Occurrence:
*/

define "Occurrence A of Diagnosis: Acute Pharyngitis":
  "Diagnosis: Acute Pharyngitis" D
    with "Occurrence A of Encounter, Performed: Ambulatory or ED Visit" E
      such that D.prevalencePeriod starts during E.relevantPeriod
        or (
          D.prevalencePeriod starts same or before start of E.relevantPeriod
            and D.prevalencePeriod ends same or after end of E.relevantPeriod
        )

/*
Note here that CQL does not have the notion of "specific occurrences" as they are
used in QDM; we are just naming the expressions with "Occurrence A" as a way to
reference the specific encounter we are interested in.
*/

/*
Note also that the second relationship is saying that the prevalence period of the
diagnosis should be entirely included in the relevant period of the encounter:
  starts before and ends after

This is the inverse of the "during" relationship, and CQL has an operator we can use:
  includes
*/

define "Occurrence A of Diagnosis: Acute Pharyngitis":
  "Diagnosis: Acute Pharyngitis" D
    with "Occurrence A of Encounter, Performed: Ambulatory or ED Visit" E
      such that D.prevalencePeriod starts during E.relevantPeriod
        or D.prevalencePeriod includes E.relevantPeriod

/*
Next, we express the tonsillitis diagnosis:

"Occurrence A of Diagnosis: Acute Tonsillitis" satisfies any:
    starts during "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
    satisfies all:
        starts before or concurrent with start of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
        ends after or concurrent with end of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
*/

/*
This is the same relationship to the encounter, but for a different diagnosis:

*/

define "Occurrence A of Diagnosis: Acute Tonsillitis":
  "Diagnosis: Acute Tonsillitis" D
    with "Occurrence A of Encounter, Performed: Ambulatory or ED Visit" E
      such that D.prevalencePeriod starts during E.relevantPeriod
        or D.prevalencePeriod includes E.relevantPeriod

/*
And now we can express the complete initial population:
*/

define "Initial Population":
  "Occurrence A of Encounter, Performed: Ambulatory or ED Visit" E
    where AgeInYearsAt(start of "Measurement Period") >= 3
      and AgeInYearsAt(start of "Measurement Period") < 18
      and exists (
        "Occurrence A of Diagnosis: Acute Pharyngitis"
          union "Occurrence A of Diagnosis: Acute Tonsillitis"
      )

/*
  Encounters that were performed during the measurement period, where the patient
  was between 3 and up to 18 years of age, and had a diagnosis of Acute Pharyngitis
  or Tonsillitis that started during or includes the encounter
*/

/*
    Denominator =
        AND: Initial Population
*/

/*
  The denominator does not define any additional criteria, so we just specify that it
  is the same as the initial population:
*/

define "Denominator":
  "Initial Population"

/*
  We re-express this because recall that since this is an encounter-based measure,
  all the criteria need to return lists of encounters.
*/

/*
    Denominator Exclusions =
        OR: "Medication, Active: Antibiotic Medications for Pharyngitis" < 30 day(s) starts before start of Union of:
            "Occurrence A of Diagnosis: Acute Pharyngitis"
            "Occurrence A of Diagnosis: Acute Tonsillitis"
        OR:
            AND: "Occurrence A of Medication, Active: Antibiotic Medications for Pharyngitis" > 30 day(s) starts before start of "Occurrence A of Diagnosis: Acute Pharyngitis"
            AND NOT: "Occurrence A of Medication, Active: Antibiotic Medications for Pharyngitis" > 30 day(s) ends before start of "Occurrence A of Diagnosis: Acute Pharyngitis"
        OR:
            AND: "Occurrence A of Medication, Active: Antibiotic Medications for Pharyngitis" > 30 day(s) starts before start of "Occurrence A of Diagnosis: Acute Tonsillitis"
            AND NOT: "Occurrence A of Medication, Active: Antibiotic Medications for Pharyngitis" > 30 day(s) ends before start of "Occurrence A of Diagnosis: Acute Tonsillitis"
*/

/*
  For the denominator exclusions, we're looking for antibiotic medications that start
  less than 30 days before the start of the diagnosis, or that started more than 30 days before
  the start of the diagnosis and did not end more than 30 days before the start of the diagnosis
*/

/*
  We'll start with the first scenario:

  OR: "Medication, Active: Antibiotic Medications for Pharyngitis" < 30 day(s) starts before start of Union of:
      "Occurrence A of Diagnosis: Acute Pharyngitis"
      "Occurrence A of Diagnosis: Acute Tonsillitis"
*/

"Medication, Active: Antibiotic Medications for Pharyngitis" M
  with ("Occurrence A of Diagnosis: Acute Pharyngitis" union "Occurrence A of Diagnosis: Acute Tonsillitis") D
    such that M.relevantPeriod starts 29 days or less before start of D.prevalencePeriod

/*
  And the second scenario for Pharyngitis:

  OR:
      AND: "Occurrence A of Medication, Active: Antibiotic Medications for Pharyngitis" > 30 day(s) starts before start of "Occurrence A of Diagnosis: Acute Pharyngitis"
      AND NOT: "Occurrence A of Medication, Active: Antibiotic Medications for Pharyngitis" > 30 day(s) ends before start of "Occurrence A of Diagnosis: Acute Pharyngitis"
*/

"Medication, Active: Antibiotic Medications for Pharyngitis" M
  with "Occurrence A of Diagnosis: Acute Pharyngitis" D
    such that M.relevantPeriod starts 31 days or more before start of D.prevalencePeriod
      and not (M.relevantPeriod ends 31 days or more before start of D.prevalencePeriod)

/*
  Note that we didn't need to do anything to address the specific occurrence on the Medication
  in this case; the only reason it was introduced is to make sure that the same "specific occurrence"
  of the medication satisfies both the starts before and not ends before criteria. Within the
  CQL, we are already expressing both criteria against the same medication.
*/

/*
  And the second scenario for Tonsillitis:

  OR:
      AND: "Occurrence A of Medication, Active: Antibiotic Medications for Pharyngitis" > 30 day(s) starts before start of "Occurrence A of Diagnosis: Acute Tonsillitis"
      AND NOT: "Occurrence A of Medication, Active: Antibiotic Medications for Pharyngitis" > 30 day(s) ends before start of "Occurrence A of Diagnosis: Acute Tonsillitis"
*/

"Medication, Active: Antibiotic Medications for Pharyngitis" M
  with "Occurrence A of Diagnosis: Acute Tonsillitis" D
    such that M.relevantPeriod starts 31 days or more before start of D.prevalencePeriod
      and not (M.relevantPeriod ends 31 days or more before start of D.prevalencePeriod)

/*
  Notice here that this is the same content, we're just referencing a different diagnosis,
  so we can actually combine the diagnoses using a union and reduce this to a single
  expression:
*/

"Medication, Active: Antibiotic Medications for Pharyngitis" M
  with ("Occurrence A of Diagnosis: Acute Pharyngitis" union "Occurrence A of Diagnosis: Acute Tonsillitis") D
    such that M.relevantPeriod starts 31 days or more before start of D.prevalencePeriod
      and not (M.relevantPeriod ends 31 days or more before start of D.prevalencePeriod)


/*
  Now we can express the denominator exclusions.
  Again, this is encounter-based, so the exclusions need to return a list of encounters:
*/

define "Denominator Exclusions":
  "Occurrence A of Encounter, Performed: Ambulatory or ED Visit" E
    where exists (
      "Medication, Active: Antibiotic Medications for Pharyngitis" M
        with ("Occurrence A of Diagnosis: Acute Pharyngitis" union "Occurrence A of Diagnosis: Acute Tonsillitis") D
          such that M.relevantPeriod starts 29 days or less before start of D.prevalencePeriod
    )
    or exists (
      "Medication, Active: Antibiotic Medications for Pharyngitis" M
        with ("Occurrence A of Diagnosis: Acute Pharyngitis" union "Occurrence A of Diagnosis: Acute Tonsillitis") D
          such that M.relevantPeriod starts 31 days or more before start of D.prevalencePeriod
            and not (M.relevantPeriod ends 31 days or more before start of D.prevalencePeriod)
    )

/*
    Numerator =
        AND: Union of:
            "Laboratory Test, Performed: Group A Streptococcus Test (result)" <= 3 day(s) starts before end of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
            "Laboratory Test, Performed: Group A Streptococcus Test (result)" <= 3 day(s) starts after end of "Occurrence A of Encounter, Performed: Ambulatory/ED Visit"
*/

/*
  For the numerator, we want encounters that had a lab test for streptococcus 3 days or less
  before or after the end of the encounter
*/

define "Numerator":
  "Occurrence A of Encounter, Performed: Ambulatory or ED Visit" E
    with "Laboratory Test, Performed: Group A Streptococcus Test" L
      such that L.relevantPeriod starts 3 days or less before end of E.relevantPeriod
        or L.relevantPeriod starts 3 days or less after end of E.relevantPeriod

/*
  This is effectively saying, Laboratory Tests that occurred within 3 days of the end of the encounter,
  which CQL has an operator for "within"
*/

define "Numerator":
  "Occurrence A of Encounter, Performed: Ambulatory or ED Visit" E
    with "Laboratory Test, Performed: Group A Streptococcus Test" L
      such that L.relevantPeriod starts within 3 days of end of E.relevantPeriod

/*
  Also, the (result) in QDM means that we are looking for laboratory tests that have a result,
  so we can define an expression for that:
*/

define "Laboratory Test, Performed: Group A Streptococcus Test (result)":
  "Laboratory Test, Performed: Group A Streptococcus Test" L
    where L.result is not null

/*
  And then we use that expression in the numerator:
*/

define "Numerator":
  "Occurrence A of Encounter, Performed: Ambulatory or ED Visit" E
    with "Laboratory Test, Performed: Group A Streptococcus Test (result)" L
      such that L.relevantPeriod starts within 3 days of end of E.relevantPeriod

/*
    Numerator Exclusions =
        None
    Denominator Exceptions =
        None
    Stratification =
        None
*/
