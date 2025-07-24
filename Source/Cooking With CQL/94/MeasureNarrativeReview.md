This topic provides a review of the latest measure narrative templates, illustrating how a FHIR- and CQL-based measure is represented and how that representation is presented in the human-readable narrative for the resource.

## FHIR Measure Specifications

Broadly, measure specifications are made up of the following information:

| Component | Description | FHIR Representation |
|----|----|----|
| **Metadata** | Identifiers, narrative description, supporting evidence, topics, governance, relationship to other artifacts, etc. | [Measure](https://hl7.org/fhir/R4/measure.html) |
| **Structure** | The population criteria of the measure (i.e. initial population, numerator, denominator, etc) | [Measure.group](https://hl7.org/fhir/R4/measure-definitions.html#Measure.group) |
| **Logic** | The conditions involved in building the criteria | [Library](https://hl7.org/fhir/R4/library.html) |

Consider the example FHIR- and CQL-based CMS130FHIR for Colorectal Cancer Screening in the CMS 2025 Connectathon repository:

* [Measure](https://github.com/cqframework/ecqm-content-cms-2025/blob/master/input/resources/measure/CMS130FHIRColorectalCancerScreening.json)
* [Library](https://github.com/cqframework/ecqm-content-cms-2025/blob/master/input/resources/library/CMS130FHIRColorectalCancerScreening.json)
* [CQL](https://github.com/cqframework/ecqm-content-cms-2025/blob/master/input/cql/CMS130FHIRColorectalCancerScreening.cql)
* [Narrative](https://build.fhir.org/ig/cqframework/ecqm-content-cms-2025/Measure-CMS130FHIRColorectalCancerScreening.html)

Broadly, the narrative is grouped into the following sections:

* Metadata
    * Identifiers, Versioning, Effective Period
    * Contributors, Steward
    * Description, Rationale, Recommendation Statement
    * Copyrights and Disclaimers
    * References
    * Guidance
* Groups (Rates)
    * Basis
    * Scoring
    * Improvement Notation
    * Populations
    * Stratifiers
* Supplemental Data
* Logic
    * Primary Library (Link)
    * Contents (Links to sections)
    * Population Criteria
        * Groups (Rates)
            * Population Criteria Definitions (CQL)
            * Stratifier Definitions (CQL)
    * Logic Definitions (CQL)
    * Terminology
    * Dependencies
    * Data Requirements

