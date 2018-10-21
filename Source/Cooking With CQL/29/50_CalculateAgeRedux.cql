library CalculateAgeRedux

using QDM version '5.3'

parameter "Measurement Period" Interval<DateTime>

context Patient

// There are two different ways to access the birthDate of a patient with CQL and QDM

// 1) Using the Patient Characteristic Birthdate:

["Patient Characteristic Birthdate"] BirthDate 
  where Global.CalendarAgeInYearsAt(BirthDate.birthDatetime, start of "Measurement Period") >= 2
	
// 2) Using the Patient.birthDatetime attribute:

Global.CalendarAgeInYearsAt(Patient.birthDatetime, start of "Measurement Period") >= 2

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
      where Global.CalendarAgeInYearsAt(BirthDate.birthDatetime, start of "Measurement Period") >= 2
  )
  
// Could be simplified to:
define "Initial Population":
  Global.CalendarAgeInYearsAt(Patient.birthDatetime, start of "Measurement Period") >= 2
  
// Note that the reason for the Global.CalendarAgeInYearsAt function is to ensure that time is not considered.
// As of CQL 1.3, because CQL has a Date type, the AgeInYearsAt function now ignores time if it is present for the patient
// As a result, patient age calculations can all be simplified:

"Inpatient Encounter" Encounter
  where AgeInYearsAt(start of Encounter.relevantPeriod) >= 2
	
define "Initial Population": AgeInYearsAt(start of Encounter.relevantPeriod) >= 2

