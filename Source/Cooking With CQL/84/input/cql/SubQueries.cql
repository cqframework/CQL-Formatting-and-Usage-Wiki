library SubQueries

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '4.1.0' called FC

context Patient

/*
The _query_ construct in CQL lets authors manipulate lists of values, as the
following simple examples demonstrate:
*/

define ListOfIntegers: { 1, 2, 3, 4, 5 }

define SimpleWhereQuery:
  ListOfIntegers X
    where X > 1

define SimpleReturnQuery:
  ListOfIntegers X
    return X + 1

/*
The _source_ list for the query can be a simple list like the previous examples,
but more commonly, it is a list of _structured values_ or _tuples_:
*/

define ListOfTuples: {
  { id: 1, date: Date(2024, 01, 01), value: 5.0 },
  { id: 2, date: Date(2024, 01, 01), value: 6.0 },
  { id: 3, date: Date(2024, 01, 02), value: 9.0 },
  { id: 4, date: Date(2024, 01, 02), value: 3.0 },
  { id: 5, date: Date(2024, 01, 03), value: 1.0 }
}

/*
And when retrieving FHIR data in particular, it is a list of resource instances:
*/

define Observations:
  [Observation] O

/*
Note that the source list for the query can also be part of a larger structure. Consider
patient phone numbers:
*/

define PatientPhoneNumbers:
  Patient.telecom T
    where T.system = 'phone'

/*
And because a _query_ is an _expression_ (in terms of CQL syntax), a query can
appear anywhere an expression can:
*/

define ObservationsWithDelta:
  Observations O
    where exists (
      O.extension E
        where E.url = 'http://hl7.org/fhir/StructureDefinition/observation-delta'
    )

/*
This use of a query within a query is commonly referred to as a "nested query",
or a "sub-query", and these queries can be nested to any degree.
*/

/*
Since the sub-query is in the _scope_ of the containing query, the _aliases_
in any parent query can be referenced:
*/

define DiagnosticReportsWithObservations:
  [DiagnosticReport] D
    where exists (
      Observations O
        where D.result.references(O)
    )

/*
This is known as a "correlated sub-query", because the sub-query is
referencing values in the parent query
*/

/*
We can use this capability to perform what is commonly referred to as a "group-by" query
in SQL, where we want to compute aggregates based on groupings of data.
*/

/*
Returning to the simple "list of tuples" example:
*/

define ListOfTuples2: {
  { id: 1, date: Date(2024, 01, 01), value: 5.0 },
  { id: 2, date: Date(2024, 01, 01), value: 6.0 },
  { id: 3, date: Date(2024, 01, 02), value: 9.0 },
  { id: 4, date: Date(2024, 01, 02), value: 3.0 },
  { id: 5, date: Date(2024, 01, 03), value: 1.0 }
}

/*
What if I want to find the sum of the values on each different day?
*/

define DaysInList:
  ListOfTuples2 D
    return { date: D.date }

/*
We start by finding the days, and note that this is _unique_ days, 
if we want all the days, with duplicates included, we have to include the `all` keyword.
In thise case, we want the distinct days, so this is the starting point
*/

/*
We then use a correlated sub-query to ask, for each date, what are the tuples that are on that date:
*/

define DaysInListWithTuples:
  ListOfTuples2 D
    return {
      date: D.date,
      tuples: ListOfTuples2 SD where SD.date = D.date
    }

/*
Then we can simply sum the values for the tuples for each date:
*/

define DaysInListWithSum:
  ListOfTuples2 D
    return {
      date: D.date,
      sum: Sum(ListOfTuples2 SD where SD.date = D.date return SD.value)
    }
