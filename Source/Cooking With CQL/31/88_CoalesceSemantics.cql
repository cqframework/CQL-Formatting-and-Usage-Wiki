/*
Coalesce semantics
*/

/*
In the Coalesce() expression below, if the relevantPeriod is found and fails the logic, 
should the definition #2 stop processing? According to CQL definition, Coalesce() returns 
the first non-null value. Although UNION() has been addressed many times, we need more 
elaboration on interpretation and implementation.
*/

/* 
Consider the following  data:

First ICU                 12-06-2018
Intervention, Order       12-07-2018
Intervention, Performed   12-08-2018
*/

define "Intervention Comfort Measures":
  ["Intervention, Order": "Comfort Measures"]
    union ["Intervention, Performed": "Comfort Measures"]

define "Intervention Comfort Measures on Day of or Day After Start of Hospitalization":
  "Encounter With Age Range and Without VTE Diagnosis or Obstetrical Conditions" QualifyingEncounter
    with "Intervention Comfort Measures" ComfortMeasures
      such that Coalesce(start of ComfortMeasures.relevantPeriod, ComfortMeasures.authorDatetime) 
        1 day or less on or after day of start of Global."Hospitalization"(QualifyingEncounter)

define "Intervention Comfort Measures on Day of or Day After Start of Hospitalization":
  "Encounter With Age Range and Without VTE Diagnosis or Obstetrical Conditions" QualifyingEncounter
    where exists (
      "Intervention Comfort Measures" ComfortMeasures
        where Coalesce(start of ComfortMeasures.relevantPeriod, ComfortMeasures.authorDatetime) 
          1 day or less on or after day of start of Global."Hospitalization"(QualifyingEncounter)
    )
 
define "Intervention Comfort Measures":
   ["Intervention, Order": "Comfort Measures"]
     union (
       ["Intervention, Performed": "Comfort Measures"] I
         return "Intervention, Order" {
           id: I.id,
           code: I.code,
           authorDatetime: start of I.relevantPeriod
         }
     )

define "Intervention Comfort Measures on Day of or Day After Start of Hospitalization":
  "Encounter With Age Range and Without VTE Diagnosis or Obstetrical Conditions" QualifyingEncounter
    with "Intervention Comfort Measures" ComfortMeasures
      such that ComfortMeasures.authorDatetime
        1 day or less on or after day of start of Global."Hospitalization"(QualifyingEncounter)
