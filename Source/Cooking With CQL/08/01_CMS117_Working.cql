// Numerator with Immunization and various timings (CMS117)

library CMS117

using QDM version '5.0'

valueset "DTaP Vaccine": 'DTaP Vaccine'
valueset "DTaP Vaccine Administered": 'DTaP Vaccine Administered'
valueset "Anaphylactic Reaction to DTaP Vaccine": 'Anaphylactic Reaction to DTaP Vaccine'
valueset "Encephalopathy due to Childhood Vaccination": 'Encephalopathy due to Childhood Vaccination'

parameter "Measurement Period" Interval<DateTime>

/*
Numerator =
  AND: Union of:
    "Immunization, Administered: DTaP Vaccine" satisfies all:
      >= 1 day(s) starts after end of (
        "Immunization, Administered: DTaP Vaccine" >= 1 day(s) starts after end of (
          "Immunization, Administered: DTaP Vaccine" >= 1 day(s) starts after end of (
            "Immunization, Administered: DTaP Vaccine" >= 42 day(s) ends after start of
              "Birthdate : Patient Characteristic Birthdate"
            )
          )
        )
      <= 730 day(s) ends after start of "Birthdate : Patient Characteristic Birthdate"
    "Procedure, Performed: DTaP Vaccine Administered" satisfies all:
      >= 1 day(s) starts after end of (
        "Procedure, Performed: DTaP Vaccine Administered" >= 1 day(s) starts after end of (
          "Procedure, Performed: DTaP Vaccine Administered" >= 1 day(s) starts after end of (
            "Procedure, Performed: DTaP Vaccine Administered" >= 42 day(s) ends after start of
              "Birthdate : Patient Characteristic Birthdate"
            )
          )
        )
      <= 730 day(s) ends after start of "Birthdate : Patient Characteristic Birthdate"
    Union of:
      "Diagnosis: Anaphylactic Reaction to DTaP Vaccine"
      "Diagnosis: Encephalopathy due to Childhood Vaccination"
      <= 730 day(s) starts after start of "Birthdate : Patient Characteristic Birthdate"
*/

// Literal translation
// NOTE: This would need to be duplicated for the Procedure just like the QDM
define "DTaP Vaccines":
  ["Immunization, Administered": "DTaP Vaccine"] DTaPVaccine1
    with (
        ["Immunization, Administered": "DTaP Vaccine"] DTaPVaccine3
          with (
              ["Immunization, Administered": "DTaP Vaccine"] DTaPVaccine5
                with (
                    ["Immunization, Administered": "DTaP Vaccine"] DTaPVaccine7
                      with ["Patient Characteristic Birthdate"] Birthdate
                        such that DTaPVaccine7.authorDatetime 42 days or more after Birthdate.birthDatetime
                ) DTaPVaccine6
                  such that DTaPVaccine5.authorDatetime 1 day or more after DTaPVaccine6.authorDatetime
          ) DTaPVaccine4
            such that DTaPVaccine3.authorDatetime 1 day or more after DTaPVaccine4.authorDatetime
    ) DTaPVaccine2
      such that DTaPVaccine1.authorDatetime 1 day or more after DTaPVaccine2.authorDatetime

// Translation using expressions to make the logic more clear:
define "First DTaP Vaccine":
  ["Immunization, Administered": "DTaP Vaccine"] Vaccine
    with ["Patient Characteristic Birthdate"] Birthdate
      such that Vaccine.authorDatetime 42 days or more after Birthdate.birthDatetime

define "Second DTaP Vaccine":
  ["Immunization, Administered": "DTaP Vaccine"] Vaccine
    with "First DTaP Vaccine" FirstVaccine
      such that Vaccine.authorDatetime 1 day or more after FirstVaccine.authorDatetime

define "Third DTaP Vaccine":
  ["Immunization, Administered": "DTaP Vaccine"] Vaccine
    with "Second DTaP Vaccine" SecondVaccine
      such that Vaccine.authorDatetime 1 day or more after SecondVaccine.authorDatetime

define "Fourth DTaP Vaccine":
  ["Immunization, Administered": "DTaP Vaccine"] Vaccine
    with "Third DTaP Vaccine" ThirdVaccine
      such that Vaccine.authorDatetime 1 day or more after ThirdVaccine.authorDatetime

define "DTaP Vaccines":
  "Fourth DTaP Vaccine" Vaccine
    with ["Patient Characteristic Birthdate"] Birthdate
      such that Vaccine.authorDatetime 730 days or less after Birthdate.birthDatetime

// NOTE: The logic is looking for 4 Administrations, or 4 Procedures, but what if some of the
// vaccinations are recorded as administrations, and some are recorded as procedures?
// The following approach solves that problem:
define "DTaP Immunization or Procedure":
  distinct (
    ["Immunization, Administered": "DTaP Vaccine"] Vaccine
      union (
        ["Procedure, Performed": "DTaP Vaccine Administered"] Procedure
          return "Immunization, Administered" {
            authorDatetime: start of Procedure.relevantPeriod,
            reason: Procedure.reason,
            negationRationale: Procedure.negationRationale
          }
      )
  )

define "First DTaP Vaccine":
  "DTaP Immunization or Procedure" Vaccine
    with ["Patient Characteristic Birthdate"] Birthdate
      such that Vaccine.authorDatetime 42 days or more after Birthdate.birthDatetime

define "Second DTaP Vaccine":
  "DTaP Immunization or Procedure" Vaccine
    with "First DTaP Vaccine" FirstVaccine
      such that Vaccine.authorDatetime 1 day or more after FirstVaccine.authorDatetime

define "Third DTaP Vaccine":
  "DTaP Immunization or Procedure" Vaccine
    with "Second DTaP Vaccine" SecondVaccine
      such that Vaccine.authorDatetime 1 day or more after SecondVaccine.authorDatetime

define "Fourth DTaP Vaccine":
  "DTaP Immunization or Procedure" Vaccine
    with "Third DTaP Vaccine" ThirdVaccine
      such that Vaccine.authorDatetime 1 day or more after ThirdVaccine.authorDatetime

define "DTaP Vaccines":
  "Fourth DTaP Vaccine" Vaccine
    with ["Patient Characteristic Birthdate"] Birthdate
      such that Vaccine.authorDatetime 730 days or less after Birthdate.birthDatetime

// Another possibility is to use a from to express all the possible combinations
define "DTaP Immunization or Procedure":
  distinct (
    ["Immunization, Administered": "DTaP Vaccine"] Vaccine
      union (
        ["Procedure, Performed": "DTaP Vaccine Administered"] Procedure
          return "Immunization, Administered" {
            authorDatetime: start of Procedure.relevantPeriod,
            reason: Procedure.reason,
            negationRationale: Procedure.negationRationale
          }
      )
  )

define "DTaP Vaccines":
  from
    "DTaP Immunization or Procedure" Vaccine1,
    "DTaP Immunization or Procedure" Vaccine2,
    "DTaP Immunization or Procedure" Vaccine3,
    "DTaP Immunization or Procedure" Vaccine4,
    ["Patient Characteristic Birthdate"] Birthdate
  where Vaccine1.authorDatetime 42 days or more after Birthdate.birthDatetime
    and Vaccine2.authorDatetime 1 day or more after Vaccine1.authorDatetime
    and Vaccine3.authorDatetime 1 day or more after Vaccine2.authorDatetime
    and Vaccine4.authorDatetime 1 day or more after Vaccine3.authorDatetime
    and Vaccine4.authorDatetime 730 days or less after Birthdate.birthDatetime
  return Vaccine4
