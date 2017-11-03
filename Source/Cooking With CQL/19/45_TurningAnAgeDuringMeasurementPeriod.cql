library TurningAnAgeDuringMeasurementPeriod

using QDM version '5.3'

include "Global Common MAT Functions" version '1.0.0' called "Common"

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population":
  AgeInYearsAt(start of "Measurement Period") = 13
    or exists ( ["Patient Characteristic Birthdate": "Birthdate"] Birthdate
      where AgeInYearsAt(start of "Measurement Period") >= 12
        and AgeInYearsAt(end of "Measurement Period") = 13
    )

// The Patient Characteristic retrieves the patient's birthdate, if you need that for calculation
// But the AgeInYearsAt calculation does this automatically, so this can be simplified to:
define "Initial Population":
  Common.CalendarAgeInYearsAt(start of "Measurement Period") = 13
    or (Common.CalendarAgeInYearsAt(start of "Measurement Period") >= 12 and Common.CalendarAgeInYearsAt(end of "MeasurementPeriod") = 13)

// Note that this example is assuming birthdate will be present without a time component.
// To explicitly ignore time, use the CalendarAgeInYearsAt function.
 