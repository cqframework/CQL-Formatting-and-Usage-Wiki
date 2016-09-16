// Numerator with occurrencing and timing (CMS124)

library CMS124

using QDM version '5.0'

valueset "Pap Test": 'Pap Test'
valueset "HPV Test": 'HPV Test'

parameter "Measurement Period" Interval<DateTime>

define "Pap Test With Results":
  ["Laboratory Test, Performed": "Pap Test"] LabTest
    where LabTest.result is not null

define "Pap Test Within 3 Years":
  "Pap Test With Results" Test
    where Test.resultDatetime 3 years or less before end of "Measurement Period"

define "HPV Test With Results":
["Laboratory Test, Performed": "HPV Test"] LabTest
  where LabTest.result is not null

define "Pap Test With HPV Test Within 5 Years":
  "Pap Test With Results" Test
    with "HPV Test With Results" HPVTest
      such that HPVTest.resultDatetime within 1 day of Test.resultDatetime
    where CalculateAgeInYearsAt(Test.resultDatetime) >= 30
      and Test.resultDatetime 5 years or less before end of "Measurement Period"

define Numerator:
  exists ("Pap Test Within 3 Years")
    or exists ("Pap Test With HPV Test Within 5 Years")

/*
Numerator =
  AND:
    OR: "Laboratory Test, Performed: Pap Test (result)" < 3 year(s) ends before end of "Measurement Period"
      OR:
        AND: Age>= 30 year(s) at: "Occurrence A of Laboratory Test, Performed: Pap Test"
        AND: "Occurrence A of Laboratory Test, Performed: Pap Test" satisfies all:
          (result) < 5 year(s) ends before end of "Measurement Period"
          satisfies any:
            <= 1 day(s) starts after or concurrent with start of "Laboratory Test, Performed: HPV Test (result)"
            <= 1 day(s) starts before start of "Laboratory Test, Performed: HPV Test (result)"
*/
