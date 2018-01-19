library SecondTylenolDuringAnEncounter

using QDM version '5.3'

valueset "Tylenol": 'urn:oid:1.2.3.4.5'
valueset "Inpatient": 'urn:oid:1.2.3.4.5'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Inpatient Encounter":
  ["Encounter, Performed": "Inpatient"] Encounter
    where Encounter.relevantPeriod during "Measurement Period"
    
define "Tylenol Administration":
  ["Medication, Administered": "Tylenol"] Medication
    where Medication.relevantPeriod during "Measurement Period"

// This returns a list of Tylenol Administrations that are the second Tylenol Administration
// During the Encounter  
define "Second Tylenol Administration":
  "Inpatient Encounter" Encounter
    return ("Tylenol Administration" Administration
        where Administration.relevantPeriod during Encounter.relevantPeriod)[1]

// To return Encounters together with the second Tylenol Administration during that encounter
define "Encounter with Second Tylenol Administration":
  "Inpatient Encounter" Encounter
    let SecondAdministration:
      ("Tylenol Administration" Administration
        where Administration.relevantPeriod during Encounter.relevantPeriod)[1]
    return { Encounter: Encounter, SecondAdministration: SecondAdministration }

// This returns a row for each Encounter with two element:
// { Encounter "Encounter, Performed", SecondAdministration "Medication, Administered" }

// Note that the SecondAdministration element will be null if there is no second administration during the encounter

