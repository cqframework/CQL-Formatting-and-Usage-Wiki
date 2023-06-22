library Test05_ScreeningForDepression version '0.0.001'

using QDM version '5.3'

include AnnualWellness version '1.0.000' called AWV

valueset "Depression or Bipolar Disorder": 'urn:oid:2.16.840.1.113883.3.464.1003.105.12.1040'
valueset "PHQ 2 Total Score (in points)": 'urn:oid:2.16.840.1.113883.3.464.1003.105.12.1013'

context Patient

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
				such that PHQ_2.authorDatetime 12 months or less on or before 
				end of AWV.relevantPeriod
	)
