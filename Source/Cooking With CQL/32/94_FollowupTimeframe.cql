library FollowupTimeframe

/*
This example is based on CMS159v7 - Depression Remission at Twelve Months
This example illustrates definning a followup timeframe and looking for events within that timeframe
*/

using QDM version '5.3'

include MATGlobalCommonFunctions version '2.0.000' called Global

codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'

valueset "Contact or Office Visit": 'urn:oid:2.16.840.1.113762.1.4.1080.5'
valueset "Dysthymia": 'urn:oid:2.16.840.1.113883.3.67.1.101.1.254'
valueset "Major Depression Including Remission": 'urn:oid:2.16.840.113883.3.67.1.101.3.2444'

code "Birthdate": '21112-8' from "LOINC" display 'Birth date'
code "Patient Health Questionnaire 9 item (PHQ-9) total score [Reported]": '44261-6' 
  from "LOINC" display 'Patient Health Questionnaire 9 item (PHQ-9) total score [Reported]'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
The measure defines an Index Depression Assessment
*/
define "Index Depression Assessment":
	( First(["Assessment, Performed": "Patient Health Questionnaire 9 item (PHQ-9) total score [Reported]"] DepressionAssessment
				with "Depression Encounter" DepressionEncounter
					such that DepressionAssessment.authorDatetime during DepressionEncounter.relevantPeriod
				where DepressionAssessment.result > 9
					and DepressionAssessment.authorDatetime is not null
				sort by authorDatetime
		)
	)
  
define "Depression Encounter":
	["Encounter, Performed": "Contact or Office Visit"] DepressionEncounter
		with "Depression Diagnoses" Depression
			such that DepressionEncounter.relevantPeriod overlaps Depression.prevalencePeriod
				and DepressionEncounter.relevantPeriod ends during "Denominator Identification Period"

define "Depression Diagnoses":
	["Diagnosis": "Major Depression Including Remission"]
		union ["Diagnosis": "Dysthymia"]

define "Denominator Identification Period":
	Interval[start of "Measurement Period" - 14 months, start of "Measurement Period" - 2 months )

/*
That index assessment is then used to characterize the initial population, patients with
the index depression assessment when they were 12 or older
*/
define "Initial Population":
	exists ( ["Patient Characteristic Birthdate": "Birthdate"] BirthDate
			with "Index Depression Assessment" IndexAssessment
				such that Global."CalendarAgeInYearsAt"(BirthDate.birthDatetime, IndexAssessment.authorDatetime)>= 12
	)

/*
As well as a followup timeframe:
*/

define "Follow-Up Assessment Period":
	"Index Depression Assessment" FirstIndexAssessment
		return Interval[
      Global."ToDate"(FirstIndexAssessment.authorDatetime) + 12 months - 60 days, 
      Global."ToDate"(FirstIndexAssessment.authorDatetime) + 12 months + 60 days
    ]

/*
And then looks for an assessment within that followup timeframe:
*/

define "Numerator":
	Last(["Assessment, Performed": "Patient Health Questionnaire 9 item (PHQ-9) total score [Reported]"] DepressionAssessment
			where Global."ToDate"(DepressionAssessment.authorDatetime) in "Follow-Up Assessment Period"
			sort by authorDatetime
	).result < 5

