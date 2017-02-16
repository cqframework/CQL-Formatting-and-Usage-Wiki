library MultipleWithClauses version '1.0.0'

using QDM version '5.0.2'

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'
valueset "Non-Elective Inpatient Encounter": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.424'
valueset "Comfort Measures Value Set": 'urn:oid:1.3.6.1.4.1.33895.1.3.0.45'

define "Comfort Measures":
  ["Intervention, Performed": "Comfort Measures Value Set"] Intervention

// The such that is combining references to multiple with clauses:
define "Nonelective Inpatient Encounters with Comfort Measures":
  "Nonelective Inpatient" inp
    with ["Encounter, Performed": "Emergency Department Visit"] ed
    with "Comfort Measures" comf
      such that ed.relevantPeriod ends 1 hour or less before start of inp.relevantPeriod
        and comf.relevantPeriod starts during ed.relevantPeriod

// Using a nested with allows you to state the relationship
define "Nonelective Inpatient Encounters with Comfort Measures":
  "Nonelective Inpatient" inp
    with (
      ["Encounter, Performed": "Emergency Department Visit"] ed
        with "comfort measures" comf such that comf.relevantPeriod starts during ed.relevantPeriod
    ) ed
      such that ed.relevantPeriod ends 1 hour or less before start of inp.relevantPeriod

// This can be made more clear by defining a separate expression for the nesting
define "ED Visits with Comfort Measures":
  ["Encounter, Performed": "Emergency Department Visit"] ed
    with "Comfort Measures" comf such that comf.relevantPeriod starts during ed.relevantPeriod

define "Nonelective Inpatient Encounters with Comfort Measures":
  "Nonelective Inpatient" inp
    with "ED Visits with Comfort Measures" ed
      such that ed.relevantPeriod ends 1 hour or less before start of inp.relevantPeriod
