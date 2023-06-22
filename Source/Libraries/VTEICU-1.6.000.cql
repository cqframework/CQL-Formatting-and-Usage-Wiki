library VTEICU version '1.6.000'

using QDM version '5.3'

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292' version 'urn:hl7:version:eCQM%20Update%202018%20EP-EC%20and%20EH' 
valueset "ICU Admission or Transfer": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.305' 
valueset "Intensive Care Unit": 'urn:oid:2.16.840.1.113762.1.4.1110.23' 

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'

parameter "Measurement Period" Interval<DateTime>

context Patient

define function "ToDate"(Value DateTime ):
	DateTime(year from Value, month from Value, day from Value, 0, 0, 0, 0, timezone from Value)

define function "CalendarDayOfOrDayAfter"(StartValue DateTime ):
	Interval[StartValue, ToDate(StartValue + 2 days))

define function "First Intensive Care Unit"(Encounter "Encounter, Performed" ):
	First(("Inpatient Locations"(Encounter))L
			where L.code in "Intensive Care Unit"
			sort by start of locationPeriod
	)

define function "Inpatient Locations"(Encounter "Encounter, Performed" ):
	Encounter.facilityLocations L
		where L.locationPeriod during Encounter.relevantPeriod

define function "Start of First ICU"(Encounter "Encounter, Performed" ):
	start of "First Intensive Care Unit"(Encounter).locationPeriod
  
  