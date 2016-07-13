/*
Denominator =
  AND: Initial Population
  AND: "Physical Exam, Performed: Estimated Gestational Age at Delivery" satisfies all:
    (result >= 37 week(s))
    (result < 39 week(s))
    < 1 day(s) starts before start of ("Physical Exam, Performed: Time of Delivery" starts during Occurrence A of $EncounterInpatient )
*/

define "Denominator":
  ["Assessment, Performed": "Estimated Gestational Age at Delivery"] Assessment
    with ["Assessment, Performed": "Time of Delivery"] DeliveryTime
      such that DeliveryTime.result 1 day or less before start of Assessment.relevantPeriod
    where Assessment.result in Interval[37 weeks, 39 weeks)
