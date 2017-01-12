library EXM105 version '5.2.000'

using QDM version '5.0'

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'
valueset "Non-Elective Inpatient Encounter": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.424'
valueset "Comfort Measures": 'urn:oid:1.3.6.1.4.1.33895.1.3.0.45'
valueset "LDL-c": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.215'
valueset "Statin Allergen": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.423'
valueset "Statin Grouper": 'urn:oid:2.16.840.1.113762.1.4.1110.19'
valueset "Statin ingredient specific": 'urn:oid:2.16.840.1.113762.1.4.1021.7'
valueset "Medical Reason": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.473'
valueset "Patient Refusal": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.93'
valueset "Patient Expired": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.309'
valueset "Left Against Medical Advice": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.308'
valueset "Discharged to Health Care Facility for Hospice Care": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.207'
valueset "Ischemic Stroke": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.247'
valueset "Discharge To Acute Care Facility": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.87'
valueset "Discharged to Home for Hospice Care": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.209'
valueset "Hemorrhagic Stroke": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.212'

valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'

parameter "Measurement Period" default Interval[@2015-01-01T00:00:00, @2016-01-01T00:00:00)

context Patient

/*
$EncounterInpatientNonElective =
  "Encounter, Performed: Non-Elective Inpatient Encounter" satisfies all:
    (length of stay <= 120 day(s))
    ends during "Measurement Period"

$InterventionComfortMeasures =
  Union of:
    "Intervention, Order: Comfort Measures"
    "Intervention, Performed: Comfort Measures"
*/

//Region: Initial Population
/*
Initial Population =
  AND: Age>= 18 year(s) at: Occurrence A of $EncounterInpatientNonElective
  AND:
    OR: Intersection of:
      Occurrence A of $EncounterInpatientNonElective
      "Encounter, Performed: Non-Elective Inpatient Encounter (principal diagnosis: Ischemic Stroke)"
    OR: Intersection of:
      Occurrence A of $EncounterInpatientNonElective
      "Encounter, Performed: Non-Elective Inpatient Encounter (principal diagnosis: Hemorrhagic Stroke)"
*/
define "Non-Elective Encounter":
  ["Encounter, Performed": "Non-Elective Inpatient Encounter"] NonElectiveEncounter
    where NonElectiveEncounter.lengthOfStay <= 120 days
      and NonElectiveEncounter.relevantPeriod ends during "Measurement Period"

define "Encounter with Principal Diagnosis of Hemorrhagic or Ischemic Stroke":
  "Non-Elective Encounter" NonElectiveEncounter
    where NonElectiveEncounter.principalDiagnosis in "Hemorrhagic Stroke"
      or NonElectiveEncounter.principalDiagnosis in "Ischemic Stroke"

define "Initial Population":
  "Encounter with Principal Diagnosis of Hemorrhagic or Ischemic Stroke" NonElectiveEncounter
	   where AgeInYearsAt(start of NonElectiveEncounter.relevantPeriod) >= 18

//EndRegion: Initial Population

//Region: Denominator
/*
Denominator =
  AND: Initial Population
  AND: Intersection of:
    Occurrence A of $EncounterInpatientNonElective
    "Encounter, Performed: Non-Elective Inpatient Encounter (principal diagnosis: Ischemic Stroke)"
*/
define "Encounter with Principal Diagnosis of Ischemic Stroke":
  "Non-Elective Encounter" Encounter
    where Encounter.principalDiagnosis in "Ischemic Stroke"

define "Denominator":
    "Initial Population"
        intersect "Encounter with Principal Diagnosis of Ischemic Stroke"

//EndRegion: Denominator

//Region: Denominator Exclusions
/*
Denominator Exclusions =
  OR: "Laboratory Test, Performed: LDL-c" satisfies all:
    (result < 70 mg/dL)
    satisfies any:
      <= 30 day(s) ends before start of Occurrence A of $EncounterInpatientNonElective
      starts during Occurrence A of $EncounterInpatientNonElective
  OR: Intersection of:
    Occurrence A of $EncounterInpatientNonElective
      "Encounter, Performed: Non-Elective Inpatient Encounter" satisfies any:
        (discharge status: Discharge To Acute Care Facility)
        (discharge status: Left Against Medical Advice)
        (discharge status: Patient Expired)
        (discharge status: Discharged to Home for Hospice Care)
        (discharge status: Discharged to Health Care Facility for Hospice Care)
  OR: $InterventionComfortMeasures starts during ("Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatientNonElective )
  OR: $InterventionComfortMeasures starts during Occurrence A of $EncounterInpatientNonElective
*/

// LA: Not able to use special characters in define statements in the MAT entry
// LA: Getting a lot of errors in the MAT entry
define "LDL-c < 70 mg/dL":
  // LA: Do we want to reference this or do we need to reference Non Elective Inpatient Encounter instead?
  // BR: Either one will work because we are excluding encounters that had LDL < 70, but the denominator already consists
  // of only those encounters with a principal diagnosis of Ischemic Stroke
  "Encounter with Principal Diagnosis of Ischemic Stroke" Encounter
    with ["Laboratory Test, Performed": "LDL-c"] Ldl
     	such that  Ldl.result < 70 'mg/dL'
    		and (Ldl.resultDatetime 30 days or less before start of Encounter.relevantPeriod
          or Ldl.resultDatetime during Encounter.relevantPeriod)

define "Intervention Comfort Measures":
  distinct (
 ["Intervention, Order": "Comfort Measures"]
   union (
    ["Intervention, Performed": "Comfort Measures"] Intervention
       return "Intervention, Order" {
        authorDatetime: start of Intervention.relevantPeriod,
            reason: Intervention.reason
          }
       )
    )

