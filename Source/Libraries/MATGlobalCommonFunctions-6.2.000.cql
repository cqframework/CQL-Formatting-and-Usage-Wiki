library MATGlobalCommonFunctions version '6.2.000'

/*This is an interim version for use prior to AU 2020 release.  We anticipate another release for inclusion with the program measures in Spring 2020*/

/*
Update to 5.6 to get "class" as an attribute of an encounter, performed
*/
using QDM version '5.6'

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Intensive Care Unit": 'urn:oid:2.16.840.1.113762.1.4.1029.206'
valueset "Observation Services": 'urn:oid:2.16.840.1.113762.1.4.1111.143'
valueset "Outpatient Surgery Service": 'urn:oid:2.16.840.1.113762.1.4.1110.38'

/*
Encounter Class Discussion:
http://hl7.org/fhir/R4/v3/ActEncounterCode/vs.html

Code	Display	Definition
AMB	ambulatory	A comprehensive term for health care provided in a healthcare facility (e.g. a practitioneraTMs office, clinic setting, or hospital) on a nonresident basis. The term ambulatory usually implies that the patient has come to the location and is not assigned to a bed. Sometimes referred to as an outpatient encounter.
EMER	emergency	A patient encounter that takes place at a dedicated healthcare service delivery location where the patient receives immediate evaluation and treatment, provided until the patient can be discharged or responsibility for the patient's care is transferred elsewhere (for example, the patient could be admitted as an inpatient or transferred to another facility.)
FLD	field	A patient encounter that takes place both outside a dedicated service delivery location and outside a patient's residence. Example locations might include an accident site and at a supermarket.
HH	home health	Healthcare encounter that takes place in the residence of the patient or a designee
IMP	inpatient encounter	A patient encounter where a patient is admitted by a hospital or equivalent facility, assigned to a location where patients generally stay at least overnight and provided with room, board, and continuous nursing service.
ACUTE	inpatient acute	An acute inpatient encounter.
NONAC	inpatient non-acute	Any category of inpatient encounter except 'acute'
OBSENC	observation encounter	An encounter where the patient usually will start in different encounter, such as one in the emergency department (EMER) but then transition to this type of encounter because they require a significant period of treatment and monitoring to determine whether or not their condition warrants an inpatient admission or discharge. In the majority of cases the decision about admission or discharge will occur within a time period determined by local, regional or national regulation, often between 24 and 48 hours.
PRENC	pre-admission	A patient encounter where patient is scheduled or planned to receive service delivery in the future, and the patient is given a pre-admission account number. When the patient comes back for subsequent service, the pre-admission encounter is selected and is encapsulated into the service registration, and a new account number is generated. Usage Note: This is intended to be used in advance of encounter types such as ambulatory, inpatient encounter, virtual, etc.
SS	short stay	An encounter where the patient is admitted to a health care facility for a predetermined length of time, usually less than 24 hours.
VR	virtual	A patient encounter where the patient and the practitioner(s) are not in the same physical location. Examples include telephone conference, email exchange, robotic surgery, and televideo conference.
*/

/*
Propose the definition of value sets to support these "class" concepts:
*/
valueset "Ambulatory Encounter Class": 'http://example.org/fhir/ValueSet/ambulatory-encounter-class'
valueset "Emergency Encounter Class": 'http://example.org/fhir/ValueSet/emergency-encounter-class'
valueset "Field Encounter Class": 'http://example.org/fhir/ValueSet/field-encounter-class'
valueset "Home Health Encounter Class": 'http://example.org/fhir/ValueSet/home-health-encounter-class'
valueset "Inpatient Encounter Class": 'http://example.org/fhir/ValueSet/inpatient-encounter-class'
valueset "Acute Encounter Class": 'http://example.org/fhir/ValueSet/acute-encounter-class'
valueset "Nonacute Encounter Class": 'http://example.org/fhir/ValueSet/nonacute-encounter-class'
valueset "Observation Encounter Class": 'http://example.org/fhir/ValueSet/observation-encounter-class'
valueset "Preadmission Encounter Class": 'http://example.org/fhir/ValueSet/preadmission-encounter-class'
valueset "Short Stay Encounter Class": 'http://example.org/fhir/ValueSet/short-stay-encounter-class'
valueset "Virtual Encounter Class": 'http://example.org/fhir/ValueSet/virtual-encounter-class'
// DISCUSSION: Use ambulatory
//valueset "Outpatient Encounter Class": 'http://example.org/fhir/ValueSet/outpatient-encounter-class'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "ED Encounter":
  ["Encounter, Performed": "Emergency Department Visit"]

