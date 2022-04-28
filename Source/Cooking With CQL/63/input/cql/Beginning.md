# Beginning CQL

## What is CQL?

1. CQL is a _query language_
2. CQL is a _typed language_
3. CQL is a _functional language_
4. CQL is a clinically-focused _domain-specific language_
4. CQL is _model independent_
5. CQL is _location independent_
6. CQL has _contexts_

* [CQL Getting Started](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Getting-Started)

## What can I use CQL for?

1. Retrieve data from a FHIR server
1. Define _data elements_
1. Define _cohorts_
1. Define _inclusion_ and _exclusion criteria_
1. Define _clinical decision support logic_
1. Define _quality measure logic_
1. Define _questionnaire skip logic_
1. You can use CQL to define _documentation templates_
1. You can use CQL to define _shareable libraries_ of clinical logic

## What can I _not_ use CQL for?

1. Store data
2. Write _imperative_ logic (i.e. CQL is not a _programming_ language)
3. Build _user interactions_

## Example 01 - Qualifying Encounters

> NOTE: To be able to run these examples, you will need to download local copies of the ValueSet resources listed in [README.md](../vocabulary/valueset/README.md)

* [Example01](Example01.cql)

```cql
library Example01

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2019-01-01T00:00:00.0, @2020-01-01T00:00:00.0)

context Patient

/**
 * @description: Returns finished encounters in the "Office Visit" value set
 * during the measurement period
 */
define "Qualifying Encounters":
  [Encounter: "Office Visit"] ValidEncounter
    where ValidEncounter.status  = 'finished'
      and ValidEncounter.period during "Measurement Period"
```

### Language Elements

* CQL logic is written in collections called _libraries_
* Libraries have an _identifier_ and optionally a _version_
* Libraries can declare the _model_, which specifies what kind of data the logic will be using
* Libraries can _include_ other libraries
* Libraries can include _terminology_ declarations
* Libraries can include _parameters_
* Libraries typically declare a _context_, which specifies the "perspective" for the logic (i.e. in terms of a Patient)
* Libraries can include _named expressions_ and _functions_

### CQL Queries

The central construct for querying data in CQL is the _query_. For example:

```cql
define "Qualifying Encounters":
  [Encounter: "Office Visit"] ValidEncounter
    where ValidEncounter.status  = 'finished'
      and ValidEncounter.period during "Measurement Period"
```

This named expression, `"Qualifying Encounters"`, returns finished "`Office Visit`" encounters during the `"Measurement Period"`

The _source_ for this query is a _retrieve_:

```cql
  [Encounter: "Office Visit"]
```

The _retrieve_ expression is the way all data access is performed in CQL. Retrieves allow authors to ask for specific types of data, based on the _model_, FHIR in this case, and optionally filtered by terminology, the `"Office Visit"` value set.

The _retrieve_ can optionally specify a property for the terminology filter:

```cql
  [Encounter: type in "Office Visit"]
```

