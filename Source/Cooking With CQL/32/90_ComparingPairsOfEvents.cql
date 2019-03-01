library ComparingPairsOfEvents

/*
This example is based on CMS52v7 - HIV/AIDS: Pneumocystis Jiroveci Pneumonia (PCP) Prophylaxis.
The example illustrates comparing pairs of events.
*/

using QDM version '5.3'

valueset "Office Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Outpatient Consultation": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1008'

parameter "Measurement Period" Interval<DateTime>

context Patient

// NOTE: Removed several union elements as not relevant for this example
define "Qualifying Encounters":
	( ["Encounter, Performed": "Office Visit"]
		union ["Encounter, Performed": "Outpatient Consultation"] ) ValidEncounter
		where ValidEncounter.relevantPeriod during "Measurement Period"
    
define "Followup HIV Visit":
	"Qualifying Encounters" FollowupVisit
		with "Qualifying Encounters" PriorVisit
			such that FollowupVisit.authorDatetime 90 days or more after day of PriorVisit.authorDatetime
