library Adult_Outpatient_Encounters version '1.1.000'

using QDM version '5.3'

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

valueset "Office Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Annual Wellness Visit": 'urn:oid:2.16.840.1.113883.3.526.3.1240'
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1023'
valueset "Home Healthcare Services": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1016'

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Qualifying Encounters":
	( ["Encounter, Performed": "Office Visit"]
		union ["Encounter, Performed": "Annual Wellness Visit"]
		union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
		union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
		union ["Encounter, Performed": "Home Healthcare Services"] ) ValidEncounter
		where ValidEncounter.relevantPeriod during "Measurement Period"
