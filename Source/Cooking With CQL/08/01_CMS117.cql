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
