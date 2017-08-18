library 41_SideBySide_CMS22

using QDM version '5.0.2'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Diagnosis of hypertension": 'urn:oid:2.16.840.1.113883.3.600.263'
valueset "ECG 12 lead or study order": 'urn:oid:2.16.840.1.113883.3.600.2448'
valueset "BP Screening Encounter Codes": 'urn:oid:2.16.840.1.113883.3.600.1920'
valueset "Dietary Recommendations": 'urn:oid:2.16.840.1.113883.3.600.1515'
valueset "Followup within 4 weeks": 'urn:oid:2.16.840.1.113883.3.600.1537'
valueset "Followup within one year": 'urn:oid:2.16.840.1.113883.3.600.1474'
valueset "Lifestyle Recommendation": 'urn:oid:2.16.840.1.113883.3.600.1508'
valueset "Moderation of ETOH Consumption Recommendation": 'urn:oid:2.16.840.1.113883.3.600.823'
valueset "Physical Activity Recommendation": 'urn:oid:2.16.840.1.113883.3.600.1518'
valueset "Referral to Alternative Provider / Primary Care Provider": 'urn:oid:2.16.840.1.113883.3.600.1475'
valueset "Weight Reduction Recommended": 'urn:oid:2.16.840.1.113883.3.600.1510'
valueset "Patient Reason refused": 'urn:oid:2.16.840.1.113883.3.600.791'
valueset "Laboratory Tests for Hypertension": 'urn:oid:2.16.840.1.113883.3.600.1482'
valueset "Anti-Hypertensive Pharmacologic Therapy": 'urn:oid:2.16.840.1.113883.3.600.1476'
valueset "Diastolic Blood Pressure": 'urn:oid:2.16.840.1.113883.3.526.3.1033'
valueset "Systolic Blood Pressure": 'urn:oid:2.16.840.1.113883.3.526.3.1032'
valueset "Medical or Other reason not done": 'urn:oid:2.16.840.1.113883.3.600.1.1502'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
    Initial Population =
        AND: Age>= 18 year(s) at: "Measurement Period"
        AND: "Occurrence A of Encounter, Performed: BP Screening Encounter Codes" during "Measurement Period"
*/

define "In Demographic":
	AgeInYearsAt(start of "Measurement Period")>= 18

define "Encounters During Measurement Period":
	["Encounter, Performed": "BP Screening Encounter Codes"] Encounter
		where Encounter.relevantPeriod during "Measurement Period"

define "Initial Population":
	"In Demographic"
		and exists ( "Encounters During Measurement Period" )

/*
    Denominator =
        AND: Initial Population
*/
define "Denominator":
	"Initial Population"

