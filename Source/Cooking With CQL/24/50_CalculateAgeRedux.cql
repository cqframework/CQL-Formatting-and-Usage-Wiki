library CalculateAgeRedux

using QDM version '5.3'

parameter "Measurement Period" Interval<DateTime>

context Patient

// There are two different ways to access the birthDate of a patient with CQL and QDM

// 1) Using the Patient Characteristic Birthdate:

["Patient Characteristic Birthdate"] BirthDate 
  where Global.CalendarAgeInYearsAt(BirthDate.birthDatetime, start of "Measurement Period") >= 2

// 2) Using the Patient.birthDatetime attribute:

Global.CalendarAgeInYearsAt(Patient.birthDatetime, start of "Measurement Period")

// When relating birthdate to another source using a with, Patient Characteristic is reasonable, though still a bit more verbose:

"Inpatient Encounter" Encounter
  with ["Patient Characteristic Birthdate"] BirthDate
    where Global.CalendarAgeInYearsAt(BirthDate.birthDatetime, start of Encounter.relevantPeriod) >= 2
    
"Inpatient Encounter" Encounter
  where Global.CalendarAgeInYearsAt(Patient.birthDatetime, start of Encounter.relevantPeriod) >= 2

// When referencing Patient Characteristic Birthdate in the initial population of a Patient-Based measure, it requires an exists:

define "Initial Population":
  exists (
    ["Patient Characteristic Birthdate"] BirthDate
      where Global.CalendarAgeInYearsAt(BirthDate.birthDatetime, start of "Measurement Period")
  )
  
// Could be simplified to:
define "Initial Population":
  Global.CalendarAgeInYearsAt(Patient.birthDatetime, start of "Measurement Period")
  
