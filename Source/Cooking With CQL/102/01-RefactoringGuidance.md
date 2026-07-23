# Refactoring Guidance

This topic provides a review of shared library usage in the current dQM AU QI-Core-based measures, together with refactoring guidance for how those can be refactored to make use of the newly published US Quality Core 0.5.0 implementation guide.

For context, the following repositories are the focus of these discussions:

* [2025 AU dQMs (QI Core)](https://github.com/cqframework/dqm-content-qicore-2025): 2025 Annual Update (AU) measures expressed in MADiE as FHIR dQMs using QI Core profiles
* [2025 AU dQMs (US Quality Core)](https://github.com/cqframework/dqm-content-cms-2025): 2025 Annual Update (AU) measures copied from the QI Core repository, then refactored to use US Quality Core

As part of this process, we have reviewed shared library usage across these measures for the following shared libraries:

* [CQMCommon version 4.1.000](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/CQMCommon.cql)
* [QICoreCommon version 4.0.000](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/QICoreCommon.cql)
* [SupplementalDataElements version 5.1.000](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/SupplementalDataElements.cql)
* [Status version 1.15.000](https://github.com/cqframework/dqm-content-qicore-2025/blob/master/input/cql/Status.cql)

Review Refactoring Guidance:

[US Quality Core Refactoring](https://github.com/cqframework/dqm-content-cms-2025/blob/main/USQualityCoreUpdateProcess.md)

The shared library review has confirmed that all content from QICoreCommon has been refactored into FHIRCommon, USCoreCommon, and USQualityCoreCommon. These shared libraries should now all be accessed via their published implementation guides as follows:

```cql
include hl7.fhir.uv.cql.FHIRHelpers version '4.0.1' called FHIRHelpers
include hl7.fhir.uv.cql.FHIRCommon version '2.0.0' called FHIRCommon
include hl7.fhir.us.cql.USCoreCommon version '2.0.0' called USCoreCommon
include fhir.onc."us-quality-core".USQualityCoreCommon version '0.5.0' called USQualityCoreCommon
```

> NOTE: While the CQL US is still in draft, use the `2.0.0-cibuild` label for libraries in that implementation guide.

Candidates for refactoring:

* CQMCommon.ToDateInterval
* CQMCommon.encounterDiagnosis() - See encounter diagnosis pattern
* USQualityCoreCommon.getId() - Should use FHIRCommon.references()

Review Status library functions:

[Status version 2.1.000](https://github.com/cqframework/dqm-content-cms-2025/blob/main/input/cql/Status.cql)

