# Colorectal Cancer Concepts Walkthrough

This walkthrough guides you through setting up, building, and modifying the Colorectal Cancer Concepts artifact library to illustrate how to author, distribute, and consume FHIR- and CQL-based knowledge artifacts for decision support and quality measurement related to Colorectal Cancer Screening.

## Overview

The walkthrough is organized into the following sections:

- [Colorectal Cancer Concepts Walkthrough](#colorectal-cancer-concepts-walkthrough)
  - [Overview](#overview)
  - [Background](#background)
  - [USPSTF Recommendation on Colorectal Cancer Screening](#uspstf-recommendation-on-colorectal-cancer-screening)
  - [Approach](#approach)
  - [Artifact Source](#artifact-source)
  - [Unit Testing](#unit-testing)
  - [Building the Artifact Library](#building-the-artifact-library)
  - [Running the Decision Support](#running-the-decision-support)
    - [Configuring the CDS Hooks Sandbox](#configuring-the-cds-hooks-sandbox)
  - [Running the Quality Measure](#running-the-quality-measure)
  - [Updating the Content](#updating-the-content)

## Background

This walkthrough is an illustration of FHIR- and CQL-based knowledge artifacts that provide quality measurement and decision support implementations of the US Preventive Services Task Force Recommendation on Colorectal Cancer Screening.

The artifacts are built using the [approach](https://hl7.org/fhir/uv/cpg/approach.html) and [methodology](https://hl7.org/fhir/uv/cpg/methodology.html) of the FHIR Clinical Guidelines IG (CPG). The walkthrough does not assume familiarity with this material, but interested readers can find more detailed information.

Specifically, because the knowledge artifacts in this Artifact Library are FHIR canonical resources, the content here is built as a FHIR Implementation Guide, allowing knowledge authors to leverage the FHIR publishing toolchain to provide distribution and documentation of the artifacts.

## USPSTF Recommendation on Colorectal Cancer Screening

The artifacts in this walkthrough provide a platform-independent, standards-based representation of a decision support rule and quality measure for implementing the US Preventive Services Task Force recommendation on Colorectal Cancer Screening:

* The U.S. Preventive Services Task Force (2016) recommends screening for colorectal cancer starting at age 50 years and continuing until age 75 years. This is a Grade A recommendation ([U.S. Preventive Services Task Force, 2016](https://www.uspreventiveservicestaskforce.org/uspstf/recommendation/colorectal-cancer-screening-june-2016)).

> NOTE: This recommendation was updated in May of 2021; the updates have not been applied to this artifact. It is an exercise for the reader to update the content per the 2021 recommendation.

## Approach

Although there are many different [mechanisms](https://hl7.org/fhir/uv/cpg/documentation-approach-10-mechanisms-of-integration.html) available for implementing CPG knowledge artifacts, this walkthrough will focus on a service-based integration using the [CDS Hooks](http://cds-hooks.hl7.org) specification:

![CDS Hooks Integration](images/integration-content-service.png)

In this approach, a Clinical Reasoning service is used to provide a CDS Hooks endpoint to the clinical system. The service is registered with the clinical system and then calls the service at the appropriate point in the user's workflow. The walkthrough will illustrate the basic steps of:

1. Building the recommendation as a FHIR- and CQL- knowledge artifact
2. Unit testing the recommendation functionality
2. Deploying the recommendation to the Clinical Reasoning service
3. Integration testing the recommendation with the CDS Hooks Sandbox

## Artifact Source

For delivery as a CDS Hooks service, we represent the recommendation as an Event-condition-action or ECA rule, using the following source artifacts:

1. [CQL Logic](input/cql/ColorectalCancerScreeningCDS.cql) - The representation of the logic in Clinical Quality Language
2. [FHIR Library](resources/library/ColorectalCancerScreeningCDS.json) - The FHIR Library that packages the CQL logic
3. [FHIR PlanDefinition](resources/plandefinition/ColorectalCancerScreeningCDS.xml) - The FHIR PlanDefinition that represents the ECA rule

## Unit Testing

For unit testing, we define test cases in the `input/tests/cdshooks` directory. In the CQL editor, right-clicking and selecting Execute will run the tests in the tests folder with the same name as the library. For example, the ColorectalCancerScreeningCDS library has two tests:

* should-not-screen-ccs
    * [Patient](input/tests/cdshooks/ColorectalCancerScreeningCDS/patient-should-not-screen-ccs.json)
    * [Encounter](input/tests/cdshooks/ColorectalCancerScreeningCDS/encounter-should-not-screen-ccs-4.json)
    * [Procedure](input/tests/cdshooks/ColorectalCancerScreeningCDS/procedure-should-not-screen-ccs-1.json)
* should-screen-ccs
    * [Patient](input/tests/cdshooks/ColorectalCancerScreeningCDS/patient-should-screen-ccs.json)
    * [Encounter](input/tests/cdshooks/ColorectalCancerScreeningCDS/encounter-should-screen-ccs-1.json)
    * [Procedure](input/tests/cdshooks/ColorectalCancerScreeningCDS/procedure-should-screen-ccs-2.json)

To run the tests, open the [ColorectalCancerScreeningCDS.cql](input/cql/ColorectalCancerScreeningCDS.cql) file, and in the CQL editor, right-click and select `Execute CQL`:

![Execute CQL](images/ccs-cds-execute-cql.png)

This opens a new editor window with the result of evaluating each expression defined in the library for each of the test cases:

![Execute Results](images/ccs-cds-execute-results.png)

Validate that the results are as expected:

* should-not-screen-ccs
    * Patient=Patient(id=should-not-screen-ccs)
    * Is Recommendation Applicable=false
    * Get Card Summary=Patient has appropriate colorectal cancer screening
    * Rationale=most recent Colonoscopy performed on 2015-01-01
    * Get Card Detail=Patient has appropriate colorectal cancer screening: most recent Colonoscopy performed on 2015-01-01.
    * Get Card Indicator=info
* should-screen-ccs
    * Patient=Patient(id=should-screen-ccs)
    * Is Recommendation Applicable=true
    * Get Card Summary=Recommend appropriate colorectal cancer screening
    * Rationale=most recent Colonoscopy performed on 2011-12-30
    * Get Card Detail=Patient meets the inclusion criteria for appropriate colorectal cancer screening, but has most recent Colonoscopy performed on 2011-12-30.
    * Get Card Indicator=warning

> NOTE: The execution output includes several warnings from the terminology provider indicating that there is no expansion element so the provider is using a naive expansion, as well as some warnings about not being able to parse resources. These are expected in this configuration.

## Building the Artifact Library

To build the Artifact Library, run the CQF Refresh tooling, and then the Publisher. Both of these are available as Java packages. They're too big to commit to the repository, so there are scripts to make downloading them to your local environment easy. First, make sure the CQF Tooling and Publisher are in your local cache by running the following:

    bash _updatePublisher.sh

    bash _updateCQFTooling.sh

Follow the prompts to allow the downloads to be placed in your local input-cache directory.

Then, run the CQF Tooling refresh with:

    bash _refresh.sh

> NOTE: The refresh tooling is performing several steps to process the knowledge artifacts, and there are some non-fatal errors reported during the process. For example, `Error setting PlanDefinition paths...` and `Error reading resource from path...`. These are known issues and do not affect the refresh for the artifacts in this walkthrough.

And finally, run the Publisher with:

    bash _genonce.sh

The result of the publisher step will create the Artifact Library as a FHIR Implementation Guide in the `output` folder, so open a browser on the [index.html](output/index.html) page to see the result.

> NOTE: The index.html link above will open the index.html page in an editor in the environment. Right-click in that editor and select "Open with Live Server" to view the page in your browser.

## Running the Decision Support

To run the decision support, we load the [ColorectalCancerScreeningCDS](bundles/plandefinition/ColorectalCancerScreeningCDS-bundle.json) bundle, which contains all the resources for the recommendation (including the test case data) into the Clinical Reasoning server:

    curl -d "@bundles/plandefinition/ColorectalCancerScreeningCDS/ColorectalCancerScreeningCDS-bundle.json" -H "Content-Type: application/json" -X POST https://cloud.alphora.com/sandbox/r4/cds/fhir

> NOTE: If you get an error about "HSEARCH" not working, that is a known issue with indexing in the HAPI FHIR Server. Just re-run the command and it should work the second time. We're working on it.

### Configuring the CDS Hooks Sandbox

Next, we configure the CDS Hooks sandbox to use the cds-sandbox as the FHIR server, and as the CDS Hooks service. To configure the cds-sandbox as the FHIR Server, navigate to the CDS Hooks sandbox:

http://sandbox.cds-hooks.org/

In the upper right-hand corner of the page, click the settings gear to bring down the settings menu and select `Change FHIR Server`. In the dialog that is displayed, Enter the URL for the CDS Sandbox FHIR server:

https://cloud.alphora.com/sandbox/r4/cds/fhir

and then click Next. In the patient dialog that comes up, enter the Patient ID:

`should-screen-ccs`

and then click Next.

To configure the sandbox to call the ColorectalCancerScreeningCDS service, click the settings gear again and select `Add CDS Service`. In the dialog that is displayed, enter the URL for the CDS Sandbox Discovery endpoint:

https://cloud.alphora.com/sandbox/r4/cds/cds-services

and then click Next. The CDS Hooks sandbox will then call that service with the should-screen-ccs patient, and return the recommendation. To see the request/response, click the Select a Service drop down in the CDS Developer panel and select ColorectalCancerScreeningCDS. This will display the actual CDS Hooks request that was sent, and the CDS Hooks response that came back.

## Running the Quality Measure

To run the quality measure, post the quality measure bundle to the CQM sandbox with the following command:

    curl -d "@bundles/measure/ColorectalCancerScreeningCQM/ColorectalCancerScreeningCQM-bundle.json" -H "Content-Type: application/json" -X POST https://cloud.alphora.com/sandbox/r4/cqm/fhir

As with the decision support bundle, this bundle contains all the files necessary to evaluate the measure, including test data. To run the measure, use the [$evaluate-measure](https://hl7.org/fhir/measure-operation-evaluate-measure.html) operation:

    curl 'https://cloud.alphora.com/sandbox/r4/cqm/fhir/Measure/ColorectalCancerScreeningCQM/$evaluate-measure?patient=denom-EXM130&periodStart=2022-01-01&periodEnd=2022-12-31' -H "Content-Type: application/json"


## Updating the Content

To update the content, perform the following steps:

1. Update the source CQL and/or FHIR resources.
2. Run the `bash _refresh.sh` command to refresh the FHIR Library and repackage the artifact bundles
3. Redeploy the updated artifact using the `curl` command (or a similar client such as Postman)

And because you've made changes in the source artifacts, to rebuild the IG, run the `bash _genonce.sh` command to rerun the publisher.