// LA: Original measure has comfort measures either during the ED encounter or
// the Inpatient encounter, this seems to only have the Inpatient encounter.
// Would it be able to model this using EpisodeOfCare? Our intent is to exclude
// anyone with comfort measures during ED, Observation or Inpatient, as long as
// that episode actually ends up as an inpatient admission
// BR: Regarding the ED encounter, we need to define ED visits with comfort measures
// that occurred just prior to the encounter.
// Regarding the use of an EpisodeOfCare, yes, that would be an appropriate use
// of an episode of care, so if we express this measure with FHIR, it could take
// advantage of that construct.
define "Encounters with Comfort Measures":
  "Non-Elective Encounter" NonElectiveEncounter
    with "Intervention Comfort Measures" ComfortMeasure
      such that ComfortMeasure.authorDatetime during NonElectiveEncounter.relevantPeriod

define "ED Encounters with Comfort Measures":
  ["Encounter, Performed": "Emergency Department Visit"] EDEncounter
    with "Intervention Comfort Measures" ComfortMeasure
      such that ComfortMeasure.authorDatetime during EDEncounter.relevantPeriod

define "Encounters with Prior ED Encounters with Comfort Measures":
  "Non-Elective Encounter" NonElectiveEncounter
    with "ED Encounters with Comfort Measures" EDEncounter
      such that EDEncounter.relevantPeriod ends 1 hour or less before start of NonElectiveEncounter.relevantPeriod

// LA: Multiple errors with MAT entry
define "Denominator Exclusions":
  distinct ((
    "Non-Elective Encounter" Encounter
      where Encounter.dischargeDisposition in "Discharge To Acute Care Facility"
         or Encounter.dischargeDisposition in "Left Against Medical Advice"
         or Encounter.dischargeDisposition in "Patient Expired"
         or Encounter.dischargeDisposition in "Discharged to Home for Hospice Care"
         or Encounter.dischargeDisposition in "Discharged to Health Care Facility for Hospice Care"
    )
    union "Encounters with Comfort Measures"
    // LA: Cannot just Or this, as we are describing a list of encounters,
    // but cannot figure out how to add it as an exclusion - want to exclude
    // people with the appropriate discharge statues, or people with comfort measures,
    // or people with an LDL <70 in the specified timeframe
    // BR: Right, the or cannot be used here because we're in an episode-of-care-based
    // measure, so the expressions are returning lists of encounters, rather than
    // true/false values like they would for a patient-based measure.
    // We want to include any of the sets of encounters we've defined for inclusion
    // so we use "union" to combine them all
    union "LDL-c < 70 mg/dL"
    union "Encounters with Prior ED Encounters with Comfort Measures"
  )

//EndRegion: Denominator Exclusions

//Region: Numerator
/*
Numerator =
  AND: "Medication, Discharge: Statin Grouper" starts during Occurrence A of $EncounterInpatientNonElective
*/
define "Statin at Discharge":
    ["Medication, Discharge": "Statin Grouper"] Statin

define "Numerator":
    // LA: Do we want to reference this or the Encounter with Principal Diagnosis
    // of Ischemic Stroke definition?
    // Also, I am getting errors with MAT entry, I think because this definition
    // is referencing an alias that is not in this section, but was already defined
    // in a previous section. How do I get them both in this section?
    "Non-Elective Encounter" Encounter
        with "Statin at Discharge" Statin such that Statin.authorDatetime during Encounter.relevantPeriod

//EndRegion: Numerator

//Region: Numerator Exclusions
//NONE
//EndRegion: Numerator Exclusions

//Region: Denominator Exceptions
/*
Denominator Exceptions =
  OR: "Medication, Allergy: Statin Allergen" starts before or concurrent with end of Occurrence A of $EncounterInpatientNonElective
  OR: Union of:
    "Medication, Discharge not done: Patient Refusal" for "Statin ingredient specific"
    "Medication, Discharge not done: Medical Reason" for "Statin ingredient specific"
    starts during Occurrence A of $EncounterInpatientNonElective
*/
define "Statin Allergy":
  ["Allergy/Intolerance": "Statin Allergen"] Allergy

define "Statin Not Given at Discharge":
  ["Medication, Not Discharged": "Statin ingredient specific"] StatinDischarge
    where StatinDischarge.negationRationale in "Medical Reason"
      or StatinDischarge.negationRationale in "Patient Refusal"

define "Denominator Exceptions":
  // LA: Getting lots of errors with MAT entry- first, do we want to call in the non-elective encounter,
  // or should I really be calling in the Encounters with Principal Diagnosis of Ischemic Stroke
  // Second - there is no attribute of authorDatetime Medication, Not Discharge
  distinct (
    ("Non-Elective Encounter" Encounter
      with "Statin Not Given at Discharge" StatinDischarge such that StatinDischarge.authorDatetime during Encounter.relevantPeriod
    )
      union (
        "Non-Elective Encounter" Encounter
          with "Statin Allergy" Allergy such that Allergy.prevalencePeriod starts same or before end of Encounter.relevantPeriod
      )
  )

//EndRegion: Denominator Exceptions

//Region: Stratification
//NONE
//EndRegion: Stratification

//Region: Supplemental Data Elements

define "SDE Ethnicity":
    ["Patient Characteristic Ethnicity": "Ethnicity"] Characteristic
        return Characteristic.code

define "SDE Payer":
    ["Patient Characteristic Payer": "Payer"] Characteristic
        return Characteristic.code

define "SDE Race":
    ["Patient Characteristic Race": "Race"] Characteristic
        return Characteristic.code

define "SDE Sex":
    ["Patient Characteristic Sex": "ONC Administrative Sex"] Characteristic
        return Characteristic.code

//EndRegion: Supplemental Data Elements
