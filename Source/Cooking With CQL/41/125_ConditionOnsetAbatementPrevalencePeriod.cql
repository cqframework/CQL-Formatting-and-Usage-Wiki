library ConditionOnsetAbatementPrevalencePeriod

/*
Based on EXM135
Illustrates determining Onset/Abatement and PrevalencePeriod for a Condition
*/

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include MATGlobalCommonFunctions_FHIR4 version '4.0.000' called Global

valueset "Pregnancy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.378'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2019-01-01T00:00:00.0, @2020-01-01T00:00:00.0)

context Patient

/*
http://build.fhir.org/ig/HL7/fhir-qi-core/StructureDefinition-qicore-condition-definitions.html#Condition.onset[x]

OnSet for QICoreCondition (STU3) is specified as a choice of:
* dateTime
* Age
* Period
* Range
Abatement is specified as a choice of:
* date
* Age
* boolean (in FHIR, constrained out of QICore)
* Period
* Range
*/

/*
So we define a "Normalize Onset" that determines the onset interval for the pregnancy
and a "Normalize Abatement" that determines the abatement interval for the pregnancy
*/
define "Diagnosis of Pregnancy Outpatient":
	["Condition": "Pregnancy"] Pregnancy
		with "Heart Failure Outpatient Encounter with Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
      such that Global."Normalize Onset"(Pregnancy.onset) overlaps ModerateOrSevereLVSDHFOutpatientEncounter.period
        or Global."Normalize Abatement"(Pregnancy) overlaps ModerateOrSevereLVSDHFOutpatientEncounter.period
		where FHIRHelpers.ToConcept(Pregnancy.clinicalStatus) ~ Global."active"
			and FHIRHelpers.ToConcept(Pregnancy.verificationStatus) ~ Global."confirmed"

define function "Normalize Onset"(onset Choice<FHIR.dateTime, FHIR.Age, FHIR.Period, FHIR.Range, FHIR.string>):
  if onset is FHIR.dateTime then
	  Interval[FHIRHelpers.ToDateTime(onset as FHIR.dateTime), FHIRHelpers.ToDateTime(onset as FHIR.dateTime)]
	else if onset is FHIR.Period then
	  FHIRHelpers.ToInterval(onset as FHIR.Period)
	else if onset is FHIR.Age then
	  Interval[FHIRHelpers.ToDate(Patient.birthDate) + FHIRHelpers.ToQuantity(onset as FHIR.Age),
		  FHIRHelpers.ToDate(Patient.birthDate) + FHIRHelpers.ToQuantity(onset as FHIR.Age) + 1 year)
	else null

define function "Normalize Abatement"(condition Condition):
	if condition.abatement is FHIR.dateTime then
	  Interval[FHIRHelpers.ToDateTime(condition.abatement as FHIR.dateTime), FHIRHelpers.ToDateTime(condition.abatement as FHIR.dateTime)]
	else if condition.abatement is FHIR.Period then
	  FHIRHelpers.ToInterval(condition.abatement as FHIR.Period)
	else if condition.abatement is FHIR.Age then
		Interval[FHIRHelpers.ToDate(Patient.birthDate) + FHIRHelpers.ToQuantity(condition.abatement as FHIR.Age),
			FHIRHelpers.ToDate(Patient.birthDate) + FHIRHelpers.ToQuantity(condition.abatement as FHIR.Age) + 1 year)
	else if condition.abatement is FHIR.boolean then
    // TODO: handle true vs false
    // DISCUSSION: Note that this assumes that the condition abated some time before the recorded date,
    // which may not be clinically appropriate, depending on the use case
	  Interval[end of "Normalize Onset"(condition.onset), condition.recordedDate)
	else null

/*
But given these functions, we could simplify the above by defining a "Prevalence Period" function
that combines Normalize Onset and Normalize Abatement:
*/

define function "Prevalence Period"(condition Condition):
  Interval[start of "Normalize Onset"(condition.onset), end of "Normalize Abatement"(condition))

define "Diagnosis of Pregnancy Outpatient (simplified)":
	["Condition": "Pregnancy"] Pregnancy
		with "Heart Failure Outpatient Encounter with Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
      such that Global."Prevalence Period"(Pregnancy) overlaps ModerateOrSevereLVSDHFOutpatientEncounter.period
		where FHIRHelpers.ToConcept(Pregnancy.clinicalStatus) ~ Global."active"
			and FHIRHelpers.ToConcept(Pregnancy.verificationStatus) ~ Global."confirmed"

// NOTE: Only included for testing, see the source for EXM135 for the actual definition:

define "Heart Failure Outpatient Encounter with Moderate or Severe LVSD":
  ["Encounter"]
