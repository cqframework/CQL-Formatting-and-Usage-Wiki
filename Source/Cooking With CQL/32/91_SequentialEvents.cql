library SequentialEvents

/*
This example is based on CMS117v7 - Childhood Immunization Status
The example illustrates finding sequential events
*/

using QDM version '5.3'

include MATGlobalCommonFunctions version '2.0.000' called Global

codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'

valueset "DTaP Vaccine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1214'

code "Birthdate": '21112-8' from "LOINC" display 'Birth date'

parameter "Measurement Period" Interval<DateTime>

context Patient

// NOTE: Simplified the union as not relevant to the example
define "DTaP Immunizations or Procedures":
	["Immunization, Administered": "DTaP Vaccine"] DTaPVaccination
		with ["Patient Characteristic Birthdate": "Birthdate"] BirthDate
			such that Global."CalendarAgeInDaysAt"(BirthDate.birthDatetime, DTaPVaccination.authorDatetime) 
        between 42 and 730

define "Four DTaP Vaccinations":
	from
		"DTaP Immunizations or Procedures" DTaPVaccination1,
		"DTaP Immunizations or Procedures" DTaPVaccination2,
		"DTaP Immunizations or Procedures" DTaPVaccination3,
		"DTaP Immunizations or Procedures" DTaPVaccination4
		where DTaPVaccination2.authorDatetime 1 day or more after day of DTaPVaccination1.authorDatetime
			and DTaPVaccination3.authorDatetime 1 day or more after day of DTaPVaccination2.authorDatetime
			and DTaPVaccination4.authorDatetime 1 day or more after day of DTaPVaccination3.authorDatetime
		return DTaPVaccination1
