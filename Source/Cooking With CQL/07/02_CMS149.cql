// Numerator with Risk Category Assessment and Intervention (CMS149)

library CMS149

using QDM version '5.0'

valueset "Psych Visit - Diagnostic Evaluation": 'Psych Visit - Diagnostic Evaluation'
valueset "Nursing Facility Visit": 'Nursing Facility Visit'
valueset "Care Services in Long-Term Residential Facility": 'Care Services in Long-Term Residential Facility'
valueset "Home Healthcare Services": 'Home Healthcare Services'
valueset "Face-to-Face Interaction": 'Face-to-Face Interaction'
valueset "Psych Visit - Psychotherapy": 'Psych Visit - Psychotherapy'
valueset "Behavioral/Neuropsych Assessment": 'Behavioral/Neuropsych Assessment'
valueset "Occupational Therapy Evaluation": 'Occupational Therapy Evaluation'
valueset "Office Visit": 'Office Visit'
valueset "Outpatient Consultation": 'Outpatient Consultation'
valueset "Standardized Tools for Assessment of Cognition": 'Standardized Tools for Assessment of Cognition'
valueset "Cognitive Assessment": 'Cognitive Assessment'

parameter "Measurement Period" Interval<DateTime>

define "Cognition Risk Assessment":
  ["Assessment, Performed": "Standardized Tools for Assessment of Cognition"] Assessment
    where Assessment.result is not null

define "Cognitive Intervention":
  ["Intervention, Performed": "Cognitive Assessment"] Intervention

define "Numerator":
  "DEM Encounters 149" Encounter
    where exists (
        "Cognition Risk Assessment" Assessment
          where Assessment.authorDatetime 12 months or less before end of Encounter.relevantPeriod
      )
      or exists (
        "Cognitive Intervention" Intervention
          where Intervention.relevantPeriod starts 12 months or less before end of Encounter.relevantPeriod
      )

/*
Numerator =
  AND: Union of:
    "Risk Category Assessment: Standardized Tools for Assessment of Cognition (result)"
    "Intervention, Performed: Cognitive Assessment"
    <= 12 month(s) starts before end of Occurrence A of $DEMEncounters149
*/

define "DEM Encounters 149":
  distinct (
    ["Encounter, Performed": "Psych Visit - Diagnostic Evaluation"]
      union ["Encounter, Performed": "Nursing Facility Visit"]
      union ["Encounter, Performed": "Care Services in Long-Term Residential Facility"]
      union ["Encounter, Performed": "Home Healthcare Services"]
      union ["Encounter, Performed": "Face-to-Face Interaction"]
      union ["Encounter, Performed": "Psych Visit - Psychotherapy"]
      union ["Encounter, Performed": "Behavioral/Neuropsych Assessment"]
      union ["Encounter, Performed": "Occupational Therapy Evaluation"]
      union ["Encounter, Performed": "Office Visit"]
      union ["Encounter, Performed": "Outpatient Consultation"]
  ) Encounter
    where Encounter.relevantPeriod during "Measurement Period"

/*
$DEMEncounters149 =
  Union of:
    "Encounter, Performed: Psych Visit - Diagnostic Evaluation"
    "Encounter, Performed: Nursing Facility Visit"
    "Encounter, Performed: Care Services in Long-Term Residential Facility"
    "Encounter, Performed: Home Healthcare Services"
    "Encounter, Performed: Face-to-Face Interaction"
    "Encounter, Performed: Psych Visit - Psychotherapy"
    "Encounter, Performed: Behavioral/Neuropsych Assessment"
    "Encounter, Performed: Occupational Therapy Evaluation"
    "Encounter, Performed: Office Visit"
    "Encounter, Performed: Outpatient Consultation"
    during "Measurement Period"
*/
