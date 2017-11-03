library ChildhoodImmunizationStatusCIS version '0.0.013'

// This example comes from Child Immunization Status from NCQA
// Only the Hepatitis B vaccination criteria is presented here

using QDM version '5.3'

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

valueset "Hepatitis B Vaccine Administered": 'urn:oid:2.16.840.1.113883.3.464.1003.110.12.1042'
valueset "Hepatitis B Vaccine": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1216'
valueset "Hepatitis B Antigen Test": 'urn:oid:2.16.840.1.113883.3.464.1003.198.12.1031'
valueset "Hepatitis B": 'urn:oid:2.16.840.1.113883.3.464.1003.110.12.1025'
valueset "Anaphylactic Reaction to Hepatitis B Vaccine": 'urn:oid:2.16.840.1.113883.3.464.1003.199.12.1029'
valueset "Anti Hepatitis B Virus Surface Ab": 'urn:oid:2.16.840.1.113883.3.464.1003.198.12.1073'
valueset "Hepatitis B Antigen Test Positive": 'urn:oid:2.16.840.1.113762.1.4.1116.11'
valueset "Newborn Hepatitis Vaccine Administered": 'urn:oid:2.16.840.1.113883.3.464.1004.1397'

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'

parameter "Measurement Period" Interval<DateTime>

context Patient

// Measure intent is looking for 3 Hepatitis B vaccinations, each on different days
// However, the first of those vaccinations can be a newborn hepatitis vaccination
// which must be administered between 1 and 8 days of birth

// This expression identifies valid immunizations
define "Hepatitis B Immunizations or Procedures":
	( ["Immunization, Administered": "Hepatitis B Vaccine"]
		union ( ["Procedure, Performed": "Hepatitis B Vaccine Administered"] Procedure
				return "Immunization, Administered" { authorDatetime: start of Procedure.relevantPeriod }
		) ) HepBVaccination
		where AgeInDaysAt(HepBVaccination.authorDatetime)>= 1
			and AgeInDaysAt(HepBVaccination.authorDatetime)<= 730

// This expression works for identifying 3 vaccinations on different days, but does not account 
// for the infant vaccination
/*
define "Hepatitis B Vaccinations":
	from
		( "Hepatitis B Immunizations or Procedures" ) Vaccination1,
		( "Hepatitis B Immunizations or Procedures" ) Vaccination2,
		( "Hepatitis B Immunizations or Procedures" ) Vaccination3
		where Vaccination2.authorDatetime 1 day or more after Vaccination1.authorDatetime
			and Vaccination3.authorDatetime 1 day or more after Vaccination2.authorDatetime
*/

// This expression identifies the infant vaccination, but we now need to combine the above
// pattern so that this vaccination can count for the first of the 3
define "Hepatitis B Vaccination for Newborn":
	( ["Immunization, Administered": "Newborn Hepatitis Vaccine Administered"] Procedure
			with ["Patient Characteristic Birthdate": "Birthdate"] Birthdate
				such that Procedure.authorDatetime 1 day or more after Birthdate.birthDatetime
					and Procedure.authorDatetime 8 day or less after Birthdate.birthDatetime
	)
	
// The solution is to union the two in the first term of the pattern:
define "Hepatitis B Vaccinations":
	from
		( "Hepatitis B Immunizations or Procedures" union "Hepatitis B Vaccination for Newborn" ) Vaccination1,
		( "Hepatitis B Immunizations or Procedures" ) Vaccination2,
		( "Hepatitis B Immunizations or Procedures" ) Vaccination3
		where Vaccination2.authorDatetime 1 day or more after Vaccination1.authorDatetime
			and Vaccination3.authorDatetime 1 day or more after Vaccination2.authorDatetime

