This page documents the addition of a proposed Claims Patterns page to the US CQL IG.

Claim data in FHIR is represented with the [Claim](http://hl7.org/fhir/R4/claim.html) and [ExplanationOfBenefit](http://hl7.org/fhir/R4/explanationofbenefit.html) resources.

The Claim resource represents a claim for a product or service provided from the provider perspective, whereas the ExplanationOfBenefit resource represents an adjudicated claim from the payer perspective.

> NOTE: US Core does not define profiles for either of these resources. QI-Core defines a Claim profile to represent the claim for a service from the provider perspective, and CARIN BlueButton defines ExplanationOfBenefit profiles to represent adjudicated claims from the payer perspective. The content here treats these resources from the base FHIR perspective.

### Modifier Elements

The Claim resource defines the following modifier elements:

* status

The ExplanationOfBenefit resource defines the following modifier elements:

* status

In addition to being modifiers, the `status` elements of these resources are required with a required binding.

### Search Parameters

The base FHIR specification defines multiple search parameters for both of these resources; feedback is sought on which of the defined search parameters are likely to be available.

> NOTE: For discussion on how to manage search parameters with terminology, see the [Terminology Considerations](architectural-guidance.html#terminology-considerations) discussion in the Architectural Guidance topic.

> NOTE: For discussion on how to manage optional search parameters, see the [Performant Data Access](architectural-guidance.html#performant-data-access) discussion in the Architectural Guidance topic.

### Cross-Version Considerations

Not applicable

### Common Elements and Functions

#### Status, Use, and Type

```cql
define fluent function isProfessional(claim Claim):
  claim.type ~ "professional"

define fluent function isInstitutional(claim Claim):
  claim.type ~ "institutional"

define fluent function isActcive(claim Claim):
  claim.status = 'active'

define fluent function isClaim(claim Claim):
  claim.use = 'claim'

define fluent function isProfessional(eob ExplanationOfBenefit):
  claim.type ~ "professional"

define fluent function isInstitutional(eob ExplanationOfBenefit):
  claim.type ~ "institutional"

define fluent function isActcive(eob ExplanationOfBenefit):
  claim.status = 'active'

define fluent function isClaim(eob ExplanationOfBenefit):
  claim.use = 'claim'
```

#### Principal Diagnosis

```cql
/*
@description: Returns the claim diagnosis elements for the given encounter
@comment: See the QICore 6 Authoring Patterns discussion on [Principal Diagnosis and Present on Admission](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns-QICore-v6.0.0#conditions-present-on-admission-and-principal-diagnoses) for more information
*/
define fluent function claimDiagnosis(encounter Encounter):
  encounter E
    let 
      claim: ([Claim] C where C.status = 'active' and C.use = 'claim' and exists (C.item I where I.encounter.references(E))),
      claimItem: (claim.item I where I.encounter.references(E))
    return claim.diagnosis D where D.sequence in claimItem.diagnosisSequence
```

```cql
/*
@description: Returns the claim diagnosis element that is specified as the principal diagnosis for the encounter
 @comment: See the QICore 6 Authoring Patterns discussion on [Principal Diagnosis and Present on Admission](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns-QICore-v6.0.0#conditions-present-on-admission-and-principal-diagnoses) for more information
*/
define fluent function principalDiagnosis(encounter Encounter):
singleton from (
     (encounter.claimDiagnosis()) CD
       where CD.type.includesCode("Principal Diagnosis")
   )
```

```cql
/*
 @description: Returns the condition that is specified as the principal diagnosis for the encounter and has a code in the given valueSet.
 @comment: See the QICore 6 Authoring Patterns discussion on [Principal Diagnosis and Present on Admission](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns-QICore-v6.0.0#conditions-present-on-admission-and-principal-diagnoses) for more information
 */
 define fluent function hasPrincipalDiagnosisOf(encounter Encounter, valueSet ValueSet):
   (encounter.principalDiagnosis()) PD
     return PD.diagnosis in valueSet
       or PD.diagnosis.getCondition().code in valueSet
```

```cql
define "Encounter With Principal Diagnosis Of Asthma":
  [Encounter] E
    where E.hasPrincipalDiagnosisOf("Asthma")
```

#### Present On Admission

```cql
/*
 @description: Returns true if the given diagnosis is present on admission, based on the given poaValueSet
 @comment: See the QICore 6 Authoring Patterns discussion on [Principal Diagnosis and Present on Admission](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns-QICore-v6.0.0#conditions-present-on-admission-and-principal-diagnoses) for more information
 */
 define fluent function isDiagnosisPresentOnAdmission(encounter Encounter, diagnosisValueSet ValueSet, poaValueSet ValueSet):
   exists (
     (encounter.claimDiagnosis()) CD
       where CD.onAdmission in poaValueSet
         and (
           CD.diagnosis in diagnosisValueSet
             or CD.diagnosis.getCondition().code in diagnosisValueSet
         )
   )
```

```cql
define "Encounter With Asthma Present On Admission":
  [Encounter] E
    where E.isDiagnosisPresentOnAdmission("Asthma", "Present On Admission Indicators")
```

#### Principal Procedure

```cql
/*
@description: Returns the claim procedure elements for the given encounter
*/
define fluent function principalProcedure(encounter Encounter):  	  
  	 encounter E
  	 let 
        claim: [Claim] C where C.status = 'active' and C.use = 'claim' and exists (C.item I where I.encounter.references(E)),
        claimItem: claim.item I where I.encounter.references(E),
        princProcedure: singleton from (claim.procedure P where P.sequence in claimItem.procedureSequence and P.type.includesCode("Primary procedure"))
    return princProcedure

define fluent function hasPrincipalProcedureOf(encounter Encounter, procedureValueSet ValueSet):
   encounter E
   let
        PPx: E.principalProcedure(),
        CPx: singleton from ([Procedure] P where PPx.procedure.references(P.id))
     return PPx.procedure in procedureValueSet
       or CPx.code in procedureValueSet
```

```cql
define "Encounters With Principal Procedure of General Surgery":
  [Encounter] E
    where E.hasPrincipalProcedureOf("General Surgery")
```

#### Claim Items

```cql
define "Claim Item":
  [Claim] C
    where C.isActive()
      and C.isClaim()
      and (C.isInstitutional() or C.isProfessional())
    return C.item
```

#### EoB Items

```cql
define "EoB Item":
  [ExplanationOfBenefit] E
    where E.isActive()
      and E.isClaim()
      and (E.isInstitutional() or E.isProfessional())
    return E.item
```

> NOTE: Content for this page was adapted from the [QICore Authoring Patterns - ](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Patterns-QICore-v6.0.0#procedures) topic as well as the [Cooking with CQL Session 90 - Claim Diagnosis and Principal Procedure](https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/blob/master/Source/Cooking%20With%20CQL/90/03-ClaimDiagnosisAndPrincipalProcedure.md) topic.


> These changes are proposed for inclusion in the US CQL IG: (https://jira.hl7.org/browse/FHIR-53461)