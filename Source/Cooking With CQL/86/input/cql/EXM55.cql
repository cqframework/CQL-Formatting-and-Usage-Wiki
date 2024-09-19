/*
This example is a work in progress and should not be considered a final specification
or recommendation for guidance. This example will help guide and direct the process
of finding conventions and usage patterns that meet the needs of the various stakeholders
in the measure development community.
*/

library EXM55 version '5.0.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers

codesystem "Diagnosis Role": 'http://terminology.hl7.org/CodeSystem/diagnosis-role'

valueset "Emergency Department Visit" : 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.292'
valueset "Psychiatric/Mental Health Patient" : 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.299'
valueset "Hospital Settings" : 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1111.126'

code "Billing": 'billing' from "Diagnosis Role" display 'Billing'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population" :
  "Inpatient Encounter" Encounter
    with ["Encounter" : "Emergency Department Visit"] ED
     such that ED.status = 'finished'
       and ED.period ends 1 hour or less before start of Encounter.period

define "Measure Population" :
  "Initial Population"

define "Inpatient Encounter" :
  ["Encounter"] Encounter
    where LengthInDays(Encounter.period) <= 120
      and Encounter.period ends during "Measurement Period"

define "Measure Population Exclusion" :
  "Inpatient Encounter" Encounter
    with ["Encounter" : "Emergency Department Visit"] ED
      such that ED.period ends 1 hour or less before start of Encounter.period
        and ED.status = 'finished'
        and ED.hospitalization.admitSource in "Hospital Settings"

define function "PrincipalDiagnosis"(Encounter Encounter):
	(singleton from (Encounter.diagnosis D where D.use ~ ToConcept("Billing") and D.rank.value = 1)) PD
		return singleton from ([Condition: id in "GetId"(PD.condition.reference)])

define function "LengthInDays"(Value Interval<DateTime>):
	difference in days between start of Value and end of Value

define function "GetId"(uri String):
	Last(Split(uri, '/'))

define "Stratification 1" :
  "Inpatient Encounter" Encounter
    where not (PrincipalDiagnosis(Encounter).code in "Psychiatric/Mental Health Patient")

define "Stratification 2" :
  "Inpatient Encounter" Encounter
    where PrincipalDiagnosis(Encounter).code in "Psychiatric/Mental Health Patient"

define "Stratification 3" :
  "Inpatient Encounter" Encounter
    where PrincipalDiagnosis(Encounter) is null

//Measure Observation
define function "Related ED Visit" (Encounter "Encounter" ) :
  Last(["Encounter" : "Emergency Department Visit"] ED
    where ED.status = 'finished'
      and ED.period ends 1 hour or less before start of Encounter.period
    sort by start of period )

define function "Measure Observation" (Encounter "Encounter" ) :
  duration in minutes of "Related ED Visit"(Encounter).period
