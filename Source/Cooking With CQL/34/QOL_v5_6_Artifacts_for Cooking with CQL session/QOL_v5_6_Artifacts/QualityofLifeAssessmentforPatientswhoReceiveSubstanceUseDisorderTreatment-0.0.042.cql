library QualityofLifeAssessmentforPatientswhoReceiveSubstanceUseDisorderTreatment version '0.0.042'

using QDM version '5.5'

include MATGlobalCommonFunctions version '4.0.000' called Global

codesystem "SNOMEDCT": 'urn:oid:2.16.840.1.113883.6.96'

valueset "Alcohol and Drug Dependence": 'urn:oid:2.16.840.1.113883.3.464.1003.106.12.1001'
valueset "Alcohol and Drug Dependence Treatment": 'urn:oid:2.16.840.1.113762.1.4.1145.15'
valueset "Eligible Clinician Outpatient Encounters with Telehealth": 'urn:oid:2.16.840.1.113762.1.4.1046.150'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Hospice for the Terminally Ill": 'urn:oid:2.16.840.1.113762.1.4.1046.147'
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "PROMIS 10 Global Mental Health Score": 'urn:oid:2.16.840.1.113883.3.464.1003.118.11.1138'
valueset "PROMIS 10 Global Physical Health Score": 'urn:oid:2.16.840.1.113883.3.464.1003.118.12.1139'
valueset "Psych Visit - Diagnostic Evaluation": 'urn:oid:2.16.840.1.113883.3.526.3.1492'
valueset "Psych Visit - Psychotherapy": 'urn:oid:2.16.840.1.113883.3.526.3.1496'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "VR 36 Mental Component Summary (MCS) Score": 'urn:oid:2.16.840.1.113883.3.464.1003.118.12.1225'
valueset "VR 36 Physical Component Summary (PCS) Score": 'urn:oid:2.16.840.1.113883.3.464.1003.118.12.1226'
valueset "VR12 Mental Component T Score": 'urn:oid:2.16.840.1.113883.3.464.1003.118.12.1177'
valueset "VR12 Physical Component T Score": 'urn:oid:2.16.840.1.113883.3.464.1003.118.12.1176'

code "Dead (finding)": '419099009' from "SNOMEDCT" display 'Dead (finding)'

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

define "Identification Period":
	/*Occurs 6 months before the measurement period starts (July 1 of the year prior to the measurement period) to 6 months before it ends (June 30 of the current measurement period)*/
	Interval[start of "Measurement Period" - 6 months, start of "Measurement Period" + 6 months]

define "Denominator":
	"Initial Population"

define "QOL Assessment":
	["Assessment, Performed": "PROMIS 10 Global Mental Health Score"]
		union ["Assessment, Performed": "PROMIS 10 Global Physical Health Score"]
		union ["Assessment, Performed": "VR 36 Mental Component Summary (MCS) Score"]
		union ["Assessment, Performed": "VR 36 Physical Component Summary (PCS) Score"]
		union ["Assessment, Performed": "VR12 Mental Component T Score"]
		union ["Assessment, Performed": "VR12 Physical Component T Score"]

define "Same Assessment Performed":
	/*The follow-up assessment must use the same assessment tool used in the baseline assessment.*/
	( ( ["Assessment, Performed": "PROMIS 10 Global Mental Health Score"] PromisMental1
				with ["Assessment, Performed": "PROMIS 10 Global Mental Health Score"] PromisMental2
					such that PromisMental1.authorDatetime 3 months or more before PromisMental2.authorDatetime
						and PromisMental1.authorDatetime 6 months or less before PromisMental2.authorDatetime
		)
			union ( ["Assessment, Performed": "PROMIS 10 Global Physical Health Score"] PromisGlobal1
					with ["Assessment, Performed": "PROMIS 10 Global Physical Health Score"] PromisGlobal2
						such that PromisGlobal1.authorDatetime 3 months or more before PromisGlobal2.authorDatetime
							and PromisGlobal1.authorDatetime 6 months or less before PromisGlobal2.authorDatetime
			)
	)
		union ( ( ["Assessment, Performed": "VR 36 Mental Component Summary (MCS) Score"] MCS1
					with ["Assessment, Performed": "VR 36 Mental Component Summary (MCS) Score"] MCS2
						such that MCS1.authorDatetime 3 months or more before MCS2.authorDatetime
							and MCS1.authorDatetime 6 months or less before MCS2.authorDatetime
			)
				union ( ["Assessment, Performed": "VR 36 Physical Component Summary (PCS) Score"] PCS1
						with ["Assessment, Performed": "VR 36 Physical Component Summary (PCS) Score"] PCS2
							such that PCS1.authorDatetime 3 months or more before PCS2.authorDatetime
								and PCS1.authorDatetime 6 months or less before PCS2.authorDatetime
				)
		)
		union ( ( ["Assessment, Performed": "VR12 Mental Component T Score"] MentalTScore1
					with ["Assessment, Performed": "VR12 Mental Component T Score"] MentalTScore2
						such that MentalTScore1.authorDatetime 3 months or more before MentalTScore2.authorDatetime
							and MentalTScore1.authorDatetime 6 months or less before MentalTScore2.authorDatetime
			)
				union ( ["Assessment, Performed": "VR12 Physical Component T Score"] PhysicalTScore1
						with ["Assessment, Performed": "VR12 Physical Component T Score"] PhysicalTScore2
							such that PhysicalTScore1.authorDatetime 3 months or more before PhysicalTScore2.authorDatetime
								and PhysicalTScore1.authorDatetime 6 months or less before PhysicalTScore2.authorDatetime
				)
		)

