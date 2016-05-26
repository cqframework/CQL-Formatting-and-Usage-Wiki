library AgeExamples version '1'

using QDM // version '4.2'

parameter "Measurement Period" Interval<DateTime>

/*
Example 01
Unbounded upper age range tied to Measurement Period
CMS132

Initial Population =
  AND: Age>= 18 year(s) at: "Measurement Period"
*/

define "In Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 18

/*
Example 02
Unbounded upper age range tied to encounter
CMS104

Initial Population =
  AND: Age>= 18 year(s) at: Occurrence A of $EncounterInpatientNonElective

$EncounterInpatientNonElective =
  "Encounter, Performed: Non-Elective Inpatient Encounter" satisfies all:
    (length of stay <= 120 day(s))
    ends during "Measurement Period"
*/

valueset "Non-Elective Inpatient Encounter": 'X.Y.Z'

define "Encounter Inpatient Non-Elective":
  ["Encounter, Performed", "Non-Elective Inpatient Encounter"] Encounter
    where Encounter.lengthOfStay <= 120 days
      and Encounter.stopDateTime during "Measurement Period"

// Didn't need to be separated, but defined separately because the use of
// Occurrence indicates it will be used as part of some other criteria later in the measure
define "Encounter Inpatient Non-Elective, at least 18 years"
  "Encounter Inpatient Non-Elective" Encounter
    where AgeInYearsAt(Encounter.startDateTime) >= 18

define "In Initial Population":
  exists ("Encounter Inpatient Non-Elective, at least 18 years")

/*
Example 03
Bounded age range tied to Measurement Period
CMS122

Initial Population =
  AND: Age>= 18 year(s) at: "Measurement Period"
  AND: Age< 75 year(s) at: "Measurement Period"
*/

define "In Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 18
    and AgeInYearsAt(start of "Measurement Period") < 75

// An alternative formulation involving intervals
define "In Initial Population":
  AgeInYearsAt(start of "Measurement Period") in Interval[18, 75)

/*
Example 04
Bounded age range tied to encounter
CMS113

Initial Population =
  AND: Age>= 8 year(s) at: Occurrence A of $EncounterInpatient
  AND: Age< 65 year(s) at: Occurrence A of $EncounterInpatient

$EncounterInpatient =
  "Encounter, Performed: Encounter Inpatient" satisfies all:
    (length of stay <= 120 day(s))
    ends during "Measurement Period"
*/

valueset "Encounter Inpatient Valueset": 'TBD'

define "Encounter Inpatient":
  ["Encounter, Performed": "Encounter Inpatient Valueset"] Encounter
    where Encounter.lengthOfStay <= 120 days
      and Encounter.stopDateTime during "Measurement Period"

/*
Example 05
Use of age for numerator compliance (1st example)
CMS2

Initial Population =
  AND: Age>= 12 year(s) at: "Measurement Period"
  AND: "Encounter, Performed: Depression Screening Encounter Codes" during "Measurement Period"
Numerator =
  AND:
    OR:
      AND: Most Recent: "Occurrence A of Risk Category Assessment: Adolescent Depression Screening (result)" during ("Encounter, Performed: Depression Screening Encounter Codes" during "Measurement Period" )
      AND: "Occurrence A of Risk Category Assessment: Adolescent Depression Screening (result: Negative Depression Screening)"
      AND: Age< 18 year(s) at: "Measurement Period"
    OR:
      AND: Most Recent: "Occurrence A of Risk Category Assessment: Adult Depression Screening (result)" during ("Encounter, Performed: Depression Screening Encounter Codes" during "Measurement Period" )
      AND: "Occurrence A of Risk Category Assessment: Adult Depression Screening (result: Negative Depression Screening)"
      AND: Age>= 18 year(s) at: "Measurement Period"
*/

valueset "Depression Screening Encounter Codes": 'TBD'
valueset "Adolescent Depression Screening": 'TBD'
valueset "Adult Depression Screening": 'TBD'
valueset "Negative Depression Screening": 'TBD'

define "Depression Screening Encounter":
  "Encounter, Performed": "Depression Screening Encounter Codes" Encounter
    where Interval[Encounter.startDateTime, Encounter.stopDateTime] during "Measurement Period"

define "In Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 12
    and exists (
      "Encounter, Performed": "Depression Screening Encounter Codes" Encounter
        where Interval[Encounter.startDateTime, Encounter.stopDateTime] during "Measurement Period"
    )

