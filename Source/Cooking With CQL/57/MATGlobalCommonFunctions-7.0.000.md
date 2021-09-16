# MATGlobalCommonFunctions version 7.0.000
The MATGlobalCommonFunctions library provides common functions and expressions used throughout electronic
Clinical Quality Measures (eCQM) published for use in Centers for Medicare and Medicaid (CMS) quality programs.

## Using QDM version '5.6'

## Terminology
```
valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Intensive Care Unit": 'urn:oid:2.16.840.1.113762.1.4.1029.206'
valueset "Observation Services": 'urn:oid:2.16.840.1.113762.1.4.1111.143'
valueset "Outpatient Surgery Service": 'urn:oid:2.16.840.1.113762.1.4.1110.38'
```

## Parameters
```
parameter "Measurement Period" Interval<DateTime>
```

## Context
```
context Patient
```

## Function `ToDateInterval(Interval<DateTime>): Interval<Date>`
Returns an interval of date values extracted from the input interval of date-time values

This function returns an interval constructed using the `date from` extractor on the start
and end values of the input date-time interval. Note that using a precision specifier as part of a
timing phrase is preferred to communicate intent to perform day-level comparison, as well as for
general readability.

```
define function "ToDateInterval"(period Interval<DateTime>):
  Interval[date from start of period, date from end of period]
```

### Examples:
For example, the function could be used to get day-level comparison as in the following:

```
define Example1:
  ["Physical Exam, Performed": "Observation Services"] RetinalExam
    where "ToDateInterval"("NormalizeInterval"(RetinalExam.relevantDatetime, RetinalExam.relevantPeriod))
      during "ToDateInterval"(Interval[start of "Measurement Period" - 1 year, end of "Measurement Period"])
```

However, note that the function must sill be used on both sides of the `during` operator, whereas
using the `day of` precision specifier both communicates the intent to perform the comparisons to
the day, and results in more readable criteria:

```
define Example2:
  ["Physical Exam, Performed": "Observation Services"] RetinalExam
    where "NormalizeInterval"(RetinalExam.relevantDatetime, RetinalExam.relevantPeriod)
      during day of Interval[start of "Measurement Period" - 1 year, end of "Measurement Period"]
```


## Expression `ED Encounter`
```
define "ED Encounter":
  ["Encounter, Performed": "Emergency Department Visit"]
```

## Expression `Inpatient Encounter`
```
define "Inpatient Encounter":
  ["Encounter, Performed": "Encounter Inpatient"] EncounterInpatient
    where "LengthInDays"(EncounterInpatient.relevantPeriod)<= 120
      and EncounterInpatient.relevantPeriod ends during day of "Measurement Period"
```

## Function `LengthInDays(Interval<DateTime>): Integer`
Calculates the difference in calendar days between the start and end of the given interval.

```
define function "LengthInDays"(Value Interval<DateTime> ):
  difference in days between start of Value and end of Value
```

## Function `HospitalizationLocations("Encounter, Performed"): List<Location>`
Returns list of all locations within an encounter, including locations for immediately prior ED visit.

```
define function "HospitalizationLocations"(Encounter "Encounter, Performed" ):
  Encounter Visit
  	let EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] LastED
  			where LastED.relevantPeriod ends 1 hour or less on or before start of Visit.relevantPeriod
  			sort by
  			end of relevantPeriod
  	)
  	return if EDVisit is null then Visit.facilityLocations
  		else flatten { EDVisit.facilityLocations, Visit.facilityLocations }
```

## Function `EmergencyDepartmentArrivalTime("Encounter, Performed"): DateTime`
Returns the arrival time in the ED for the encounter.

```
define function "EmergencyDepartmentArrivalTime"(Encounter "Encounter, Performed" ):
  start of First(("HospitalizationLocations"(Encounter))HospitalLocation
  		where HospitalLocation.code in "Emergency Department Visit"
  		sort by start of locationPeriod
  ).locationPeriod
```

## Function `HospitalAdmissionTime("Encounter, Performed"): DateTime`
Returns admission time for an encounter or for immediately prior emergency department visit.

```
define function "HospitalAdmissionTime"(Encounter "Encounter, Performed" ):
  start of "Hospitalization"(Encounter)
```

## Function `HospitalArrivalTime("Encounter, Performed"): DateTime`
Returns earliest arrival time for an encounter including any prior ED visit.

```
define function "HospitalArrivalTime"(Encounter "Encounter, Performed" ):
  start of First(("HospitalizationLocations"(Encounter))HospitalLocation
  		sort by start of locationPeriod
  ).locationPeriod
```

## Function `Hospitalization("Encounter, Performed"): Interval<DateTime>`
Hospitalization returns the total interval for admission to discharge for the given encounter, or for the admission of any immediately prior emergency department visit to the discharge of the given encounter.

```
define function "Hospitalization"(Encounter "Encounter, Performed" ):
  Encounter Visit
  	let EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] LastED
  			where LastED.relevantPeriod ends 1 hour or less on or before start of Visit.relevantPeriod
  			sort by
  			end of relevantPeriod
  	)
  	return Interval[Coalesce(start of EDVisit.relevantPeriod, start of Visit.relevantPeriod),
  	end of Visit.relevantPeriod]
```

