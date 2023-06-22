library SafeUseofOpioids version '0.1.016'

using QDM version '5.3'

include MATGlobalCommonFunctions version '2.0.000' called Global

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1' 
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836' 
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837' 
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591' 
valueset "Benzodiazepines": 'urn:oid:2.16.840.1.113762.1.4.1125.1' 
valueset "Cancer": 'urn:oid:2.16.840.1.113883.3.526.3.1010' 
valueset "Encounter ED and Observation Stay": 'urn:oid:2.16.840.1.113883.3.3157.1002.81' 
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307' 
valueset "Palliative care": 'urn:oid:2.16.840.1.113762.1.4.1125.3' 
valueset "Schedule II and Schedule III Opioids": 'urn:oid:2.16.840.1.113762.1.4.1125.2' 

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

define "Denominator":
	"Initial Population"

define "Has an Active Cancer Diagnosis":
	"Hospital Based Encounter" Encounter
		with ["Diagnosis": "Cancer"] Cancer
			such that Cancer.prevalencePeriod overlaps Encounter.relevantPeriod

define "Has Active Benzodiazepines":
	/*Patient on an active benzodiazepine starting before and not ending before end of the encounter
	*/
	"Hospital Based Encounter" Encounter
		with ["Medication, Active": "Benzodiazepines"] Benzodiazepine
			such that Benzodiazepine.relevantPeriod starts before start Encounter.relevantPeriod
				and Benzodiazepine.relevantPeriod ends after end of Encounter.relevantPeriod

define "Has Benzodiazepines at Discharge":
	"Hospital Based Encounter" Encounter
		with ["Medication, Discharge": "Benzodiazepines"] Benzodiazepine
			such that Benzodiazepine.authorDatetime during Encounter.relevantPeriod

define "Inpatient Encounters":
	["Encounter, Performed": "Encounter Inpatient"] InpatientEncounter
		where InpatientEncounter.lengthOfStay <= 120 days
			and InpatientEncounter.relevantPeriod ends during "Measurement Period"

define "Has Active Opioids":
	/*Patients on an active opioid starting before and not ending before the end of the encounter*/
	"Hospital Based Encounter" Encounter
		with ["Medication, Active": "Schedule II and Schedule III Opioids"] Opioids
			such that Opioids.relevantPeriod starts before start Encounter.relevantPeriod
				and Opioids.relevantPeriod ends after end of Encounter.relevantPeriod

define "Has Opioids at Discharge":
	/*Opioid at discharge
	*/
	"Hospital Based Encounter" Encounter
		with ["Medication, Discharge": "Schedule II and Schedule III Opioids"] Opioids
			such that Opioids.authorDatetime during Encounter.relevantPeriod

define "Has Palliative Care Order":
	"Hospital Based Encounter" Encounter
		with ["Intervention, Order": "Palliative care"] OrderedPalliative
			such that OrderedPalliative.authorDatetime during Encounter.relevantPeriod

define "Has Palliative Care Performed":
	"Hospital Based Encounter" Encounter
		with ["Intervention, Performed": "Palliative care"] PerformedPalliative
			such that PerformedPalliative.relevantPeriod overlaps Encounter.relevantPeriod
				or PerformedPalliative.relevantPeriod starts during Encounter.relevantPeriod

define "Denominator Exclusion":
	/*Patients with cancer or who are receiving palliative care.
	*/
	"Has Palliative Care Order"
		union "Has Palliative Care Performed"
		union "Has an Active Cancer Diagnosis"

define "Hospital Based Encounter with Age Greater than or Equal to 18":
	"Hospital Based Encounter" Encounter
		with ["Patient Characteristic Birthdate"] BirthDate
			such that Global.CalendarAgeInYearsAt(BirthDate.birthDatetime, start of Encounter.relevantPeriod)>= 18

define "Emergency Department and Observation Encounters":
	["Encounter, Performed": "Encounter ED and Observation Stay"] EDorObservationEncounter
		where EDorObservationEncounter.relevantPeriod during "Measurement Period"

define "Hospital Based Encounter":
	"Inpatient Encounters"
		union "Emergency Department and Observation Encounters"

define "Number of Active Opioids":
	Count(["Medication, Active": "Schedule II and Schedule III Opioids"] Opioids
			with "Hospital Based Encounter" Encounter
				such that Opioids.relevantPeriod overlaps after Encounter.relevantPeriod
	)

define "Number of Discharged Opioids":
	( "Number of Active Opioids" + "Number of Opioids at Discharge" ) >= 2