/*
    Numerator =
        AND: Most Recent:
            "Occurrence A of Encounter, Performed: BP Screening Encounter Codes" satisfies all:
                overlaps "Physical Exam, Performed: Diastolic Blood Pressure (result)"
                overlaps "Physical Exam, Performed: Systolic Blood Pressure (result)"
        AND:
            OR:
                AND: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
                    Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                    (result < 120 mmHg)
                AND: "Physical Exam, Performed: Diastolic Blood Pressure" satisfies all:
                    Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                    (result < 80 mmHg)
            OR:
                AND:
                    OR:
                        AND: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
                            Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                            (result >= 120 mmHg)
                            (result < 140 mmHg)
                        AND: "Physical Exam, Performed: Diastolic Blood Pressure" satisfies all:
                            Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                            (result < 90 mmHg)
                    OR:
                        AND: "Physical Exam, Performed: Diastolic Blood Pressure" satisfies all:
                            Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                            (result >= 80 mmHg)
                            (result < 90 mmHg)
                        AND: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
                            Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                            (result < 140 mmHg)
                AND:
                    OR: "Intervention, Order: Referral to Alternative Provider / Primary Care Provider (reason: Finding of Hypertension)" <= 1 day(s) starts after or concurrent with start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                    OR:
                        AND: $HypertensionRecommendations <= 1 day(s) starts after or concurrent with start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                        AND: "Intervention, Order: Followup within one year (reason: Finding of Hypertension)" <= 1 day(s) starts after or concurrent with start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
            OR:
                AND:
                    OR:
                        AND NOT: "Physical Exam, Performed: Systolic Blood Pressure (result)" < 1 year(s) starts before start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                        AND NOT: "Physical Exam, Performed: Diastolic Blood Pressure (result)" < 1 year(s) starts before start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                    OR:
                        AND: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
                            Most Recent: < 1 year(s) starts before start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                            (result < 140 mmHg)
                        AND: "Physical Exam, Performed: Diastolic Blood Pressure" satisfies all:
                            Most Recent: < 1 year(s) starts before start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                            (result < 90 mmHg)
                AND:
                    OR: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
                        Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                        (result >= 140 mmHg)
                    OR: "Physical Exam, Performed: Diastolic Blood Pressure" satisfies all:
                        Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                        (result >= 90 mmHg)
                AND:
                    OR: "Intervention, Order: Referral to Alternative Provider / Primary Care Provider (reason: Finding of Hypertension)" <= 1 day(s) starts after or concurrent with start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                    OR:
                        AND: $HypertensionRecommendations <= 1 day(s) starts after or concurrent with start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                        AND: "Intervention, Order: Followup within 4 weeks (reason: Finding of Hypertension)" <= 1 day(s) starts after or concurrent with start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
            OR:
                AND:
                    OR: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
                        Most Recent: < 1 year(s) starts before start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                        (result >= 140 mmHg)
                    OR: "Physical Exam, Performed: Diastolic Blood Pressure" satisfies all:
                        Most Recent: < 1 year(s) starts before start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                        (result >= 90 mmHg)
                AND:
                    OR: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
                        Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                        (result >= 140 mmHg)
                    OR: "Physical Exam, Performed: Diastolic Blood Pressure" satisfies all:
                        Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                        (result >= 90 mmHg)
                AND:
                    OR: "Intervention, Order: Referral to Alternative Provider / Primary Care Provider (reason: Finding of Hypertension)" <= 1 day(s) starts after or concurrent with start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                    OR:
                        AND: $HypertensionRecommendations <= 1 day(s) starts after or concurrent with start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
                        AND: Union of:
                            "Medication, Order: Anti-Hypertensive Pharmacologic Therapy"
                            "Laboratory Test, Order: Laboratory Tests for Hypertension"
                            "Diagnostic Study, Order: ECG 12 lead or study order"
                            <= 1 day(s) starts after or concurrent with start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
*/

define "Most Recent BP Screening Encounter":
	Last("BP Screening Encounters with Readings")

define "Most Recent BP normal":
	exists ( { from
			"Most Recent Systolic Reading During Most Recent Encounter" Systolic,
			"Most Recent Diastolic Reading During Most Recent Encounter" Diastolic
			where ( Systolic.result < 120 'mm[Hg]'
					and Diastolic.result < 80 'mm[Hg]'
			) }
	)

define "Most Recent BP prehypertensive":
	exists ( { from
			"Most Recent Systolic Reading During Most Recent Encounter" Systolic,
			"Most Recent Diastolic Reading During Most Recent Encounter" Diastolic
			where ( Systolic.result >= 120 'mm[Hg]'
					and Systolic.result < 140 'mm[Hg]'
			)
				or ( Diastolic.result >= 80 'mm[Hg]'
						and Diastolic.result < 90 'mm[Hg]'
				) }
	)

define "Most Recent BP high":
	exists ( { from
			"Most Recent Systolic Reading During Most Recent Encounter" Systolic,
			"Most Recent Diastolic Reading During Most Recent Encounter" Diastolic
			where ( Systolic.result >= 140 'mm[Hg]'
					or Diastolic.result >= 90 'mm[Hg]'
			) }
	)

define "Last BP within one year high":
	exists ( { from
			"Last Diastolic one year before encounter high" lastdias,
			"Last Systolic one year before encounter high" lastsys
			where lastdias.result is not null
				and lastsys.result is not null }
	)

define "Second high BP":
	"Last BP within one year high"
		and "Most Recent BP high"

/*
    $HypertensionRecommendations =
        Union of:
            "Intervention, Order: Lifestyle Recommendation"
            "Intervention, Order: Weight Reduction Recommended"
            "Intervention, Order: Dietary Recommendations"
            "Intervention, Order: Physical Activity Recommendation"
            "Intervention, Order: Moderation of ETOH Consumption Recommendation"
*/

