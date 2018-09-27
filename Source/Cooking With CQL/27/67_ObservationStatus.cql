library ObservationStatus

/*
Measures need to account for care delivered in "observation" status

To do this, the notion of episode-of-care needs to account for the possibility of observation status

But like emergency department visits, EHRs may account for observation status differently

An example of the issue can be found here:
https://oncprojectracking.healthit.gov/support/browse/CQM-1608
*/

/*
Episode-of-care, conceptual scenarios, beginning with Arrival to the hospital, 
and ending with discharge from inpatient care:
*/

1: Inpatient
2: ED -> Inpatient
3: ED -> Observation -> Inpatient
4: Observation -> Inpatient
5: Outpatient -> Observation -> Inpatient
6: Outpatient -> Inpatient

/*
Question: We don't currently account for Outpatient -> Inpatient, what is different
about observation that means we need to account for Outpatient in that case?

Answer: Yes, for example in the case of complications arising from outpatient surgeries
that result in patients placed in observation followed by admission. In addition, the
possibility exists for an admission directly from an outpatient setting.
*/

/*
ED visits are currently handled in two ways:

A) As a different type of Encounter, separate from the Inpatient Encounter:
*/

define "Emergency Department (Approach A)":
  ["Encounter, Performed": "Emergency Department Visit"]

/*
B) As a different location within an Inpatient Encounter
*/

define "Emergency Department (Approach B)":
  ["Encounter, Performed": "Encounter Inpatient"] E
    return E.facilityLocations L where L.code in "Emergency Department Facility"

/*
  Hospitalization returns the total interval for admission to discharge for the
  given encounter, or for the admission of any immediately prior emergency
  department visit to the discharge of the given encounter.
  
  NOTE: Planned change to this function is to use First, rather than singleton from
  to return the closest immediately prior ED visit
*/
define function "Hospitalization"(Encounter "Encounter, Performed" ):
	( singleton from ( ["Encounter, Performed": "Emergency Department Visit"] EDVisit
			where EDVisit.relevantPeriod ends 1 hour or less on or before start of Encounter.relevantPeriod
	) ) X
		return if X is null then Encounter.relevantPeriod else Interval[start of X.relevantPeriod, end of Encounter.relevantPeriod]

/*
Observation has even more variability in the way that hospital systems may provide the data:

O1: All patients placed in observation who were subsequently admitted have the ED 
visit end at the time the Observation starts and the “status” is outpatient such 
that all services are billed as outpatient services. The hospital admission initiates 
with the actual admission and then the outpatient status ends. But the EHR may not 
recognize this outpatient, or observation “status”; rather only recognizing the 
patient’s location during that time.

TJC -> Suggestion is to use Encounter to represent Observation, not a location within an Encounter

ESAC -> We should make sure we continue to support the current approach for ED and use a consistent pattern for representing observation

O2: All patients placed in observation and subsequently admitted have the ED visit 
end at the time Observation begins. The EHR retains an Observation status as a type 
of visit. The Hospitalization starts (admission) when the observation ends and the 
EHR has a record of each “status”.

O3: All patients placed in observation and subsequently admitted have the ED visit 
end at the time Observation begins. However, if admitted, the hospital admission 
time is retroactively set at the time observation begins (i.e., the observation 
is converted to an admission).

O4+: There may be other practices.
*/

/*
As a result, representation within QDM may use different approaches:
*/

/*
O) As a different type of Encounter, separate from the Inpatient and Emergency Department encounters:
*/

define "Observation (Approach O)":
  ["Encounter, Performed": "Observation"]
  
/*
P) As a different location within the Inpatient Encounter:
*/

define "Observation (Approach P)":
  ["Encounter, Performed": "Encounter Inpatient"] E
    return E.facilityLocations L where L.code in "Observation"

/*    
NOTE: Observation beds are often scattered throughout the hospital and are not 
necessarily designated as observation beds
*/

/*
Question: For scenario O1, if the system recognizes, the "location", what would that look like?
Is that Approach P?

Question: For scenario O2, that seems to be Approach O?

Question: For scenario O3, if the admission time is retroactively set, 
that should just make the observation status transparent to logic that uses the
inpatient admission, assuming the observation status is modeled as a location
within the inpatient encounter, correct?
*/

