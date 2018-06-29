library ContraceptiveProvisionMostModeratelyEffectiveMethods version '2.0.014'

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
valueset "Most or Moderately Effective Contraceptive Methods": 'urn:oid:2.16.840.1.113762.1.4.1166.47' version 'urn:hl7:version:20180411'
valueset "Not at risk for unintended pregnancy": 'urn:oid:2.16.840.1.113762.1.4.1166.48' version 'urn:hl7:version:20180411'
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

define "EncounterInMeasurementPeriod":
	( ["Encounter, Performed": "Office Visit"]
		union ["Encounter, Performed": "Preventive Care Services, Initial Office Visit, 0 to 17"]
		union ["Encounter, Performed": "Preventive Care, Established Office Visit, 0 to 17"]
		union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
		union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
		union ["Encounter, Performed": "Home Healthcare Services"] ) ValidEncounter
		where ValidEncounter.relevantPeriod during "Measurement Period"

define "IsFemale":
	exists ["Patient Characteristic Sex": "Female"]

define "Current Pregnancy":
	( ["Assessment, Performed": "Pregnancy"] ) Preg
		where Preg.negationRationale is null

define "Numerator":
	exists ( ["Intervention, Order": "Most or Moderately Effective Contraceptive Methods"] ) MostMod
		// NOTE: This test for negationRationale is not required, the "Intervention, Order" data type
		// will only return "positive" intervention orders
		where MostMod.negationRationale is null
		
// NOTE: The value set here is a mixture of concepts including procedures, interventions, and medications
// The value set should be split up and used with different QDM data types:
define "Most or Moderately Effective Contraceptive Provided":
	["Intervention, Performed": "Most or Moderately Effective Contraceptive Methods"]
		
// NOTE: My read of the measure intent is that the contraceptive should be provided within 60 days
// so we should add:
define "Most or Moderately Effective Contraceptive Provided within 60 days":
	"Most or Moderately Effective Contraceptive Provided" C
		with "LiveBirths" B
			such that C.authorDatetime 60 days or less on or after end of B.relevantPeriod

define "Denominator":
	"Initial Population"
	  // NOTE: This should be an and, we are defining the denominator as the initial population plus the fact that there was a live birth
		or exists "LiveBirths"

define "LiveBirths":
	( ["Procedure, Performed": "Delivery Live Births"] ) LiveBirths
	  // NOTE: Since the Denominator Exclusion will exclude these, it's not necessary to express this restriction here
		where LiveBirths.relevantPeriod starts 2 months or more before end of "Measurement Period"
		  // NOTE: The intent of this condition is to limit to live births during encounters, it should be stated as a relationship to the encounters
			and "Initial Population"

define "LiveBirthsLast2Months":
  // NOTE: This can be expressed in terms of the LiveBirths definition
	( ["Procedure, Performed": "Delivery Live Births"] ) LiveBirths2
		where LiveBirths2.relevantPeriod starts 2 months or less before end of "Measurement Period"
			and "Initial Population"

define "Denominator Exclusion":
	exists ["Assessment, Performed": "Not at risk for unintended pregnancy"]
		or exists "Current Pregnancy"
		or exists "LiveBirthsLast2Months"

define "Initial Population":
	AgeInYearsAt(end of "Measurement Period")>= 15
		and AgeInYearsAt(end of "Measurement Period")<= 44
		and ( "IsFemale" )
		and exists ( "EncounterInMeasurementPeriod" )

// Stratifiers
// 1) The percentage of women aged 15-20 who were provided a most or moderately effective contraceptive method within 3 days after the delivery of a live birth
// 2) The percentage of women aged 15-20 years who were provided a most or moderately effective contraceptive method within 60 days after the delivery of a live birth
// 3) The percentage of women aged 21-44 years who were provided a most or moderately effective contraceptive method within 3 days after the delivery of a live birth
// 4) The percentage of women aged 21-44 years who were provided a most or moderately effective contraceptive method within 60 days after the delivery of a live birth

define "InAgeStratum1":
	AgeInYearsAt(end of "Measurement Period")>= 15
		and AgeInYearsAt(end of "Measurement Period")<= 20

define "InAgeStratum2":
	AgeInYearsAt(end of "Measurement Period")>= 21
		and AgeInYearsAt(end of "Measurement Period")<= 44


