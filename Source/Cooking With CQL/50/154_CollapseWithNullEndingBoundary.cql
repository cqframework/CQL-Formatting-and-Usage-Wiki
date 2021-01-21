library CollapseWithNullEndingBoundary

/*
CQLIT-247_CMS156_Collapsing date time intervals with an undefined end point-20210109:

# Question:
When collapse is called on a set of intervals where one of the intervals has an
undefined end point, what is the expected result?

For example:
  collapse(
    { [@2021-01-06 - @2021-01-08], [@2021-01-08 - null] }
  )

Collapse is defined in terms of overlaps and meets, which themselves use
predecessor and successor.  Both predecessor and successor indicate that a run
time error should be thrown if the value is already the minimum or maximum
allowed. End semantics indicate that the if the interval is closed then null
should be interpreted as the maximum value. Our implementation is throwing the
run time when we call successor from meets.

This question arises from interpreting EHR data for Medication, Order's for
CMS156 where the end point for the order is not defined. When I recreated this
issue in Bonnie, no error was thrown. When I dug into Bonnie's javascript I do
not see the javascript calling Overlaps or Meets. It appears to me that the
javascript is doing something custom.
*/

/*
Answer: re Collapse Operator
As background, here are links to relevant sections of the CQL documentation:
References:
* [Collapse](https://cql.hl7.org/09-b-cqlreference.html#collapse)
* [DateTime](https://cql.hl7.org/09-b-cqlreference.html#datetime)
* [Developer's Guide](https://cql.hl7.org/03-developersguide.html)
* [Time Interval Calculations](https://cql.hl7.org/15-h-timeintervalcalculations.html)

Regarding Collapse(), as noted in the Section 9.3 of Appendix B of the CQL Reference Guide:
“The collapse operator returns the unique set of intervals that completely covers
the ranges present in the given list of intervals. In other words, adjacent intervals
within a sorted list are merged if they either overlap or meet. Note that because the
semantics for overlaps and meets are themselves defined in terms of the interval
successor and predecessor operators, sets of Date-, DateTime-, or Time-based intervals
that are only defined to a particular precision will calculate meets and overlaps at
that precision. For example, a list of DateTime-based intervals where the boundaries
are all specified to the hour will collapse at the hour precision, unless the collapse
precision is overridden with the per argument. Conceptually, the per argument to the
collapse operator partitions the value-space for the operation into units of size 'per',
and the intervals will be collapsed aligning with those partitions. Note that the 'per'
partitions start from the starting boundary of the first input interval, ordered.”

To summarize, the list of "Medication, Order" relevant periods contained as the
Collapse(attributes) would be sorted chronologically by the start (lo) datetime
then the current item end (hi) datetime would be compared as equal to or greater
than the subsequent item start (lo) datetime for adjacent members of the list.
If true, the adjacent members would be combined as [start datetime (i), end datetime (i+1)].

The following snippets are from the CMS156 v9.0.003 cql file for 2021 Measurement Period:

define "Two High Risk Medications With Prolonged Duration":
  ( "Cumulative Medication Duration"("AntiInfectives During Measurement Period")>= 90
      and "More than One AntiInfective Order"
  )
    or ( "Cumulative Medication Duration"("Hypnotics During Measurement Period")>= 90
        and "More than One Nonbenzodiazepine Hypnotics Order"
    )

define function "Cumulative Medication Duration"(Medication List<"Medication, Order">):
  Sum((collapse(Medication.relevantPeriod))CumulativeDosages
      return all duration in days of CumulativeDosages
  )

Using Medication.relevantPeriod from your example:
  before collapse:  { [@2021-01-06,@2021-01-08], [@2021-01-08,null] }
  after collapse:   { [@2021-01-06,null] }

"Cumulative Medication Duration" would determine this interval duration in days.
Evaluation of null end date as a maximum hi closed interval [@2021-01-06,@9999-12-31]
which would sum to more than 90 days.

If your example was { [@2021-01-06,@2021-01-07], [@2021-01-08,null] }
then the two medication orders would not meet or overlap and be calculated separately,
but the "Cumulative Medication Duration" would still sum to more than 90 days.

Response due to Peter Muir MD, ESAC
*/

/*
Examples:
*/

define Test1:
  collapse(
    {
      Interval[@2021-01-06, @2021-01-08],
      Interval[@2021-01-08, null]
    }
  )

define Test2:
  collapse(
    {
      Interval[@2021-01-06, @2021-01-08],
      Interval[@2021-01-08, null],
      Interval[@2021-01-15, @2021-01-18]
    }
  )

// NOTE: This does throw, so the Java and Java Script implementations are most likely testing the boundary first:
// Psuedo code here
// http://build.fhir.org/ig/HL7/cql/09-b-cqlreference.html#collapse
define Test3: successor of maximum DateTime

/*
Results:
Test1=[Interval[2021-01-06, 9999-12-31]]
Test2=[Interval[2021-01-06, 9999-12-31]]
*/