define "hypertensive interventions":
	exists ( ( ["Intervention, Order": "Referral to Alternative Provider / Primary Care Provider"] Referral
				with "Most Recent BP Screening Encounter" Enc
					such that Referral.authorDatetime within 1 day of start Enc.relevantPeriod
		)
			union ( ["Intervention, Order": "Lifestyle Recommendation"] Lifestyle
					with "Most Recent BP Screening Encounter" Enc
						such that Lifestyle.authorDatetime within 1 day of start Enc.relevantPeriod
			)
			union ( ["Intervention, Order": "Weight Reduction Recommended"] Weight
					with "Most Recent BP Screening Encounter" Enc
						such that Weight.authorDatetime within 1 day of start Enc.relevantPeriod
			)
			union ( ["Intervention, Order": "Dietary Recommendations"] Diet
					with "Most Recent BP Screening Encounter" Enc
						such that Diet.authorDatetime within 1 day of start Enc.relevantPeriod
			)
			union ( ["Intervention, Order": "Physical Activity Recommendation"] Phys
					with "Most Recent BP Screening Encounter" Enc
						such that Phys.authorDatetime within 1 day of start Enc.relevantPeriod
			)
			union ( ["Intervention, Order": "Moderation of ETOH Consumption Recommendation"] Modetoh
					with "Most Recent BP Screening Encounter" Enc
						such that Modetoh.authorDatetime within 1 day of start Enc.relevantPeriod
			)
	)

define "prehypertensive with intervention":
	"Most Recent BP prehypertensive"
		and "hypertensive interventions"
		and "follow up one year"

define "follow up one year":
	exists ( ["Intervention, Order": "Followup within one year"] Followupone
			with "Most Recent BP Screening Encounter" Recentenc
				such that Followupone.authorDatetime within 1 day of start Recentenc.relevantPeriod
	)

define "Numerator":
	"Most Recent BP normal"
		or "prehypertensive with intervention"
		or "First hypertensive with interventions"
		or "Second high BP with interventions"

define "Most Recent Prior BP Screening Encounter":
	Last("BP Screening Encounters with Readings" Encounter
			with "Most Recent BP Screening Encounter" MostRecentEncounter
				such that Encounter.relevantPeriod starts 1 year or less before MostRecentEncounter.relevantPeriod
			sort by start of relevantPeriod
	)

define "Most recent prior BP reading not high":
	exists ( { from
			"Most Recent Systolic Reading During Most Recent Prior Encounter" Systolic,
			"Most Recent Diastolic Reading During Most Recent Prior Encounter" Diastolic
			where ( Systolic.result < 140 'mm[Hg]'
					and Diastolic.result < 90 'mm[Hg]'
			) }
	)

define "Follow up within 4 weeks":
	exists ( ["Intervention, Order": "Followup within 4 weeks"] Followupweeks
			with "Most Recent BP Screening Encounter" Recentenc
				such that Followupweeks.authorDatetime within 1 day of start Recentenc.relevantPeriod
	)

define "First hypertensive with interventions":
	"Most Recent BP high"
		and "Most recent prior BP reading not high"
		and "hypertensive interventions"
		and "Follow up within 4 weeks"

define "Meds ordered":
	exists ( ["Medication, Order": "Anti-Hypertensive Pharmacologic Therapy"] meds
			with "Most Recent BP Screening Encounter" Enc
				such that meds.authorDatetime within 1 day of start Enc.relevantPeriod
	)

define "Labs ordered":
	exists ( ["Laboratory Test, Order": "Laboratory Tests for Hypertension"] labs
			with "Most Recent BP Screening Encounter" Enc
				such that labs.authorDatetime within 1 day of start Enc.relevantPeriod
	)

define "Ecg ordered":
	exists ( ["Diagnostic Study, Order": "ECG 12 lead or study order"] ecg
			with "Most Recent BP Screening Encounter" Enc
				such that ecg.authorDatetime within 1 day of start Enc.relevantPeriod
	)

define "Second hypertensive interventions":
	"Meds ordered"
		or "Labs ordered"
		or "Ecg ordered"

define "Second high BP with interventions":
	"Second high BP"
		and "hypertensive interventions"
		and "Second hypertensive interventions"

