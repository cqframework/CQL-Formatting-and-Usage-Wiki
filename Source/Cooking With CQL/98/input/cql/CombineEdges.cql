library CombineEdges

// FHIRPath join:
/*
https://build.fhir.org/ig/HL7/FHIRPath/#joinseparator-string--string

The join function takes a collection of strings and joins them into a single string, optionally using the given separator.

If the input is empty, the result is empty.

If no separator is specified, the strings are directly concatenated.

The following example illustrates the behavior of the .join operator:
*/

// CQL Reference for Combine
/*
https://cql.hl7.org/09-b-cqlreference.html#combine

The Combine operator combines a list of strings, optionally separating each string with the given separator.

If either argument is null, or the source list is empty, the result is null.

For consistency with aggregate operator behavior, null elements in the input list are ignored.
*/

define TestCombine1: Combine({ 'a', 'b', 'c', null }, ', ')
define TestCombine2: Combine({ }, ', ') = ''

// CQL Logical Specification for Combine
/*
https://cql.hl7.org/04-logicalspecification.html#combine

The Combine operator combines a list of strings, optionally separating each string with the given separator.

If either argument is null, or any element in the source list of strings is null, the result is null.
*/
