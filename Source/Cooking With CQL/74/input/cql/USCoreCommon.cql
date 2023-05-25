/*
@author: Bryn Rhodes
@description: This library defines functions to expose extensions defined
in QICore as fluent functions in CQL, as well as common terminology and functions
used in writing CQL with FHIR and QICore profiles.
*/
library USCoreCommon version '0.1.0'

using USCore version '3.1.1'

include FHIRHelpers version '4.0.1'

codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMEDCT": 'http://snomed.info/sct'
codesystem "CVX": 'http://hl7.org/fhir/sid/cvx'
codesystem "ActCode": 'http://terminology.hl7.org/CodeSystem/v3-ActCode'
codesystem "RoleCode": 'http://terminology.hl7.org/CodeSystem/v3-RoleCode'
codesystem "Diagnosis Role": 'http://terminology.hl7.org/CodeSystem/diagnosis-role'
codesystem "RequestIntent": 'http://hl7.org/fhir/request-intent'
codesystem "MedicationRequestCategory": 'http://terminology.hl7.org/CodeSystem/medicationrequest-category'
codesystem "ConditionClinicalStatusCodes": 'http://terminology.hl7.org/CodeSystem/condition-clinical'
codesystem "ConditionVerificationStatusCodes": 'http://terminology.hl7.org/CodeSystem/condition-ver-status'
codesystem "AllergyIntoleranceClinicalStatusCodes": 'http://terminology.hl7.org/CodeSystem/allergyintolerance-clinical'
codesystem "AllergyIntoleranceVerificationStatusCodes": 'http://terminology.hl7.org/CodeSystem/allergyintolerance-verification'
codesystem "ObservationCategoryCodes": 'http://terminology.hl7.org/CodeSystem/observation-category'
codesystem "USCoreObservationCategory": 'http://hl7.org/fhir/us/core/CodeSystem/us-core-observation-category'
codesystem "ConditionCategory": 'http://terminology.hl7.org/CodeSystem/condition-category'
codesystem "USCoreConditionCategory": 'http://hl7.org/fhir/us/core/CodeSystem/condition-category'
codesystem "CDC Race and Ethnicity Codes": 'urn:oid:2.16.840.1.113883.6.238'
codesystem "CommunicationCategoryCodeSystem": 'http://terminology.hl7.org/CodeSystem/communication-category'

code "Birthdate": '21112-8' from "LOINC" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT" display 'Dead'
code "ER": 'ER' from "RoleCode" display 'Emergency room'
code "ICU": 'ICU' from "RoleCode" display 'Intensive care unit'
code "Billing": 'billing' from "Diagnosis Role" display 'Billing'

// Encounter Class Codes
code "ambulatory": 'AMB' from ActCode display 'ambulatory'
code "emergency": 'EMER' from ActCode display 'emergency'
code "field": 'FLD' from ActCode display 'field'
code "home health": 'HH' from ActCode display 'home health'
code "inpatient encounter": 'IMP' from ActCode display 'inpatient encounter'
code "inpatient acute": 'ACUTE' from ActCode display 'inpatient acute'
code "inpatient non-acute": 'NONAC' from ActCode display 'inpatient non-acute'
code "observation encounter": 'OBSENC' from ActCode display 'observation encounter'
code "pre-admission": 'PRENC' from ActCode display 'pre-admission'
code "short stay": 'SS' from ActCode display 'short stay'
code "virtual": 'VR' from ActCode display 'VR'

// Condition Category Codes
code "problem-list-item": 'problem-list-item' from "ConditionCategory" display 'Problem List Item'
code "encounter-diagnosis": 'encounter-diagnosis' from "ConditionCategory" display 'Encounter Diagnosis'
code "health-concern": 'health-concern' from "USCoreConditionCategory" display 'Health Concern'

// Condition Clinical Status Codes - Consider value sets for these
code "active": 'active' from "ConditionClinicalStatusCodes"
code "recurrence": 'recurrence' from "ConditionClinicalStatusCodes"
code "relapse": 'relapse' from "ConditionClinicalStatusCodes"
code "inactive": 'inactive' from "ConditionClinicalStatusCodes"
code "remission": 'remission' from "ConditionClinicalStatusCodes"
code "resolved": 'resolved' from "ConditionClinicalStatusCodes"

// Condition Verification Status Codes - Consider value sets for these
code "unconfirmed": 'unconfirmed' from ConditionVerificationStatusCodes
code "provisional": 'provisional' from ConditionVerificationStatusCodes
code "differential": 'differential' from ConditionVerificationStatusCodes
code "confirmed": 'confirmed' from ConditionVerificationStatusCodes
code "refuted": 'refuted' from ConditionVerificationStatusCodes
code "entered-in-error": 'entered-in-error' from ConditionVerificationStatusCodes

