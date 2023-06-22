library Test05_ScreeningForDepression version '1.0.000'

using QDM version '5.3'

include AnnualWellness version '1.0.000' called AWV

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Depression or Bipolar Disorder": 'urn:oid:2.16.840.1.113883.3.464.1003.105.12.1040'
valueset "Afraid Something Bad is Going to Happen": 'urn:oid:2.16.840.1.113883.3.464.1003.105.12.1039'
valueset "Dropped Activities or Interests": 'urn:oid:2.16.840.1.113883.3.464.1003.105.12.1028'
valueset "Feel Full of Energy": 'urn:oid:2.16.840.1.113883.3.464.1003.105.12.1051'
valueset "Feel Helpless Often": 'urn:oid:2.16.840.1.113883.3.464.1003.105.12.1046'
valueset "Feel Life is Empty": 'urn:oid:2.16.840.1.113883.3.464.1003.105.12.1029'
valueset "Feel Situation is Hopeless": 'urn:oid:2.16.840.1.113883.3.464.1003.105.12.1052'
valueset "PHQ 2 Total Score (in points)": 'urn:oid:2.16.840.1.113883.3.464.1003.105.12.1013'

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity":
	["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer":
	["Patient Characteristic Payer": "Payer"]

define "SDE Race":
	["Patient Characteristic Race": "Race"]

define "SDE Sex":
	["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Initial Population":
	exists ( AWV."Annual Wellness Encounters" )

define "Denominator":
	"Initial Population"

define "Denominator Exclusions":
	exists ( ["Diagnosis": "Depression or Bipolar Disorder"] Bipolar
			with AWV."Annual Wellness Encounters" AWV
				such that Bipolar.prevalencePeriod overlaps before AWV.relevantPeriod
	)

define "Numerator":
	exists ( ["Assessment, Performed": "PHQ 2 Total Score (in points)"] PHQ_2
			with AWV."Annual Wellness Encounters" AWV
				such that PHQ_2.authorDatetime 12 months or less on or before end of AWV.relevantPeriod
	)
