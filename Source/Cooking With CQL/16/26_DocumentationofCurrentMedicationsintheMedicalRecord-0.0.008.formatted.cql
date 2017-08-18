library DocumentationofCurrentMedicationsintheMedicalRecord version '0.0.008'

using QDM version '5.0.2'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Medications Encounter Code Set": 'urn:oid:2.16.840.1.113883.3.600.1.1834'
valueset "Current Medications Documented SNMD": 'urn:oid:2.16.840.1.113883.3.600.1.462'
valueset "Medical or Other reason not done": 'urn:oid:2.16.840.1.113883.3.600.1.1502'

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

define "In Demographic":
	AgeInYearsAt(start of "Measurement Period")>= 18

define "Encounter":
	["Encounter, Performed": "Medications Encounter Code Set"]
	
define "Encounters during Measurement Period":
	"Encounter" Encounter
		where Encounter.relevantPeriod during "Measurement Period"

// NOTE: This is an encounter-based measure, so this IPP should be returning a list of encounters, not a yes/no
// NOTE: The use of "IPP" here goes against QDM-conventions, which state that the name of the population should be used
define "Initial Population":
  "Encounters during MP" Encounter
	  where "In Demographic"
		
define "Numerator":
	"Medications Documented"

define "Denominator":
	"Initial Population"

// NOTE: This would need to be updated to return a list of encounters, not procedures
define "Medications Documented":
	"Encounters during Measurement Period" Encounter
		with ["Procedure, Performed": "Current Medications Documented SNMD"] Procedure
			such that Procedure.relevantPeriod during Encounter.relevantPeriod

// NOTE: The use of abbreviations can impact the readability of the resulting human-readable
// Consider using the complete word, "Medications" here, rather than "Meds"
define "Medications Not Documented for Medical Reason":
	["Procedure, Not Performed": "Current Medications Documented SNMD"] NotPerformed
		where NotPerformed.negationRationale in "Medical or Other reason not done"

// NOTE: Again, the use of "MP", rather than "Measurement Period" can have an impact
// on the human-readable
define "Denominator Exception":
	"Encounters during MP" Enc
		with "Meds Not Documented Medical Reason" Meds
			such that Meds.authorDatetime during Enc.relevantPeriod
