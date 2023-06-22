library Test01_ScreeningForAlcoholMisuse version '1.1.000'

using QDM version '5.3'

include AnnualWellness version '1.0.000' called AWV

valueset "Alcohol abuse or dependence": 'urn:oid:2.16.840.1.113883.3.464.1003.106.12.1010'
valueset "Alcohol Abuse Screening": 'urn:oid:2.16.840.1.113883.3.464.1003.106.12.1026'
valueset "AUDIT C Total Score (in points)": 'urn:oid:2.16.840.1.113883.3.464.1003.107.12.1039'
valueset "Frequency of Drinking in the Past Year": 'urn:oid:2.16.840.1.113883.3.464.1003.106.12.1019'
valueset "Never Response": 'urn:oid:2.16.840.1.113883.3.464.1003.122.12.1022'
valueset "Times Per Week Or Month Response": 'urn:oid:2.16.840.1.113883.3.464.1003.122.12.1023'
valueset "Current Non Drinker of Alcohol": 'urn:oid:2.16.840.1.113883.3.464.1003.122.12.1017'
valueset "Current Drinker of Alcohol": 'urn:oid:2.16.840.1.113883.3.464.1003.122.12.1018'

context Patient

define "Denominator":
	true

define "Initial Population":
	exists ( AWV."Annual Wellness Encounters" )

define "Numerator":
	exists ( ["Assessment, Performed": "AUDIT C Total Score (in points)"] AuditC
			with AWV."Annual Wellness Encounters" AWV
				such that AuditC.authorDatetime 12 months or less on or before 
				end of AWV.relevantPeriod
	)
		or exists ( ( ( ["Assessment, Performed": "Frequency of Drinking in the Past Year"] DrinkingFrequency
					where DrinkingFrequency.result in "Never Response"
			)
				union ( ["Assessment, Performed": "Alcohol Abuse Screening"] AlcoholAbuse
						where AlcoholAbuse.result in "Current Non Drinker of Alcohol"
				) ) Assessment
				with AWV."Annual Wellness Encounters" AWV
					such that Assessment.authorDatetime 12 months or less on or before 
					end of AWV.relevantPeriod
		)
	
	//TODO:
	/*OR:
	        AND: Union of:
	            "Risk Category Assessment: Frequency of Drinking in the Past Year (result: Times Per Week Or Month Response)"
	            "Risk Category Assessment: Alcohol Abuse Screening (result: Current Drinker of Alcohol)"
	            <= 12 month(s) ends before end of "Occurrence A of Encounter, Performed: Annual Wellness Visit"
	        AND: Union of:
	            "Risk Category Assessment: Frequency of Four or More Drinks on One Occasion in Past Year (result: Heavy Drinking Days in Past Year Response)"
	            "Risk Category Assessment: Frequency of Four or More Drinks on One Occasion in Past Year (result >= 0 )"
	            <= 12 month(s) ends before end of "Occurrence A of Encounter, Performed: Annual Wellness Visit"*/
		or exists ( ( ( ["Assessment, Performed": "Frequency of Drinking in the Past Year"] DrinkingFrequency
					where DrinkingFrequency.result in "Times Per Week Or Month Response"
			)
				union ( ["Assessment, Performed": "Alcohol Abuse Screening"] AlcoholAbuse
						where AlcoholAbuse.result in "Current Drinker of Alcohol"
				) ) Assessment
				with AWV."Annual Wellness Encounters" AWV
					such that Assessment.authorDatetime 12 months or less on or before 
					end of AWV.relevantPeriod
		)

define "Denominator Exclusions":
	exists ( ["Diagnosis": "Alcohol abuse or dependence"] Dx
			with AWV."Annual Wellness Encounters" AWV
				such that Dx.prevalencePeriod overlaps before AWV.relevantPeriod
	)