If no property is specified, the retrieve is performed using the `primaryCodePath` specified by the model. Primary code paths for the FHIR model are documented in the [FHIRModelInfo](https://github.com/cqframework/clinical_quality_language/wiki/FHIRModelInfo#retrievable-types-r4) topic on the CQL Formatting and Usage wiki.

#### Aliases

Queries are introduced by specifying an _alias_ for the _source_ of the query:

```cql
  [Encounter: "Office Visit"] ValidEncounter
```

This example sets up `ValidEncounter` as the alias for office visits in this query. This alias is then used to refer to elements of office visit in the various _clauses_ of the query, such as the _where_ clause:

```cql
  [Encounter: "Office Visit"] ValidEncounter
    where ValidEncounter.status  = 'finished'
      and ValidEncounter.period during "Measurement Period"
```

The _where_ clause defines the criteria that must be true in order for the encounter to be returned from the query. In this case, that the status is equal to `'finished'` and that the `period` is during the measurement period.

The [structure](https://cql.hl7.org/02-authorsguide.html#full-query) of a single-source [query](https://cql.hl7.org/19-l-cqlsyntaxdiagrams.html#query) is:

```
<primary-source> <alias>
  <with-or-without-clauses>
  <where clause>
  <return clause>
  <sort clause>
```

* The _with_ and _without_ clauses can be used to specify filtering relationships to other sources
* The _return_ clause can be used to "shape" the result of query
* The _sort_ clause can be used to order the results of the query

```cql
  [Encounter: "Office Visit"] ValidEncounter
    where ValidEncounter.status  = 'finished'
      and ValidEncounter.period during "Measurement Period"
    return { id: ValidEncounter.id, status: ValidEncounter.status, period: ValidEncounter.period }
```

## Example 02 - Cervical Cancer Screening

The next example builds on the Qualifying Encounters example to illustrate defining population criteria for a Cervical Cancer Screening measure. This is a simplified example taken from the current draft FHIR-based [eCQM content repository](https://github.com/cqframework/ecqm-content-r4-2021) used for FHIR connectathon testing.

The initial population criteria is specified as:

```cql
define "Initial Population":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[23, 64)
    and Patient.gender = 'female'
    and exists "Qualifying Encounters"
```

Note the `"Qualifying Encounters"` definition is expanded in this example:

```cql
define "Qualifying Encounters":
  ( [Encounter: "Office Visit"]
    union [Encounter: "Preventive Care Services - Established Office Visit, 18 and Up"]
    union [Encounter: "Preventive Care Services-Initial Office Visit, 18 and Up"]
    union [Encounter: "Home Healthcare Services"]
    union [Encounter: "Telephone Visits"]
    union [Encounter: "Online Assessments"]
  ) ValidEncounter
    where ValidEncounter.status = 'finished'
      and ValidEncounter.period during "Measurement Period"
```

The basic query is the same, but the _source_ for this query is a _union_ of multiple retrieves, each one pulling encounters from different value sets.

The denominator is the same as the initial population:

```cql
define "Denominator":
  "Initial Population"
```

Denominator exclusions are defined as:

```cql
define "Denominator Exclusions":
  exists "Absence of Cervix"
```

> NOTE: This is a simplification, the actual exclusions involve determination of hospice and palliative care

```cql
define "Absence of Cervix":
  ( [Procedure: "Hysterectomy with No Residual Cervix"] NoCervixProcedure
    where NoCervixProcedure.status = 'completed'
      and Global."Normalize Interval"(NoCervixProcedure.performed) ends on or before end of "Measurement Period"
  )
    union ( [Condition: "Congenital or Acquired Absence of Cervix"] NoCervixDiagnosis
        where Global."Prevalence Period"(NoCervixDiagnosis) starts on or before end of "Measurement Period"
    )
```

Note the use of `Global."Normalize Interval"`. This is important because of choice types in FHIR, and allows the underlying data to be reported based on the FHIR profile, which allows the performed element to be represented as a DateTime or as a Period. The `"Normalize Interval"` function takes either and turns it into a _normalized_ interval.

Note also that the `union` here is combining `Procedure` and `Condition` resources into a single result.

And finally, the numerator is defined as:

```cql
define "Numerator":
  exists "Cervical Cytology Within 3 Years"
    or exists "HPV Test Within 5 Years for Women Age 30 and Older"
```

```cql
define "Cervical Cytology Within 3 Years":
  [Observation: "Pap Test"] CervicalCytology
    where CervicalCytology.status in { 'final', 'amended', 'corrected' }
      and exists ( CervicalCytology.category CervicalCytologyCategory
        where "laboratory" in FHIRHelpers.ToConcept(CervicalCytologyCategory).codes
      )
      and Global."Latest"(CervicalCytology.effective) 3 years or less on or before end of "Measurement Period"
      and CervicalCytology.value is not null
```

Cervical Cytology results in FHIR are represented as Laboratory observations. That means the criteria must check for Observations with a category of Laboratory and a status of final, amended, or corrected. In addition, this is using the "Latest" function to normalize the effective element. This means that if the effective element is specified as a date, it will use the date, but if it's specified as a period, it will use the end of the period if specified, otherwise it will fall back to the start of the period.

So the criteria is checking for complete cervical cytology laboratory results that were effective 3 years on or before the end of the measurement period, and that have a result.

```cql
define "HPV Test Within 5 Years for Women Age 30 and Older":
  [Observation: "HPV Test"] HPVTest
    where HPVTest.status in { 'final', 'amended', 'corrected' }
      and exists ( HPVTest.category HPVTestCategory
          where "laboratory" in FHIRHelpers.ToConcept(HPVTestCategory).codes
      )
      and AgeInYearsAt(date from start of Global."Normalize Interval"(HPVTest.effective)) >= 30
      and Global."Latest"(HPVTest.effective) 5 years or less on or before end of "Measurement Period"
      and HPVTest.value is not null
```

And similarly, this criteria is checking for complete HPV test laboratory results that were effective on or after the patient's 30th birthday, and 5 years or less on or before the end of the measurement period, and that have a result.

## Next Steps

For a deeper dive, the [Getting Started](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Getting-Started) page provides a host of resources including tutorials and walkthroughs:

* [Authoring Measures in CQL](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Measures-in-CQL)
* [Developer's Introduction to CQL](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Developers-Introduction-to-CQL)
* [CQL Exercises](https://github.com/cqframework/cqf-exercises)
* [Content IG Walkthrough](https://github.com/cqframework/content-ig-walkthrough)
* [Colorectal Cancer Screening Example](https://github.com/cqframework/cqf-ccc)

In addition, there are links to all the relevant specifications, as well as links to community tooling and projects pages where you can see lots of examples of CQL being used in various applications including decision support, guideline representation, and quality measurement.