code "allergy-active": 'active' from "AllergyIntoleranceClinicalStatusCodes"
code "allergy-inactive": 'inactive' from "AllergyIntoleranceClinicalStatusCodes"
code "allergy-resolved": 'resolved' from "AllergyIntoleranceClinicalStatusCodes"

// Allergy/Intolerance Verification Status Codes - Consider value sets for these
code "allergy-unconfirmed": 'unconfirmed' from AllergyIntoleranceVerificationStatusCodes
code "allergy-confirmed": 'confirmed' from AllergyIntoleranceVerificationStatusCodes
code "allergy-refuted": 'refuted' from AllergyIntoleranceVerificationStatusCodes

// MedicationRequest Category Codes
code "Inpatient": 'inpatient' from "MedicationRequestCategory" display 'Inpatient'
code "Outpatient": 'outpatient' from "MedicationRequestCategory" display 'Outpatient'
code "Community": 'community' from "MedicationRequestCategory" display 'Community'
code "Discharge": 'discharge' from "MedicationRequestCategory" display 'Discharge'

// Diagnosis Role Codes
code "AD": 'AD' from "Diagnosis Role" display 'Admission diagnosis'
code "DD": 'DD' from "Diagnosis Role" display 'Discharge diagnosis'
code "CC": 'CC' from "Diagnosis Role" display 'Chief complaint'
code "CM": 'CM' from "Diagnosis Role" display 'Comorbidity diagnosis'
code "pre-op": 'pre-op' from "Diagnosis Role" display 'pre-op diagnosis'
code "post-op": 'post-op' from "Diagnosis Role" display 'post-op diagnosis'
code "billing": 'billing' from "Diagnosis Role" display 'billing diagnosis'

// Observation Category Codes
code "social-history": 'social-history' from "ObservationCategoryCodes" display 'Social History'
code "vital-signs": 'vital-signs' from "ObservationCategoryCodes" display 'Vital Signs'
code "imaging": 'imaging' from "ObservationCategoryCodes" display 'Imaging'
code "laboratory": 'laboratory' from "ObservationCategoryCodes" display 'Laboratory'
code "procedure": 'procedure' from "ObservationCategoryCodes" display 'Procedure'
code "survey": 'survey' from "ObservationCategoryCodes" display 'Survey'
code "exam": 'exam' from "ObservationCategoryCodes" display 'Exam'
code "therapy": 'therapy' from "ObservationCategoryCodes" display 'Therapy'
code "activity": 'activity' from "ObservationCategoryCodes" display 'Activity'
code "clinical-test": 'clinical-test' from "USCoreObservationCategory" display 'Clinical Test'

context Patient

/* Candidates for FHIRCommon */

/*
@description: Returns true if the given condition has a clinical status of active, recurrence, or relapse
*/
define fluent function isActive(condition Condition):
  condition.clinicalStatus ~ "active"
    or condition.clinicalStatus ~ "recurrence"
    or condition.clinicalStatus ~ "relapse"

define fluent function active(conditions List<Condition>):
  conditions C
    where C.clinicalStatus ~ "active"
      or C.clinicalStatus ~ "recurrence"
      or C.clinicalStatus ~ "relapse"

define fluent function isActive(allergyIntolerance AllergyIntolerance):
  allergyIntolerance.clinicalStatus ~ "allergy-active"

define fluent function active(allergyIntolerances List<AllergyIntolerance>):
  allergyIntolerances A
    where A.clinicalStatus ~ "allergy-active"

define fluent function isInactive(allergyIntolerance AllergyIntolerance):
  allergyIntolerance.clinicalStatus ~ "allergy-inactive"

define fluent function inactive(allergyIntolerances List<AllergyIntolerance>):
  allergyIntolerances A
    where A.clinicalStatus ~ "allergy-inactive"

define fluent function isResolved(allergyIntolerance AllergyIntolerance):
  allergyIntolerance.clinicalStatus ~ "allergy-resolved"

define fluent function resolved(allergyIntolerances List<AllergyIntolerance>):
  allergyIntolerances A
    where A.clinicalStatus ~ "allergy-resolved"

define fluent function isConfirmed(allergyIntolerance AllergyIntolerance):
  allergyIntolerance.verificationStatus ~ "allergy-confirmed"

define fluent function confirmed(allergyIntolerances List<AllergyIntolerance>):
  allergyIntolerances A
    where A.verificationStatus ~ "allergy-confirmed"

