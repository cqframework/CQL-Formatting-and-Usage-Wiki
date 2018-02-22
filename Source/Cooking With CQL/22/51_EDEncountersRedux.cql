library EDEncountersRedux

using QDM version '5.3'

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292' 
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307' 

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
  How do we identify the Emergency Department visit associated with an Inpatient encounter?
    Current approach is typically the ED Visit that ends one hour or 
    less on or before the start of the inpatient encounter.
  This assumes there is only one ED visit that meets this criterion. What do
  we do if there are multiple?
    Different measures are currently using different approaches, which will
    result in different behavior/answers.
*/

/*
  The running example:
  
    Patient has an ED visit on 2/21 from 8:00AM to 10:00AM. The same patient
    has another ED visit on 2/21 from 10:15AM to 10:56AM, and an inpatient
    encounter on 2/21 from 11:00AM to 2/22 at 5:00PM
*/

/*
  Hospitalization returns the total interval for admission to discharge for the
  given encounter, or for the admission of any immediately prior emergency 
  department visit to the discharge of the given encounter.
*/
define function "Hospitalization"(Encounter "Encounter, Performed"):
	( singleton from ( ["Encounter, Performed": "Emergency Department Visit"] EDVisit
			where EDVisit.relevantPeriod ends 1 hour or less on or before start of Encounter.relevantPeriod
	) ) X
		return if X is null then Encounter.relevantPeriod else Interval[start of X.relevantPeriod, end of Encounter.relevantPeriod]

/*
  Related ED Visit uses the Last function to find the Most Recent
*/
define function "Related ED Visit"(Encounter "Encounter, Performed"):
  Last(
    ["Encounter, Performed":"Emergency Department Visit"] EDVisit
      where EDVisit.relevantPeriod ends 1 hour or less on or before start of Encounter.relevantPeriod
      sort by start of relevantPeriod
  )

/*
  Within any given measure, the pattern just uses a with:
*/
define "Qualifying Encounter":
  "Inpatient Encounter" Encounter
    with ["Encounter, Performed": "Emergency Department Visit"] EDVisit
      such that EDVisit.relevantPeriod ends 1 hour or less on or before start of Encounter.relevantPeriod

/* Supporting definitions */
define "Inpatient Encounter":
	["Encounter, Performed": "Encounter Inpatient"] EncounterInpatient
		where "LengthInDays"(EncounterInpatient.relevantPeriod)<= 120
			and EncounterInpatient.relevantPeriod ends during "Measurement Period"

/*
define "Emergency Department Encounters":
  {
    "Encounter, Performed" { id: 'ED-0001', relevantPeriod: Interval[@2018-02-21T08:00:00.0, @2018-02-21T10:00:00.0] },
    "Encounter, Performed" { id: 'ED-0002', relevantPeriod: Interval[@2018-02-21T10:15:00.0, @2018-02-21T10:56:00.0] }
  }
  
define "Inpatient Encounters":
  {
    "Encounter, Performed" { id: 'IP-0001', relevantPeriod: Interval[@2018-02-21T11:00:00.0, @2018-02-22T17:00:00.0] }
  }
*/

