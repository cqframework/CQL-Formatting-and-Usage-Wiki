library CQLIT448

using QICore version '4.1.1'

codesystem ExampleCodeSystem: 'http://example.org/fhir/CodeSystem/example'

valueset "Status Post Right Mastectomy": 'http://example.org/fhir/ValueSet/status-post-right-mastectomy'
valueset "Unilateral Mastectomy, Unspecified Laterality": 'http://example.org/fhir/ValueSet/unilateral-mastectomy-unspecified-laterality'

code "Right (qualifier value)": 'Right (qualifier value)' from ExampleCodeSystem

context Patient

define "Right Mastectomy Diagnosis With Qualifier":
  ["Condition": "Unilateral Mastectomy, Unspecified Laterality"] UnilateralMastectomyDiagnosis
    where "Right (qualifier value)" in UnilateralMastectomyDiagnosis.bodySite

define "Right Mastectomy Diagnosis With Terminology Comparison":
  ["Condition": "Unilateral Mastectomy, Unspecified Laterality"] UnilateralMastectomyDiagnosis
    where exists (
      UnilateralMastectomyDiagnosis.bodySite BodySite
        where BodySite ~ "Right (qualifier value)"
    )
