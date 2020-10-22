library MATGlobalCommonFunctions version '4.0.111'

/*For use with program eCQMs during the AU 2019*/

using QDM version '5.5'

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Intensive Care Unit": 'urn:oid:2.16.840.1.113762.1.4.1110.23'
valueset "Observation Services": 'urn:oid:2.16.840.1.113762.1.4.1111.143'
valueset "Outpatient Surgery Service": 'urn:oid:2.16.840.1.113762.1.4.1110.38'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Inpatient Encounter":
	["Encounter, Performed": "Encounter Inpatient"] EncounterInpatient
		where "LengthInDays"(EncounterInpatient.relevantPeriod)<= 120
			and EncounterInpatient.relevantPeriod ends during "Measurement Period"

define "ED Encounter":
	["Encounter, Performed": "Emergency Department Visit"]

/*ToDate takes a given DateTime value and returns a DateTime with the time components "zeroed", and the timezone of the input value, for example, given the DateTime @2012-01-01T06:30:00.0Z, this function will return @2012-01-01T00:00:00.0Z.*/
define function "ToDate"(Value DateTime ):
	DateTime(year from Value, month from Value, day from Value, 0, 0, 0, 0, timezoneoffset from Value)

/*CalendarAgeInDaysAt calculates the calendar age (meaning the age without considering time components) in days.*/
define function "CalendarAgeInDaysAt"(BirthDateTime DateTime, AsOf DateTime ):
	days between ToDate(BirthDateTime)and ToDate(AsOf)

/*CalendarAgeInDays calculates the calendar age (meaning the age without considering time components) in days as of today*/
define function "CalendarAgeInDays"(BirthDateTime DateTime ):
	CalendarAgeInDaysAt(BirthDateTime, Today())

/*CalendarAgeInMonthsAt calculates the calendar age (meaning the age without considering time components) in months.*/
define function "CalendarAgeInMonthsAt"(BirthDateTime DateTime, AsOf DateTime ):
	months between ToDate(BirthDateTime)and ToDate(AsOf)

/*CalendarAgeInMonths calculates the calendar age (meaning the age without considering time components) in months as of today.*/
define function "CalendarAgeInMonths"(BirthDateTime DateTime ):
	CalendarAgeInMonthsAt(BirthDateTime, Today())

/*CalendarAgeInYearsAt calculates the calendar age (meaning the age without considering time components) in years.*/
define function "CalendarAgeInYearsAt"(BirthDateTime DateTime, AsOf DateTime ):
	years between ToDate(BirthDateTime)and ToDate(AsOf)

/*CalendarAgeInYears calculates the calendar age (meaning the age without considering time components) in years as of today.*/
define function "CalendarAgeInYears"(BirthDateTime DateTime ):
	CalendarAgeInYearsAt(BirthDateTime, Today())

/*calculates the difference in calendar days between the start and end of the given interval.*/
define function "LengthInDays"(Value Interval<DateTime> ):
	difference in days between start of Value and end of Value

/* returns list of all locations within an encounter, including locations for immediately prior ED visit. */
define function "HospitalizationLocations"(Encounter "Encounter, Performed" ):
	Encounter Visit
		let EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] LastED
				where LastED.relevantPeriod ends 1 hour or less on or before start of Visit.relevantPeriod
				sort by
				end of relevantPeriod
		)
		return if EDVisit is null then Visit.facilityLocations
			else flatten { EDVisit.facilityLocations, Visit.facilityLocations }

/*Returns the arrival time in the ED for the encounter.
*/
define function "EmergencyDepartmentArrivalTime"(Encounter "Encounter, Performed" ):
	start of First(("HospitalizationLocations"(Encounter))HospitalLocation
			where HospitalLocation.code in "Emergency Department Visit"
			sort by start of locationPeriod
	).locationPeriod

/*First Inpatient Intensive Care Unit returns the first intensive care unit for
the given encounter, without considering any immediately prior emergency
department visit.*/
define function "FirstInpatientIntensiveCareUnit"(Encounter "Encounter, Performed" ):
	First((Encounter.facilityLocations)HospitalLocation
			where HospitalLocation.code in "Intensive Care Unit"
				and HospitalLocation.locationPeriod during Encounter.relevantPeriod
			sort by start of locationPeriod
	)

