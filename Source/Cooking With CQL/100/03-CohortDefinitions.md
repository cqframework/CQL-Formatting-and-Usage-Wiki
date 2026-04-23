# Cohort Definitions

This topic discusses the use of cohort definitions as a mechanism to address challenges in measure evaluation, including attribution and potentially performance. The approach builds on existing capabilities and aligns with other approaches to cohort definition throughout the community.

## Group Resource

The [Group](https://hl7.org/fhir/R4/group.html) resource in FHIR is used to:

> ... define a group of people, animals, devices, etc. that is being tracked, examined or otherwise referenced as part of healthcare-related activities

We already use the Group resource in quality measurement

1. Measure.subjectReference - A reference to a Group that identifies the set of subjects for the measure
2. Measure/$evaluate.subjectGroup - The set of subjects on which to run the measure
3. MeasureReport.subject - Can be a reference to a Group, if that is how the subjects were provided to the evaluate

In particular, we use Group as the mechanism to support varying attribution models over the same measure, specifically the DaVinci Attribution IG.

## Actual vs Descriptive

However, Group usage thus far has been mostly with `actual` groups, as opposed to descriptive groups. The Group resource supports two primary use cases,

1. To define a group of _specific_ members
2. To define a group of _possible_ members

For _specific_ members, the Group resource uses the `member` element to explicitly list the members of the group:

```json
    "quantity": 100,
    "member": [
        { "entity": { "reference": "Patient/patient-0152-fhir" } },
        { "entity": { "reference": "Patient/patient-0052-fhir" } },
        { "entity": { "reference": "Patient/patient-0136-fhir" } },
        ...
```

## Structured Characteristics

For _descriptive_ groups, the resource allows membership criteria to be specified using the `characteristic` element, such as:

```json
  "characteristic": [{
    "code": { "text": "Age" },
    "valueRange": {
        "low": { "value": 18 },
    }
  }, {
    "code": { "text": "Encounter.type" },
    "valueReference": { "reference": "http://example.org/ValueSet/inpatient-encounter" }
  }]
```

Full Example: [MembershipCriteriaStructured](input/resources/group/MembershipCriteriaStructured.json)

## Group Evaluate

With a _descriptive_ group, then we can define an $evaluate operation that lets us get the result of evaluating those criteria:

```
POST [Base]/Group/DefaultSearchParameter/$evaluate
```

And the result is an _actual_ group with the members that met the criteria explicitly listed.

## Expression-based Characteristics

Rather than _structured_ characteristics, with CQL, we can provide the criteria as an expression, in the same way we specify the population criteria for measures:

```cql
define "Membership Criteria":
  Patient.ageInYears() >= 18
    and exists ([Encounter: Inpatient] E where E.period starts 1 year on or before Today())
```

```json
  "extension": [{
    "url": "http://hl7.org/fhir/StructureDefinition/characteristicExpression",
    "valueExpression": {
        "language": "text/cql-identifier",
        "expression": "Membership Criteria"
    }
  }]
```

Full Example: [MembershipCriteriaExpression](input/resources/group/MembershipCriteriaExpression.json)

These capabilities have been proposed in the Using CQL IG:

See the proposed [CQLGroupDefinition](https://build.fhir.org/ig/HL7/cql-ig/en/StructureDefinition-cql-groupdefinition.html) profile in the Using CQL IG for more detail on specifying a CQL-based cohort definition with Group.

## Population-level Ad-hoc Query

Now we can use the proposed Group/$evaluate to perform arbitrary queries against a FHIR server. Note that we can parameterize the queries, so for example:

```cql
define "Has Imaging Studies With Modality":
  exists ([ImagingStudy: modality ~ ModalityCode])
```

```json
    "parameter": [{
        "name": "ModalityCode",
        "valueString": "CT"
    },
    ...
```

Example Group: [HasImagingStudiesWithModality](input/resources/group/HasImagingStudiesWithModality.json)

See the proposed [CQLGroupEvaluate](https://build.fhir.org/ig/HL7/cql-ig/en/OperationDefinition-cql-group-evaluate.html) operation definition in the Using CQL IG for more detail on the evaluating a CQL-based cohort definition

## Search Parameter Optimization

As far as execution, the simplest approach is just patient-at-a-time evaluation. The server literally goes through all the patients, evaluating this expression for each one, and whenever the result is true, the patient gets added to the Group.member element. 

This brute-force approach works, but obviously there are ways to be smarter about how this works. This is where the search parameters come in. Note that the imaging study example is using the `modality` element, which has a search parameter defined. This means that rather than looking through all the patients, the server can use the search parameter as an _index_, and look up patients that have ImagingStudy resources with the given modality.

Of course, real membership criteria are much more complex than the simple examples we have seen here, but even in those cases, servers can analyze the criteria and determine which terms have search parameters, use those search parameters to narrow the set of patients, and then evaluate the full criteria on the (potentially much) smaller list of patients.

Specifically, servers can most easily perform this type of analysis on queries that only have two levels of logical operators; queries that are either:

* ANDs of ORs, or
* ORs of ANDs

For example:

```cql
[Encounter] E
  where (A and B) or (C and D)
```

or

```cql
[Encounter] E
  where (A or B) and (C or D)
```

There can be any number of clauses (the `(A and B)` part), and the clauses can have any number of terms (the `A`, `B`, `C`, and `D` parts), so long as the overall query follows this same structure.

Note that the terms can also include negation.

The following example follows this form:

```cql
  [Encounter] E
    where E.status = 'active'
      or (E.status = 'completed' and E.period.start same day or after @2026-01-01)
```

Whereas the following example does not:

```cql
  [Encounter] E
    where E.status = 'active'
      or (
        E.status = 'completed'
          and (
            E.period.start same day or after @2026-01-01
              or E.meta.lastUpdated same day or after @2026-01-01
          )
      )
```

because there are three levels of parentheses in the query:

```cql
(A or (B and (C or D)))
```

Note that servers can still be enhanced to perform the analysis required to determine which search parameters can be used for queries list this one, but keeping the queries expressed in the simpler form makes it easier for servers to process the criteria.

## US Core and US Quality Core Search Parameters

One of the main features of the US Core and US Quality Core implementation guides is the definition of supported search parameters. Generally, FHIR defines a large number of search parameters for each resource type, but just because a search parameter is defined for the resource, does not mean that servers have to (or will) have support for that search parameter.

For example, Observation (R4) defines [38 search parameters](https://hl7.org/fhir/R4/observation.html#search) covering a huge number of potential use cases for the Observation resource. However, US Core only [mandates](https://hl7.org/fhir/us/core/STU6.1/StructureDefinition-us-core-respiratory-rate.html#mandatory-search-parameters) support for searching by `patient, category`, `patient, code`, and `patient, category, and date`, and [recommends](https://hl7.org/fhir/us/core/STU6.1/StructureDefinition-us-core-respiratory-rate.html#optional-search-parameters) support for searching by `patient, category, status`, and `patient, code, date`.

Because of this, care should be taken to ensure that CQL queries are aligned with the search parameters that are defined for the profiles being referenced.

Search parameters for US Core are described in the Quick Start sections for each profile. Search parameters for US Quality Core are described in the [Server Capability Statement Summary](https://build.fhir.org/ig/FHIR/us-quality-core/CapabilityStatement-us-quality-core-server.html#resourcesSummary1)

## Custom and Otherwise Supported Search Parameters

Having said that, it remains a useful feature that many FHIR servers implement to define custom search parameters. In addition, different FHIR servers may provide support for different search parameters.

In the general case, this means that CQL execution environments can be built to take advantage of whatever search parameters are available in a given environment. A query that performs slowly in one environment, may perform better in another, due to the presence of different search parameters.

This also means though, that it is possible to "tune" queries to run in particular environments. For example, consider a `manufacturer` search parameter defined for ImagingStudy that uses a hypothetical `manufacturer` extension.

```cql
  [ImagingStudy: manufacturer ~ 'Canon Medical Systems']
```

The ImagingStudy resource does not have a `manufacturer` element. However, because the reference is inside the retrieve, the CQL translator will issue a warning, but otherwise allow this to be translated. An implementation environment can then use that name to attempt to resolve against a search parameter name, rather than an element name. If a search parameter is present, that search parameter is used to perform the query.

In this way, CQL queries can be written to directly take advantage of custom search parameters defined on the FHIR server.

## Cohort Definitions for Attribution in Measures

Returning to quality measures, this ability to define cohorts using CQL membership criteria, combined with the ability to specify a Group in the Measure/$evaluate operation, gives implementers a powerful way to address the attribution problem: use a CQLGroupDefinition to define the membership criteria:

```cql
parameter "Measurement Period" Interval<Date>
parameter Provider String

context Patient

define "Attribution Criteria":
  exists (
    [Encounter: Inpatient] E
      where E.period ends during "Measurement Period"
        and E.serviceProvider.references(Provider)
  )
```

This approach neatly addresses the attribution model issue for measure calculation, keeping attribution logic completely separate from measure specifications, and allowing implementers to define their own attribution models appropriate for their use cases. See the [Multi-provider Scenario](https://github.com/cqframework/ecqm-content-qicore-2024#multi-provider-patient-scenario) for more detail. This will likely be proposed as a scenario at the upcoming CMS Connectathon.

## Bulk Cohort API

In addition, this approach to defining groups using expressions for membership criteria aligns with the [Bulk Cohort API](https://hl7.org/fhir/uv/bulkdata/en/group.html#bulk-cohort-api) in the Bulk Data implementation guide. There are some specific differences that we will be balloting on, but overall the approach is consistent and allows implementers to use the Bulk Cohort API to evaluate quality measures.

## Eligibility Criteria

And finally, this approach is also consistent with work that is being done in the clinical trials space to use Group resources to define eligibility criteria. That effort makes use of the Group resource, typically using the _structured_ criteria representation approach, but the same `characteristicExpression` extension may also be used, allowing groups defined in this way to be used to determine clinical trial eligibility as well.