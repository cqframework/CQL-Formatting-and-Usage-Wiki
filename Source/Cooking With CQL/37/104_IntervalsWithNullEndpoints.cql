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

NOTE: This guidance is incorrect, see followup note below for the actual fix that was applied to the specification:

*/

/*
A comment on the specification will be submitted to add this interpretation of an interval
with both endpoints null.
*/

/*

Followup 2026-05-01:

That comment was submitted as part of the 2019 May CQL STU4 Ballot, it ended up being comment #35 in that ballot, and suggested:

> If an interval has both boundaries null and closed, the current semantics indicate that this is the interval from the beginning of time to the end of time. However, this results in surprising behavior when performing comparisons that involve building an interval from a single value (such as the interval from 30 days before to 30 days after the documentation time of an event). If the point used to build the interval is null, this results in an effectively infinite interval, and all comparisons return true, resulting the opposite of the intent. The "null" interval should be considered a null like any other throughout CQL.

However, reconciliation identified the root cause of the issue in this case being that the "within" translation phrases were incorrectly translating when the point argument to the within phrase was null:

> This is an error in the specification. Specifically, the timing phrase translations in [5.5.3.2](https://cql.hl7.org/05-languagesemantics.html#beforeafter) and [5.5.3.3](https://cql.hl7.org/05-languagesemantics.html#within). The problem is that these translations are constructing intervals out of expressions that may result in null, and whenever an inclusive boundary is used with a null, the resulting translation incorrectly resolves to the beginning or end of time, rather than the unknown that was used to construct the interval. The translation semantics either need to add an explicit check for null, or use predecessor and successor functions so that an exclusive boundary can always be used. The former approach is preferred as simpler and more correct in the presence of variable precision values.

The comment was found _Not persuasive with mod_ and the following change was actually applied to the spec:

> Change the timing phrase translations in the specification to account for the possibility that the expression used to construct an interval as part of the translation may be null by adding a null check to the translation.

[Source](https://www.hl7.org/documentcenter/public/ballots/2019MAY/reconciliation/recon_hl7_cqlang_r1_d4_2019may.xlsx)

The change log shows this change applied as part of STU4 ballot reconciliation:

> STU4B#35: Changed timing phrase translations to add null check when the translation constructs an interval from a nullable element (Substantive)

[Source](https://cql.hl7.org/v1.4-changelog.html#:~:text=STU4B%2335%3A%20Changed%20timing%20phrase%20translations%20to%20add%20null%20check%20when%20the%20translation%20constructs%20an%20interval%20from%20a%20nullable%20element%20(Substantive))

*/