define "Most Recent Adolescent Risk Category Assessment":
  First(
    ["Risk Category Assessment": "Adolescent Depression Screening"] Assessment
      with "Depression Screening Encounter" Encounter
        such that Interval[Assessment.startDateTime, Assessment.stopDateTime]
          during Interval[Encounter.startDateTime, Encounter.stopDateTime]
      where Assessment.result is not null
      sort by startDateTime desc
  )

define "Most Recent Adult Risk Category Assessment":
  First(
    ["Risk Category Assessment": "Adult Depression Screening"] Assessment
      with "Depression Screening Encounter" Encounter
        such that Interval[Assessment.startDateTime, Assessment.stopDateTime]
          during Interval[Encounter.startDateTime, Encounter.stopDateTime]
      where Assessment.result is not null
      sort by startDateTime desc
  )

define "In Numerator":
  (
    AgeInYearsAt(start of "Measurement Period") < 18
      and "Most Recent Adolescent Risk Category Assessment".result in "Negative Depression Screening"
  ) or (
    AgeInYearsAt(start of "Measurement Period") >= 18
      and "Most Recent Adult Risk Category Assessment".result in "Negative Depression Screening"
  )

// Alternative formulation:

define "Risk Category Assessment":
  ["Risk Category Assessment": "Adolescent Depression Screening"] Assessment
    where Assessment.result is not null
      and AgeInYearsAt(start of "Measurement Period") < 18
  union (
    ["Risk Category Assessment": "Adult Depression Screening"] Assessment
      where Assessment.result is not null
        and AgeInYearsAt(start of "Measurement Period") >= 18
  )

define "Most Recent Risk Category Assessment":
  First(
    "Risk Category Assessment" Assessment
      with "Depression Screening Encounter" Encounter
        such that Interval[Assessment.startDateTime, Assessment.stopDateTime]
          during Interval[Encounter.startDateTime, Encounter.stopDateTime]
      sort by startDateTime desc
  )

define "In Numerator":
  "Most Recent Risk Category Assessment".result in "Negative Depression Screening"

/*
Example 06
Use of age for numerator compliance (2nd example)
CMS124

Initial Population =
  AND: Age>= 23 year(s) at: "Measurement Period"
  AND: Age< 64 year(s) at: "Measurement Period"
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

define "In Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 23
    and AgeInYearsAt(start of "Measurement Period") < 64

define "Pap Test Within 3 Years":
  ["Laboratory Test, Performed": "Pap Test"] PapTest
    where PapTest.stopDateTime 3 years or less before end of "Measurement Period"
      and PapTest.result is not null

define "Pap Test Within 5 Years":
  ["Laboratory Test, Performed": "Pap Test"] PapTest
    with ["Laboratory Test, Performed": "HPV Test"] HPVTest
      such that HPVTest.result is not null
        and HPVTest.startDateTime within 1 day of PapTest.startDateTime
    where PapTest.stopDateTime 5 years or less before end of "Measurement Period"
      and PapTest.result is not null
      and AgeInYearsAt(PapTest.startDateTime) >= 30

define "In Numerator":
  exists ("Pap Test Within 3 Years")
    or exists ("Pap Test Within 5 Years")

/*
Example 07
Use of age for stratification (1st example)
CMS153

Initial Population =
  AND: Age>= 16 year(s) at: "Measurement Period"
  AND: Age< 24 year(s) at: "Measurement Period"
Stratifications =
  Stratification 1 =
    AND: Age>= 16 year(s) at: "Measurement Period"
    AND: Age< 20 year(s) at: "Measurement Period"
  Stratification 2 =
    AND: Age>= 20 year(s) at: "Measurement Period"
    AND: Age< 24 year(s) at: "Measurement Period"
*/

define "In Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 16
    and AgeInYearsAt(start of "Measurement Period") < 24

define "Stratification 1":
  AgeInYearsAt(start of "Measurement Period") >= 16
    and AgeInYearsAt(start of "Measurement Period") < 20

define "Stratification 2":
  AgeInYearsAt(start of "Measurement Period") >= 20
    and AgeInYearsAt(start of "Measurement Period") < 24

/*
Example 08
Use of age for stratification (2nd example) 
CMS137

Initial Population =
  AND: Age>= 13 year(s) at: "Measurement Period"

Stratifications =
  Stratification 1 =
    AND: Age>= 13 year(s) at: "Measurement Period"
    AND: Age< 18 year(s) at: "Measurement Period"
Stratification 2 =
  AND: Age>= 18 year(s) at: "Measurement Period"
*/

