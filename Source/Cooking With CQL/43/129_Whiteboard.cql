library Whiteboard

/*
This example illustrates the use of an "empty source query" to support ad-hoc calculation
within CQL
*/

/*
Sometimes within measures or decision support rules, calculations need to be performed
that don't need a specific starting source. In these cases, an "empty source query" can be
used. This allows authors to introduce intermediate calculated values, and perform the final
computation with the return clause:
*/

define EmptyTupleQuery:
  ({ : }) Whiteboard 
    let Foo: 2, Bar: 3 
    return Foo + Bar

/*
Note that we used an empty tuple `{ : }`, not an empty list. This is because if we
used an empty list:
*/

define AntiPattern:
  ({ }) Whiteboard
    let Foo: 2, Bar: 3
    return Foo + Bar

/*
We're saying "for each element in the empty list, return Foo + Bar" and since there
are no elements in the empty list, this query returns the empty list and nothing is
ever calculated. By using the empty tuple (`{ : }`) the query is now a "singleton"
result and the expected result is returned (5 in this contrived example).
*/
