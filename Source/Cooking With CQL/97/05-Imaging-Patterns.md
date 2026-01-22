This page documents proposed additions to the [Observation](https://build.fhir.org/ig/HL7/us-cql-ig/patterns-observation.html) and [Service](https://build.fhir.org/ig/HL7/us-cql-ig/patterns-service.html) Patterns pages in the US CQL IG.


#### Clinical Results

Clinical test results **(including imaging results)** in US Core use the [ObservationClinicalResult]({{site.data.fhir.ver.uscore7}}/StructureDefinition-qicore-observation-clinical-result.html) profile. By default, clinical test results in US Core are characterized by the code element.

```cql
define ObservationClinicalResult:
  ["Observation Clinical Result Profile"] O
    where O.isResulted()
```

Note that observations associated with imaging are expected to represent specific measurements obtained from imaging. See the [Imaging Procedures](patterns-service.html#imaging-procedures) discussion for more information.

> NOTE: US Core 5 defined two different profiles for clinical results, one for [test results](https://hl7.org/fhir/us/core/STU5.0.1/StructureDefinition-us-core-observation-clinical-test.html), and one for [imaging results](https://hl7.org/fhir/us/core/STU5.0.1/StructureDefinition-us-core-observation-imaging.html). These profiles were combined in US Core 6 in the clinical result profile.


#### Procedures Performed

US Core defines the [Procedure]({{site.data.fhir.ver.uscore7}}/StructureDefinition-us-core-procedure.html) profile to represent an in-progress or complete procedure for a patient. By default, Procedure resources in US Core are characterized by the `code` element.

```cql
define "Application of Intermittent Pneumatic Compression Devices":
  ["Procedure": "Application of Intermittent Pneumatic Compression Devices (IPC)"] DeviceApplied
    where DeviceApplied.status = 'completed'
```

> NOTE: Because the Procedure profile does not fix the value of the `status` element, authors must consider all the possible values of the element to ensure the expression meets measure intent. In this case, `completed` status is used to indicate that only completed procedures should be returned.

#### Imaging Procedures

In FHIR generally, because they involve significant and specialized information, imaging procedures (such as X-Rays, CT-Scans, MRIs, etc.) have resources designed specifically to represent imaging information. Overall, imaging procedures are represented using a combination of the following FHIR resources:

* [ServiceRequest](http://hl7.org/fhir/R4/servicerequest.html) - representing a proposal, plan, or order for an imaging procedure, using the `code` element to distinguish the type of procedure being ordered
* [Procedure](http://hl7.org/fhir/R4/procedure.html) - representing the actual performance of the imaging procedure, using the `code` element to distinguish the type of procedure performed
* [ImagingStudy](http://hl7.org/fhir/R4/imagingstudy.html) - representing the resulting images and other DICOM content, using the `procedureCode`, `procedureReference`, and/or `basedOn` elements to associate the study to an order or procedure
* [DiagnosticReport](http://hl7.org/fhir/R4/diagnosticreport.html) - representing the interpretation or clinical impression of the imaging procedure (detected or ruled out diagnoses), using the `code` element to distinguish the type of test or report
* [Observation](http://hl7.org/fhir/R4/observation.html) - representing individual measurements and comments on the images, using the `code` element to distinguish the type of measurement
* [Claim](http://hl7.org/fhir/R4/claim.html) - representing the claim for an imaging procedure, specifically the `procedure[x]` element to distinguish the type of procedure performed
* [ExplanationOfBenefit](http://hl7.org/fhir/R4/explanationofbenefit.html) - representing an adjudicated claim response for an imaging procedure, specifically the `procedure[x]` element to distinguish the type of procedure performed

Depending on the procedure, and the extent to which the results of that procedure are captured by clinical systems, there is variation in whether each of these resources is present for any given imaging procedure. In particular, [Some diagnostic procedures might not have a Procedure record. The Procedure record is only necessary when there is a need to capture information about the physical intervention that was performed to capture the diagnostic information (e.g. anaesthetic, incision, scope size, etc.)](https://hl7.org/fhir/procedure.html#bnr). As a result, authors must consider how to approach gathering information for specific procedures to ensure expressions match application intent.

For example, if application intent is that a CT Scan was performed, regardless of the results of that scan, authors should consider looking in all of the above possible locations for evidence that a CT Scan was performed:

* [ServiceRequest](#requested-services) with an intent of order and a status of completed
* [Procedure](#procedures-performed) with a status of completed
* [ImagingStudy](http://hl7.org/fhir/R4/imagingstudy.html) with a status of available and related by `basedOn` or one of the `procedure` elements
* [DiagnosticReportNote]({{site.data.fhir.ver.uscore7}}/StructureDefinition-us-core-diagnosticreport-note) with a status of final, amended, appended, or corrected
* [ObservationClinicalResult](patterns-observation.html#clinical-results) with a status of final, amended, or corrected
* [Claim](patterns-claim.html#claim-items) with a status of `active` and a use of `claim`
* [ExplanationOfBenefit](patterns-claim.html#eob-items) with a status of `active` and a use of `claim`

If application intent is only looking for the performance of the scan, not whether it was resulted, the first two may suffice:

```cql
define "CT Scan Order Completed":
  ["ServiceRequest": "CT Scan Codes"] SR
    where SR.intent = 'order'
      and SR.status = 'completed'

define "CT Scan Procedure Performed":
  ["Procedure": "CT Scan Codes"] P
    where P.status = 'completed'

define "CT Scan Performed":
  exists "CT Scan Order Completed"
    or exists "CT Scan Procedure Performed"
```

However, if application intent is that the scan was performed and resulted, diagnostic report provides the next level of checking:

```cql
define "CT Scan Diagnostic Report":
  ["DiagnosticReportNote": "CT Scan Notes"] DR
    where DR.status in ('final', 'amended', 'corrected', 'appended')
```

An additional check may be considered by looking for any imaging study results:

```cql
define "CT Scan Imaging Study":
  ["ImagingStudy"] IS
    where exists (IS.procedureCode C where C in "CT Scan Procedure Codes")
      or exists ("CT Scan Procedure Performed" P
        where IS.procedureReference.references(P)
      )
```

As well as potentially looking for any measurements performed as part of the scan or study.

> NOTE: This topic is a summary of discussion with the Orders & Observations Work Group in the following FHIR Zulip chat: https://chat.fhir.org/#narrow/channel/179256-Orders-and-Observation-WG/topic/How.20to.20represent.20CT-Scan.3F/with/541254708. Also note that part of that discussion suggests that [ChargeItem](https://hl7.org/fhir/R4/chargeitem.html) may be useful as a source of evidence that something was done. This needs followup and additional investigation.

> These changes are proposed for inclusion in the US CQL IG: (https://jira.hl7.org/browse/FHIR-53461)