library AgeCalculation

/*
This library illustrates common examples for calculation of patient age in a quality measures
*/

using QDM version '5.3'

include MATGlobalCommonFunctions version '2.0.000' called Global

codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'

valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'

code "Birthdate": '21112-8' from "LOINC" display 'Birth date'

parameter "Measurement Period" Interval<DateTime>

context Patient

// Age at start of measurement period
define "Is 18 or Over at Start of Measurement Period":
  exists ( ["Patient Characteristic Birthdate": "Birthdate"] BirthDate 
    where Global."CalendarAgeInYearsAt"(BirthDate.birthDatetime, start of "Measurement Period") >= 18
  )

// Age at start of encounter
define "Inpatient Encounters with a Patient 18 or Over":
	["Encounter, Performed": "Encounter Inpatient"] EncounterInpatient
    with ["Patient Characteristic Birthdate": "Birthdate"] BirthDate
      such that Global."CalendarAgeInYearsAt"(BirthDate.birthDatetime, start of EncounterInpatient.relevantPeriod) >= 18

