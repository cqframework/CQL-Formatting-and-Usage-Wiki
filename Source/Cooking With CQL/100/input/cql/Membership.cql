library Membership

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

parameter "Measurement Period" Interval<Date>
parameter Provider String
parameter ModalityCode String

context Patient

define "Membership Criteria":
  Patient.ageInYears() >= 18
    and exists ([Encounter: Inpatient] E where E.period starts 1 year on or before Today())

define "Has Imaging Studies With Modality":
  exists ([ImagingStudy: modality ~ ModalityCode])

define "Well-Formed Expression":
  [Encounter] E
    where E.status = 'active'
      or (E.status = 'completed' and E.period.start same day or after @2026-01-01)

define "Non Well-Formed Expression":
  [Encounter] E
    where E.status = 'active'
      or (
        E.status = 'completed'
          and (
            E.period.start same day or after @2026-01-01
              or E.meta.lastUpdated same day or after @2026-01-01
          )
      )

define "Custom Search Parameter Use":
  [ImagingStudy: manufacturer ~ 'Canon Medical Systems']

define "Attribution Criteria":
  exists (
    [Encounter: Inpatient] E
      where E.period ends during "Measurement Period"
        and E.serviceProvider.references(Provider)
  )


