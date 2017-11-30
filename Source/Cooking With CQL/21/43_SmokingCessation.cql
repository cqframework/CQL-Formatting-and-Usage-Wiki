library SmokingCessation

using QDM version '5.3'

codesystem "LOINC": 'http://loinc.org'

valueset "Inpatient Encounter": '1.2.3.4'

code "Date quit tobacco smoking": '74010-0' from "LOINC" display 'Date quit tobacco smoking'

context Patient

define "Quit Date":
  Max(["Assessment, Performed": "Date quit tobacco smoking"] Quit
    return Quit.result as DateTime
  )
  
define "Encounter with Quit Date":
  ["Encounter, Performed": "Inpatient Encounter"] Encounter
    where "Quit Date" more than 30 days before start of Encounter.relevantPeriod

