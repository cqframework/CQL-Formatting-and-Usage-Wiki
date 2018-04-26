library ContraceptiveProvisionAccesstoLongActingReversibleContraceptiveMethod version '0.0.000'

using QDM version '5.3'

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'
codesystem "SNOMEDCT:2017-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2017-03'
codesystem "LOINC:2.63": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.63'
codesystem "CPT:2018": 'urn:oid:2.16.840.1.113883.6.12' version 'urn:hl7:version:2018'
codesystem "HCPCS:2018": 'urn:oid:2.16.840.1.113883.6.285' version 'urn:hl7:version:2018'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1' 
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836' 
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837' 
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591' 
valueset "Delivery Live Births": 'urn:oid:2.16.840.1.113883.3.464.1003.111.12.1015' 
valueset "Administrative Gender (HL7 V3)": 'urn:oid:2.16.840.1.113883.1.11.1' 
valueset "Female": 'urn:oid:2.16.840.1.113883.3.560.100.2' 
valueset "Home Healthcare Services": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "Face-to-Face Interaction": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1048' 
valueset "Preventive Care, Established Office Visit, 0 to 17": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1024' 
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1025' 
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1023' 
valueset "Preventive Care Services, Initial Office Visit, 0 to 17": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1022' 
valueset "Office Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Long Acting Reversible Contraceptive (LARC) Methods": 'urn:oid:2.16.840.1.113762.1.4.1166.46' version 'urn:hl7:version:20180411' 
valueset "Not at risk for unintended pregnancy": 'urn:oid:2.16.840.1.113762.1.4.1166.48' version 'urn:hl7:version:20180411' 

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

define "InAgeStratum1":
	AgeInYearsAt(end of "Measurement Period")>= 15
		and AgeInYearsAt(end of "Measurement Period")<= 20

define "InAgeStratum2":
	AgeInYearsAt(end of "Measurement Period")>= 21
		and AgeInYearsAt(end of "Measurement Period")<= 44

define "InPopulationAgeGroup":
	InAgeStratum1
		or InAgeStratum2

define "IsFemale":
	exists ( ["Patient Characteristic Sex": "Female"] )

define "HasEncounterInMeasurementPeriod":
	( ["Encounter, Performed": "Office Visit"]
		union ["Encounter, Performed": "Preventive Care Services, Initial Office Visit, 0 to 17"]
		union ["Encounter, Performed": "Preventive Care, Established Office Visit, 0 to 17"]
		union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
		union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
		union ["Encounter, Performed": "Home Healthcare Services"] ) ValidEncounter
		where ValidEncounter.relevantPeriod during "Measurement Period"

define "LiveBirths":
	( ["Procedure, Performed": "Delivery Live Births"] ) LiveBirths
		where LiveBirths.relevantPeriod during "Measurement Period"

define "LiveBirthinLast2Months":
	( ["Procedure, Performed": "Delivery Live Births"] ) LiveBirths
		where LiveBirths.relevantPeriod starts within 2 months of end of "Measurement Period"

define "Denominator":
	AgeInYearsAt(end of "Measurement Period")>= 15
		and AgeInYearsAt(end of "Measurement Period")<= 44
		and ( "IsFemale" )
		and exists ( "HasEncounterInMeasurementPeriod" )
		and exists ( "Not at risk for unintended pregnancy" )

define "Numerator":
	exists ( "Long Acting Reversible Contraceptive (LARC) Methods" )

define "Initial Population":
	AgeInYearsAt(end of "Measurement Period")>= 15
		and AgeInYearsAt(end of "Measurement Period")<= 44
		and ( "IsFemale" )
		and exists ( "HasEncounterInMeasurementPeriod" )
		and exists ( "Not at risk for unintended pregnancy" )

