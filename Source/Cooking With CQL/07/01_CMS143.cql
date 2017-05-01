// Numerator with Diagnostic Study (CMS143)

library CMS143

using QDM version '5.0'

valueset "Cup to Disc Ratio": 'Cup to Disc Ratio'
valueset "Optic Disc Exam for Structural Abnormalities": 'Optic Disc Exam for Structural Abnormalities'
valueset "Ophthalmological Services": 'Ophthalmological Services'
valueset "Care Services in Long-Term Residential Facility": 'Care Services in Long-Term Residential Facility'
valueset "Nursing Facility Visit": 'Nursing Facility Visit'
valueset "Office Visit": 'Office Visit'
valueset "Outpatient Consultation": 'Outpatient Consultation'
valueset "Face-to-Face Interaction": 'Face-to-Face Interaction'

parameter "Measurement Period" Interval<DateTime>

/*
Numerator =
  AND: "Diagnostic Study, Performed: Cup to Disc Ratio (result)"
    during Occurrence A of $EyeCareEncounters
  AND: "Diagnostic Study, Performed: Optic Disc Exam for Structural Abnormalities (result)"
    during Occurrence A of $EyeCareEncounters
*/

define "Cup to Disc Ratio Study":
  ["Diagnostic Study, Performed": "Cup to Disc Ratio"] Study
    where Study.result is not null

define "Optic Disc Exam for Structural Abnormalities Study":
  ["Diagnostic Study, Performed": "Optic Disc Exam for Structural Abnormalities"] Study
    where Study.result is not null

define "Numerator":
  "Eye Care Encounters" Encounter
    with "Cup to Disc Ratio Study" Study
      such that Study.relevantPeriod during Encounter.relevantPeriod
    with "Optic Disc Exam for Structural Abnormalities Study" Study
      such that Study.relevantPeriod during Encounter.relevantPeriod

/*
$EyeCareEncounters =
  Union of:
    "Encounter, Performed: Ophthalmological Services"
    "Encounter, Performed: Care Services in Long-Term Residential Facility"
    "Encounter, Performed: Nursing Facility Visit"
    "Encounter, Performed: Office Visit"
    "Encounter, Performed: Outpatient Consultation"
    "Encounter, Performed: Face-to-Face Interaction"
    during "Measurement Period"
*/

define "Eye Care Encounters":
  distinct (
      ["Encounter, Performed": "Ophthalmological Services"]
        union ["Encounter, Performed": "Care Services in Long-Term Residential Facility"]
        union ["Encounter, Performed": "Nursing Facility Visit"]
        union ["Encounter, Performed": "Office Visit"]
        union ["Encounter, Performed": "Outpatient Consultation"]
        union ["Encounter, Performed": "Face-to-Face Interaction"]
  ) Encounter
    where Encounter.relevantPeriod during "Measurement Period"