define "BP Screening Encounters with Readings":
	["Encounter, Performed": "BP Screening Encounter Codes"] Encounter
		with ["Physical Exam, Performed": "Diastolic Blood Pressure"] Diastolic
			such that Diastolic.relevantPeriod starts during Encounter.relevantPeriod
				and Diastolic.result is not null
		with ["Physical Exam, Performed": "Systolic Blood Pressure"] Systolic
			such that Systolic.relevantPeriod starts during Encounter.relevantPeriod
				and Systolic.result is not null
		sort by start of relevantPeriod

define "Most Recent Diastolic Reading During Most Recent Encounter":
	Last(["Physical Exam, Performed": "Diastolic Blood Pressure"] Diastolic
			with "Most Recent BP Screening Encounter" Encounter
				such that Diastolic.relevantPeriod during Encounter.relevantPeriod
					and Diastolic.result is not null
			sort by start of relevantPeriod
	)

define "Most Recent Diastolic Reading During Most Recent Prior Encounter":
	Last(["Physical Exam, Performed": "Diastolic Blood Pressure"] Diastolic
			with "Most Recent Prior BP Screening Encounter" Encounter
				such that Diastolic.relevantPeriod during Encounter.relevantPeriod
			sort by start of relevantPeriod
	)

define "Most Recent Systolic Reading During Most Recent Encounter":
	Last(["Physical Exam, Performed": "Systolic Blood Pressure"] Systolic
			with "Most Recent BP Screening Encounter" Encounter
				such that Systolic.relevantPeriod during Encounter.relevantPeriod
					and Systolic.result is not null
			sort by start of relevantPeriod
	)

define "Most Recent Systolic Reading During Most Recent Prior Encounter":
	Last(["Physical Exam, Performed": "Systolic Blood Pressure"] Systolic
			with "Most Recent Prior BP Screening Encounter" Encounter
				such that Systolic.relevantPeriod during Encounter.relevantPeriod
			sort by start of relevantPeriod
	)

define "Last Diastolic one year before encounter high":
	Last(["Physical Exam, Performed": "Diastolic Blood Pressure"] Diastolic
			with "Most Recent BP Screening Encounter" Encounter
				such that Diastolic.relevantPeriod starts 1 year before start Encounter.relevantPeriod
					and Diastolic.result >= 90 'mm[Hg]'
			sort by start of relevantPeriod
	)

define "Last Systolic one year before encounter high":
	Last(["Physical Exam, Performed": "Systolic Blood Pressure"] Systolic
			with "Most Recent BP Screening Encounter" Encounter
				such that Systolic.relevantPeriod starts 1 year before start Encounter.relevantPeriod
					and Systolic.result >= 140 'mm[Hg]'
			sort by start of relevantPeriod
	)

/*
    Denominator Exceptions =
        OR: Union of:
            "Physical Exam, Performed not done: Medical or Other reason not done" for "Diastolic Blood Pressure"
            "Physical Exam, Performed not done: Patient Reason refused" for "Diastolic Blood Pressure"
            "Physical Exam, Performed not done: Medical or Other reason not done" for "Systolic Blood Pressure"
            "Physical Exam, Performed not done: Patient Reason refused" for "Systolic Blood Pressure"
            starts during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
        OR: Union of:
            "Intervention, Order not done: Patient Reason refused" for "Referral to Alternative Provider / Primary Care Provider"
            "Intervention, Order not done: Patient Reason refused" for "Lifestyle Recommendation"
            "Intervention, Order not done: Patient Reason refused" for "Weight Reduction Recommended"
            "Intervention, Order not done: Patient Reason refused" for "Dietary Recommendations"
            "Intervention, Order not done: Patient Reason refused" for "Physical Activity Recommendation"
            "Intervention, Order not done: Patient Reason refused" for "Moderation of ETOH Consumption Recommendation"
            "Medication, Order not done: Patient Reason refused" for "Anti-Hypertensive Pharmacologic Therapy"
            "Laboratory Test, Order not done: Patient Reason refused" for "Laboratory Tests for Hypertension"
            "Diagnostic Study, Order not done: Patient Reason refused" for "ECG 12 lead or study order"
            <= 1 day(s) starts after or concurrent with start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
*/

