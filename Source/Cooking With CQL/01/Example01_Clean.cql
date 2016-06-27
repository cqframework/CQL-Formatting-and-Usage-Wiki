library "Depression Example 01" version '1'

using QDM // version '4.2'

codesystem "LOINC": 'http://loinc.org'
valueset "Depression Encounter": 'OID'
code "Ideation": 'L90815-2' from "LOINC" display 'Ideation'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
 * Utilization of the PHQ-9 to Monitor Depression Symptoms for Adolescents and Adults
 */

/*
Initial Population:
  AND: Age >=12 years at “Measurement Period”
  AND: “Depression Encounter” during “Measurement Period”
  AND: Union of:
    Diagnosis: “Major Depression”
    Diagnosis: “Dysthymia”
    Overlaps “Measurement Period
*/

define "In Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 12
    and exists "Depression Encounter"
    and exists "Depression Diagnosis"

define "Depression Encounter":
  ["Encounter, Performed": "Depression Encounter"] Encounter
    where Encounter.negationRationale is null
      and Encounter.admissionDateTime during "Measurement Period"

define "Depression Diagnosis":
  (["Diagnosis": "Major Depression"]
    union ["Diagnosis": "Dysthymia"]
  ) Diagnosis
    where Interval[Diagnosis.onsetDateTime, Diagnosis.abatementDateTime]
      overlaps "Measurement Period"

define "Assessment Period 1":
  Interval[start of "Measurement Period", start of "Measurement Period" + 4 months)

define "Assessment Period 2":
  Interval[start of "Measurement Period" + 4 months, start of "Measurement Period" + 8 months)

define "Assessment Period 3":
  Interval[start of "Measurement Period" + 8 months, end of "Measurement Period"]

define "PHQ-9 Assessment":
  (["Risk Category Assessment": "PHQ-9 Tool"]
    union ["Risk Category Assessment": "PHQ-9 Modified Score"]
  ) RiskAssessment
    where RiskAssessment.negationRationale is null
      and RiskAssessment.result is not null

/*
Numerator 1
	AND: Union Of:
		"Risk Category Assessment: PHQ-9 Tool (result)"
		“Risk Category Assessment: PHQ-9 Modified Score (result)”
		< 4 month(s) starts after start of "Measurement Period"
*/

define "Assessments in Period 1":
  "PHQ-9 Assessment" Assessment
    where Assessment.startDateTime during "Assessment Period 1"

define "Numerator 1":
  exists ("Assessments in Period 1")

define "Ideation Assessments":
  ["Risk Category Assessment": "Ideation"] Assessment
    where Assessment.negationRationale is null
      and Assessment.result is not null

Assessment { startDateTime: , stopDateTime, negationRationale, result Integer }

/*
Numerator 2
	AND: Union Of:
		"Risk Category Assessment: PHQ-9 Tool" satisfies all:
			(result)
			>= 4 month(s) starts after start of "Measurement Period"
			< 8 month(s) ends after start of "Measurement Period"
		Risk Category Assessment: PHQ-9 Modified Score" satisfies all:
			(result)
			>= 4 month(s) starts after start of "Measurement Period"
			< 8 month(s) ends after start of "Measurement Period"
*/

define "Assessments in Period 2":
  "PHQ-9 Assessment" Assessment
    where Assessment.startDateTime during "Assessment Period 2"

define "Numerator 2":
  First("Assessments in Period 2") is not null

/*
Numerator 3
	AND: Union Of:
	 "Risk Category Assessment: PHQ-9 Tool (result)"
	 “Risk Category Assessment: PHQ- Modified Score (result)”
	 < 4 month(s) ends before end of "Measurement Period"
*/

define "Assessments in Period 3":
  "PHQ-9 Assessment" Assessment
    where Assessment.startDateTime during "Assessment Period 3"

define "Numerator 3":
  exists ("Assessments in Period 3")

/*
Stratification=
	Stratification 1 =
		AND: Age>= 12 year(s) at: "Measurement Period"
		AND: Age< 18 year(s) at: "Measurement Period"
	Stratification 2 =
		AND: Age>= 18 year(s) at: "Measurement Period"
		AND: Age< 45 year(s) at: "Measurement Period"
	Stratification 3 =
		AND: Age>= 45 year(s) at: "Measurement Period"
		AND: Age< 65 year(s) at: "Measurement Period"
	Stratification 4 =
		Age>= 65 year(s) at: "Measurement Period"
*/

define "Stratification 1":
  AgeInYearsAt(start of "Measurement Period") in Interval[12, 18)

define "Stratification 1":
  AgeInYearsAt(start of "Measurement Period") in Interval[18, 45)

define "Stratification 1":
  AgeInYearsAt(start of "Measurement Period") in Interval[45, 65)

define "Stratification 1":
  AgeInYearsAt(start of "Measurement Period") >= 65
