library EXM146 version '4'

/*
  Based on CMS146v3
  Appropriate Testing for Children with Pharyngitis

  Episode-Of-Care-Based Proportion Measure

  This example is a work in progress and should not be considered a final specification
  or recommendation for guidance. This example will help guide and direct the process
  of finding conventions and usage patterns that meet the needs of the various stakeholders
  in the measure development community.
*/

using QDM version '5.0.2'

include Common version '1' called Common

valueset "Acute Pharyngitis": 'urn:oid:2.16.840.1.113883.3.464.1003.102.12.1011'
valueset "Acute Tonsillitis": 'urn:oid:2.16.840.1.113883.3.464.1003.102.12.1012'
valueset "Ambulatory/ED Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1061'
valueset "Antibiotic Medications": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1001'
valueset "Group A Streptococcus Test": 'urn:oid:2.16.840.1.113883.3.464.1003.198.12.1012'

parameter "Measurement Period" Interval<DateTime>

context Patient

// Region: Initial Population

define "In Demographic":
  AgeInYearsAt(start of "Measurement Period") >= 2
    and AgeInYearsAt(start of "Measurement Period") < 18

define "Antibiotics":
  ["Medication, Order": "Antibiotic Medications"]

define "Pharyngitis":
  ["Diagnosis": "Acute Pharyngitis"] union ["Diagnosis": "Acute Tonsillitis"]

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

define "Initial Population":
  "Pharyngitis Encounters With Antibiotics"

// EndRegion: Initial Population

// Region: Denominator

// None

// EndRegion: Denominator

// Region: Denominator Exclusions

define "Pharyngitis With Prior Antibiotics":
  "Pharyngitis" Pharyngitis
    with "Antibiotics" Antibiotics
      such that Antibiotics.authorDatetime 30 days or less before start of Pharyngitis.prevalencePeriod

define "Excluded Encounters":
  "Pharyngitis Encounters With Antibiotics" Encounters
    with "Pharyngitis With Prior Antibiotics" Pharyngitis
      such that Common."Includes Or Starts During"(Pharyngitis, Encounters)

define "Denominator Exclusions":
  "Excluded Encounters"

// EndRegion: Denominator Exclusions

// Region: Denominator Exceptions

// None

// EndRegion: Denominator Exceptions

// Region: Numerator

define "Strep Test Encounters":
  "Pharyngitis Encounters With Antibiotics" Encounters
    with ["Laboratory Test, Performed": "Group A Streptococcus Test"] Test
      such that Test.result is not null
        and Test.relevantPeriod starts during Interval[start of Encounters.relevantPeriod - 3 days, end of Encounters.relevantPeriod + 3 days]

define "Numerator":
   "Strep Test Encounters"

// EndRegion: Numerator

// Region: Numerator Exclusion

// None

// EndRegion: Numerator Exclusion