/*
R) Need to be able to represent immediately prior outpatient services
*/

define "Outpatient Encounter":
  ["Encounter, Performed": "Outpatient Service"]

/*
SNOMED models observation using (procedure):

SNOMED codes are available to use for representing Observation within eCQMs.
Value set "Observation Services" -(2.16.840.1.113762.1.4.1111.143)	
Includes 3 Observation SNOMED procedure codes that are of interest:
  Hospital admission, for observation (procedure) – 76464004
  Hospital admission from observation unit (procedure) – 448851000124103 - Seems relevant and it is in the same parent hierarchy in SNOMED as "Hospital admission, for observation (procedure)"
  Admission to observation unit (procedure) – 448951000124107 - Comes from the Parent code of "Admission to establishment (procedure)"
*/

/*
Question: Given that these are "procedure" codes, are we confident that they
would be used to code encounters? In other words, wouldn't we expect these to
come through as Procedure, Performed, rather than Encounter, Performed?
*/

/*
Question: Assuming that we can model observation time in the same way we model
the ER, (i.e. as a location within the Encounter, Performed) then we could change
the Hospitalization function to:
*/

/*
X: Inpatient Encounter with an immediately prior Observation Visit with an immediately prior ED Visit
*/

define "Hospitalization Encounter (Approach X)":
  ["Encounter, Performed": "Inpatient Encounter"] E
    with (
        ["Encounter, Performed": "Observation"] O
          with ["Encounter, Performed": "Emergency Department"] ED
            such that ED.relevantPeriod ends 1 hour or less on or before start of O.relevantPeriod
      ) OED
        such that OED.relevantPeriod ends 1 hour or less on or before start of E.relevantPeriod

/*
Y: Inpatient Encounter with an Observation Location with an immediately prior ED Visit

Feedback: This specific approach probably isn't correct because observation is 
most typically modeled as a "status" rather than a particular location within the hospital
*/

define "Hospitalization Encounter (Approach Y)":
  ["Encounter, Performed": "Inpatient Encounter"] E
    with ["Encounter, Performed": "Emergency Department"] ED
      such that ED.relevantPeriod ends 1 hour or less on or before start of (
        First(E.facilityLocations L where L.code in "Observation" sort by start of locationPeriod).locationPeriod
      )

/*
Given these approaches, we can modify the hospitalization function to:
*/

define function "Hospitalization with Observation"(Encounter "Encounter, Performed" ):
  Encounter E
    let 
      ObsVisit: Last(["Encounter, Performed": "Observation"] O
          where O.relevantPeriod ends 1 hour or less on or before start of E.relevantPeriod
            sort by end of relevantPeriod),
      VisitStart: Coalesce(start of ObsVisit.relevantPeriod, start of E.relevantPeriod),
      EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] ED
          where ED.relevantPeriod ends 1 hour or less on or before VisitStart
            sort by end of relevantPeriod
        )
    return Interval[Coalesce(start of EDVisit.relevantPeriod, VisitStart), end of E.RelevantPeriod]

define function "Hospitalization with Observation and Outpatient"(Encounter "Encounter, Performed" ):
  Encounter E
    let 
      ObsVisit: Last(["Encounter, Performed": "Observation"] O
          where O.relevantPeriod ends 1 hour or less on or before start of E.relevantPeriod
            sort by end of relevantPeriod),
      VisitStart: Coalesce(start of ObsVisit.relevantPeriod, start of E.relevantPeriod),
      EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] ED
          where ED.relevantPeriod ends 1 hour or less on or before VisitStart
            sort by end of relevantPeriod
        ),
      VisitStartWithED: Coalesce(start of EDVisit.relevantPeriod, VisitStart),
      OutpatientVisit: Last(["Encounter, Performed": "Outpatient Service"] O
        where O.relevantPeriod ends 1 hour or less on or before start of VisitStartWithED
          sort by end of relevantPeriod
        )
    return Interval[Coalesce(start of OutpatientVisit.relevantPeriod, VisitStartWithED), end of E.RelevantPeriod]

    



