As discussed on the eCQM Working Group Call, updated versions of the following shared libraries are now available in MADiE:

| Library | Version |
|----|----|
| ClaimCommon | 0.4.000 |
| ClaimElements | 0.4.000 |
| CQMConcepts | 0.3.000 |
| CQMElements | 0.3.000 |
| CQMInferences | 0.3.000 |
| FHIRBuilders | 0.1.000 |
| MedicationCommon | 0.2.000 |

The Authoring Patterns pages have also been updated to reflect these latest versions.

As always, the Library Index is available to keep track of what the latest expected versions are of all the shared library content:

* [Library Index](https://build.fhir.org/ig/cqframework/cms-qmd/refactored_index.html#library-index)

If you are the steward of a shared library and have a newer version of a library than is listed on that index, please let us know so we can keep the index up to date.

### Shared Library Testing

To ensure correct functioning of the contents of these shared libraries, we are creating "test suites" using MADiE, where each test suite is modeled as a "Cohort" Measure named the name of the shared library plus Tests:

| Shared Library | Testing Measure |
|----|----|
| [ClaimCommon](https://madie.cms.gov/cql-libraries/6ad8c979bf531c0659c86b75/edit/details) | [ClaimCommonTests](https://madie.cms.gov/measures/6ad8c9ff1fbcbfc8d7e0c9aa/edit/details/) |
| [ClaimElements](https://madie.cms.gov/cql-libraries/6ad8cc29bf531c0659c86b76/edit/details) | [ClaimElementsTests](https://madie.cms.gov/measures/6ad8ccb11fbcbfc8d7e0c9b5/edit/details/) |
| [CQMConcepts](https://madie.cms.gov/cql-libraries/6ad7e87bbf531c0659c86b73/edit/details) | [CQMConceptsTests](https://madie.cms.gov/measures/6ad7e9421fbcbfc8d7e0c8d2/edit/details/) |
| [CQMElements](https://madie.cms.gov/cql-libraries/6ad7ed9abf531c0659c86b74/edit/details) | [CQMElementsTests]https://madie.cms.gov/measures/6ad7eeae1fbcbfc8d7e0c8de/edit/details/) |
| [CQMInferences](https://madie.cms.gov/cql-libraries/6ad8d1c1bf531c0659c86b7a/edit/details) | _in-progress_ |
| [FHIRBuilders](https://madie.cms.gov/cql-libraries/6ad7ddacbf531c0659c86b71/edit/details) | [FHIRBuildersTests](https://madie.cms.gov/measures/6ad7de9d1fbcbfc8d7e0c8bb/edit/details/) |
| [MedicationCommon](https://madie.cms.gov/cql-libraries/6ad8cd51bf531c0659c86b77/edit/details) | [MedicationCommonTests](https://madie.cms.gov/measures/6ad8cdd11fbcbfc8d7e0c9bd/edit/details/) |

> NOTE: Development versions of these testing libraries and cases are available in the [dqm-content-cms-2026](https://github.com/cqframework/dqm-content-cms-2026) repository.

There are two general patterns of shared library test cases:

1. **Infrastructure** - Common/Concepts layer libraries that don't need/expect patient data to run
2. **Elements** - Elements/Inferences layer libraries that can be effectively tested using cohort test patterns

#### Infrastructure Shared Libraries

The Infrastructure library testing follows the community convention of defining test cases as "defines that evaluate to true", so a `Tests` library consists basically of:

```cql
library CQMConceptsTests version '0.3.000'

using USQualityCore version '0.5.0'
using USCore version '6.1.0-derived'
using FHIR version '4.0.1'

include hl7.fhir.uv.cql.FHIRHelpers version '4.0.1'

include CQMConcepts version '0.3.000'

...

/*
 * lengthInDays
 */

define TestLengthInDays:
  Interval[@2024-03-01T08:00:00.000Z, @2024-03-05T10:00:00.000Z].lengthInDays() = 4

define TestLengthInDaysSameDay:
  Interval[@2024-03-01T00:00:00.000Z, @2024-03-01T23:59:59.999Z].lengthInDays() = 0

...
```

However, there are often numerous test expressions in a given testing library, so defining individual test cases in MADiE to support these would require significant effort. Instead, we have adopted a pattern of defining a single `_Passed` expression that is the result of testing all the expressions in the library:

```cql
define _Passed:
  true
    and TestLengthInDays
    and TestLengthInDaysSameDay
    and TestLengthInDaysCrossesMidnight
    and TestLengthInDaysNearlyTwoDays
    and TestLengthInDaysLeapYear
    and TestLengthInDaysNonLeapYear
    and TestLengthInDaysYearBoundary
    and TestLengthInDaysOpenEndAtMidnight
    and TestLengthInDaysNullEnd
    and TestLengthInDaysUnknownEnd
    and TestLengthInDaysNull
    ...
```

In MADiE then, these infrastructure libraries can be tested as a Cohort measure whose Initial Population is the `_Passed` expression, with a single test case where the expected result of the Initial Population criteria is `true`.

#### Elements/Inferences Shared Libraries

The second category of shared libraries are _elements_ and _inferences_ libraries that, because they are already dealing with expressions that are expected to return results, can be more effectively expressed in terms of test cases in MADiE. The current approach uses cohort measures and simply defines cohort scores for each aspect being tested in each case.

All of these shared library test measures are works in progress. We are working with the MADiE team on some issues that have come up as part of working through these.