define fluent function isUnconfirmed(allergyIntolerance AllergyIntolerance):
  allergyIntolerance.verificationStatus ~ "allergy-unconfirmed"

define fluent function unconfirmed(allergyIntolerances AllergyIntolerance):
  allergyIntolerances A
    where A.verificationStatus ~ "allergy-unconfirmed"

define fluent function isRefuted(allergyIntolerance AllergyIntolerance):
  allergyIntolerance.verificationStatus ~ "allergy-refuted"

define fluent function refuted(allergyIntolerances AllergyIntolerance):
  allergyIntolerances A
    where A.verificationStatus ~ "allergy-refuted"

/*
@description: Returns true if the given condition has the given category
*/
define fluent function hasCategory(condition Condition, category Code):
  exists (condition.category C
    where C ~ category
  )

/*
@description: Returns true if the given condition is a problem list item.
*/
define fluent function isProblemListItem(condition Condition):
  exists (condition.category C
    where C ~ "problem-list-item"
  )

/*
@description: Returns true if the given condition is an encounter diagnosis
*/
define fluent function isEncounterDiagnosis(condition Condition):
  exists (condition.category C
    where C ~ "encounter-diagnosis"
  )

/*
@description: Returns true if the given condition is a health concern
*/
define fluent function isHealthConcern(condition Condition):
  exists (condition.category C
    where C ~ "health-concern"
  )

define fluent function isUnconfirmed(condition Condition):
  condition.verificationStatus ~ "unconfirmed"

define fluent function unconfirmed(conditions List<Condition>):
  conditions C
    where C.verificationStatus ~ "unconfirmed"

define fluent function isProvisional(condition Condition):
  condition.verificationStatus ~ "provisional"

define fluent function provisional(conditions List<Condition>):
  conditions C
    where C.verificationStatus ~ "provisional"

define fluent function isDifferential(condition Condition):
  condition.verificationStatus ~ "differential"

define fluent function differential(conditions List<Condition>):
  conditions C
    where C.verificationStatus ~ "differential"

define fluent function isConfirmed(condition Condition):
  condition.verificationStatus ~ "confirmed"

define fluent function confirmed(conditions List<Condition>):
  conditions C
    where C.verificationStatus ~ "confirmed"

define fluent function isRefuted(condition Condition):
  condition.verificationStatus ~ "refuted"

define fluent function refuted(conditions List<Condition>):
  conditions C
    where C.verificationStatus ~ "refuted"

/*
@description: Returns true if the given observation has the given category
*/
define fluent function hasCategory(observation LaboratoryResultObservationProfile, category Code):
  exists (observation.category C
    where C ~ category
  )

/*
@description: Returns true if the given MedicationRequest has a category of Community
*/
define fluent function isCommunity(medicationRequest MedicationRequestProfile):
  exists (medicationRequest.category C
    where C ~ Community
  )

/*
@description: Returns true if the given MedicationRequest has a category of Discharge
*/
define fluent function isDischarge(medicationRequest MedicationRequestProfile):
  exists (medicationRequest.category C
    where C ~ Discharge
  )

/*
@description: Returns true if the given MedicationRequest has the given category
*/
define fluent function hasCategory(medicationRequest MedicationRequestProfile, category Code):
  exists (medicationRequest.category C
    where C ~ category
  )

/*
@description: Normalizes a value that is a choice of timing-valued types to an equivalent interval
@comment: Normalizes a choice type of DateTime, Quanitty, Interval<DateTime>, or Interval<Quantity> types
to an equivalent interval. This selection of choice types is a superset of the majority of choice types that are used as possible
representations for timing-valued elements in QICore, allowing this function to be used across any resource.
The input can be provided as a DateTime, Quantity, Interval<DateTime> or Interval<Quantity>.
The intent of this function is to provide a clear and concise mechanism to treat single
elements that have multiple possible representations as intervals so that logic doesn't have to account
for the variability. More complex calculations (such as medication request period or dispense period
calculation) need specific guidance and consideration. That guidance may make use of this function, but
the focus of this function is on single element calculations where the semantics are unambiguous.
If the input is a DateTime, the result a DateTime Interval beginning and ending on that DateTime.
If the input is a Quantity, the quantity is expected to be a calendar-duration interpreted as an Age,
and the result is a DateTime Interval beginning on the Date the patient turned that age and ending immediately before one year later.
If the input is a DateTime Interval, the result is the input.
If the input is a Quantity Interval, the quantities are expected to be calendar-durations interpreted as an Age, and the result
is a DateTime Interval beginning on the date the patient turned the age given as the start of the quantity interval, and ending
immediately before one year later than the date the patient turned the age given as the end of the quantity interval.
Any other input will reslt in a null DateTime Interval
*/
define fluent function toInterval(choice Choice<DateTime, Quantity, Interval<DateTime>, Interval<Quantity>>):
  case
	  when choice is DateTime then
    	Interval[choice as DateTime, choice as DateTime]
		when choice is Interval<DateTime> then
  		choice as Interval<DateTime>
		when choice is Quantity then
		  Interval[Patient.birthDate + (choice as Quantity),
			  Patient.birthDate + (choice as Quantity) + 1 year)
		when choice is Interval<Quantity> then
		  Interval[Patient.birthDate + (choice.low as Quantity),
			  Patient.birthDate + (choice.high as Quantity) + 1 year)
		else
			null as Interval<DateTime>
	end