## Function `HospitalizationLengthOfStay("Encounter, Performed"): Integer`
Returns the length of stay in days (i.e. the number of days between admission and discharge) for the given encounter, or from the
admission of any immediately prior emergency department visit to the discharge of the encounter.

```
define function "HospitalizationLengthofStay"(Encounter "Encounter, Performed" ):
  LengthInDays("Hospitalization"(Encounter))
```

## Function `HospitalDerpartureTime("Encounter, Performed"): DateTime`
Returns the latest departure time for encounter including any prior ED visit.

```
define function "HospitalDepartureTime"(Encounter "Encounter, Performed" ):
  end of Last(("HospitalizationLocations"(Encounter))HospitalLocation
  		sort by start of locationPeriod
  ).locationPeriod
```

## Function `HospitalDischargeTime("Encounter, Performed"): DateTime`
Hospital Discharge Time returns the discharge time for an encounter.

```
define function "HospitalDischargeTime"(Encounter "Encounter, Performed" ):
  end of Encounter.relevantPeriod
```

## Function `HospitalizationWithObservationAndOutpatientSurgeryService("Encounter, Performed"): Interval<DateTime>`
Hospitalization with Observation and Outpatient Surgery Service returns the total interval from the start of any immediately prior emergency department visit, outpatient surgery visit or observation visit to the discharge of the given encounter.

```
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
```

## Function `HospitalizationWithObservation("Encounter, Performed"): Interval<DateTime>`
Hospitalization with Observation returns the total interval from the start of any immediately prior emergency department visit through the observation visit to the discharge of the given encounter.

```
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
```

## Function `HospitalizationWithObservationLengthofStay("Encounter, Performed"): Interval<DateTime>`
Hospitalization with Observation Length of Stay returns the length in days from the start of any immediately prior emergency
department visit through the observation visit to the discharge of the given encounter.

```
define function "HospitalizationWithObservationLengthofStay"(Encounter "Encounter, Performed" ):
  "LengthInDays"("HospitalizationWithObservation"(Encounter))
```

## Function `FirstInpatientIntensiveCareUnit("Encounter, Performed"): Location`
First Inpatient Intensive Care Unit returns the first intensive care unit for the given encounter, without considering any immediately prior emergency department visit.

```
define function "FirstInpatientIntensiveCareUnit"(Encounter "Encounter, Performed" ):
  First((Encounter.facilityLocations)HospitalLocation
      where HospitalLocation.code in "Intensive Care Unit"
        and HospitalLocation.locationPeriod during Encounter.relevantPeriod
      sort by start of locationPeriod
  )
```

## Function `NormalizeInterval(DateTime, Interval<DateTime>): Interval<DateTime>`
Given a datetime and a period, returns the period (if a period is provided) or the interval beginning and ending on the datetime (if a datetime is provided).

```
define function "NormalizeInterval"(pointInTime DateTime, period Interval<DateTime> ):
  if pointInTime is not null then Interval[pointInTime, pointInTime]
    else if period is not null then period
    else null as Interval<DateTime>
```

## Function `HasStart(Interval<DateTime>): Boolean`
Given an interval, return true if the interval has a starting boundary specified (i.e. the start of the interval is not null and not the minimum DateTime value).

```
define function "HasStart"(period Interval<DateTime> ):
  not ( start of period is null
      or start of period = minimum DateTime
  )
```

## Function `HasEnd(Interval<DateTime>): Boolean`
Given an interval, return true if the interval has an ending boundary specified (i.e. the end of the interval is not null and not the maximum DateTime value).

```
define function "HasEnd"(period Interval<DateTime> ):
  not (
    end of period is null
      or
      end of period = maximum DateTime
  )
```

## Function `Latest(Interval<DateTime>): DateTime`
Given an interval, return the ending point if the interval has an ending boundary specified, otherwise, return the starting point.

```
define function "Latest"(period Interval<DateTime> ):
  if ( HasEnd(period)) then
  end of period
    else start of period
```

## Function `Earliest(Interval<DateTime>): DateTime`
Given an interval, return the starting point if the interval has a starting boundary specified, otherwise, return the ending point.

```
define function "Earliest"(period Interval<DateTime> ):
  if ( HasStart(period)) then start of period
    else
  end of period
```

## Function `LatestOf(DateTime, Interval<DateTime>): DateTime`
Given a pointInTime or period, if the pointInTime is specified, returns the pointInTime, returns the ending point of the period if the period has an ending boundary specified, otherwise returns the starting point of the interval.

```
define function "LatestOf"(pointInTime DateTime, period Interval<DateTime> ):
  Latest(NormalizeInterval(pointInTime, period))
```
## Function `EarliestOf(DateTime, Interval<DateTime>): DateTime`
Given a pointInTime or period, if the pointInTime is specified, returns the pointInTime, returns the starting point of the period if the period has a starting boundary specified, otherwise returns the ending point of the period.

```
define function "EarliestOf"(pointInTime DateTime, period Interval<DateTime> ):
  Earliest(NormalizeInterval(pointInTime, period))
```