define "SUD Encounter During Identification Period with Patient Age at Start":
	"SUD Encounter During Identification Period" SUDEncounter
		with ["Patient Characteristic Birthdate"] BirthDate
			such that Global."CalendarAgeInYearsAt"(BirthDate.birthDatetime, start of SUDEncounter.relevantPeriod)>= 18

define "Initial Population":
	exists ( "SUD Encounter During Identification Period with Patient Age at Start" )

define "Deceased During Follow Up QOL Assessment Period":
	["Patient Characteristic Expired": "Dead (finding)"] Deceased
		with "SUD Encounter During Identification Period with Patient Age at Start" NewSUDEncounter
			such that Deceased.expiredDatetime 6 months or less after NewSUDEncounter.relevantPeriod

define "Denominator Exclusions":
	exists ( "Hospice During Follow Up QOL Assessment Period" )
		or exists ( "Deceased During Follow Up QOL Assessment Period" )

define "Numerator 1":
	exists ( "Baseline QOL Assessment" )

define "Numerator 2":
	exists ( "Follow Up QOL Assessment" )

define "SUD Psych Encounters with Principal Diagnosis":
	["Encounter, Performed": "Eligible Clinician Outpatient Encounters with Telehealth"] Encounter
		with ( ["Procedure, Performed": "Psych Visit - Psychotherapy"]
			union ["Procedure, Performed": "Psych Visit - Diagnostic Evaluation"] ) ValidProcedure
			such that Encounter.principalDiagnosis in "Alcohol and Drug Dependence"
				and ValidProcedure.relevantPeriod during Encounter.relevantPeriod

define "SUD Treatment Encounters":
	["Encounter, Performed": "Eligible Clinician Outpatient Encounters with Telehealth"] Encounter
		with ["Procedure, Performed": "Alcohol and Drug Dependence Treatment"] Treatment
			such that Treatment.relevantPeriod during Encounter.relevantPeriod

// BTR ->
define "SUD Encounters":
	"SUD Treatment Encounters"
		union "SUD Psych Encounters with Principal Diagnosis"

define "New SUD Encounter":
  "SUD Encounters" S
    without "SUD Encounters" S2 such that S2.relevantPeriod ends 60 days or less before start of S.relevantPeriod
    where S.relevantPeriod starts during "Identification Period"
    
/*
define "Second New SUD Encounter":
  "SUD Encounters" S
    without "SUD Encounters" S2 such that S2.relevantPeriod ends 60 days or less before start of S.relevantPeriod
    where S.relevantPeriod starts after end of "Identification Period" and ends before end of "Measurement Period"
*/
// End

define "SUD Encounter During Identification Period":
	"SUD Encounters" SUDEncounter
		where SUDEncounter.relevantPeriod during "Identification Period"

define "Hospice During Follow Up QOL Assessment Period":
	"SUD Encounter During Identification Period with Patient Age at Start" NewSUDEncounter
		with ( ["Encounter, Performed": "Hospice for the Terminally Ill"]
			union ["Encounter, Order": "Hospice for the Terminally Ill"] ) HospiceCare
			such that HospiceCare.authorDatetime 6 months or less after NewSUDEncounter.relevantPeriod

// BTR ->
define "Follow Up QOL Assessment":
	from
		"SUD Encounter During Identification Period with Patient Age at Start" NewSUDEncounter,
		"QOL Assessment" BaselineAssessment,
		"QOL Assessment" FollowupAssessment
		where (BaselineAssessment.authorDatetime 14 days or less before or on start of NewSUDEncounter.relevantPeriod
      or BaselineAssessment.authorDatetime during NewSUDEncounter.relevantPeriod)
      and FollowupAssessment.authorDatetime 3 months or more after start of NewSUDEncounter.relevantPeriod
			and FollowupAssessment.authorDatetime 6 months or less after start of NewSUDEncounter.relevantPeriod
      and exists ("SUD Encounter" SUDEncounter where SUDEncounter.relevantPeriod starts 60 days or less before or on FollowupAssessment.authorDatetime)
      and BaselineAssessment.code ~ FollowupAssessment.code
    return FollowupAssessment
// End

define "Baseline QOL Assessment":
	"QOL Assessment" Assessment
		with "SUD Encounter During Identification Period with Patient Age at Start" NewSUDEncounter
			such that Assessment.authorDatetime 14 days or less before or on start of NewSUDEncounter.relevantPeriod
				or Assessment.authorDatetime during NewSUDEncounter.relevantPeriod