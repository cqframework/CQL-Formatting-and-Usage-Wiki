library HospitalHarmPressureInjury version '0.0.029'

using QDM version '5.4'

codesystem "SNOMEDCT:2017-09": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2017-09'

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Observation Services": 'urn:oid:2.16.840.1.113762.1.4.1111.143'
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Pressure Ulcer Stage": 'urn:oid:2.16.840.1.113883.11.20.9.35'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'

code "Nonstageable pressure ulcer (disorder)": '421594008' from "SNOMEDCT:2017-09" display 'Nonstageable pressure ulcer (disorder)'
code "Pressure injury of deep tissue (disorder)": '723071003' from "SNOMEDCT:2017-09" display 'Pressure injury of deep tissue (disorder)'
code "Pressure ulcer stage 2 (disorder)": '420324007' from "SNOMEDCT:2017-09" display 'Pressure ulcer stage 2 (disorder)'
code "Pressure ulcer stage 3 (disorder)": '421927004' from "SNOMEDCT:2017-09" display 'Pressure ulcer stage 3 (disorder)'
code "Pressure ulcer stage 4 (disorder)": '420597008' from "SNOMEDCT:2017-09" display 'Pressure ulcer stage 4 (disorder)'

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

define "Qualifying Inpatient Encounter":
	["Encounter, Performed": "Encounter Inpatient"] InpatientEncounter
		where InpatientEncounter.relevantPeriod during "Measurement Period"

define "Initial Population":
	"Qualifying Inpatient Encounter" QualifyingEncounter
		where AgeInYearsAt(start of "Hospitalization, Potentially Starting in Emergency Department and or with Observation"(QualifyingEncounter))>= 18

define "Denominator":
	"Initial Population"

define "Numerator":
	"Denominator"
		intersect "New Pressure Injury Stage 2, Stage 3, Stage 4, Nonstageable, or Deep Tissue Injury"

define "New Pressure Injury Stage 2, Stage 3, Stage 4, Nonstageable, or Deep Tissue Injury":
	"Denominator" EncounterWithQualifyingAge
		with ["Diagnosis": "Pressure Ulcer Stage"] PressureInjuryStage
			such that ( PressureInjuryStage.code ~ "Pressure ulcer stage 2 (disorder)"
					or PressureInjuryStage.code ~ "Pressure ulcer stage 3 (disorder)"
					or PressureInjuryStage.code ~ "Pressure ulcer stage 4 (disorder)"
					or PressureInjuryStage.code ~ "Nonstageable pressure ulcer (disorder)"
					or PressureInjuryStage.code ~ "Pressure injury of deep tissue (disorder)"
			)
				and PressureInjuryStage.prevalencePeriod starts more than 24 hours after start of "Hospitalization, Potentially Starting in Emergency Department and or with Observation"(EncounterWithQualifyingAge)
				and PressureInjuryStage.prevalencePeriod during "Hospitalization, Potentially Starting in Emergency Department and or with Observation"(EncounterWithQualifyingAge)

define function "Hospitalization, Potentially Starting in Emergency Department and or with Observation"(Inpatient_Encounter "Encounter, Performed"):
	Inpatient_Encounter QualifyingInpatientEncounter
		let LastObservationVisit: Last(["Encounter, Performed": "Observation Services"] ObservationVisit
				where ObservationVisit.relevantPeriod ends 1 hour or less on or before start of QualifyingInpatientEncounter.relevantPeriod
				sort by 
				end of relevantPeriod
		),
		HospitalVisitStart: Coalesce(start of LastObservationVisit.relevantPeriod, start of QualifyingInpatientEncounter.relevantPeriod),
		LastEDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] EDVisit
				where EDVisit.relevantPeriod ends 1 hour or less on or before HospitalVisitStart
				sort by 
				end of relevantPeriod
		)
		return Interval[Coalesce(start of LastEDVisit.relevantPeriod, HospitalVisitStart), 
		end of QualifyingInpatientEncounter.relevantPeriod]