define "Not Done Systolic Diastolic":
	exists ( ( ["Physical Exam, Not Performed": "Systolic Blood Pressure"] NoSystolicmed
				with "Encounters During Measurement Period" Enc
					such that NoSystolicmed.negationRationale in "Medical or Other reason not done"
						and NoSystolicmed.authorDatetime within 1 day of start Enc.relevantPeriod
		)
			union ( ["Physical Exam, Not Performed": "Diastolic Blood Pressure"] NoDiastolicmed
					with "Encounters During Measurement Period" Enc
						such that NoDiastolicmed.negationRationale in "Medical or Other reason not done"
							and NoDiastolicmed.authorDatetime within 1 day of start Enc.relevantPeriod
			)
			union ( ["Physical Exam, Not Performed": "Systolic Blood Pressure"] NoSystolicref
					with "Encounters During Measurement Period" Enc
						such that NoSystolicref.negationRationale in "Patient Reason refused"
							and NoSystolicref.authorDatetime during Enc.relevantPeriod
			)
			union ( ["Physical Exam, Not Performed": "Diastolic Blood Pressure"] NoDiastolicref
					with "Encounters During Measurement Period" Enc
						such that NoDiastolicref.negationRationale in "Patient Reason refused"
							and NoDiastolicref.authorDatetime during Enc.relevantPeriod
			)
	)

define "Not Done Followup Interventions":
	exists ( ( ["Intervention, Not Ordered": "Referral to Alternative Provider / Primary Care Provider"] NoReferral
				with "Most Recent BP Screening Encounter" Enc
					such that NoReferral.negationRationale in "Patient Reason refused"
						and NoReferral.authorDatetime within 1 day of start Enc.relevantPeriod
		)
			union ( ["Intervention, Not Ordered": "Lifestyle Recommendation"] NoLifestyle
					with "Most Recent BP Screening Encounter" Enc
						such that NoLifestyle.negationRationale in "Patient Reason refused"
							and NoLifestyle.authorDatetime within 1 day of start Enc.relevantPeriod
			)
			union ( ["Intervention, Not Ordered": "Weight Reduction Recommended"] NoWeight
					with "Most Recent BP Screening Encounter" Enc
						such that NoWeight.negationRationale in "Patient Reason refused"
							and NoWeight.authorDatetime within 1 day of start Enc.relevantPeriod
			)
			union ( ["Intervention, Not Ordered": "Dietary Recommendations"] NoDiet
					with "Most Recent BP Screening Encounter" Enc
						such that NoDiet.negationRationale in "Patient Reason refused"
							and NoDiet.authorDatetime within 1 day of start Enc.relevantPeriod
			)
			union ( ["Intervention, Not Ordered": "Physical Activity Recommendation"] NoPhys
					with "Most Recent BP Screening Encounter" Enc
						such that NoPhys.negationRationale in "Patient Reason refused"
							and NoPhys.authorDatetime within 1 day of start Enc.relevantPeriod
			)
			union ( ["Intervention, Not Ordered": "Moderation of ETOH Consumption Recommendation"] NoModetoh
					with "Most Recent BP Screening Encounter" Enc
						such that NoModetoh.negationRationale in "Patient Reason refused"
							and NoModetoh.authorDatetime within 1 day of start Enc.relevantPeriod
			)
	)

define "Denominator Exceptions":
	"Not Done Systolic Diastolic"
		or "Not Done Followup Interventions"

/*
    Denominator Exclusions =
        OR: "Diagnosis: Diagnosis of hypertension" starts before start of "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
*/

define "Denominator Exclusions":
	exists ( ["Diagnosis": "Diagnosis of hypertension"] Diag
			with "Most Recent BP Screening Encounter" Enc
				such that Diag.prevalencePeriod starts before start of Enc.relevantPeriod
	)

/*
    Numerator Exclusions =
        None
*/

/*
    Stratification =
        None
*/

// Supplemental Data

define "SDE Ethnicity":
	["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer":
	["Patient Characteristic Payer": "Payer"]

define "SDE Race":
	["Patient Characteristic Race": "Race"]

define "SDE Sex":
	["Patient Characteristic Sex": "ONC Administrative Sex"]

