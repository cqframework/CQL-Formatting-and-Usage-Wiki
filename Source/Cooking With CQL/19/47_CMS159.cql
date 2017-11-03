library Test159 version '0.0.020'

// This example is an excerpt of CMS159
// Only the relevant logic is included

using QDM version '5.3'

valueset "Dysthymia": 'urn:oid:2.16.840.1.113883.3.67.1.101.1.254'
valueset "Bipolar Disorder": 'urn:oid:2.16.840.1.113883.3.67.1.101.1.128'
valueset "Major Depression Including Remission": 'urn:oid:2.16.840.113883.3.67.1.101.3.2444'
valueset "Personality Disorder": 'urn:oid:2.16.840.1.113883.3.67.1.101.1.246'
valueset "Care Services in Long-Term Residential Facility": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1014'
valueset "Face to Face Interaction - No ED": 'urn:oid:2.16.840.1.113762.1.4.1080.1'
valueset "Office Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Psych Visit": 'urn:oid:2.16.840.113883.3.67.1.101.3.2445'
valueset "Palliative Care": 'urn:oid:2.16.840.1.113883.3.600.1.1579'
valueset "PHQ-9 Tool": 'urn:oid:2.16.840.1.113883.3.67.1.101.11.723'
valueset "Palliative care encounter": 'urn:oid:2.16.840.1.113883.3.600.1.1575'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
// Use of parentheses versus brackets in the Interval definition
define "Depression Office Visit Encounter":
	["Encounter, Performed": "Office Visit"] OfficeVisitEncounter
		with "Union Diagnoses" Diagnoses
			such that OfficeVisitEncounter.relevantPeriod overlaps Diagnoses.prevalencePeriod
		where OfficeVisitEncounter.relevantPeriod ends during Interval [ start of "Measurement Period" - 12 months, start of "Measurement Period" )

// Collapse these to "Depression Encounters"
define "Depression Face to Face Encounter":
	["Encounter, Performed": "Face to Face Interaction - No ED"] FacetoFaceEncounter
		with "Union Diagnoses" Diagnoses
			such that FacetoFaceEncounter.relevantPeriod overlaps Diagnoses.prevalencePeriod
		where FacetoFaceEncounter.relevantPeriod ends during Interval [ start of "Measurement Period" - 12 months, start of "Measurement Period" )

define "Depression Behavioral Health Encounter":
	["Encounter, Performed": "Psych Visit"] BehaviorHealthEncounter
		where ( BehaviorHealthEncounter.principalDiagnosis in "Major Depression Including Remission"
				or BehaviorHealthEncounter.principalDiagnosis in "Dysthymia"
		)
			and BehaviorHealthEncounter.relevantPeriod ends during Interval [ start of "Measurement Period" - 12 months, start of "Measurement Period" )
*/

define "Depression Encounters":
  (
		["Encounter, Performed": "Office Visit"]
			union ["Encounter, Performed": "Face to Face Interaction - No ED"]
			union (
			["Encounter, Performed": "Psych Visit"] BehaviorHealthEncounter
				where ( BehaviorHealthEncounter.principalDiagnosis in "Major Depression Including Remission"
						or BehaviorHealthEncounter.principalDiagnosis in "Dysthymia"
				)
			)
	) Encounter
		where Encounter.relevantPeriod ends during Interval[start of "Measurement Period" - 12 months, start of "Measurement Period")

define "Index Depression Assessment":
	["Assessment, Performed": "PHQ-9 Tool"] IndexAssessment
		with ( "Depression Office Visit Encounter"
			union "Depression Face to Face Encounter"
			union "Depression Behavioral Health Encounter" ) IndexDepressionEncounter
			such that IndexAssessment.authorDatetime during IndexDepressionEncounter.relevantPeriod
		where IndexAssessment.result > 9

define "Index Depression Assessment":
	["Assessment, Performed": "PHQ-9 Tool"] IndexAssessment
		with "Depression Encounters" IndexDepressionEncounter
			such that IndexAssessment.authorDatetime during IndexDepressionEncounter.relevantPeriod
		where IndexAssessment.result > 9

define "First Index Depression Assessment":
	First("Index Depression Assessment" FirstIndexAssessment
			where FirstIndexAssessment.authorDatetime is not null
			sort by authorDatetime
	)

// Use of List is an "anti-pattern" here, create a "First Index Depression Assessment Date" instead
// Based on the measure guidance, this ought to be 11 months?
// But really, the "grace period" is 30 days, so shouldn't it be +/- 30 days, rather than 1 month?
define "Numerator":
	exists ( ["Assessment, Performed": "PHQ-9 Tool"] DepressionAssessment
			//with ( List { "First Index Depression Assessment" } ) FirstIndexAssessment
			//	such that DepressionAssessment.authorDatetime in Interval ( FirstIndexAssessment.authorDatetime + 10 months, FirstIndexAssessment.authorDatetime + 13 months )
			where DepressionAssessment.authorDatetime in 
				Interval["First Index Depression Assessment".authorDatetime + 12 months - 30 days, 
					"First Index Depression Assessment".authorDatetime  + 12 months + 30 days
				]
			 and DepressionAssessment.result < 5
	)

// The name "Union Diagnoses" could be more descriptive
define "Depression Diagnoses":
	( ["Diagnosis": "Major Depression Including Remission"]
		union ["Diagnosis": "Dysthymia"] ) Diagnoses
		where Diagnoses.prevalencePeriod is not null
