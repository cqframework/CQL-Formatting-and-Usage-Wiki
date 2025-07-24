This topic provides a review of the latest measure narrative templates, illustrating how a FHIR- and CQL-based measure is represented and how that representation is presented in the human-readable narrative for the resource.

## FHIR Measure Specifications

Broadly, measure specifications are made up of the following information:

| Component | Description | FHIR Representation |
|----|----|----|
| **Metadata** | Identifiers, narrative description, supporting evidence, topics, governance, relationship to other artifacts, etc. | Measure |
| **Structure** | The population criteria of the measure (i.e. initial population, numerator, denominator, etc) | Measure.group |
| **Logic** | The conditions involved in building the criteria | Library |

Consider the example FHIR- and CQL-based CMS130FHIR for Colorectal Cancer Screening in the CMS 2025 Connectathon repository:

https://build.fhir.org/ig/cqframework/ecqm-content-cms-2025/Measure-CMS130FHIRColorectalCancerScreening.html

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

