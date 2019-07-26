library NonDeterministicSupport

/*
[CQLIT-171](https://oncprojectracking.healthit.gov/support/browse/CQLIT-171) - Randomly pick an element for a list

Does CQL support a mechanism for randomly picking an item from a list?
*/

/*
The short answer is no.

CQL is purposely a deterministic language, so we don't have functions like Random(). 
This was a design decision in the very earliest phases of language development to 
ensure that systems could reliably cache intermediate results. Even functions 
like Today() and Now() are defined deterministically so that they return the same 
value within any given evaluation session.

Having said that, CQL 1.3 introduced the ability to define external libraries. 
From the perspective of the translator, external definitions are just function signatures; 
it's up to the engine to resolve external definitions and provide the run-time 
implementation for them. For engines, this would be fairly straightforward to 
support, but:

1. It would tie the CQL that uses the external definitions to engines that understood 
those externals (reducing portability) 

2. The Java-based open source engine does support external libraries, but it's not a feature
that has been well-tested.
*/
