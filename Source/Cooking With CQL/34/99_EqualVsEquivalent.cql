library EqualVsEquivalent

/*
From [CQLIT-157](https://oncprojectracking.healthit.gov/support/browse/CQLIT-157)

CMS 157 and 161 both have expressions that test for Equivalent encounters or procedures.  
How should equivalence of encounters or procedures be determined?
*/

/*

When used to compare data elements, the rules for "tuples" apply since data 
elements are represented as tuples within CQL:

Equivalent:
https://cql.hl7.org/STU2/09-b-cqlreference.html#equivalent

"For tuple types, this means that two tuple values are equivalent if and only if 
the tuples are of the same type, and the values for all elements by name are equivalent."
*/

/*
Equal:
https://cql.hl7.org/STU2/09-b-cqlreference.html#equal

*/

/*
The reason for the use of equivalent in this case, rather than equal, is that in 
CQL 1.2, the Equal operator for tuples is defined as the same elements with the 
same values for each element, using Equal semantics, and since `null = null` 
returns null, comparing a tuple to itself with equality will return null if that
 tuple has any null elements.

Equivalent, on the other hand is defined as the same elements with the same values 
for each element using Equivalent semantics, and since `null = null` returns true, 
it will return true when used to compare a tuple to itself.

And since one of the elements of the tuple is the id, that constitutes a unique 
value and there's no possibility that two different encounters would compare equivalent,
 since they would have different ids.

So effectively, `TupleA !~ TupleB` is a shorthand for `TupleA.id !~ TupleB.id`
*/

