library TestHIVAssay

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

valueset "Assay 1": 'http://example.org/fhir/ValueSet/assay-1'
valueset "Assay 2": 'http://example.org/fhir/ValueSet/assay-2'
valueset "HIV Diagnostic Tests": 'http://example.org/fhir/ValueSet/hiv-diagnostic-tests' // Include the Rapid diagnostic test for HIV and Enzyme immunoassay for HIV codes in this value set
valueset "Reactive": 'http://example.org/fhir/ValueSet/reactive'
valueset "Non-reactive": 'http://example.org/fhir/ValueSet/non-reactive'

context Patient

/*
Initial queries:
//triggeredBy ~ order for Assay 1
define "Continue with performing HIV 'Assay 2'":
[Observation] O
with [O.basedOn -> ServiceRequest] SR
such that (SR.code in {"Assay 1"})
where (O.status in { 'final', 'amended' }
and O.code in { "Rapid diagnostic test for HIV", "Enzyme immunoassay for HIV" }
and O.value in { "Reactive" }
and "Age_greater_than_18_months")
// Output Service Request for Assay 2 
*/

/*
@description: Indicates whether to output Service Request for Assay 2 
@triggeredBy: Order for Assay 1
*/
define "Should Continue With Performing HIV Assay 2":
  [Observation: "HIV Diagnostic Tests"] O
    with [ServiceRequest: "Assay 1"] SR
      such that O.basedOn.references(SR)
    where O.status in { 'final', 'amended' }
      and O.value in "Reactive"
      and AgeInMonths() > 18


/*
//triggeredBy ~ "Continue with performing HIV 'Assay 2'"
define "Continue with performing HIV 'Assay 1 repeated'":
[Observation] O
with [O.basedOn -> ServiceRequest] SR
such that (SR.reasonCode in "Assay 1 reactive" and
SR.code in {"Assay 2"})
where (O.status in { 'final', 'amended' }
and O.code in { "Rapid diagnostic test for HIV", "Enzyme immunoassay for HIV" }
and O.value in { "Non-reactive" }
and "Age_greater_than_18_months")
// Output Service Request for Continue with performing HIV 'Assay 1 repeated' 
*/

/*
@description: Indicates whether to output a Service Request for Assay 1
@triggeredBy: Order for Assay 2
*/
define "Continue With Performing HIV 'Assay 1 repeated'":
  [Observation: "HIV Diagnostic Tests"] O
    with [ServiceRequest: "Assay 2"] SR
      such that O.basedOn.references(SR)
  where O.status in { 'final', 'amended' }
    and O.value in "Non-reactive"
    and AgeInMonths() > 18

// Helper functions, candidates for inclusion in FHIRCommon
define fluent function references(reference FHIR.Reference, resource FHIR.Resource):
  resource.id = Last(Split(reference.reference, '/'))  

define fluent function references(references List<FHIR.Reference>, resource FHIR.Resource):
  exists (references R where R.references(resource))

