library EncounterTest

using QICore version '4.1.1'

include FHIRHelpers version '4.2.000'

codesystem "Concept Codes": 'http://example.org/fhir/CodeSystem/concept-codes'

valueset "Inpatient Encounters": 'http://hl7.org/fhir/ValueSet/inpatient-encounters'

code "Inpatient": 'inpatient' from "Concept Codes"

context Patient

/*
[CQLIT-368](https://oncprojectracking.healthit.gov/support/browse/CQLIT-368)
[Translator Issue #1181](https://github.com/cqframework/clinical_quality_language/issues/1181)
[Encounter Authoring Patterns](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns---QICore-v4.1.1#accessing-encounters-with-a-direct-reference-code)
*/

define "Encounters By ValueSet":
  ["Encounter": "Inpatient Encounters"]

define "Encounters By Code":
  ["Encounter": "Inpatient"]

define "Encounters Except":
  ["Encounter": "Inpatient Encounters"] E
    where case
      when exists ((E.type) T where T ~ "Inpatient") then getThreshold(E) > 10
      else getThreshold(E) > 15
    end

define function getThreshold(encounter Encounter): 1

define "Office Visit Encounters By Code Alternate (Anti-pattern)":
  [Encounter] E
    where "Inpatient" in E.type

// Don't use this approach because it will resolve as a List in, not a terminology in