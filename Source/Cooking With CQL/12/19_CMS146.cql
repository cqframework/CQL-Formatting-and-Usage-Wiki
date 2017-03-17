library CMS146 version '3'

/*
This example illustrates a complete translation of a measure from QDM to CQL. The
Working version provides a walk-through of the development of the measure.
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

define "Diagnosis: Acute Pharyngitis":
  ["Diagnosis": "Acute Pharyngitis"]

define "Diagnosis: Acute Tonsillitis":
  ["Diagnosis": "Acute Tonsillitis"]

define "Encounter, Performed: Ambulatory/ED Visit":
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

define "Occurrence A of Encounter, Performed: Ambulatory/ED Visit":
  "Encounter, Performed: Ambulatory/ED Visit" E
    with "Medication, Order: Antibiotic Medications for Pharyngitis" M
      such that M.relevantPeriod starts 3 days or less after start of E.relevantPeriod
    where E.relevantPeriod during "Measurement Period"

define "Occurrence A of Diagnosis: Acute Pharyngitis":
  "Diagnosis: Acute Pharyngitis" D
    with "Occurrence A of Encounter, Performed: Ambulatory/ED Visit" E
      such that D.prevalencePeriod starts during E.relevantPeriod
        or D.prevalencePeriod includes E.relevantPeriod

define "Occurrence A of Diagnosis: Acute Tonsillitis":
  "Diagnosis: Acute Tonsillitis" D
    with "Occurrence A of Encounter, Performed: Ambulatory/ED Visit" E
      such that D.prevalencePeriod starts during E.relevantPeriod
        or D.prevalencePeriod includes E.relevantPeriod

define "Initial Population":
  "Occurrence A of Encounter, Performed: Ambulatory/ED Visit" E
    where AgeInYearsAt(start of "Measurement Period") >= 3
      and AgeInYearsAt(start of "Measurement Period") < 18
      and exists (
        "Occurrence A of Diagnosis: Acute Pharyngitis"
          union "Occurrence A of Diagnosis: Acute Tonsillitis"
      )

/*
    Denominator =
        AND: Initial Population
*/

define "Denominator":
  "Initial Population"

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

define "Denominator Exclusions":
  "Occurrence A of Encounter, Performed: Ambulatory/ED Visit" E
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

define "Laboratory Test, Performed: Group A Streptococcus Test (result)":
  "Laboratory Test, Performed: Group A Streptococcus Test" L
    where L.result is not null

define "Numerator":
  "Occurrence A of Encounter, Performed: Ambulatory/ED Visit" E
    with "Laboratory Test, Performed: Group A Streptococcus Test (result)" L
      such that L starts within 3 days of end of E.relevantPeriod

/*
    Numerator Exclusions =
        None
    Denominator Exceptions =
        None
    Stratification =
        None
*/
