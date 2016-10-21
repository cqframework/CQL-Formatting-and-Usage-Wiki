library CMS104 version '5.2.000'

using QDM version '5.0'

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'
valueset "Non-Elective Inpatient Encounter VS": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.424'
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
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'

parameter "Measurement Period" Interval<DateTime>

context Patient

//Region: Initial Population
define "Non-Elective Inpatient Encounter":
  ["Encounter, Performed": "Non-Elective Inpatient Encounter VS"] Encounter
    where Encounter.lengthOfStay <= 120 days
      and Encounter.relevantPeriod during "Measurement Period"
      and AgeInYearsAt(start of Encounter.relevantPeriod) >= 18

define "Encounter with Principal Diagnosis of Hemorrhagic or Ischemic Stroke":
  "Non-Elective Inpatient Encounter" Encounter
    where Encounter.principalDiagnosis in "Hemorrhagic Stroke"
      or Encounter.principalDiagnosis in "Ischemic Stroke"

define "Initial Population":
  "Encounter with Principal Diagnosis of Hemorrhagic or Ischemic Stroke"

//EndRegion: Initial Population

//Region: Denominator

define "Encounter with Principal Diagnosis of Ischemic Stroke":
  "Non-Elective Inpatient Encounter" Encounter
    where Encounter.principalDiagnosis in "Ischemic Stroke"

define "Denominator":
  "Initial Population"
    intersect "Encounter with Principal Diagnosis of Ischemic Stroke"

//EndRegion: Denominaator

//Region: Denominator Exclusions

// The such that clause is only valid as part of a with or without clause in a query
// The union operator combines queries, so in order to express a with clause, you need to create a query
// whose source is the result of the union.
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

define "Encounters with Comfort Measures":
  "Non-Elective Inpatient Encounter" Encounter
    with "Intervention Comfort Measures" ComfortMeasure
      such that ComfortMeasure.authorDatetime during Encounter.relevantPeriod

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