define "Has Two or More Opioids at Discharge":
	/*This logic is intended to capture patients who have two or more active
	opioids at discharge resulting in concurrent therapy.
	*/
	"Hospital Based Encounter" Encounter
		where "Number of Discharged Opioids"

define "Number of Opioids at Discharge 1 or More":
	( "Number of Active Opioids" + "Number of Opioids at Discharge" ) >= 1

define "Number of Benzodiazepines at Discharge":
	( "Number of Active Benzodiazepines" + "Number of Discharge Benzodiazepines" ) >= 1

define "Number of Discharge Benzodiazepines":
	Count(["Medication, Discharge": "Benzodiazepines"] Benzodiazipines
			with "Hospital Based Encounter" Encounter
				such that Benzodiazipines.authorDatetime during Encounter.relevantPeriod
	)

define "Number of Opioids and Benzodiazepines at Discharge":
	"Hospital Based Encounter" Encounter
		where "Number of Opioids at Discharge 1 or More"
			and "Number of Benzodiazepines at Discharge"

define "Has One or More Opioids with Benzodiazepines at Discharge":
	"Number of Opioids and Benzodiazepines at Discharge"

define "Number of Active Benzodiazepines":
	Count(["Medication, Active": "Benzodiazepines"] Benzodiazepine
			with "Hospital Based Encounter" Encounter
				such that Benzodiazepine.relevantPeriod overlaps after Encounter.relevantPeriod
	)

define "Number of Opioids at Discharge":
	Count(["Medication, Discharge": "Schedule II and Schedule III Opioids"] Opioids
			with "Hospital Based Encounter" Encounter
				such that Opioids.authorDatetime during Encounter.relevantPeriod
	)

define "Initial Population archive":
	/*Patients prescribed an opioid or benzodiazepine at discharge or patients with an opioid or a benzodiazepine active on admission and continued at discharge
	*/
	"Hospital Based Encounter with Age Greater than or Equal to 18"
		intersect ( "Has Active Opioids"
				union "Has Active Benzodiazepines"
				union "Has Opioids at Discharge"
				union "Has Benzodiazepines at Discharge"
		)

define "Numerator archive":
	/*Patients prescribed two or more opioids or an opioid and benzodiazepine at discharge.
	*/
	"Initial Population" Population
		intersect ( "Has Two or More Opioids at Discharge"
				union "Has One or More Opioids with Benzodiazepines at Discharge"
		)

define "Initial Population":
	"Encounters with Opiates and Benzodiazepines" EncounterWithMeds
		where exists ( EncounterWithMeds.opioidsAtDischarge )
			or exists ( EncounterWithMeds.benzodiazepineAtDischarge )
			or exists ( EncounterWithMeds.opioidsActive )
			or exists ( EncounterWithMeds.benzodiazepineActive )
		return EncounterWithMeds.encounter

define "Encounters with Opiates and Benzodiazepines":
	"Hospital Based Encounter with Age Greater than or Equal to 18" Encounter
		return Tuple {
			encounter: Encounter,
			opioidsAtDischarge: ( ["Medication, Discharge": "Schedule II and Schedule III Opioids"] OpioidsDischarge
					where OpioidsDischarge.authorDatetime during Encounter.relevantPeriod
			),
			benzodiazepineAtDischarge: ( ["Medication, Discharge": "Benzodiazepines"] BenzodiazepineDischarge
					where BenzodiazepineDischarge.authorDatetime during Encounter.relevantPeriod
			),
			opioidsActive: ( ["Medication, Active": "Schedule II and Schedule III Opioids"] OpioidsActive
					where OpioidsActive.relevantPeriod starts before start Encounter.relevantPeriod
						and OpioidsActive.relevantPeriod overlaps after Encounter.relevantPeriod
			),
			benzodiazepineActive: ( ["Medication, Active": "Benzodiazepines"] BenzodiazepineActive
					where BenzodiazepineActive.relevantPeriod starts before start Encounter.relevantPeriod
						and BenzodiazepineActive.relevantPeriod overlaps after Encounter.relevantPeriod
			)
		}

define "Numerator":
	"Encounters with Opiates and Benzodiazepines" EncounterWithMeds
		where ( Count(EncounterWithMeds.opioidsAtDischarge
					union EncounterWithMeds.opioidsActive
			)>= 2
		)
			or ( exists ( EncounterWithMeds.opioidsAtDischarge
						union EncounterWithMeds.opioidsActive
				)
					and exists ( EncounterWithMeds.benzodiazepineAtDischarge
							union EncounterWithMeds.benzodiazepineActive
					)
			)
		return EncounterWithMeds.encounter

