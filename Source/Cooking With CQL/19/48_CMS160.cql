library Test160 version '0.0.021'

// This example is an excerpt of CMS160
// Only the relevant logic is included

using QDM version '5.3'

valueset "Dysthymia": 'urn:oid:2.16.840.1.113883.3.67.1.101.1.254'
valueset "Major Depression Including Remission": 'urn:oid:2.16.840.113883.3.67.1.101.3.2444'
valueset "Psych Visit": 'urn:oid:2.16.840.113883.3.67.1.101.3.2445'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "First Third": Interval[start of "Measurement Period", start of "Measurement Period" + 4 months)

define "Second Third": Interval[start of "Measurement Period" + 4 months, start of "Measurement Period" + 8 months)

define "Third Third": Interval[start of "Measurement Period" + 8 months, end of "Measurement Period")

define "Depression Behavioral Health Encounters":
	["Encounter, Performed": "Psych Visit"] BehaviorHealthEncounter
		where ( BehaviorHealthEncounter.principalDiagnosis in "Major Depression Including Remission"
				or BehaviorHealthEncounter.principalDiagnosis in "Dysthymia"
		)

// Suggest defining expressions for the ranges here
define "Depression Behavioral Health Encounter 1":
	"Depression Behavioral Health Encounters" BehaviorHealthEncounter1
		  where BehaviorHealthEncounter1.relevantPeriod ends during "First Third"
			//and BehaviorHealthEncounter1.relevantPeriod ends during "Measurement Period"
			//and difference in months between end of BehaviorHealthEncounter1.relevantPeriod and end of "Measurement Period" <= 2

define "Depression Behavioral Health Encounter 2":
	"Depression Behavioral Health Encounters" BehaviorHealthEncounter2
		  where BehaviorHealthEncounter2.relevantPeriod ends during "Second Third"
			//and BehaviorHealthEncounter2.relevantPeriod ends 8 months or less after start of "Measurement Period"
			//and difference in months between end of BehaviorHealthEncounter2.relevantPeriod and ( start of "Measurement Period" + 8 months ) <= 4

define "Depression Behavioral Health Encounter 3":
	"Depression Behavioral Health Encounters" BehaviorHealthEncounter3
		  where BehaviorHealthEncounter3.relevantPeriod ends during "Third Third"
			//and BehaviorHealthEncounter3.relevantPeriod ends during "Measurement Period"
			//and difference in months between start of "Measurement Period" and end of BehaviorHealthEncounter3.relevantPeriod <= 3