/*Returns admission time for an encounter or for immediately prior emergency department visit.  */
define function "HospitalAdmissionTime"(Encounter "Encounter, Performed" ):
	start of "Hospitalization"(Encounter)

/*Returns earliest arrival time for an encounter including any prior ED visit. */
define function "HospitalArrivalTime"(Encounter "Encounter, Performed" ):
	start of First(("HospitalizationLocations"(Encounter))HospitalLocation
			sort by start of locationPeriod
	).locationPeriod

/*Hospitalization returns the total interval for admission to discharge for the given encounter, or for the admission of any immediately prior emergency department visit to the discharge of the given encounter.*/
define function "Hospitalization"(Encounter "Encounter, Performed" ):
	Encounter Visit
		let EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] LastED
				where LastED.relevantPeriod ends 1 hour or less on or before start of Visit.relevantPeriod
				sort by
				end of relevantPeriod
		)
		return Interval[Coalesce(start of EDVisit.relevantPeriod, start of Visit.relevantPeriod),
		end of Visit.relevantPeriod]

/*Returns the length of stay in days (i.e. the number of days between admission and discharge) for the given encounter, or from the admission of any immediately prior emergency department visit to the discharge of the encounter*/
define function "HospitalizationLengthofStay"(Encounter "Encounter, Performed" ):
	LengthInDays("Hospitalization"(Encounter))

/*Returns the latest departure time for encounter including any prior ED visit. */
define function "HospitalDepartureTime"(Encounter "Encounter, Performed" ):
	end of Last(("HospitalizationLocations"(Encounter))HospitalLocation
			sort by start of locationPeriod
	).locationPeriod

/*Hospital Discharge Time returns the discharge time for an encounter*/
define function "HospitalDischargeTime"(Encounter "Encounter, Performed" ):
	end of Encounter.relevantPeriod

/*Hospitalization with Observation and Outpatient Surgery Service returns the total interval from the start of any immediately prior emergency department visit, outpatient surgery visit or observation visit to the discharge of the given encounter.*/
define function "HospitalizationWithObservationAndOutpatientSurgeryService"(Encounter "Encounter, Performed" ):
	Encounter Visit
		let ObsVisit: Last(["Encounter, Performed": "Observation Services"] LastObs
				where LastObs.relevantPeriod ends 1 hour or less on or before start of Visit.relevantPeriod
				sort by
				end of relevantPeriod
		),
		VisitStart: Coalesce(start of ObsVisit.relevantPeriod, start of Visit.relevantPeriod),
		EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] LastED
				where LastED.relevantPeriod ends 1 hour or less on or before VisitStart
				sort by
				end of relevantPeriod
		),
		VisitStartWithED: Coalesce(start of EDVisit.relevantPeriod, VisitStart),
		OutpatientSurgeryVisit: Last(["Encounter, Performed": "Outpatient Surgery Service"] LastSurgeryOP
				where LastSurgeryOP.relevantPeriod ends 1 hour or less on or before VisitStartWithED
				sort by
				end of relevantPeriod
		)
		return Interval[Coalesce(start of OutpatientSurgeryVisit.relevantPeriod, VisitStartWithED),
		end of Visit.relevantPeriod]

/*Hospitalization with Observation returns the total interval from the start of any immediately prior emergency department visit through the observation visit to the discharge of the given encounter*/
define function "HospitlizationWithObservation"(Encounter "Encounter, Performed" ):
	Encounter Visit
		let ObsVisit: Last(["Encounter, Performed": "Observation Services"] LastObs
				where LastObs.relevantPeriod ends 1 hour or less on or before start of Visit.relevantPeriod
				sort by
				end of relevantPeriod
		),
		VisitStart: Coalesce(start of ObsVisit.relevantPeriod, start of Visit.relevantPeriod),
		EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] LastED
				where LastED.relevantPeriod ends 1 hour or less on or before VisitStart
				sort by
				end of relevantPeriod
		)
		return Interval[Coalesce(start of EDVisit.relevantPeriod, VisitStart),
		end of Visit.relevantPeriod]

/*
Normalize Interval functions for use on QDM Data Types that have both a relevantPeriod and a
relevantDatetime. Submitting systems may send either relevantPeriod or relevantDatetime, but
not both, so logic needs to be flexible in order to allow implementers to send the most
appropriate data they have for the element.
*/

