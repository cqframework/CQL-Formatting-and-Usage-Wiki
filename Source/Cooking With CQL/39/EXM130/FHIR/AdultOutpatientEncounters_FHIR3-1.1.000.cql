library AdultOutpatientEncounters_FHIR3 version '1.1.000'

/*
This example is a work in progress and should not be considered a final specification
or recommendation for guidance. This example will help guide and direct the process
of finding conventions and usage patterns that meet the needs of the various stakeholders
in the measure development community.
*/

using FHIR version '3.0.0'

include FHIRHelpers version '3.0.0' called FHIRHelpers

valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Annual Wellness Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1240'
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023'
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016'

context Patient

define function "Qualifying Encounters"(MeasurementPeriod Interval<DateTime>):
	(
	    [Encounter: "Office Visit"]
		union [Encounter: "Annual Wellness Visit"] 
		union [Encounter: "Preventive Care Services - Established Office Visit, 18 and Up"] 
		union [Encounter: "Preventive Care Services-Initial Office Visit, 18 and Up"] 
		union [Encounter: "Home Healthcare Services"]
    ) ValidEncounter
		where ValidEncounter.period during day of MeasurementPeriod
		and ValidEncounter.status  = 'finished' 
