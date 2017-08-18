library 40_SideBySideCMS68

using QDM version '5.0.2'


valueset "ONC Administrative Sex (1)": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "ONC Administrative Sex (2)": 'urn:oid:2.16.840.1.113762.1.4.2'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Medications Encounter Code Set": 'urn:oid:2.16.840.1.113883.3.600.1.1834'
valueset "Current Medications Documented SNMD": 'urn:oid:2.16.840.1.113883.3.600.1.462'
valueset "Medical or Other reason not done": 'urn:oid:2.16.840.1.113883.3.600.1.1502'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
    Initial Population =
        AND: Age>= 18 year(s) at: "Measurement Period"
        AND: "Occurrence A of Encounter, Performed: Medications Encounter Code Set" during "Measurement Period"
*/

define "Encounter":
	["Encounter, Performed": "Medications Encounter Code Set"]

define "Encounters during Measurement Period":
	"Encounter" Encounter
		where Encounter.relevantPeriod during "Measurement Period"

define "Initial Population":
	"Encounters during Measurement Period" Encounter
		where AgeInYearsAt(start of "Measurement Period")>= 18

/*
    Denominator =
        AND: Initial Population
*/

define "Denominator":
	"Initial Population"

/*
    Numerator Exclusions =
        None
*/

/*
    Numerator =
        AND: "Procedure, Performed: Current Medications Documented SNMD" during "Occurrence A of Encounter, Performed: Medications Encounter Code Set"
*/

define "Medications Documented":
	"Encounters during Measurement Period" Encounter
		with ["Procedure, Performed": "Current Medications Documented SNMD"] Procedure
			such that Procedure.relevantPeriod during Encounter.relevantPeriod

define "Numerator":
	"Medications Documented"

/*
    Denominator Exclusions =
        None
*/

/*
    Denominator Exceptions =
        OR: "Procedure, Performed not done: Medical or Other reason not done" for "Current Medications Documented SNMD" during "Occurrence A of Encounter, Performed: Medications Encounter Code Set"
*/

define "Medications Not Documented for Medical Reason":
	["Procedure, Not Performed": "Current Medications Documented SNMD"] Performed
		where Performed.negationRationale in "Medical or Other reason not done"

define "Denominator Exceptions":
	"Encounters during Measurement Period" Enc
		with "Medications Not Documented for Medical Reason" Meds
			such that Meds.authorDatetime during Enc.relevantPeriod

/*
    Stratification =
        None
*/

// Supplemental Data:

define "SDE Ethnicity":
	["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer":
	["Patient Characteristic Payer": "Payer"]

define "SDE Race":
	["Patient Characteristic Race": "Race"]

define "SDE Sex":
	["Patient Characteristic Sex": "ONC Administrative Sex"]

