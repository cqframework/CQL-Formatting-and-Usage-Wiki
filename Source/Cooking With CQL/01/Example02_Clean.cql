/*
 * Depression Remission or Response for Adolescents and Adults
 */

/*
Initial Population

AND: Age >= 12 year(s) at: "Measurement Period"
AND: $DepressionEncounter
AND: $DepressionIndex
*/

define "In Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 12
    and exists ("Depression Encounter")
    and exists ("Depression Index")

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

define "Depression Remission":
  "PHQ-9 Assessment" Assessment
    with "Depression Index" DepressionIndex
      such that Assessment.startDateTime in
        Interval[DepressionIndex.startDateTime + 5 months, DepressionIndex.startDateTime + 7 months)
          and Assessment.result < (DepressionIndex / 2)
// Result Type:
// List<Assessment>

define "Depression Remission":
  "PHQ-9 Assessment" Assessment,
    "Depression Index" DepressionIndex
  where Assessment.startDateTime in
    Interval[DepressionIndex.startDateTime + 5 months, DepressionIndex.startDateTime + 7 months)
      and Assessment.result < (DepressionIndex / 2)

// Result Type:
// List<{ Assessment "Risk Category Assessment", DepressionIndex "Risk Category Assessment" }>



define "Depression Diagnosis":
  (["Diagnosis": "Major Depression Including Remission"]
    union ["Diagnosis": "Dysthymia"]
  )

define "Outpatient Encounter During Intake":
  ["Encounter, Performed": "Outpatient"] Encounter
    where Encounter.negationRationale is null
      and Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime]
        during Interval[start of "Measurement Period" - 8 months, start of "Measurement Period" + 4 months]

define "Depression Encounter":
  "Outpatient Encounter During Intake" Encounter
    with "Depression Diagnosis" Diagnosis
      such that Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime]
        overlaps Interval[Diagnosis.onsetDateTime, Diagnosis.abatementDateTime]

/*
$DepressionEncounter =
	$Encounter Satisfies all:
		<= 8 month(s) ends before start of "Measurement Period"
		<= 4 month(s) ends after start of "Measurement Period"
		satisfies any:
			overlaps "Diagnosis: Major Depression Including Remission"
			overlaps "Diagnosis: Dysthymia"
*/

define "PHQ-9 Assessment":
  (["Risk Category Assessment": "PHQ-9 Tool"]
    union ["Risk Category Assessment": "PHQ-9 Modified Score"]
  ) RiskAssessment
    where RiskAssessment.negationRationale is null
      and RiskAssessment.result is not null

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

define "Depression Index":
  First("PHQ-9 Assessment" Assessment
    with "Depression Encounter" Encounter
      such that Assessment.startDateTime within 15 days of Encounter.admissionDateTime
    where Assessment.result > 9
  )
