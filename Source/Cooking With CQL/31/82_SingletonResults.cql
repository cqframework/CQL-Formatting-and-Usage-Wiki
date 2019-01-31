/*
https://oncprojectracking.healthit.gov/support/browse/CQLIT-144

Although it's true that the "retrieve" expression always returns a list, 
expressions in general in CQL don't have to return lists. In particular, 
the Last and First operators return a "singleton", i.e. one element from the list, 
rather than a list with one element. When the result of a particular query or 
definition is a singleton, the appropriate test for presence of a value is to 
use the is null / is not null operators, as opposed to the use of exists / not exists 
when testing lists.

Note also that queries don't have to return a list either, they may also return 
singletons. For example, in the CQL specification section on non-retrieve queries, 
an [example](https://cql.hl7.org/03-developersguide.html#non-retrieve-queries) is 
given of using a singleton query to redefine the elements of a tuple.

So, looking at the specific example raised in this issue:
*/

define "Most Recent Adult Depression Screening Negative":
	"Most Recent Adult Depression Screening" RecentAdultScreening
		where RecentAdultScreening.result in "Negative Depression Screening"
    
/*
The question is what is the result type of a singleton query that includes a "where" clause?

In the CQL specification, this is covered in the section on [Type Inference](https://cql.hl7.org/03-developersguide.html#queries-1),
specifically, the section on query type inference. The 5th bullet says:

A where clause only limits the set of results returned by the query, it does not 
impact the type of the result.

So the wording here implies a list-based query, but it also states clearly that 
the where clause does not impact the type, so the type of a singleton query would 
still be just the type of the singleton source. It is worth a clarification in the
spec though, since it does imply a list-based source.
*/

