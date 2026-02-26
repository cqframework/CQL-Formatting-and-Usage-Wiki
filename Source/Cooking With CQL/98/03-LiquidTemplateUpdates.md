The currently released version of the liquid templates (0.5.3) generally follows the principle that, for criteria, if the measure specification does not have a criteria specified, nothing is rendered in the narrative.

This is true for:
* Population Criteria
* Supplemental Data Elements
* Risk Adjustment Variables
* Stratifier Criteria

However, this has been a common discussion area, and represents an aspect of the human readable for a measure that is different than the QDM eCQM rendering. Specifically, QDM eCQMs will in general include a `None` or `N/A` marker in the human readable when an otherwise expected criteria is not present in the measure.

Quality measure implementation guide establishes the set of allowable criteria types per scoring type in [Table 3-1: Measure populations based on types of measure scoring](https://hl7.org/fhir/uv/cqm/measure-conformance.html#conformance-requirement-3-9). Arranged from the perspective of the scoring type, this gives:

* Cohort
    * Initial Population
* Proportion
    * Initial Population
    * Denominator
    * Denominator Exclusion
    * Denominator Exception
    * Numerator
    * Numerator Exclusion
* Ratio
    * Initial Population
    * Denominator
    * Denominator Exclusion
    * Numerator
    * Numerator Exclusion
    * Measure Observation
* Continuous Variable
    * Initial Population
    * Measure Population
    * Measure Population Exclusion
    * Measure Observation

Assuming these are the criteria that we want to display in the narrative, regardless of whether the specification includes them, we can adjust the narrative display to always output these sections (in both the metadata and definitions), with the text 'None' if the measure specification does not include the relevant criteria.

For supplemental data elements and risk adjustment factors, these already display in the metadata section as a single element with guidance, so we can adjust that to display a 'None' if no guidance is present in the measure. In addition, the data elements section can be modified to include a header for 'None' when the measure does not define any supplement data.

And similarly for stratifiers, in both the metadata description and the definition, we can include a 'None' indicator if the measure group does not specify any stratification criteria.

In addition, in order to accommodate the possibility that different groups may want to make different decisions about whether missing criteria are rendered in this way, we can tie the display of the 'None' indicator to an extension in the measure specification, allowing the decision to be made potentially at the measure level.

The following table provides links to example measures for each scoring type, and rendered with and without the new missing elements option:

| Scoring Type | Current | Proposed (with Missing Elements) |
|----|----|----|
| Cohort - Full | [Cohort](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/master/Measure-HRExampleCohortMeasure.html) | [Cohort](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/br-render-missing-elements/Measure-HRExampleCohortMeasure.html) |
| Cohort - Partial | [CohortEmpty](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/master/Measure-HRExampleCohortEmptyMeasure.html) | [CohortEmpty](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/br-render-missing-elements/Measure-HRExampleCohortEmptyMeasure.html) |
| Proportion - Full | [Proportion](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/master/Measure-HRExampleProportionMeasure.html) | [Proportion](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/br-render-missing-elements/Measure-HRExampleProportionMeasure.html) |
| Proportion - Partial | [ProportionEmpty](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/master/Measure-HRExampleProportionEmptyMeasure.html) | [ProportionEmpty](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/br-render-missing-elements/Measure-HRExampleProportionEmptyMeasure.html) |
| Ratio - Full | [Ratio](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/master/Measure-HRExampleRatioMeasure.html) | [Ratio](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/br-render-missing-elements/Measure-HRExampleRatioMeasure.html) |
| Ratio - Partial | [RatioEmpty](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/master/Measure-HRExampleRatioEmptyMeasure.html) | [RatioEmpty](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/br-render-missing-elements/Measure-HRExampleRatioEmptyMeasure.html) |
| Continuous-Variable - Full | [CV](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/master/Measure-HRExampleCVMeasure.html) | [CV](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/br-render-missing-elements/Measure-HRExampleCVMeasure.html) |
| Continuous-Variable - Partial | [CVEmpty](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/master/Measure-HRExampleCVEmptyMeasure.html) | [CVEmpty](https://build.fhir.org/ig/cqframework/sample-content-ig/branches/br-render-missing-elements/Measure-HRExampleCVEmptyMeasure.html) |

