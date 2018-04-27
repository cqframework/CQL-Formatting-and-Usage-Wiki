library ClaimQuery

using FHIR version '3.0.0'

include FHIRHelpers version '3.0.0'

valueset "Dx Cholesterol Embolism": 'urn:oid:1.2.3.4.5'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Lookback Interval Total One Year": 
  Interval[start of "Measurement Period" - 1 year, start of "Measurement Period")

/* We are trying to construct a CQL expression that allows the following:

    Get all Claims where 
        There was a service performed during the last year, and such a service 
        is associated to a diagnosis code that is in the the value set "Dx Cholesterol Embolism”.

*/

/*
In FHIR, a claim may contain multiple services (items) that may be associated to 
1 or more diagnosis codes via Claim.item.diagnosisLinkId. To solve the query above, 
we are trying to write something like this:
*/

define "Evidence of Diagnosis 1":
     [Claim] C
   with C.diagnosis D such that D.diagnosis in "Dx Cholesterol Embolism"
     with C.item I such that I.serviced during "Lookback Interval Total One Year"
 where D.sequence = I.diagnosisLinkId 
 
/*
Because there are potentially multiple diagnoses linked to each item, this needs
to be done with an exists:
*/

define "Evidence of Diagnosis 1":
  [Claim] C
    with C.item I such that I.serviced during "Lookback Interval Total One Year"
      and exists (
        C.diagnosis D 
          where D.sequence in I.diagnosisLinkId
            and D.diagnosis in "Dx Cholesterol Embolism"
      )
