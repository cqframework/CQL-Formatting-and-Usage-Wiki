library Adult_Outpatient_Encounters version '1.3.000'

/*
Update to 5.6 to get class attribute
*/
using QDM version '5.6'

/*
Include global to get class definitions:
*/
include MATGlobalCommonFunctions version '6.2.000' called Global

valueset "Annual Wellness Visit": 'urn:oid:2.16.840.1.113883.3.526.3.1240'
valueset "Home Healthcare Services": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1016'
valueset "Office Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1023'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Qualifying Encounters":
  ( ["Encounter, Performed": "Office Visit"]
  	union ["Encounter, Performed": "Annual Wellness Visit"]
  	union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
  	union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
  	union ["Encounter, Performed": "Home Healthcare Services"] ) ValidEncounter
  	where ValidEncounter.relevantPeriod during "Measurement Period"

/*
Can now use this notion of encounter class instead:
*/
define "Qualifying Encounters (1)":
  (
    ["Encounter, Performed": Global."Ambulatory Encounter Class"]
      union ["Encounter, Performed": Global."Home Health Encounter Class"]
      union ["Encounter, Performed": Global."Virtual Encounter Class"]
  ) ValidEncounter
    where ValidEncounter.relevantPeriod during "Measurement Period"
