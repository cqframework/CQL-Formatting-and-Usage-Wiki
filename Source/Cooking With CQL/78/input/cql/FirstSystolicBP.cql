library FirstSystolicBP

using QICore version '4.1.1'

include FHIRHelpers version '4.3.000'
include QICoreCommon version '1.5.000'
include CQMCommon version '1.4.000'

valueset "Inpatient": '...'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Inpatient Encounters":
  [Encounter: Inpatient] Encounter
    where Encounter.period starts during "Measurement Period"

define "Encounter with First Systolic Blood Pressure":
    "Inpatient Encounters" EncounterInpatient
    let FirstSystolicBP: 
        First(["observation-bp"] SystolicBP
            where SystolicBP.effective.earliest() during Interval[start of EncounterInpatient.period - 1440 minutes, start of EncounterInpatient.period + 120 minutes] 
                and SystolicBP.status in {'final', 'amended', 'corrected'}
                and SystolicBP.value is not null
            sort by effective.earliest() 
        )
    return {
        EncounterId: EncounterInpatient.id,
        FirstSystolicResult: FirstSystolicBP.SystolicBP.value as Quantity,
        Timing: FirstSystolicBP.effective.earliest()
    }
