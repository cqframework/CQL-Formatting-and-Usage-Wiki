library CookingWithCQL_01_Example_02 version '1'

using QDM // version '4.2'

/*
 * Depression Remission or Response for Adolescents and Adults
 */

parameter "Measurement Period" Interval<DateTime>

context Patient


/*

Initial Population

AND: Age >= 12 year(s) at: "Measurement Period"
AND: $DepressionEncounter
AND: $DepressionIndex
*/

define "In Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 12
    and exists "Depression Encounter"
    and exists "Depression Index"

/*
Depression Followup

AND: Union Of:
	"Risk Category Assessment: PHQ-9 Tool" satisfies all:
		(result)
		>= 5 month(s) starts after start of "$DepressionIndex"
		< 7 month(s) ends after start of "$DepressionIndex "
	“Risk Category Assessment: PHQ-9 Modified Score" satisfies all:
		(result)
		>= 5 month(s) starts after start of "$DepressionIndex"
		< 7 month(s) ends after start of "$DepressionIndex.
*/

define "PHQ-9 Assessment":
  (["Risk Category Assessment": "PHQ-9 Tool"]
    union ["Risk Category Assessment": "PHQ-9 Modified Score"]
  ) RiskAssessment
    where RiskAssessment.negationRationale is null
      and RiskAssessment.result is not null

define "Depression Followup":
  "PHQ-9 Assessment" Assessment
    with "Depression Index" DepressionIndex
      such that Assessment.startDateTime in
        Interval[DepressionIndex.startDateTime + 5 months, DepressionIndex.startDateTime + 7 months)

/*
Depression Remission

AND: Union Of:
	"Risk Category Assessment: PHQ-9 Tool" satisfies all:
		(result<5)
		>= 5 month(s) starts after start of "$DepressionIndex"
		< 7 month(s) ends after start of "$DepressionIndex "
	“Risk Category Assessment: PHQ-9 Modified Score" satisfies all:
		(result<5)
		>= 5 month(s) starts after start of "$DepressionIndex"
		< 7 month(s) ends after start of "$DepressionIndex "
*/

define "Depression Remission":
  "PHQ-9 Assessment" Assessment
    with "Depression Index" DepressionIndex
      such that Assessment.startDateTime in
        Interval[DepressionIndex.startDateTime + 5 months, DepressionIndex.startDateTime + 7 months)
    where Assessment.result < 5

/*
Depression Response

AND: Union Of:
	"Risk Category Assessment: PHQ-9 Tool" satisfies all:
		(result <= 50% $DepressionIndex)
		>= 5 month(s) starts after start of "$DepressionIndex"
		< 7 month(s) ends after start of "$DepressionIndex "
	“Risk Category Assessment: PHQ-9 Modified Score" satisfies all:
		(result <= 50% $DepressionIndex)
		>= 5 month(s) starts after start of "$DepressionIndex"
		< 7 month(s) ends after start of "$DepressionIndex "
*/

define "Depression Response":
  "PHQ-9 Assessment" Assessment
    with "Depression Index" DepressionIndex
      such that Assessment.startDateTime in
        Interval[DepressionIndex.startDateTime + 5 months, DepressionIndex.startDateTime + 7 months]
          and Assessment.result <= (DepressionIndex.result / 2)

/*
$DepressionEncounter =
	$Encounter Satisfies all:
		<= 8 month(s) ends before start of "Measurement Period"
		<= 4 month(s) ends after start of "Measurement Period"
		satisfies any:
			overlaps "Diagnosis: Major Depression Including Remission"
			overlaps "Diagnosis: Dysthymia"
*/

define "Intake Encounter":
  ["Encounter, Performed": "Outpatient"] Encounter
    where Encounter.negationRationale is null
      and Encounter.dischargeDateTime in Interval[start of "Measurement Period" - 8 months, start of "Measurement Period" + 4 months]

define "Depression Encounter":
  "Intake Encounter" Encounter
    with (["Diagnosis": "Major Depression Including Remission"]
        union ["Diagnosis": "Dysthymia"]
      ) Diagnosis
      such that Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime]
        overlaps Interval[Diagnosis.onsetDatetime, Diagnosis.abatementDateTime]

/*
$DepressionIndex =
	Satisfies any:
		"FIRST: Risk Category Assessment: PHQ-9 Tool (result > 9 )" Satisfies any:
			during $Depression Encounter
			<=15 day(s) stars before start of $Depression Encounter
			<=15 day(s) starts after start of $Depression Encounter
		 “FIRST: Risk Category Assessment: PHQ-9 Modified Tool (result > 9 )" Satisfies any:
			during $Depression Encounter
			<=15 day(s) stars before start of $DepressionEncounter
			<=15 day(s) starts after start of $DepressionEncounter
*/

define "PHQ-9 Assessment > 9":
  (["Risk Category Assessment": "PHQ-9 Tool"]
    union ["Risk Category Assessment": "PHQ-9 Modified Tool"]
  ) RiskAssessment
    where RiskAssessment.negationRationale is null
      and RiskAssessment.result > 9

define "Depression Index":
  First("PHQ-9 Assessment > 9" Assessment
    with "Depression Encounter" Encounter
      such that Assessment.startDateTime within 15 days of Encounter.admissionDateTime
  )