define function "Normalize Interval"(DataElement "Assessment, Performed"):
  if DataElement.relevantPeriod is not null then
	  DataElement.relevantPeriod
	else if DataElement.relevantDatetime is not null then
	  Interval[DataElement.relevantDatetime, DataElement.relevantDatetime]
	else
	  null as Interval<DateTime>

define function "Normalize Interval"(DataElement "Device, Applied"):
  if DataElement.relevantPeriod is not null then
	  DataElement.relevantPeriod
	else if DataElement.relevantDatetime is not null then
	  Interval[DataElement.relevantDatetime, DataElement.relevantDatetime]
	else
	  null as Interval<DateTime>

define function "Normalize Interval"(DataElement "Diagnostic Study, Performed"):
  if DataElement.relevantPeriod is not null then
	  DataElement.relevantPeriod
	else if DataElement.relevantDatetime is not null then
	  Interval[DataElement.relevantDatetime, DataElement.relevantDatetime]
	else
	  null as Interval<DateTime>

define function "Normalize Interval"(DataElement "Intervention, Performed"):
  if DataElement.relevantPeriod is not null then
	  DataElement.relevantPeriod
	else if DataElement.relevantDatetime is not null then
	  Interval[DataElement.relevantDatetime, DataElement.relevantDatetime]
	else
	  null as Interval<DateTime>

define function "Normalize Interval"(DataElement "Laboratory Test, Performed"):
  if DataElement.relevantPeriod is not null then
	  DataElement.relevantPeriod
	else if DataElement.relevantDatetime is not null then
	  Interval[DataElement.relevantDatetime, DataElement.relevantDatetime]
	else
	  null as Interval<DateTime>

define function "Normalize Interval"(DataElement "Medication, Active"):
  if DataElement.relevantPeriod is not null then
	  DataElement.relevantPeriod
	else if DataElement.relevantDatetime is not null then
	  Interval[DataElement.relevantDatetime, DataElement.relevantDatetime]
	else
	  null as Interval<DateTime>

define function "Normalize Interval"(DataElement "Medication, Administered"):
  if DataElement.relevantPeriod is not null then
	  DataElement.relevantPeriod
	else if DataElement.relevantDatetime is not null then
	  Interval[DataElement.relevantDatetime, DataElement.relevantDatetime]
	else
	  null as Interval<DateTime>

define function "Normalize Interval"(DataElement "Medication, Dispensed"):
  if DataElement.relevantPeriod is not null then
	  DataElement.relevantPeriod
	else if DataElement.relevantDatetime is not null then
	  Interval[DataElement.relevantDatetime, DataElement.relevantDatetime]
	else
	  null as Interval<DateTime>

define function "Normalize Interval"(DataElement "Physical Exam, Performed"):
  if DataElement.relevantPeriod is not null then
	  DataElement.relevantPeriod
	else if DataElement.relevantDatetime is not null then
	  Interval[DataElement.relevantDatetime, DataElement.relevantDatetime]
	else
	  null as Interval<DateTime>

define function "Normalize Interval"(DataElement "Procedure, Performed"):
  if DataElement.relevantPeriod is not null then
	  DataElement.relevantPeriod
	else if DataElement.relevantDatetime is not null then
	  Interval[DataElement.relevantDatetime, DataElement.relevantDatetime]
	else
	  null as Interval<DateTime>

define function "Normalize Interval"(DataElement "Substance, Administered"):
  if DataElement.relevantPeriod is not null then
	  DataElement.relevantPeriod
	else if DataElement.relevantDatetime is not null then
	  Interval[DataElement.relevantDatetime, DataElement.relevantDatetime]
	else
	  null as Interval<DateTime>

define TestAssessmentsWithoutNormalize:
  ["Assessment, Performed"] AssessmentPerformed
	  where AssessmentPerformed.relevantPeriod starts during "Measurement Period"
		  or AssessmentPerformed.relevantDatetime in "Measurement Period"

define TestAssessmentsWithNormalize:
  ["Assessment, Performed"] AssessmentPerformed
	  where "Normalize Interval"(AssessmentPerformed) starts during "Measurement Period"

define TestAssessmentsWithNormalizeNoOverload:
	["Assessment, Performed"] AssessmentPerformed
		where "Normalize Interval"(AssessmentPerformed.relevantPeriod, AssessmentPerformed.relevantDatetime) starts during "Measurement Period"
