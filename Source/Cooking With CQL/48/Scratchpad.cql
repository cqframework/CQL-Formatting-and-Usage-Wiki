library Scratchpad

using QDM version '5.5'

/* Normalizes a datetime and an interval to an interval. If pointInTime is specified, returns an interval beginning and ending at pointInTime, otherwise, returns the period */
define function "NormalizeInterval"(pointInTime DateTime, period Interval<DateTime>):
  if pointInTime is not null then Interval[pointInTime, pointInTime]
    else if period is not null then period
    else null as Interval<DateTime>

/*Given an interval, return true if the interval has an ending boundary specified (i.e. the end of the interval is not null and not the maximum DateTime value)*/
define function HasEnd(period Interval<DateTime>):
  not (end of period is null or end of period = maximum DateTime)

/* Given an interval, return true if the interval has a starting boundary specified (i.e. the start of the interval is not null and not the minimumDateTime value)*/
define function HasStart(period Interval<DateTime>):
  not (start of period is null or start of period = minimum DateTime)

/* Given an interval, return the ending point if the interval has an ending boundary specified, otherwise, return the starting point */
define function Latest(period Interval<DateTime>):
  if (HasEnd(period)) then
    end of period
  else
    start of period

/* Given an interval, return the starting point if the interval has a starting boundary specified, otherwise, return the ending point */
define function Earliest(period Interval<DateTime>):
  if (HasStart(period)) then
    start of period
  else
    end of period

//Latest(NormalizeInterval(Procedure.relevantDateTime, Procedure.relevantPeriod))

/* Given a pointInTime or period, if the pointInTime is specified, returns the pointInTime, returns the ending point of the period if the period has an ending boundary specified, otherwise returns the starting point of the period */
define function LatestOf(pointInTime DateTime, period Interval<DateTime>):
  Latest(NormalizeInterval(pointInTime, period))

/* Given a pointInTime or period, if the pointInTime is specified, returns the pointInTime, returns the starting point of the period if the period has a starting boundary specified, otherwise returns the ending point of the period */
define function EarliestOf(pointInTime DateTime, period Interval<DateTime>):
  Earliest(NormalizeInterval(pointInTime, period))
