library AgeCalculationExample

using QDM version '5.6'

include MATGlobalCommonFunctions version '6.3.000' called Global
include MATGlobalCommonFunctions version '7.0.000' called Global7
include AdultOutpatientEncounters version '2.0.001' called AdultOutpatientEncounters

codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'

/* CMS165 Supporting Definitions */
valueset "Essential Hypertension": 'urn:oid:2.16.840.1.113883.3.464.1003.104.12.1011'
valueset "Online Assessments": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1089'
valueset "Telephone Visits": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1080'

/* CMS74 Supporting Definitions */
valueset "Clinical Oral Evaluation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.125.12.1003'
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Preventive Care - Established Office Visit, 0 to 17": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1024'
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023'
valueset "Preventive Care- Initial Office Visit, 0 to 17": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1022'

/* CMS124 Supporting Definitions */
valueset "HPV Test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1059'

code "Birth date": '21112-8' from "LOINC" display 'Birth date'

parameter "Measurement Period" Interval<DateTime> default Interval[@2019-01-01T00:00:00.0, @2020-01-01T00:00:00.0)

context Patient

// From CMS165 - Controlling Blood Pressure

// With CalendarAgeInYearsAt
define "Initial Population (165)":
  exists ["Patient Characteristic Birthdate": "Birth date"] BirthDate
    where Global."CalendarAgeInYearsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) in Interval[18, 85 )
      and exists "Essential Hypertension Diagnosis"
      and ( exists AdultOutpatientEncounters."Qualifying Encounters"
          or exists ( ( ["Encounter, Performed": "Telephone Visits"]
              union ["Encounter, Performed": "Online Assessments"] ) Telehealth
              where Telehealth.relevantPeriod during "Measurement Period"
          )
      )

// NOTE: Preference for use of inclusive boundaries (closed bracket) to avoid potential confusion with operation invocation syntax
define "Initial Population (165) (Global v7)":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[18, 84]
      and exists "Essential Hypertension Diagnosis"
      and ( exists AdultOutpatientEncounters."Qualifying Encounters"
          or exists ( ( ["Encounter, Performed": "Telephone Visits"]
              union ["Encounter, Performed": "Online Assessments"] ) Telehealth
              where Telehealth.relevantPeriod during "Measurement Period"
          )
      )

// From CMS74 - Primary Caries Prevention

define "Stratification 1 (74)":
  exists ( ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      where Global."CalendarAgeInMonthsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) >= 6
        and Global."CalendarAgeInYearsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) <= 4
  )

define "Stratification 1 (74) (Global v7)":
  AgeInMonthsAt(date from start of "Measurement Period" ) >= 6
    and AgeInYearsAt(date from start of "Measurement Period" ) <= 4

define "Stratification 2 (74)":
  exists ["Patient Characteristic Birthdate": "Birth date"] BirthDate
    where Global."CalendarAgeInYearsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) in Interval[5, 11]

define "Stratification 2 (74) (Global v7)":
  AgeInYearsAt(date from start of "Measurement Period" ) in Interval[5, 11]

define "Stratification 3 (74)":
  exists ["Patient Characteristic Birthdate": "Birth date"] BirthDate
    where Global."CalendarAgeInYearsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) in Interval[12, 20 )

// NOTE: Preference for use of inclusive boundaries (closed bracket) to avoid potential confusion with operation invocation syntax
define "Stratification 3 (74) (Global v7)":
  AgeInYearsAt(date from start of "Measurement Period" ) in Interval[12, 19]

define "Initial Population (74)":
  exists ( ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      where Global."CalendarAgeInMonthsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) >= 6
        and Global."CalendarAgeInYearsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) < 20
  )
    and exists ( "Qualifying Encounters" )

define "Initial Population (74) (Global v7)":
  exists ( "Qualifying Encounters" )
    and AgeInMonthsAt(date from start of "Measurement Period" ) >= 6
    and AgeInYearsAt(date from start of "Measurement Period" ) <= 19

// From CMS124 - Cervical Cancer Screening

define "HPV Test Within 5 Years for Women Age 30 and Older (124)":
  ["Laboratory Test, Performed": "HPV Test"] HPVTest
    with ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      such that Global."CalendarAgeInYearsAt" ( BirthDate.birthDatetime, HPVTest.relevantDatetime ) >= 30
    where Global."LatestOf" ( HPVTest.relevantDatetime, HPVTest.relevantPeriod ) 5 years or less on or before
    end of "Measurement Period"
      and HPVTest.result is not null

define "HPV Test Within 5 Years for Women Age 30 and Older (124) (Global v7)":
  ["Laboratory Test, Performed": "HPV Test"] HPVTest
    where Global7.LatestOf(HPVTest.relevantDatetime, HPVTest.relevantPeriod) 5 years or less on or before
    end of "Measurement Period"
      and HPVTest.result is not null
      and AgeInYearsAt(date from start of Global7.NormalizeInterval(HPVTest.relevantDatetime, HPVTest.relevantPeriod)) >= 30



/*
CMS165 Supporting definitions
*/

define "Essential Hypertension Diagnosis":
  ["Diagnosis": "Essential Hypertension"] Hypertension
    where Hypertension.prevalencePeriod overlaps Interval[start of "Measurement Period", start of "Measurement Period" + 6 months )

/*
CMS74 Supporting definitions
*/

define "Qualifying Encounters":
  ( ["Encounter, Performed": "Office Visit"]
    union ["Encounter, Performed": "Preventive Care - Established Office Visit, 0 to 17"]
    union ["Encounter, Performed": "Preventive Care- Initial Office Visit, 0 to 17"]
    union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
    union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
    union ["Encounter, Performed": "Clinical Oral Evaluation"]
    union ["Encounter, Performed": "Telephone Visits"]
    union ["Encounter, Performed": "Online Assessments"] ) ValidEncounter
    where ValidEncounter.relevantPeriod during "Measurement Period"

/*
CMS124 Supporting definitions
*/
