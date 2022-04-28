library Example01

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2019-01-01T00:00:00.0, @2020-01-01T00:00:00.0)

context Patient

/**
 * @description: Returns finished encounters in the "Office Visit" value set
 * during the measurement period
 */
define "Qualifying Encounters":
  [Encounter: "Office Visit"] ValidEncounter
    where ValidEncounter.status  = 'finished'
      and ValidEncounter.period during "Measurement Period"
