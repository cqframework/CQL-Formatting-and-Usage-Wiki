This page documents proposed additions to the [Service](https://build.fhir.org/ig/HL7/us-cql-ig/patterns-service.html) Patterns page in the US CQL IG.

#### Mammography

Applying this pattern to mammography, we may find evidence of mammography performed in:

* ObservationClinicalResult - Recording a mammography test result
* Claim - Recording a claim for a mammography provided
* ExplanationOfBenefit - Recording an adjudicated claim for a mammography

Note that we are excluding the Procedure, DiagnosticReportNote, and LaboratoryTestResult possibilities

For mammography, the following patterns can be used:

```cql
define "Mammography Observation":
  ["Observation Clinical Result Profile": "Mammography Result"] MammographyResult
    where MammographyResult.isImaging()
      and MammographyResult.isResulted()
```

#### Mammography Claim

```cql
define "Mammography Claim":
  "Claim Item" I
    where I.serviced.toInterval() during "Measurement Period"
      and I.productOrService in "Mammography"

define "Mammography EoB":
  "EoB Item" I
    where I.serviced.toInterval() during "Measurement Period"
      and I.productOrService in "Mammography"
```



> These changes are proposed for inclusion in the US CQL IG: (https://jira.hl7.org/browse/FHIR-53461)