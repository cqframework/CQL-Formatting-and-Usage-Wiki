library TestOnART

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

codesystem ARTCodes: 'http://example.org/fhir/CodeSystem/art-codes'

valueset "On ART": 'http://example.org/fhir/ValueSet/on-art'

//code "On ART": 'on-art' from ARTCodes

parameter "Measurement Period" Interval<DateTime>

// Initial query:
/*
define "Stopped ART at Facility during the measurement period":
  [EpisodeOfCare] EOS
    where EOS.type.coding.code.value ~ { 'On ART' }
      and (exists ({
        EOS.statusHistory.status contains 'finished'
          and EOS.statusHistory.period ends after start of "Measurement Period"
          and EOS.statusHistory[0].period ends before end of "Measurement Period"
})
*/

// Corrected Query
define "Stopped ART at Facility during the measurement period":
  [EpisodeOfCare] EOS
    where EOS.type in "On ART"
      and exists (EOS.statusHistory H
         where H.status = 'finished'
           and H.period ends during "Measurement Period"
      )


