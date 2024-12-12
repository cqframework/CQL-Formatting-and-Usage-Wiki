This topic discusses accessing Claim information to determine some key diagnosis-related concepts used in quality measurement:

* Present on admission
* Principal diagnosis

In QICore STU 6, the [Claim](https://hl7.org/fhir/us/qicore/StructureDefinition-qicore-claim.html) profile was introduced to more accurately represent the diagnosis-related concepts of "present on admission" and "principal diagnosis", because those concepts are more reliably determined from claim-based information.

When looking for diagnoses on a claim, the first thing to do is identify the claims that are related to a particular encounter.

Reviewing the Claim resource from the perspective of accessing measurement-relevant information, it consists of:

* Claim-level information such as identifiers, patient-relationship, insurance relationships, and overall status and use
* Pertinent diagnosis information
* Pertinent procedure information
* Claim items (i.e. a list of the service items on the claim and their relationship to encounters, diagnoses, and procedures, potentially with detail and sub-detail)

Generally, the items on the claim are related to pertinent diagnosis and procedure information through `sequence` references:

* `item.diagnosisSequence` - a reference to the `Claim.diagnosis.sequence` element
* `item.procedureSequence` - a reference to the `Claim.procedure.sequence` element

And the items on the claim are related to the pertinent encounters through the `item.encounter` element.

Starting from Claim, the first step is to retrieve any Claim resources related to the Patient, and make sure that they are active, valid Claims:

```cql
define "Patient Claim":
  [Claim] C
    where C.status = 'active'
      and C.use = 'claim'
```

Starting from an Encounter then, the next step is to retrieve any Patient Claims that reference the encounter

```cql
define "Encounter With Claim":
  [Encounter] E
    let
      claim: ("Patient Claim" C where exists (C.item I where I.encounter.references(E)))
```

Note the use of the `references` function:

```cql
/*
@description: Returns true if the given reference is to the given resource
@comment: Returns true if the `id` element of the given resource exactly equals the tail of the given reference.
NOTE: This function assumes resources from the same source server.
*/
define fluent function references(reference FHIR.Reference, resource FHIR.Resource):
  resource.id = Last(Split(reference.reference, '/'))  
```

Next, we identify the specific claim items that refer to this encounter:

```cql
define "Encounter With Claim Item":
  [Encounter] E
    let
      claim: ("Patient Claim" C where exists (C.item I where I.encounter.references(E))),
      claimItem: (claim.item I where I.encounter.references(E))
```

Next, we identify the diagnosis information related to the claim item:

```cql
define "Encounter With Claim Item And Diagnosis":
  [Encounter] E
    let
      claim: ("Patient Claim" C where exists (C.item I where I.encounter.references(E))),
      claimItem: (claim.item I where I.encounter.references(E))
      claimDiagnosis: (claim.diagnosis D where D.sequence in claimItem.diagnosisSequence)
```

We can then filter to diagnosis information as needed:

```cql
define "Encounter With Claim Diagnosis of Asthma":
  [Encounter] E
    let
      claim: ("Patient Claim" C where exists (C.item I where I.encounter.references(E))),
      claimItem: (claim.item I where I.encounter.references(E))
      claimDiagnosis: (claim.diagnosis D where D.sequence in claimItem.diagnosisSequence)
    where claimDiagnosis.diagnosis in "Asthma"
```

#### Present On Admission

```cql
define "Encounter With Asthma Present On Admission":
  [Encounter] E
    let
      claim: ("Patient Claim" C where exists (C.item I where I.encounter.references(E))),
      claimItem: (claim.item I where I.encounter.references(E))
      claimDiagnosis: (claim.diagnosis D where D.sequence in claimItem.diagnosisSequence)
    where claimDiagnosis.diagnosis in "Asthma"
      and claimDiagnosis.onAdmission ~ "POA-Y"
```

Note that the "POA-Y" code is defined as:

```cql
codesystem "Present On Admission Indicators": 'https://www.cms.gov/Medicare/Medicare-Fee-for-Service-Payment/HospitalAcqCond/Coding'

code "POA-Y": 'Y' from "Present On Admission Indicators"
code "POA-N": 'N' from "Present On Admission Indicators"
code "POA-W": 'W' from "Present On Admission Indicators"
code "POA-1": '1' from "Present On Admission Indicators"
```

#### Principal Diagnosis

```cql
define "Encounter With Principal Diagnosis of Asthma":
  [Encounter] E
    let
      claim: ("Patient Claim" C where exists (C.item I where I.encounter.references(E))),
      claimItem: (claim.item I where I.encounter.references(E))
      claimDiagnosis: (claim.diagnosis D where D.sequence in claimItem.diagnosisSequence)
    where claimDiagnosis.diagnosis in "Asthma"
      and claimDiagnosis.type.includesCode("Principal Diagnosis")
```

Note that the "Principal Diagnosis" code is defined as:

```cql
codesystem "Diagnosis Type": 'http://terminology.hl7.org/CodeSystem/ex-diagnosistype'
code "Principal Diagnosis": 'principal' from "Diagnosis Type"
```

And the `includesCode` function:

```cql
/*
@description: Returns true if the given code is in the given codeList
@comment: Returns true if the `code` is equivalent to any of the codes in the given `codeList`, false otherwise.
*/
define fluent function includesCode(codeList List<FHIR.CodeableConcept>, code Code):
  exists (codeList C where C ~ code)
```

#### Potential claimDiagnosis Function:

To support reuse and consistency, as well as to simplify access to diagnosis-related claim information, we can propose a `claimDiagnosis` function:

```cql
define fluent function claimDiagnosis(encounter Encounter):
  encounter E
    let 
      claim: ([Claim] C where C.status = 'active' and C.use = 'claim' and exists (C.item I where I.encounter.references(E))),
      claimItem: (claim.item I where I.encounter.references(E))
    return claim.diagnosis D where D.sequence in claimItem.diagnosisSequence
```

Given an encounter, this would return claim diagnosis information related to that encounter, which would then potentially simplify each of the above use cases:

```
define "Encounter With Asthma Present On Admission":
  [Encounter] E
    where exists (
      (E.claimDiagnosis()) D
        where D.diagnosis in "Asthma"
          and D.onAdmission ~ "POA-Y"
    )

define "Encounter With Principal Diagnosis of Asthma":
  [Encounter] E
    where exists (
      (E.claimDiagnosis()) D
        where D.diagnosis in "Asthma"
          and D.type.includesCode("Principal Diagnosis")
    )
```    
