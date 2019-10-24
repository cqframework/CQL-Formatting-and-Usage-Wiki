library MATGlobalCommonFunctions_FHIR4 version '4.0.000'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers

codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMEDCT": 'http://snomed.info/sct/731000124108'
codesystem "RoleCode": 'http://hl7.org/fhir/v3/RoleCode'
codesystem "Diagnosis Role": 'http://terminology.hl7.org/CodeSystem/diagnosis-role'

valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'
valueset "Emergency Department Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.292'
valueset "Observation Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1111.143'

code "Birthdate": '21112-8' from "LOINC" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT" display 'Dead'
code "ER": 'ER' from "RoleCode" display 'Emergency room'
code "ICU": 'ICU' from "RoleCode" display 'Intensive care unit'
code "Billing": 'billing' from "Diagnosis Role" display 'Billing'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Inpatient Encounter":
	[Encounter: "Encounter Inpatient"] EncounterInpatient
		where EncounterInpatient.status = 'finished'
		    and "LengthInDays"(EncounterInpatient.period) <= 120
			and EncounterInpatient.period ends during "Measurement Period"

define function "ToDate"(Value DateTime):
	DateTime(year from Value, month from Value, day from Value, 0, 0, 0, 0, timezone from Value)

define function "CalendarAgeInDaysAt"(BirthDateTime DateTime, AsOf DateTime):
	days between ToDate(BirthDateTime)and ToDate(AsOf)

define function "CalendarAgeInDays"(BirthDateTime DateTime):
	CalendarAgeInDaysAt(BirthDateTime, Today())

define function "CalendarAgeInMonthsAt"(BirthDateTime DateTime, AsOf DateTime):
	months between ToDate(BirthDateTime)and ToDate(AsOf)

define function "CalendarAgeInMonths"(BirthDateTime DateTime):
	CalendarAgeInMonthsAt(BirthDateTime, Today())

define function "CalendarAgeInYearsAt"(BirthDateTime DateTime, AsOf DateTime):
	years between ToDate(BirthDateTime)and ToDate(AsOf)

define function "CalendarAgeInYears"(BirthDateTime DateTime):
	CalendarAgeInYearsAt(BirthDateTime, Today())

define function "LengthInDays"(Value Interval<DateTime>):
	difference in days between start of Value and end of Value

define function "ED Visit"(TheEncounter FHIR.Encounter):
    singleton from (
        [Encounter: "Emergency Department Visit"] EDVisit
            where EDVisit.status = 'finished'
                and EDVisit.period ends 1 hour or less on or before start of FHIRHelpers.ToInterval(TheEncounter.period)
    )

define function "Hospitalization"(TheEncounter FHIR.Encounter):
	( "ED Visit"(TheEncounter) ) X
    return
        if X is null then TheEncounter.period
        else Interval[start of FHIRHelpers.ToInterval(X.period), end of FHIRHelpers.ToInterval(TheEncounter.period)]

define function "Hospitalization Locations"(TheEncounter FHIR.Encounter):
	( "ED Visit"(TheEncounter) ) EDEncounter
    return
        if EDEncounter is null then TheEncounter.location
        else flatten { EDEncounter.location, TheEncounter.location }

define function "Hospitalization Length of Stay"(TheEncounter FHIR.Encounter):
	LengthInDays("Hospitalization"(TheEncounter))

define function "Hospital Admission Time"(TheEncounter FHIR.Encounter):
	start of "Hospitalization"(TheEncounter)

define function "Hospital Discharge Time"(TheEncounter FHIR.Encounter):
	end of FHIRHelpers.ToInterval(TheEncounter.period)

define function "Hospital Arrival Time"(TheEncounter FHIR.Encounter):
	start of FHIRHelpers.ToInterval(First(
	    ( "Hospitalization Locations"(TheEncounter) ) HospitalLocation
			sort by start of FHIRHelpers.ToInterval(period)
	).period)

// TODO - fix these (must fetch Location resources and compare id to reference)
/*define function "Hospital Departure Time"(TheEncounter FHIR.Encounter):
	end of FHIRHelpers.ToInterval(Last(
	    ( "Hospitalization Locations"(TheEncounter) ) HospitalLocation
			sort by start of FHIRHelpers.ToInterval(period)
	).period)

define function "Emergency Department Arrival Time"(TheEncounter FHIR.Encounter):
	start of FHIRHelpers.ToInterval((
	    singleton from (
	        ( "Hospitalization Locations"(TheEncounter) ) HospitalLocation
				where HospitalLocation.type ~ "ER"
		)
	).period)

define function "First Inpatient Intensive Care Unit"(TheEncounter FHIR.Encounter):
	First(
	    ( TheEncounter.location ) HospitalLocation
			where HospitalLocation.type ~ "ICU"
				and HospitalLocation.period during TheEncounter.period
			sort by start of FHIRHelpers.ToInterval(period)
	)*/




/*
*
*    CQFMeasures Common Logic
*
*/

define function "Normalize Onset"(onset Choice<FHIR.dateTime, FHIR.Age, FHIR.Period, FHIR.Range, FHIR.string>):
  if onset is FHIR.dateTime then Interval[onset.value, onset.value]
	else if onset is FHIR.Period then FHIRHelpers.ToInterval(onset as FHIR.Period)
	else null

define function "Get Choice Interval - dateTime or Period"(performed Choice<FHIR.dateTime,FHIR.Period>):
	if performed is FHIR.dateTime then Interval[performed.value, performed.value]
	else FHIRHelpers.ToInterval(performed as FHIR.Period)

define function "GetId"(uri String):
	Last(Split(uri, '/'))

define function "EncounterDiagnosis"(Encounter Encounter):
  Encounter.diagnosis D
    return singleton from ([Condition: id in "GetId"(D.condition.reference)])

// Returns the condition that is specified as the principal diagnosis for the encounter
// TODO: BTR 2019-07-30: Shouldn't need the FHIRHelpers reference here, investigate
define function "PrincipalDiagnosis"(Encounter Encounter):
	(singleton from (Encounter.diagnosis D where FHIRHelpers.ToInteger(D.rank) = 1 and FHIRHelpers.ToConcept(D.use) ~ "Billing")) PD
		return singleton from ([Condition: id in "GetId"(PD.condition.reference)])

// Returns the location for the given location reference
define function GetLocation(reference Reference):
  singleton from (
    [Location: id in GetId(reference.reference)]
  )

define function "HospitalizationWithObservation"(TheEncounter FHIR.Encounter):
	TheEncounter Visit
			let ObsVisit: Last([Encounter: "Observation Services"] LastObs
										where LastObs.period ends 1 hour or less on or before start of Visit.period
										sort by end of period
										),
					VisitStart: Coalesce(start of ObsVisit.period, start of Visit.period),
					EDVisit: Last([Encounter: "Emergency Department Visit"] LastED
									 where LastED.period ends 1 hour or less on or before VisitStart
									 sort by end of period
										)
		return Interval[Coalesce(start of EDVisit.period, VisitStart), end of Visit.period]

define function "HospitalizationWithObservationLengthofStay"(Encounter FHIR.Encounter):
	"LengthInDays"("HospitalizationWithObservation"(Encounter))

// TODO: Consider inclusion of NormalizeDateTime function
// Also look at NormalizeOnset
define function NormalizeDateTime(Value Choice<dateTime, Period>):
  if Value is dateTime then FHIRHelpers.ToDateTime(Value) else start of (Value as Period)
