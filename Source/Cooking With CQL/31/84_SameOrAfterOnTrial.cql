// Based on a question from implementers, what are the semantics of same or after with intervals?

// The specification defines it as:

/*

https://cql.hl7.org/09-b-cqlreference.html#same-or-after-2

returns true if the first interval starts on or after the second one ends
*/

/*
But this means that:

Interval[5, 7] same or after Interval[5, 7]

is actually false. Although this behavior does seem surprising, the point of the way that
it is defined in CQL is to ensure that mixed-type signatures with same or after and
same or before work as expected. For something like

authorDatetime on or after relevantPeriod

this works and is essentially asking whether the authorDatetime is on or after the
end of the relevantPeriod.
*/

