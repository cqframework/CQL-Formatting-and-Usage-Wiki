using QDM version '5.0.2'

valueset "Atrial Fibrillation/Flutter": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.202' version 'urn:hl7:profile:Most%20Recent%20Code%20System%20Versions%20in%20VSAC' 

// Note: Using a simplified definition for illustration only
define "Encounter with Principle Diagnosis of Ischemic Stroke":
  ["Encounter, Performed"]

// Note the trailing alias here CurrentAtrialFibrillationFlutter  
define "Current Diagnosis Atrial FibrillationFlutter": 
  "Encounter with Principle Diagnosis of Ischemic Stroke" NonElectiveEncounter
  where NonElectiveEncounter.diagnosis in "Atrial Fibrillation/Flutter" CurrentAtrialFibrillationFlutter

  // With 5.3 and searching for an encounter with BOTH diagnoses:
  where exists (NonElectiveEncounter.diagnoses D where D in "Atrial Fibrillation/Flutter")
    and exists (NonElectiveEncounter.diagnoses D where D in "Ischemic")
  
// This trailing alias sets up a new query, but because there are no additional clauses, it just
// returns the same set of codes as the reference to the value set would.
// Conceptually, this is valid CQL, but there are potential implementation issues
// The reason is that as part of preparing the machine-readable for the measure,
// the translator will detect valueset membership comparisons

//  NonElectiveEncounter.diagnosis in "Atrial Fibrillation/Flutter"

// And translate them using a special instruction in the machine-readable to indicate
// that this is a terminology membership test, rather than an "in" that should be 
// evaluated by the engine directly.

// So the problem in this case with the trailing alias is that because it sets up a query,
// the translator doesn't detect that it's a valueset membership and passes it through
// to the machine-readable as an "in", rather than a terminology test.

// This has implications for the implementation, because it means that the engine
// would be required to expand the value set in order to evaluate the expression.
// Besides being potentially expensive, some engines may not even have the facility
// to expand a value set, relying exclusively on terminology servers for this type
// of evaluation.

// More generally, references to value sets and code systems should always be
// careful to ensure that they don't result in an unexpected materialization.

// We have submitted enhancement requests to the tooling to detect and provide
// warnings for these cases.

