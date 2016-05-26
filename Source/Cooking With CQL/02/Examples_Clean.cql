/*
Example 01
Unbounded upper age range tied to Measurement Period
CMS132
Initial Population =
  AND: Age>= 18 year(s) at: "Measurement Period"
*/

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

/*
Example 03
Bounded age range tied to Measurement Period
CMS122
Initial Population =
  AND: Age>= 18 year(s) at: "Measurement Period"
  AND: Age< 75 year(s) at: "Measurement Period"
*/

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
