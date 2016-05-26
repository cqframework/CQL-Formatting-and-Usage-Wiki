// Two levels of conventions here?
  // 1. General CQL Conventions, applicable to any CQL written for any purpose
  // 2. QDM-specific conventions, applicable to measure development
    // Negation Rationale
    // Should criteria return individuals or a boolean
    // Should criteria be "additive"

// Pascal-casing for model class names
// Camel-casing for model attribute names
// Always use quoted identifiers for variable and type names
// All variable names start with a $ within the quote
// Never use quoted identifiers for attribute names +1
// The central construct in CQL is a query, which is a clause-based construct:
// operators and parentheses
  // operators vs functions
    // operators are keywords in the language, always lower-cased
      // May use parentheses if necessary to force precedence, but should always have a space after the keyword when used
      // unary operators are alwyas prefix
      // binary operators are always infix
    // functions are not keywords, always Pascal-cased, always use parentheses to invoke (this is syntactically required)

//primary-source alias
//	with-or-without-clauses
//	where-clause
//	return-clause
//	sort-clause


// Simple queries can just be a single line:
["Encounter": "Inpatient"] E

// More complex queries need multiple lines, but clauses should be on their own line if possible:
["Encounter": "Inpatient"] E
  where duration in days of E.period >= 120

// If a clause needs more than one line, it's continuations are indented beneath the clause:
["CommunicationRequest"] C
  where C.mode = 'ordered'
    and C.sender.role = 'nurse'
    and C.recipient.role = 'doctor'
    and C.indication in "Fever"

// Each new clause starts indented one level below the query:
["Encounter": "Inpatient"] E
  with ["Condition": "Acute Pharyngitis"] P
    such that P.onsetDateTime during E.period
      and P.abatementDate after end of E.period
  where duration in days of E.period >= 120
  return Tuple { id: E.id, lengthOfStay: duration in days of E.period }
  sort by lengthOfStay desc

// More complex queries
  // Multi-source queries
  // Let clauses


  A typed list must contain elements of the same type
  { ‘One’, ‘Two’, ‘Three’ }
  A list can contain elements of different types, but the list will be of type Any
  { 1, ‘Two’, Interval[3, 3] }
  An empty list is of type Any, unless you specify the type
  { } // List<Any>
  List<Integer> { } // Empty list of Integer
