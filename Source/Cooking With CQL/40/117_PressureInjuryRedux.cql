library PressureInjury

/*
This example comes from CMS826v0 - Hospital Harm - Pressure Injury
https://ecqi.healthit.gov/ecqm/measures/cms826v0

The current measure description is:

This measure assesses the proportion of inpatient encounters of patients 18 years
 of age or older at admission, who suffer the harm of developing a new stage 2,
 stage 3, stage 4 pressure injury, deep tissue pressure injury, or unstageable
 pressure injury. The measure defines a new pressure injury as not present on
 arrival to the hospital or not documented within the first 24 hours after
 hospital arrival. Only one harm (new qualifying pressure injury) is counted
 per encounter.


This measure was written and tested prior to the availability of some key elements
that are now available through QDM, so we want to enhance the specifications while
retaining the intent. FYI: we may need to create a new VS to address anatomical
location site if existing ones in VSAC are not appropriate for a pressure injury (TBD)
—note that current logic does not define this aspect and it is in header guidance only.

Needed for eCQM:

Numerator needs to capture 2 scenarios but rolled into a single count:

    PI stage 2+ or unstageable that was not documented as present on arrival (POA)
    PI stage 2+ or unstageable that was POA, but a new one (stage 2+ or unstageable)
			is identified in a different anatomical location site and 24 hours after arrival

Thoughts:

    1. We probably should create a definition for "PI stage 2+ or unstageable" to
		  simplify logic that needs to be added
		2. Using the Encounter Performed datatype and Diagnoses and POA components could work for aspects
    3. Anatomical location site is only available if Diagnosis datatype is used for QDM,
		  but POA is only allowable for Encounter, Performed
		4. Would POA work? It appears that it might be required with admission orders (?),
		  for the measure we want to know whether it was documented in 24hrs of arrival…
			so perhaps not using the POA indicator?

Past QDM UG had the following modeling for using POA:

define "Encounter With Ischemic Stroke Diagnosis Present On Admission":
  ["Encounter, Performed": "Inpatient"] E
    where exists (E.diagnoses D where D.code in "Ischemic Stroke"
      and D.presentOnAdmissionIndicator ~ "Y")

It is not clear on whether the above would work or become more complicated since
we need to add the aspect of anatomical location site
*/

/*
So the primary issue seems to be a need to relate a diagnosis that is indicated as present
on arrival with an active Diagnosis record, and be able to reliably ensure they are the
"same" diagnosis.
*/

using QDM version '5.5'

codesystem "SNOMEDCT:2017-09": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2017-09'
codesystem "Present On Admission Indicator Codes": 'urn:oid:2.16.840.1.113883.4.642.1.1170'

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
code "y": 'y' from "Present On Admission Indicator Codes" display 'Yes'

parameter "Measurement Period" Interval<DateTime>

context Patient

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
		intersect "Encounter With New Harmful Pressure Injury"

/*
    PI stage 2+ or unstageable that was not documented as present on arrival (POA)
    PI stage 2+ or unstageable that was POA, but a new one (stage 2+ or unstageable)
			is identified in a different anatomical location site and 24 hours after arrival
*/

define "Harmful Pressure Injury":
  ["Diagnosis": "Pressure Ulcer Stage"] PressureInjuryStage
			where ( PressureInjuryStage.code ~ "Pressure ulcer stage 2 (disorder)"
					or PressureInjuryStage.code ~ "Pressure ulcer stage 3 (disorder)"
					or PressureInjuryStage.code ~ "Pressure ulcer stage 4 (disorder)"
					or PressureInjuryStage.code ~ "Nonstageable pressure ulcer (disorder)"
					or PressureInjuryStage.code ~ "Pressure injury of deep tissue (disorder)"
			)

define "Encounter With New Harmful Pressure Injury":
  "Denominator" EncounterWithQualifyingAge
	  let PressureInjuryPOA:
		  "Harmful Pressure Injury" PressureInjury
			  where PressureInjury.prevalencePeriod
					during "Hospitalization, Potentially Starting in Emergency Department and or with Observation"(EncounterWithQualifyingAge)
					and exists (
						EncounterWithQualifyingAge.diagnoses EncounterDiagnosis
							where EncounterDiagnosis.code ~ PressureInjury.code // Best approximation in QDM, no way to link encounter diagnoses directly to Diagnosis elements
							  and EncounterDiagnosis.presentOnAdmissionIndicator ~ "y"
					)
		where exists ("Harmful Pressure Injury" PressureInjury
		  where PressureInjury.prevalencePeriod during "Hospitalization, Potentially Starting in Emergency Department and or with Observation"(EncounterWithQualifyingAge)
			  and AllTrue(
					PressureInjuryPOA POA
					  where PressureInjury.prevalencePeriod starts more than 24 hours after start of "Hospitalization, Potentially Starting in Emergency Department and or with Observation"(EncounterWithQualifyingAge)
						  and PressureInjury.anatomicalLocationSite !~ POA.anatomicalLocationSite
						return true
				)
		)

		define "Encounter With New Harmful Pressure Injury":
		  "Denominator" EncounterWithQualifyingAge
			  with (
				  "Harmful Pressure Injury" PressureInjury
					  where PressureInjury.prevalencePeriod
							during "Hospitalization, Potentially Starting in Emergency Department and or with Observation"(EncounterWithQualifyingAge)
							and exists (
								EncounterWithQualifyingAge.diagnoses EncounterDiagnosis
									where EncounterDiagnosis.code ~ PressureInjury.code // Best approximation in QDM, no way to link encounter diagnoses directly to Diagnosis elements
									  and EncounterDiagnosis.presentOnAdmissionIndicator ~ "y"
							)
				)  PressureInjuryPOA
					such that exists ("Harmful Pressure Injury" PressureInjury
					  where PressureInjury.prevalencePeriod during "Hospitalization, Potentially Starting in Emergency Department and or with Observation"(EncounterWithQualifyingAge)
						  and AllTrue(
								PressureInjuryPOA POA
								  where PressureInjury.prevalencePeriod starts more than 24 hours after start of "Hospitalization, Potentially Starting in Emergency Department and or with Observation"(EncounterWithQualifyingAge)
									  and PressureInjury.anatomicalLocationSite !~ POA.anatomicalLocationSite
									return true
							)
					)

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
