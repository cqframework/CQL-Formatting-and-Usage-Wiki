// Denominator Exclusion with timing relative to a Diagnosis (CMS154)

library CMS154

using QDM version '5.0'

valueset "Office Visit": 'Office Visit'
valueset "Emergency Department Visit": 'Emergency Department Visit'
valueset "Preventive Care- Initial Office Visit, 0 to 17": 'Preventive Care- Initial Office Visit, 0 to 17'
valueset "Preventive Care - Established Office Visit, 0 to 17": 'Preventive Care - Established Office Visit, 0 to 17'
valueset "Hospital Observation Care - Initial": 'Hospital Observation Care - Initial'
valueset "Face-to-Face Interaction": 'Face-to-Face Interaction'
valueset "Antibiotic Medications for Pharyngitis": 'Antibiotic Medications for Pharyngitis'
valueset "Upper Respiratory Infection": 'Upper Respiratory Infection'
valueset "Competing Conditions for Respiratory Conditions": 'Competing Conditions for Respiratory Conditions'

parameter "Measurement Period" Interval<DateTime>

/*
Denominator Exclusions =
  OR: "Occurrence A of Medication, Active: Antibiotic Medications for Pharyngitis"
    <= 30 day(s) starts before start of "Occurrence A of Diagnosis: Upper Respiratory Infection"
  OR:
    AND: "Occurrence A of Medication, Active: Antibiotic Medications for Pharyngitis"
      > 30 day(s) starts before start of "Occurrence A of Diagnosis: Upper Respiratory Infection"
    AND NOT: "Occurrence A of Medication, Active: Antibiotic Medications for Pharyngitis"
      > 30 day(s) ends before start of "Occurrence A of Diagnosis: Upper Respiratory Infection"
  OR: "Diagnosis: Competing Conditions for Respiratory Conditions"
    <= 3 day(s) starts after start of Occurrence A of $URIEncounter

$URIEncounter =
  Union of:
    "Encounter, Performed: Office Visit"
    "Encounter, Performed: Emergency Department Visit"
    "Encounter, Performed: Preventive Care- Initial Office Visit, 0 to 17"
    "Encounter, Performed: Preventive Care - Established Office Visit, 0 to 17"
    "Encounter, Performed: Hospital Observation Care - Initial"
    "Encounter, Performed: Face-to-Face Interaction"
    during "Measurement Period"
*/

define "URI Encounter":
  distinct (
    ["Encounter, Performed": "Office Visit"]
      union ["Encounter, Performed": "Emergency Department Visit"]
      union ["Encounter, Performed": "Preventive Care- Initial Office Visit, 0 to 17"]
      union ["Encounter, Performed": "Preventive Care - Established Office Visit, 0 to 17"]
      union ["Encounter, Performed": "Hospital Observation Care - Initial"]
      union ["Encounter, Performed": "Face-to-Face Interaction"]
  ) Encounter
    where Encounter.relevantPeriod during "Measurement Period"


/*
Denominator Exclusions =
  OR: "Occurrence A of Medication, Active: Antibiotic Medications for Pharyngitis"
    <= 30 day(s) starts before start of "Occurrence A of Diagnosis: Upper Respiratory Infection"
  OR:
    AND: "Occurrence A of Medication, Active: Antibiotic Medications for Pharyngitis"
      > 30 day(s) starts before start of "Occurrence A of Diagnosis: Upper Respiratory Infection"
    AND NOT: "Occurrence A of Medication, Active: Antibiotic Medications for Pharyngitis"
      > 30 day(s) ends before start of "Occurrence A of Diagnosis: Upper Respiratory Infection"
  OR: "Diagnosis: Competing Conditions for Respiratory Conditions"
    <= 3 day(s) starts after start of Occurrence A of $URIEncounter

*/

define "Competing Diagnosis":
  ["Diagnosis": "Competing Conditions for Respiratory Conditions"]

define "URI Diagnosis":
  ["Diagnosis": "Upper Respiratory Infection"]

define "Pharyngitis Antibiotics":
  ["Medication, Active": "Antibiotic Medications for Pharyngitis"]

define "Pharyngitis Antibiotics Prior to Diagnosis":
  "Pharyngitis Antibiotics" Antibiotics
    with "URI Diagnosis" Diagnosis
      such that Antibiotics.relevantPeriod starts 30 days or less before start of Diagnosis.prevalencePeriod
  union (
    "Pharyngitis Antibiotics" Antibiotics
      with "URI Diagnosis" Diagnosis
        such that Antibiotics.relevantPeriod starts 30 days or more before start of Diagnosis.prevalencePeriod
          and not (Antibotics.relevantPeriod ends 30 days or more before start of Diagnosis.prevalencePeriod)
  )

define "Denominator Exclusions":
  "URI Encounter" Encounter
    with "Pharyngitis Antibiotics Prior to Diagnosis" Diagnosis
      such that Diagnosis.prevalencePeriod overlaps Encounter.relevantPeriod
  union (
    "URI Encounter" Encounter
      with "Competing Diagnosis" Diagnosis
        such that Diagnosis.prevalencePeriod starts 3 days or less after Encounter.relevantPeriod
    )
