/*
* [CQLIT-162](https://oncprojectracking.healthit.gov/support/browse/CQLIT-162) - Intervals with null endpoints
*/

/*
CMS 128 'Has Initial Major Depression Diagnosis' uses an Interval with both low 
and high endpoints closed.  In CQL this is expressed as
*/

MajorDepression.prevalencePeriod starts 60 days or less before or on day of AntidepressantDispensed.authorDatetime

/*
This is translated in the ELM to:
*/

start of MajorDepression.prevalencePeriod 
  in Interval[AntidepressantDispensed.authorDatetime - 60 days, AntidepressantDispensed.authorDatetime]
  
/*
If authorDatetime is not specified this results in Interval[null, null]
which according to the CQL specification is effectively the interval from the beginning of time to the end of time:
https://cql.hl7.org/04-logicalspecification.html#interval

If the low bound of the interval is null and closed, the interval is interpreted 
to start at the minimum value of the point type, and computations involving the 
low boundary will be performed with that value.

If the high bound of the interval is null and closed, the interval is interpreted 
to end at the maximum value of the point type, and computations involving the 
high boundary will be performed with that interpretation.
*/

/*
This mechanism works well if one or the other boundary is null, but if both are null,
this actually results in the opposite of the measure intent, which is to only include
depression events with antidepressant dispensed within the 60 days prior.
*/

/*
Guidance in this case and others like it is to consider an interval with both endpoints null,
regardless of whether the boundaries are closed or open, as a null interval (i.e. the
interval collapses to a null)
*/

/*
A comment on the specification will be submitted to add this interpretation of an interval
with both endpoints null.
*/
