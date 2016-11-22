library CMS104 version '5.2.000'

using QDM version '5.0'

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'
valueset "Non-Elective Inpatient Encounter": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.424'
valueset "Comfort Measures": 'urn:oid:1.3.6.1.4.1.33895.1.3.0.45'
valueset "Antithrombotic ingredient specific": 'urn:oid: 2.16.840.1.113762.1.4.1021.8'
valueset "Antithrombotic Therapy": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.201'
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
valueset "ONC Administrative": 'urn:oid:2.16.840.1.113762.1.4.1'

parameter "Measurement Period" default Interval[@2015-01-01T00:00:00, @2016-01-01T00:00:00)

context Patient
/*QDM Variables
*/

//Region: Initial Population
/*
WAS:
define "Non-Elective Inpatient Encounter":
  ["Encounter, Performed": "Non-Elective Inpatient Encounter VS"] Encounter
    where Encounter.lengthOfStay <= 120 days
      and Encounter.relevantPeriod during "Measurement Period"
      and AgeInYearsAt(start of Encounter.relevantPeriod) >= 18
*/
/* NOTE: AGE is in the encounter variable- should be remove and add to the IPP statement- then we can reuse the variable)
*/
define "Non-Elective Inpatient Encounter":
  ["Encounter, Performed": "Non-Elective Inpatient Encounter"] NonElectiveEncounter
    where NonElectiveEncounter.lengthOfStay <= 120 days
      and NonElectiveEncounter.relevantPeriod ends during "Measurement Period"
	  and AgeInYearsAt(start of NonElectiveEncounter.relevantPeriod) >= 18

define "Encounter with Principal Diagnosis of Hemorrhagic or Ischemic Stroke":
    "Non-Elective Inpatient Encounter" NonElectiveEncounter
        where NonElectiveEncounter.principalDiagnosis in "Hemorrhagic Stroke"
            or NonElectiveEncounter.principalDiagnosis in "Ischemic Stroke"

// TODO: Changed to add the age criteria here, need to add to a where clause as part of a query
define "Initial Population":
  "Encounter with Principal Diagnosis of Hemorrhagic or Ischemic Stroke"
	   and AgeInYearsAt(start of NonElectiveEncounter.relevantPeriod) >= 18

  //EndRegion: Initial Population

//Region: Denominator

define "Encounter with Principal Diagnosis of Ischemic Stroke":
  "Non-Elective Inpatient Encounter" Encounter
    where Encounter.principalDiagnosis in "Ischemic Stroke"

define "Denominator":
    "Initial Population"
        intersect "Encounter with Principal Diagnosis of Ischemic Stroke"

//EndRegion: Denominator

//Region: Denominator Exclusions

// TODO: More discussion here around the choice types
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

// CQL 1.2 using Choice Types
/*
define "Intervention Comfort Measures":
  ["Intervention, Order": "Comfort Measures"]
    union ["Intervention, Performed": "Comfort Measures"]

// Intervention, Order has authorDateTime
// Intervention, Performed has relevantPeriod
*/

define "Encounters with Comfort Measures":
    "Non-Elective Inpatient Encounter" NonElectiveEncounter
        with "Intervention Comfort Measures" ComfortMeasure
            such that ComfortMeasure.authorDatetime during NonElectiveEncounter.relevantPeriod

// Reference to authorDatetime here will result in a warning:
// Element authorDatetime is only available for "Intervention, Order", but the
// source list also includes "Intervention, Performed"

define "Denominator Exclusions":
   distinct ((
    "Non-Elective Inpatient Encounter" Encounter
      where Encounter.dischargeDisposition in "Discharge To Acute Care Facility"
         or Encounter.dischargeDisposition in "Left Against Medical Advice"
         or Encounter.dischargeDisposition in "Patient Expired"
         or Encounter.dischargeDisposition in "Discharged to Home for Hospice Care"
         or Encounter.dischargeDisposition in "Discharged to Health Care Facility for Hospice Care"
    )
     union
       "Encounters with Comfort Measures"
 )

//EndRegion: Denominator Exclusions
//Region: Numerator

define "Antithrombotic Therapy at Discharge":
    ["Medication, Discharge": "Antithrombotic Therapy"] Antithrombotic

define "Numerator":
    "Non-Elective Inpatient Encounter" Encounter
        with "Antithrombotic Therapy at Discharge" such that Antithrombotic.authorDatetime starts during Encounter.relevantPeriod

//EndRegion: Numerator

//Region: Numerator Exclusions
//NONE
//EndRegion: Numerator Exclusions

//Region: Denominator Exceptions

define "Antihthrombotic Not Given at Discharge":
    ["Medication, Not Discharge": "Antithrombotic ingredient specific"] AntithromboticDischarge
        where AntithromboticDischarge.negationRationale in "Medical Reason"
            or AntithromboticDischarge.negationRationale in "Patient Refusal"

define "Denominator Exceptions":
    "Non-Elective Inpatient Encounter" Encounter
        with "Antithrombotic Not Given at Discharge" such that AntithromboticDischarge.authorDatetime starts during Encounter.relevantPeriod

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
