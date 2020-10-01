library HospitalStay48HoursOrMore

using QDM version '5.5'

/*
Problem Statement:
Given an episode of care based measure with the IPP / Denominator defined as:

    All inpatient encounters discharged during the measurement period for
    patients 18 years or older at the start of the encounter.

    An encounter is considered an inpatient admission, including time spent in
    the emergency department or in observation status when the patients are
    ultimately admitted to inpatient status.

We would like assistance with expressing in CQL that the qualifying encounter
length of stay must be at least 48 hours.

This could be applied as either:
    1. A denominator exclusion, where we would exclude encounters (including
    time spent in the emergency dept or in observation prior to admission) with
    length of stay < 48 hours
Or:
    2. A condition of the qualifying encounter where the length of stay
    (including time spent in the emergency dept or in observation prior to
    admission) must be > = 48 hours.

*/

/*
Attempted solution:

Change "Qualifying Encounter" from:
*/

define "Qualifying Encounter (current)":
  ["Encounter, Performed": "Encounter Inpatient"] InpatientEncounter
    with ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      such that InpatientEncounter.relevantPeriod ends during "Measurement Period"
        and Global."CalendarAgeInYearsAt" (
          BirthDate.birthDatetime,
          start of Global."HospitalizationWithObservation" ( InpatientEncounter )
        ) >= 18

define "Qualifying Encounter (updated)":
  ["Encounter, Performed": "Encounter Inpatient"] InpatientEncounter
    with ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      such that InpatientEncounter.relevantPeriod ends during "Measurement Period"
        and Global."CalendarAgeInYearsAt" (
          BirthDate.birthDatetime,
          start of Global."HospitalizationWithObservation" ( InpatientEncounter )
        ) >= 18
        and Global." HospitalizationWithObservationLengthofStay" ( InpatientEncounter ) >= 2

/*
Testing with this option doesn't meet the measure intent because the 'day' interval
doesn't always equate to 48 hours (because the LengthOfStay function is using 'difference in days')
*/

/*
Other approaches tried:
Using Qualifying Encounter relevantPeriod
*/

define "Excluded Qualifying Encounters with relevantPeriod less than 48 hours":
  "Qualifying Encounters" QualifyingEncounter
    where duration in hours of QualifyingEncounter.relevantPeriod < 48

/*
Using lengthOfStay attribute
*/

define "Excluded Qualifying Encounters with lengthOfStay less than 48 hours":
  "Qualifying Encounters" QualifyingEncounter
    where duration in hours of QualifyingEncounter.lengthOfStay < 48 hours

/*
As noted by submitter, neither of these approaches work because they don't consider
the ed and observation time.
*/

/*
Question:
Can we define a function that works similar to the HospitalizationWithObservationLengthOfStay",
but instead determines LOS based on hours instead of days be a possibility?
*/

/*
Answer:
Let's first look at the definition of HospitalizationWithObservationLengthOfStay:
*/

/*
Hospitalization with Observation Length of Stay returns the length in days
from the start of any immediately prior emergency department visit through
the observation visit to the discharge of the given encounter
*/
define function "HospitalizationWithObservationLengthofStay"(Encounter "Encounter, Performed" ):
  "LengthInDays"("HospitalizationWithObservation"(Encounter))

/*
And the "LengthInDays" and "HospitalizationWithObservation" functions that it uses:
*/

/*
Calculates the difference in calendar days between the start
and end of the given interval.
*/
define function "LengthInDays"(Value Interval<DateTime> ):
  difference in days between start of Value and end of Value

/*
Hospitalization with Observation returns the total interval from the start of
any immediately prior emergency department visit through the observation visit
to the discharge of the given encounter
*/
define function "HospitalizationWithObservation"(Encounter "Encounter, Performed" ):
  Encounter Visit
  	let ObsVisit: Last(["Encounter, Performed": "Observation Services"] LastObs
			where LastObs.relevantPeriod ends 1 hour or less on or before start of Visit.relevantPeriod
			sort by	end of relevantPeriod
  	),
  	VisitStart: Coalesce(start of ObsVisit.relevantPeriod, start of Visit.relevantPeriod),
  	EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] LastED
			where LastED.relevantPeriod ends 1 hour or less on or before VisitStart
			sort by	end of relevantPeriod
  	)
  	return Interval[
      Coalesce(start of EDVisit.relevantPeriod, VisitStart),
      end of Visit.relevantPeriod
    ]

/*
So this function is returning the Interval from the start, including ED and/or
observation time, to the end of the Qualifying Encounter, which we want to make
sure is 48 hours or more.

So we don't have to use the LengthOfStay function, we could use just the
HospitalizationWithObservation function directly:
*/

define "Qualifying Encounter (proposed)":
  ["Encounter, Performed": "Encounter Inpatient"] InpatientEncounter
    with ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      such that Global."CalendarAgeInYearsAt" (
          BirthDate.birthDatetime,
          start of Global."HospitalizationWithObservation" ( InpatientEncounter )
        ) >= 18
    where InpatientEncounter.relevantPeriod ends during "Measurement Period"
      and duration in hours of Global."HospitalizationWithObservation" ( InpatientEncounter ) >= 48

define "Qualifying Encounter (refined)":
  ["Encounter, Performed": "Encounter Inpatient"] InpatientEncounter
    let hospitalizationPeriod: Global."HospitalizationWithObservation" ( InpatientEncounter )
    with ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      such that Global."CalendarAgeInYearsAt" (
          BirthDate.birthDatetime,
          start of hospitalizationPeriod
        ) >= 18
    where hospitalizationPeriod ends during "Measurement Period"
      and duration in hours of hospitalizationPeriod >= 48
