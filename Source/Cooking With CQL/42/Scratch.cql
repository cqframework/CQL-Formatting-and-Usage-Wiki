library Scratch

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0'

valueset MedValueSet: 'TBD'
valueset X: 'TBD'

context Patient

/* Approaches to supporting references */

/*
  Option 1 uses existing syntax and related context retrieve functionality
    No grammar change
    Minimal implementation impact
*/
define Option1:
  [MedicationRequest] MR
    let M: singleton from ([MR.medication -> Medication])
    where M.code in MedValueSet

/* Option 2 is another way this same approach might appear */
define Option2:
  [MedicationRequest] MR
    with [MR.medication -> Medication] M
      such that M.code in MedValueSet

/*
  Option 3 introduces a short-hand syntax (->) for related-context retrieves
    Minor grammar change, but the translator would expand this to Option 1 in the ELM
*/
define Option3:
  [MedicationRequest] MR
    where MR.medication->code in MedValueSet

/*
  Option 4 implements references in the modelinfo/translator
    Most concise from the authoring standpoint
    No language change
    Requires the Retrieve to support "include" parameters
*/
define Option4:
  [MedicationRequest] MR
    where MR.medication.code in MedValueSet


/*
Search Parameters (IndexInfo in ModelInfo)
*/

define Example1:
  [Observation: "component-code" in X]

define Example1ExpandsTo:
  [Observation] O
    where exists (O.component C where C.code in X)
      and O.value <%:operation%> <%:observationValue%>

define Example2:
  [MedicationRequest: medication in X]

define Example2ExpandsTo:
  [MedicationRequest] MR
    with [M.medication->Medication] M where M.code in X


/*
Worsening Atherosclerosis Conditions
*/

define function SeverityRating(severity FHIR.CodeableConcept):
  case
    when severity ~ "Severe" then 3
    when severity ~ "Moderate" then 2
    when severity ~ "Mild" then 1
    else null
  end

define "Worsening Atherosclerosis Conditions":
  from
    "Atherosclerosis Conditions" A,
    "Atherosclerosis Conditions" B
  where NormalizeOnset(A.onset) starts after start of NormalizeOnset(B.onset)
    and SeverityRating(A.severity) > SeverityRating(B.severity)
  return A

define "Worsening Atherosclerosis Conditions":
  "Atherosclerosis Conditions" A
    where exists ("Atherosclerosis Conditions" B
      where NormalizeOnset(A.onset) starts after start of NormalizeOnset(B.onset)
        and SeverityRating(A.severity) > SeverityRating(B.severity)
    )

/*
Note that this is actually probably not right, in that there wouldn't in general
be multiple conditions, there be one condition whose status changed over time,
so this would actually need to be a historical query.
*/
