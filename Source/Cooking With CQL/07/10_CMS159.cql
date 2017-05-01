// Denominator Exclusion with Expired (CMS159)

library CMS159

using QDM version '5.0'

valueset "Palliative Care": 'Palliative Care'
valueset "Care Services in Long-Term Residential Facility": 'Care Services in Long-Term Residential Facility'
valueset "Bipolar Disorder": 'Bipolar Disorder'
valueset "Personality Disorder": 'Personality Disorder'

parameter "Measurement Period" Interval<DateTime>

define "Palliative Care Order":
  ["Intervention, Order": "Palliative Care"] Order
    where Order.relevantPeriod starts 1 years or less before end of "Measurement Period"

define "Long-Term Residential Facility Encounter":
  ["Encounter, Performed": "Care Services in Long-Term Residential Facility"] Order
    where Order.relevantPeriod starts 1 years or less before end of "Measurement Period"

define "Patient Expired":
  ["Patient Characteristic Expired"] Expired
    where Expired.expiredDateTime before end of "Measurement Period"

define "Bipolar Disorder Diagnosis":
  ["Diagnosis": "Bipolar Disorder"] Diagnosis
    where Diagnosis.prevalencePeriod starts before end of "Measurement Period"

define "Personality Disorder Diagnosis":
["Diagnosis": "Personality Disorder"] Diagnosis
  where Diagnosis.prevalencePeriod starts before end of "Measurement Period"

define "Denominator Exclusions":
  exists ("Palliative Care Order")
    or exists ("Long-Term Residential Facility Encounter")
    or exists ("Patient Expired")
    or exists ("Bipolar Disorder Diagnosis")
    or exists ("Personality Disorder Diagnosis")

/*
Denominator Exclusions =
  OR: Union of:
    "Intervention, Order: Palliative Care"
    "Encounter, Performed: Care Services in Long-Term Residential Facility"
    <= 1 year(s) starts before end of "Measurement Period"
  OR: Union of:
    "Expired : Patient Characteristic Expired"
    "Diagnosis: Bipolar Disorder"
    "Diagnosis: Personality Disorder"
    starts before end of "Measurement Period"
*/