define "In Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 13

define "Stratification 1":
  AgeInYearsAt(start of "Measurement Period") >= 13
    and AgeInYearsAt(start of "Measurement Period") < 18

define "Stratification 2":
  AgeInYearsAt(start of "Measurement Period") >= 18

/*
Example 09
Use of age for stratification (3rd example)
CMS74

Initial Population =
  AND: Age >= 0 year(s) at: "Measurement Period"
  AND: Age < 20 year(s) at: "Measurement Period"

Stratifications =
  Stratification 1 =
    AND: Age >= 0 year(s) at: "Measurement Period"
    AND: Age <= 4 year(s) at: "Measurement Period"
  Stratification 2 =
    AND: Age >= 5 year(s) at: "Measurement Period"
    AND: Age <= 11 year(s) at: "Measurement Period"
  Stratification 3 =
    AND: Age >= 12 year(s) at: "Measurement Period"
    AND: Age < 20 year(s) at: "Measurement Period"
*/

define "In Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 0
    and AgeInYearsAt(start of "Measurement Period") < 20

define "Stratification 1":
  AgeInYearsAt(start of "Measurement Period") >= 0
    and AgeInYearsAt(start of "Measurement Period") <= 4

define "Stratification 2":
  AgeInYearsAt(start of "Measurement Period") >= 5
    and AgeInYearsAt(start of "Measurement Period") <= 11

define "Stratification 3":
  AgeInYearsAt(start of "Measurement Period") >= 12
    and AgeInYearsAt(start of "Measurement Period") < 20

/*
Example 10
Identifying Birth Date (1st example)
CMS117

Initial Population =
  AND: "Birthdate : Patient Characteristic Birthdate" >= 1 year(s) starts before start of "Measurement Period"
  AND: "Birthdate : Patient Characteristic Birthdate" = 2 year(s) starts before end of "Measurement Period"
Numerator =
  OR: Union of:
    "Immunization, Administered: Measles, Mumps and Rubella (MMR) Vaccine"
    "Procedure, Performed: Measles, Mumps and Rubella (MMR) Vaccine Administered"
    <= 730 day(s) ends after start of "Birthdate : Patient Characteristic Birthdate"
*/

define "Birthdate":
  ["Birthdate": "Patient Characteristic Birthdate"]

define "In Initial Population":
  CalculateAgeInYearsAt("Birthdate", start of "Measurement Period") >= 1
    and CalculateAgeInYearsAt("Birthdate", end of "Measurement Period") = 2

define "In Numerator":
  exists (
    ["Immunization, Administered": "Measles, Mumps and Rubella (MMR) Vaccine"] MMRVaccine
      where MMRVacine.stopDateTime 730 days or less after "Birthdate"
  )
    or exists (
        ["Procedure, Performed": "Measles, Mumps and Rubella (MMR) Vaccine Administered"] MMRProcedure
            where MMRProcedure.stopDateTime 730 days or less after "Birthdate"
    )

/*
Example 11
Identifying Birth Date (2nd example)
CMS82

Initial Population =
  AND:
    OR: "Birthdate : Patient Characteristic Birthdate" <= 5 month(s) starts before start of "Measurement Period"
    OR:
      AND: "Birthdate : Patient Characteristic Birthdate" starts after start of "Measurement Period"
      AND: "Birthdate : Patient Characteristic Birthdate" >= 6 month(s) starts before end of "Measurement Period"
Numerator =
  AND: Union of:
    "Intervention, Performed: Maternal Post Partum Depression Care"
    "Intervention, Performed: Maternal Post Partum Depression Screening"
    <= 6 month(s) ends after start of "Birthdate : Patient Characteristic Birthdate"
*/

define "Birthdate":
  ["Birthdate": "Patient Characteristic Birthdate"]

define "In Initial Population":
  CalculateAgeInMonths("Birthdate", start of "Measurement Period") <= 5
    or (
      "Birthdate" after start of "Measurement Period"
        and CalculateAgeInMonths("Birthdate", end of "Measurement Period") >= 6
    )

define "In Numerator":
  exists ((
      ["Intervention, Performed": "Maternal Post Partum Depression Care"]
        union ["Intervention, Performed": "Maternal Post Partum Depression Screening"]
    ) Intervention
      where Intervention.stopDateTime 6 months or less after "Birthdate"
  )
