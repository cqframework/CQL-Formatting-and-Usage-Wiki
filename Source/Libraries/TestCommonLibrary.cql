library TestCommonLibrary

using QDM version '5.3'

include MATGlobalCommonFunctions version '2.1.000' called Common

valueset "ICU Admission or Transfer": 'TBD'

//define "Encounter with ICU Location Stay Greater Than Equal 1 day":
//  "Encounter Age and No Diagnosis of VTE or Obstetrics" QualifyingEncounter
//    let Location: Common."Hospitalization Locations"(QualifyingEncounter)
//    where Location.code in "ICU Admission or Transfer"
//      and difference in days between start of Location.locationPeriod and end of Location.locationPeriod >= 1
//      and Location.locationPeriod starts 1 day or less on or after day of start of QualifyingEncounter.relevantPeriod
//      and Location.locationPeriod on or after start of QualifyingEncounter.relevantPeriod

define "Encounter with ICU Location Stay Greater Than Equal 1 day":
  "Encounter Age and No Diagnosis of VTE or Obstetrics" QualifyingEncounter
    with (Common."Hospitalization Locations"(QualifyingEncounter)) Location
      such that Location.code in "ICU Admission or Transfer"
        and difference in days between start of Location.locationPeriod and end of Location.locationPeriod >= 1
        and Location.locationPeriod starts 1 day or less on or after day of start of QualifyingEncounter.relevantPeriod
        and Location.locationPeriod on or after start of QualifyingEncounter.relevantPeriod
        
define "Qualifying Encounter": ["Encounter, Performed"]
define "Encounter Age and No Diagnosis of VTE or Obstetrics": ["Encounter, Performed"]



