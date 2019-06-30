library Joins

using QDM version '5.3'

valueset "Outpatient": 'TBD'
valueset "Streptococcus Test": 'TBD'

context Patient

// In SQL, joins are used to combine data from multiple tables.
// In CQL, the focus is on simplest possible expression of single-source queries
// But multi-source queries are possible as well:

define "Semi-join Example":
 ["Encounter, Performed": "Outpatient"] Encounter
  with ["Laboratory Test, Performed": "Streptococcus Test"] Test
    such that Test.resultDatetime during Encounter.relevantPeriod
    
define "Semi-minus Example":
 ["Encounter, Performed": "Outpatient"] Encounter
  without ["Laboratory Test, Performed": "Streptococcus Test"] Test
    such that Test.resultDatetime during Encounter.relevantPeriod

define "Join Example":
 from
  ["Encounter, Performed": "Outpatient"] Encounter,
  ["Laboratory Test, Performed": "Streptococcus Test"] Test
 where Test.resultDatetime during Encounter.relevantPeriod
 return { Encounter: Encounter, Test: Test }
 
define "Join Example with Select":
 from
  ["Encounter, Performed": "Outpatient"] Encounter,
  ["Laboratory Test, Performed": "Streptococcus Test"] Test
 where Test.resultDatetime during Encounter.relevantPeriod
 return { 
   encounterId: Encounter.id, 
   encounterCode: Encounter.code, 
   encounterRelevantPeriod: Encounter.relevantPeriod,
   testId: Test.id,
   testCode: Test.code,
   testResultDatetime: Test.resultDatetime,
   testResult: Test.result
 }
 
define "Cartesian-product Example":
 from
  ["Encounter, Performed": "Outpatient"] Encounter,
  ["Laboratory Test, Performed": "Streptococcus Test"] Test

// Default result from a multi-source query is a tuple with an element for each query source
// { Encounter: "Encounter, Performed", Test: "Laboratory Test, Performed" }

define "Left-outer-join Example":
  ["Encounter, Performed": "Outpatient"] Encounter
    let Test: singleton from (["Laboratory Test, Performed": "Streptococcus Test"])
    return { Encounter: Encounter, Test: Test }

