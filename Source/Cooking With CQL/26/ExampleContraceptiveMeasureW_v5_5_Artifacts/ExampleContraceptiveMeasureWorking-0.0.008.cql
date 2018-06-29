library ExampleContraceptiveMeasureWorking version '0.0.008'

using QDM version '5.3'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Delivery Live Births": 'urn:oid:2.16.840.1.113883.3.464.1003.111.12.1015'
valueset "Female": 'urn:oid:2.16.840.1.113883.3.560.100.2'
valueset "Home Healthcare Services": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1016'
valueset "Preventive Care, Established Office Visit, 0 to 17": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1024'
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1023'
valueset "Preventive Care Services, Initial Office Visit, 0 to 17": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1022'
valueset "Office Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Most or Moderately Effective Contraceptive Methods": 'urn:oid:2.16.840.1.113762.1.4.1166.47'
valueset "Not at risk for unintended pregnancy": 'urn:oid:2.16.840.1.113762.1.4.1166.48'
valueset "Pregnancy": 'urn:oid:2.16.840.1.113883.3.600.1622'

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

define "Encounter During Measurement Period":
	( ["Encounter, Performed": "Office Visit"]
		union ["Encounter, Performed": "Preventive Care Services, Initial Office Visit, 0 to 17"]
		union ["Encounter, Performed": "Preventive Care, Established Office Visit, 0 to 17"]
		union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
		union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
		union ["Encounter, Performed": "Home Healthcare Services"] ) ValidEncounter
		where ValidEncounter.relevantPeriod during "Measurement Period"

define "Current Pregnancy":
	( ["Assessment, Performed": "Pregnancy"] ) Preg

define "Is Female":
	exists ["Patient Characteristic Sex": "Female"]

define "Initial Population":
	AgeInYearsAt(
		end of "Measurement Period"
	)>= 15
		and AgeInYearsAt(
			end of "Measurement Period"
		)<= 44
		and ( "Is Female" )
		and exists ( "Encounter During Measurement Period" )

define "Live Births During Measurement Period":
	( ["Procedure, Performed": "Delivery Live Births"] ) LiveBirth
		where LiveBirth.relevantPeriod starts during "Measurement Period"

define "Denominator":
	"Initial Population"
		and exists ( "Live Births During Measurement Period" )

define "Live Births During Last 2 Months of Measurement Period":
	"Live Births During Measurement Period" LiveBirth
		where LiveBirth.relevantPeriod starts 2 months or less before 
		end of "Measurement Period"

define "Denominator Exclusion":
	exists ["Assessment, Performed": "Not at risk for unintended pregnancy"]
		or exists "Current Pregnancy"
		or exists "Live Births During Last 2 Months of Measurement Period"

define "Most or Moderately Effective Contraception Provided":
	["Intervention, Performed": "Most or Moderately Effective Contraceptive Methods"] Intervention
		where Intervention.relevantPeriod during "Measurement Period"

define "Most or Moderately Effective Contraception Provided within 60 days":
	"Most or Moderately Effective Contraception Provided" C
		with "Live Births During Measurement Period" B
			such that C.authorDatetime 60 days or less on or after 
			end of B.relevantPeriod

define "Numerator":
	exists ( "Most or Moderately Effective Contraception Provided within 60 days" )

define "Most or Moderately Effective Contraception Provided within 3 days":
	"Most or Moderately Effective Contraception Provided" C
		with "Live Births During Measurement Period" B
			such that C.authorDatetime 3 days or less on or after 
			end of B.relevantPeriod

define "In Age Stratum 1":
	AgeInYearsAt(
		end of "Measurement Period"
	)>= 15
		and AgeInYearsAt(
			end of "Measurement Period"
		)<= 20

define "In Age Stratum 2":
	AgeInYearsAt(
		end of "Measurement Period"
	)>= 21
		and AgeInYearsAt(
			end of "Measurement Period"
		)<= 44

define "Stratifier 2":
	"In Age Stratum 1"

define "Stratifier 3":
	"In Age Stratum 2"
		and exists "Most or Moderately Effective Contraception Provided within 3 days"

define "Stratifier 4":
	"In Age Stratum 2"

define "Stratifier 1":
	"In Age Stratum 1"
		and exists "Most or Moderately Effective Contraception Provided within 3 days"

define "SDE Contraception Method":
	"Most or Moderately Effective Contraception Provided" Contraception
		return Contraception.code

define "Unintended Pregnancy Risk Assessment Method":
	["Assessment, Performed": "Not at risk for unintended pregnancy"] Assessment
		return Assessment.code
