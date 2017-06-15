library Test31 version '0.0.009'

using QDM version '5.0.2'

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'

codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1' 

valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836' 

valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837' 

valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591' 

valueset "Live Birth Newborn Born in Hospital": 'urn:oid:2.16.840.1.113762.1.4.1046.6' 

valueset "Newborn Hearing Screen Left": 'urn:oid:2.16.840.1.114222.4.1.214079.1.1.3' 

valueset "Newborn Hearing Screen Right": 'urn:oid:2.16.840.1.114222.4.1.214079.1.1.4' 

valueset "Medical Reasons": 'urn:oid:2.16.840.1.114222.4.1.214079.1.1.7' 

valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307' 

valueset "Patient Expired": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.309' 

valueset "Pass Or Refer": 'urn:oid:2.16.840.1.114222.4.1.214079.1.1.6' 

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'

code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity": ["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer": ["Patient Characteristic Payer": "Payer"]

define "SDE Race": ["Patient Characteristic Race": "Race"]

define "SDE Sex": ["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Inpatient Encounters": ["Encounter, Performed": "Encounter Inpatient"] Encounter
    where Encounter.lengthOfStay <= 120 days 
        and Encounter.relevantPeriod ends during "Measurement Period"

define "Encounter with Diagnosis of Live Birth": "Inpatient Encounters" Inpatient
intersect ["Encounter, Performed": "Encounter Inpatient"] Encounter
        where Encounter.diagnosis in "Live Birth Newborn Born in Hospital"

define "Initial Population": exists "Encounter with Diagnosis of Live Birth" 
or exists "DX LiveBirthNewbornBornInHospital"

define "Denominator": "Initial Population"

define "Newborn Hearing Screening Left": ["Diagnostic Study, Performed": "Newborn Hearing Screen Left"] Screenleft
where (Screenleft.result as Code) in "Pass Or Refer"
and Screenleft.result is not null

define "Newborn Hearing Screening Right": ["Diagnostic Study, Performed": "Newborn Hearing Screen Right"] Screenright
where (Screenright.result as Code) in "Pass Or Refer"
and Screenright.result is not null

define "Denominator Exclusions": ["Encounter, Performed": "Encounter Inpatient"]Encounter 
 without ["Diagnostic Study, Performed": "Newborn Hearing Screen Left"] Left
   such that Left.relevantPeriod during Encounter.relevantPeriod 
 without ["Diagnostic Study, Performed": "Newborn Hearing Screen Right"] Right 
   such that Right.relevantPeriod during Encounter.relevantPeriod 
      where Encounter.dischargeDisposition in "Patient Expired"

define "Medical Reason Left": ["Diagnostic Study, Not Performed": "Newborn Hearing Screen Left"] Screen
    where Screen.negationRationale in "Medical Reasons"

define "Medical Reason Right": ["Diagnostic Study, Not Performed": "Newborn Hearing Screen Right"] Screen
    where Screen.negationRationale in "Medical Reasons"

define "Numerator": "Encounter Inpatient" Encounter
where exists "Left Screen or Medical Reason" and exists
 "Right Screen or Medical Reason"

define "DX LiveBirthNewbornBornInHospital": ["Diagnosis": "Live Birth Newborn Born in Hospital"] Diagnosis
with "Inpatient Encounters" Inpatient
such that Diagnosis.prevalencePeriod starts during Inpatient.relevantPeriod

define "Left Screen or Medical Reason": from ["Encounter, Performed": "Encounter Inpatient"] E,
"Newborn Hearing Screening Left" ScreenLeft,
"Medical Reason Left" MedicalLeft
where ScreenLeft.relevantPeriod during E.relevantPeriod
or MedicalLeft.relevantPeriod during E.relevantPeriod

define "Right Screen or Medical Reason": from ["Encounter, Performed": "Encounter Inpatient"] E,
"Newborn Hearing Screening Right" ScreenRight,
"Medical Reason Right" MedicalRight
where ScreenRight.relevantPeriod during E.relevantPeriod 
or MedicalRight.relevantPeriod during E.relevantPeriod

