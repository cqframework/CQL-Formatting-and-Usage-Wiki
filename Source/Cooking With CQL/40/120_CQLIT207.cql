/*
https://oncprojectracking.healthit.gov/support/browse/CQLIT-207
*/

/*
An emergency department (ED) visit with an evaluation result that indicates
the patient is being admitted to inpatient staus and is performed during the Related ED visit
*/
define function "AdmitDecisionUsingAssessment"(Encounter "Encounter, Performed"):
  Last(["Assessment, Performed": "ED Evaluation"] EDEvaluation
    where EDEvaluation.relevantDatetime during "RelatedEDVisit"(Encounter).relevantPeriod
      and EDEvaluation.result in "Admit Inpatient"
    sort by relevantDatetime
  )

/*
The duration from the decision to admit inpatient to the departure from the Emergency Department
*/
define function "MeasureObservation"(Encounter "Encounter, Performed"):
  duration in minutes of Interval[
    Coalesce("AdmitDecisionUsingAssessment"(Encounter).authorDatetime,
      "AdmitDecisionUsingEncounterOrder"(Encounter).authorDatetime),
    "EDDepartureTime"("RelatedEDVisit"(Encounter))
  ]

/*
The first expression uses EDEvaluation.relevantDatetime and the second expression uses
"AdmitDecisionUsingEncounterOrder"(Encounter).authorDatetime)

The following expression does work and is more accurate:
*/

/*
The duration from the decision to admit inpatient to the departure from the Emergency Department
*/
define function "MeasureObservation"(Encounter "Encounter, Performed" ):
  duration in minutes of Interval[
    Coalesce("AdmitDecisionUsingAssessment"(Encounter).relevantDatetime,
      "AdmitDecisionUsingEncounterOrder"(Encounter).authorDatetime),
    "EDDepartureTime"("RelatedEDVisit"(Encounter))
  ]
