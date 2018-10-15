library MATGlobalCommonFunctions version '3.0.000'

using QDM version '5.4'

codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'
codesystem "SNOMEDCT": 'urn:oid:2.16.840.1.113883.6.96'

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292' 
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307' 
valueset "Intensive Care Unit": 'urn:oid:2.16.840.1.113762.1.4.1110.23' 

// TODO: Review these value sets, they are included to support the new Hospitalization with Observation and Hospitalization with Outpatient functions
// Further discussion can be found [here](https://github.com/esacinc/CQL-Formatting-and-Usage-Wiki/blob/master/Source/Cooking%20With%20CQL/27/67_ObservationStatus.cql#L188)
valueset "Observation Services": 'urn:oid:2.16.840.1.113762.1.4.1111.143'
valueset "Outpatient Services": 'TBD' // TODO: Need to define this value set

code "Birthdate": '21112-8' from "LOINC" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT" display 'Dead'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Encounter":
	["Encounter, Performed": "Emergency Department Visit"]

define "Inpatient Encounter":
	["Encounter, Performed": "Encounter Inpatient"] EncounterInpatient
		where "LengthInDays"(EncounterInpatient.relevantPeriod)<= 120
			and EncounterInpatient.relevantPeriod ends during "Measurement Period"

/*Hospitalization returns the total interval for admission to discharge for the given encounter, or for the admission of any immediately prior emergency department visit to the discharge of the given encounter.*/
define function "Hospitalization"(Encounter "Encounter, Performed" ):
	Encounter E
		let 
			EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] ED
				where ED.relevantPeriod ends 1 hour or less on or before start of E.relevantPeriod
				sort by end of relevantPeriod
			)
	return Interval[Coalesce(start of EDVisit.relevantPeriod, start of E.relevantPeriod), end of E.relevantPeriod]

/*calculates the difference in calendar days between the start and end of the given interval.*/
define function "LengthInDays"(Value Interval<DateTime> ):
	difference in days between start of Value and end of Value

/* returns list of all locations within an encounter, including locations for immediately prior ED visit.  If data contains many encounters within 1 hour before the start of encounter error will occur indicating the hospitalization cannot be determined*/
define function "Hospitalization Locations"(Encounter "Encounter, Performed" ):
	Encounter E
		let 
			EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] ED
				where ED.relevantPeriod ends 1 hour or less on or before start of E.relevantPeriod
				sort by end of relevantPeriod
			)
		return if EDVisit is null then E.facilityLocations else flatten { EDVisit.facilityLocations, E.facilityLocations }

/*Returns the length of stay in days (i.e. the number of days between admission and discharge) for the given encounter, or from the admission of any immediately prior emergency department visit to the discharge of the encounter*/
define function "Hospitalization Length of Stay"(Encounter "Encounter, Performed" ):
	LengthInDays("Hospitalization"(Encounter))

/*Returns admission time for an encounter or for immediately prior emergency department visit.  If the data contain many encounters within 1 hour before the start of the encounter an error indicating hospitalization cannot be determined
*/
define function "Hospital Admission Time"(Encounter "Encounter, Performed" ):
	start of "Hospitalization"(Encounter)

/*Hospital Discharge Time returns the discharge time for an encounter*/
define function "Hospital Discharge Time"(Encounter "Encounter, Performed" ):
	end of Encounter.relevantPeriod

/*Returns earliest arrival time for an encounter including any prior ED visit. If the data contain multiple encounters within 1 hour before the start of the encounter, an error will occur indicating it cannot be unambiguously determined
*/
define function "Hospital Arrival Time"(Encounter "Encounter, Performed" ):
	start of First(("Hospitalization Locations"(Encounter)) HospitalLocation
			sort by start of locationPeriod
	).locationPeriod

/*Returns the latest departure time for encounter including any prior ED visit. If the data contain multiple encounters within 1 hour before the start of the encounter, an error will occur indicating it cannot be unambiguously determined*/
define function "Hospital Departure Time"(Encounter "Encounter, Performed" ):
	end of Last(("Hospitalization Locations"(Encounter)) HospitalLocation
			sort by start of locationPeriod
	).locationPeriod

/*Returns the arrival time in the ED for the encounter.  If the data contain multiple encounters within 1 hour before the start of the encounter or multiple ED locations an error will occur indicating it cannot be determined
*/
define function "Emergency Department Arrival Time"(Encounter "Encounter, Performed" ):
	start of First(( "Hospitalization Locations"(Encounter)) HospitalLocation
				where HospitalLocation.code in "Emergency Department Visit"
				sort by start of locationPeriod
	).locationPeriod

/*First Inpatient Intensive Care Unit returns the first intensive care unit for
the given encounter, without considering any immediately prior emergency
department visit.*/
define function "First Inpatient Intensive Care Unit"(Encounter "Encounter, Performed" ):
	First((Encounter.facilityLocations) HospitalLocation
			where HospitalLocation.code in "Intensive Care Unit"
				and HospitalLocation.locationPeriod during Encounter.relevantPeriod
			sort by start of locationPeriod
	)
	
define function "Hospitalization with Observation"(Encounter "Encounter, Performed" ):
	Encounter E
		let 
			ObsVisit: Last(["Encounter, Performed": "Observation Services"] O
				where O.relevantPeriod ends 1 hour or less on or before start of E.relevantPeriod
				sort by end of relevantPeriod
			),
			VisitStart: Coalesce(start of ObsVisit.relevantPeriod, start of E.relevantPeriod),
			EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] ED
				where ED.relevantPeriod ends 1 hour or less on or before VisitStart
				sort by end of relevantPeriod
			)
		return Interval[Coalesce(start of EDVisit.relevantPeriod, VisitStart), end of E.relevantPeriod]
	
define function "Hospitalization with Observation and Outpatient"(Encounter "Encounter, Performed" ):
	Encounter E
		let 
			ObsVisit: Last(["Encounter, Performed": "Observation Services"] O
				where O.relevantPeriod ends 1 hour or less on or before start of E.relevantPeriod
				sort by end of relevantPeriod
			),
			VisitStart: Coalesce(start of ObsVisit.relevantPeriod, start of E.relevantPeriod),
			EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] ED
				where ED.relevantPeriod ends 1 hour or less on or before VisitStart
				sort by end of relevantPeriod
			),
			VisitStartWithED: Coalesce(start of EDVisit.relevantPeriod, VisitStart),
			OutpatientVisit: Last(["Encounter, Performed": "Outpatient Services"] O
				where O.relevantPeriod ends 1 hour or less on or before VisitStartWithED
				sort by end of relevantPeriod
			)
		return Interval[Coalesce(start of OutpatientVisit.relevantPeriod, VisitStartWithED), end of E.relevantPeriod]
	
	
