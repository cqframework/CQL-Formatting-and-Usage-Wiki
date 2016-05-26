/*
  AND: Age >= 2 year(s) at: "Measurement Period"
  AND: Age < 18 year(s) at: "Measurement Period"
*/

define "In Demographic":
  AgeInYearsAt(start of "Measurement Period") >= 2
    and AgeInYearsAt(start of "Measurement Period") < 18


define "In Demographic":
  Common.InAgeRangeAt([2, 18), start of "Measurement Period")
