library PatientLinksUnfiltered

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

context Unfiltered

define AllPatientProcedures:
  from [Patient] P, [Procedure] PR
    where PR.subject = P.reference()
      or PR.subject in (P.link L where L.type = 'seealso' return L.other)
