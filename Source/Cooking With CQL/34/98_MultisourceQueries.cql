library MultisourceQueries

/*
From [CQLIT-158](https://oncprojectracking.healthit.gov/support/browse/CQLIT-158)

How do we interpret the path "EncounterWithPharyngitis.AcutePharyngitisTonsillitis.prevalencePeriod"
in the following query?
*/

define "Antibiotic Active In the 30 Days Prior":
  "Encounter With Pharyngitis or Tonsillitis" EncounterWithPharyngitis
    with ["Medication, Active": "Antibiotic Medications for Pharyngitis"] ActiveAntibiotic
      such that ActiveAntibiotic.relevantPeriod 
        overlaps Interval[
          Global."ToDate"((start of 
            EncounterWithPharyngitis.AcutePharyngitisTonsillitis.prevalencePeriod) - 30 days
          ), 
          Global."ToDate"(start of 
            EncounterWithPharyngitis.AcutePharyngitisTonsillitis.prevalencePeriod
          )
        )
    return EncounterWithPharyngitis.VisitWithAntibiotic

/*
The definition "Encounter with Pharyngitis or Tonsilitis" is a multi-source query, 
which, unless explicitly shaped with a return clase, results in a tuple with an 
element for each source:
*/

define "Encounter With Pharyngitis or Tonsillitis":
  from
    "Encounter With Antibiotic Ordered Within Three Days" VisitWithAntibiotic,
    "Pharyngitis or Tonsillitis" AcutePharyngitisTonsillitis
  where AcutePharyngitisTonsillitis.prevalencePeriod 
    starts during VisitWithAntibiotic.relevantPeriod

/*
So in this case, the result of the expression is a list of tuples; 
one for each combination of tuples in the two sources where each tuple has two elements:

{ 
  VisitWithAntibiotic: { id: ... }, 
  AcutePharyngitisTonsilitis: { id: ... } 
}

The `VisitWithAntibiotic` tuple is an Encounter, and the `ActuePharyngitisTonsilitis` 
tuple is a Diagnosis. So when this definition is referenced in a query:
*/

define "Antibiotic Active In the 30 Days Prior":
  "Encounter With Pharyngitis or Tonsillitis" EncounterWithPharyngitis
    with ["Medication, Active": "Antibiotic Medications for Pharyngitis"] ActiveAntibiotic
      such that ActiveAntibiotic.relevantPeriod 
        overlaps Interval[
          Global."ToDate"((start of 
            EncounterWithPharyngitis.AcutePharyngitisTonsillitis.prevalencePeriod) - 30 days
          ), 
          Global."ToDate"(start of 
            EncounterWithPharyngitis.AcutePharyngitisTonsillitis.prevalencePeriod
          )
        )
    return EncounterWithPharyngitis.VisitWithAntibiotic

/*
The query is ranging over the list of elements in the source, so the path "AcutePharyngitisTonsilitis" 
refers to the diagnosis-valued attribute of the tuple.

The Query Evaluation section of the Language Semantics chapter of the specification 
discusses query evaluation strategy:

https://cql.hl7.org/STU2/05-languagesemantics.html#query-evaluation
 
*/