/*
@description: Returns an interval representing the normalized abatement of a given Condition.
@comment: If the abatement element of the Condition is represented as a DateTime, the result
is an interval beginning and ending on that DateTime.
If the abatement is represented as a Quantity, the quantity is expected to be a calendar-duration and is interpreted as the age of the patient. The
result is an interval from the date the patient turned that age to immediately before one year later.
If the abatement is represented as a Quantity Interval, the quantities are expected to be calendar-durations and are interpreted as an age range during
which the abatement occurred. The result is an interval from the date the patient turned the starting age of the quantity interval, and ending immediately
before one year later than the date the patient turned the ending age of the quantity interval.
*/
define fluent function abatementInterval(condition Condition):
	if condition.abatement is DateTime then
	  Interval[condition.abatement as DateTime, condition.abatement as DateTime]
	else if condition.abatement is Quantity then
		Interval[Patient.birthDate + (condition.abatement as Quantity),
			Patient.birthDate + (condition.abatement as Quantity) + 1 year)
	else if condition.abatement is Interval<Quantity> then
	  Interval[Patient.birthDate + (condition.abatement.low as Quantity),
		  Patient.birthDate + (condition.abatement.high as Quantity) + 1 year)
	else if condition.abatement is Interval<DateTime> then
	  Interval[condition.abatement.low, condition.abatement.high)
	else null as Interval<DateTime>

/*
@description: Returns an interval representing the normalized prevalence period of a given Condition.
@comment: Uses the toInterval and abatementInterval functions to determine the widest potential interval from
onset to abatement as specified in the given Condition. If the condition is active, the resulting interval will have
a closed ending boundary. If the condition is not active, the resulting interval will have an open ending boundary.
*/
define fluent function prevalenceInterval(condition Condition):
if condition.clinicalStatus ~ "active"
  or condition.clinicalStatus ~ "recurrence"
  or condition.clinicalStatus ~ "relapse" then
  Interval[start of condition.onset.toInterval(), end of condition.abatementInterval()]
else
  Interval[start of condition.onset.toInterval(), end of condition.abatementInterval())

/*
@description: Returns the tail of the given uri (i.e. everything after the last slash in the URI).
@comment: This function can be used to determine the logical id of a given resource. It can be used in
a single-server environment to trace references. However, this function does not attempt to resolve
or distinguish the base of the given url, and so cannot be used safely in multi-server environments.
*/
define fluent function getId(uri String):
  Last(Split(uri, '/'))

/*
@description: Given an interval, return true if the interval has a starting boundary specified
(i.e. the start of the interval is not null and not the minimum DateTime value)
*/
define fluent function hasStart(period Interval<DateTime> ):
  not ( start of period is null
      or start of period = minimum DateTime
  )

/*
@description: Given an interval, returns true if the interval has an ending boundary specified
(i.e. the end of the interval is not null and not the maximum DateTime value)
*/
define fluent function hasEnd(period Interval<DateTime> ):
  not (
    end of period is null
      or end of period = maximum DateTime
  )

/*
@description: Given an interval, returns the ending point if the interval has an ending boundary specified,
otherwise, returns the starting point
*/
define fluent function latest(choice Choice<DateTime, Quantity, Interval<DateTime>, Interval<Quantity>> ):
  (choice.toInterval()) period
    return
      if (period.hasEnd()) then end of period
      else start of period

/*
@description: Given an interval, return the starting point if the interval has a starting boundary specified,
otherwise, return the ending point
*/
define fluent function earliest(choice Choice<DateTime, Quantity, Interval<DateTime>, Interval<Quantity>> ):
  (choice.toInterval()) period
    return
      if (period.hasStart()) then start of period
      else end of period