/*
Then use the class concepts, rather than type codes, to indicate encounter class:
*/
define "ED Encounter (1)":
  ["Encounter, Performed": class in "Emergency Encounter Class"]

define "Inpatient Encounter":
  ["Encounter, Performed": "Encounter Inpatient"] EncounterInpatient
    where "LengthInDays"(EncounterInpatient.relevantPeriod)<= 120
      and EncounterInpatient.relevantPeriod ends during day of "Measurement Period"

/*
Similarly for inpatient encounter:
*/
define "Inpatient Encounter (1)":
  ["Encounter, Performed": class in "Inpatient Encounter Class"] EncounterInpatient
    where "LengthInDays"(EncounterInpatient.relevantPeriod)<= 120
      and EncounterInpatient.relevantPeriod ends during day of "Measurement Period"

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
define function "HospitalizationWithObservation"(Encounter "Encounter, Performed" ):
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

/*ToDate takes a given DateTime value and returns a DateTime with the time components "zeroed", and the timezone of the input value, for example, given the DateTime @2012-01-01T06:30:00.0Z, this function will return @2012-01-01T00:00:00.0Z.*/
define function "ToDate"(Value DateTime ):
  DateTime(year from Value, month from Value, day from Value, 0, 0, 0, 0, timezoneoffset from Value)

/*Hospitalization with Observation Length of Stay returns the length in days from the start of any immediately prior emergency department visit through the observation visit to the discharge of the given encounter*/
define function "HospitalizationWithObservationLengthofStay"(Encounter "Encounter, Performed" ):
  "LengthInDays"("HospitalizationWithObservation"(Encounter))

/*First Inpatient Intensive Care Unit returns the first intensive care unit for the given encounter, without considering any immediately prior emergency department visit.*/
define function "FirstInpatientIntensiveCareUnit"(Encounter "Encounter, Performed" ):
  First((Encounter.facilityLocations)HospitalLocation
      where HospitalLocation.code in "Intensive Care Unit"
        and HospitalLocation.locationPeriod during Encounter.relevantPeriod
      sort by start of locationPeriod
  )

/*Given a datetime and a period, returns the period (if a period is provided) or the interval beginning and ending on the datetime (if a datetime is provided)*/
define function "NormalizeInterval"(pointInTime DateTime, period Interval<DateTime> ):
  if pointInTime is not null then Interval[pointInTime, pointInTime]
    else if period is not null then period
    else null as Interval<DateTime>

/*Given an interval, return true if the interval has a starting boundary specified (i.e. the start of the interval is not null and not the minimum DateTime value)*/
define function "HasStart"(period Interval<DateTime> ):
  not ( start of period is null
      or start of period = minimum DateTime
  )

/*Given an interval, return true if the interval has an ending boundary specified (i.e. the end of the interval is not null and not the maximum DateTime value)*/
define function "HasEnd"(period Interval<DateTime> ):
  not (
    end of period is null
      or
      end of period = maximum DateTime
  )

/*Given an interval, return the ending point if the interval has an ending boundary specified, otherwise, return the starting point*/
define function "Latest"(period Interval<DateTime> ):
  if ( HasEnd(period)) then
  end of period
    else start of period

/*Given an interval, return the starting point if the interval has a starting boundary specified, otherwise, return the ending point*/
define function "Earliest"(period Interval<DateTime> ):
  if ( HasStart(period)) then start of period
    else
  end of period

/*Given a pointInTime or period, if the pointInTime is specified, returns the pointInTime, returns the ending point of the period if the period has an ending boundary specified, otherwise returns the starting point of the interval*/
define function "LatestOf"(pointInTime DateTime, period Interval<DateTime> ):
  Latest(NormalizeInterval(pointInTime, period))

/*Given a pointInTime or period, if the pointInTime is specified, returns the pointInTime, returns the starting point of the period if the period has a starting boundary specified, otherwise returns the ending point of the period*/
define function "EarliestOf"(pointInTime DateTime, period Interval<DateTime> ):
  Earliest(NormalizeInterval(pointInTime, period))
