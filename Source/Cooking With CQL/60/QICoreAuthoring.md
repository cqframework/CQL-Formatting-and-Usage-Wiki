# QICore Authoring

To build quality improvement artifacts such as measures and decision support rules that use FHIR as the data model, CQL libraries include a `using` statement at the top of the library. For example:

```cql
library CervicalCancerScreeningFHIR version '0.0.001'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
```

In addition, to facilitate the use of FHIR as a model directly, the `FHIRHelpers` library is included with CQL authoring environments so that authors don't have to manually convert between the FHIR representations of values like strings, integers, and codes.

Drafts of FHIR-based measures are regularly used to support testing and provide feedback at FHIR Connectathons. At the most recent connectathon, 14 FHIR-based eCQM specifications and 1 FHIR-based HEDIS measure specification were tested. That content is available as a build of a FHIR content IG here:

https://build.fhir.org/ig/cqframework/ecqm-content-r4-2021/measures.html

And the source for that content is available in Github here:

https://github.com/cqframework/ecqm-content-r4-2021

Although significant progress has been made in representing FHIR artifacts, there are still several areas where using the FHIR model directly requires extensive logic that leads to expressions that are harder to read. For example, accessing extensions:

```cql
define "SDE Ethnicity":
  (flatten (
      Patient.extension Extension
        where Extension.url = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity'
          return Extension.extension
    )) E
      where E.url = 'ombCategory'
        or E.url = 'detailed'
      return FHIRHelpers.ToCode(E.value)
```

To help address this, there is a set of tooling that can transform the profile definitions from any FHIR implementation guide into a model definition file that can be used with CQL. The current reference implementation of the CQL-to-ELM translator includes these model definitions files for USCore (version 3.1.1) and QICore (version 4.1.0). To make use of these, include a `using` statement that references the IG, rather than FHIR directly:

```cql
library SupplementalDataElementsQICore4 version '2.0.0'

using QICore version '4.1.0'

include FHIRHelpers version '4.0.1'
```

Note that including FHIRHelpers is still required because the model definition files make use of FHIRHelpers functions to facilitate mappings during translation.

With this using declaration, extensions used in profiles in the IG can be accessed as first-class elements of the types. For example, the above `"SDE Ethnicity"` expression simplifies to:

```cql
define "SDE Ethnicity":
  { Patient.ethnicity.ombCategory }
    union Patient.ethnicity.detailed
```

The `ethnicity` element is an extension defined on the `Patient` profile, and is made available as an element whose type is defined by the extension:

```cql
Ethnicity: {
  ombCategory: Coding,
  detailed: List<Coding>,
  text: string
}
```

Source: https://hl7.org/fhir/us/core/STU3.1.1/StructureDefinition-us-core-ethnicity.html

To test and validate the use of these model definition files for specifying artifacts, two eCQM specifications and their supporting libraries have been expressed using this approach. The source for these draft measure specifications can be found here:

https://github.com/cqframework/ecqm-content-qicore-2020

> Note that there is also a qicore-2021 repository, that repository is focused on specifications that use a slightly different approach based on _element_ libraries generated from profile definitions but still based directly on FHIR as a model definition.

For the most part, because the profiles in QICore are so similar to the base resources defined in FHIR, there is very little difference between the expressions in a FHIR-based measure versus a QICore-based measure. For example, consider the `AdultOutpatientEncounters."Qualifying Encounters"` expression:

```cql
define "Qualifying Encounters":
	(
    [Encounter: "Office Visit"]
  		union [Encounter: "Annual Wellness Visit"]
  		union [Encounter: "Preventive Care Services - Established Office Visit, 18 and Up"]
  		union [Encounter: "Preventive Care Services-Initial Office Visit, 18 and Up"]
  		union [Encounter: "Home Healthcare Services"]
  ) ValidEncounter
		where ValidEncounter.period during "Measurement Period"
  		and ValidEncounter.status  = 'finished'
```

This expression references the `Encounter` type in a FHIR-based measure, and the `QICoreEncounter` profile in a QICore-based measure, but both expressions still require the restriction to the measurement period, and the test of the status element to ensure only finished encounters are considered.

However, when the logic starts to make use of profile-specific information such as a blood pressure reading, the advantage of having a profile-informed model definition become clear:

```cql
define "Qualifying Diastolic Blood Pressure Reading":
  [Observation: "Blood pressure panel with all children optional"] BloodPressure
    where BloodPressure.status in {'final', 'amended'}
      and Global."Normalize Interval"(BloodPressure.effective) during "Measurement Period"
      and exists (
        BloodPressure.component DiastolicBP
          where FHIRHelpers.ToConcept(DiastolicBP.code) ~ "Diastolic blood pressure"
            and DiastolicBP.value.unit = 'mm[Hg]'
      )
```

The above expression retrieves observations that have a code of `"Blood pressure panel with all children optional"`, a status of `final` or `amended`, taken during the measurement period, and having a component with a code of `"Diastolic blood pressure"` and a value unit of `mm[Hg]`.

However, much of this information is already specified in the `observation-bp` profile used by QICore, so the model definition file makes the components available directly, and the expression can be simplified to:

```cql
define "Qualifying Diastolic Blood Pressure Reading":
	["observation-bp"] BloodPressure
	  where BloodPressure.DiastolicBP.value is not null
      and BloodPressure.status in {'final', 'amended'}
      and BloodPressure.effective during "Measurement Period"
```

The two measures in this repository are still work-in-progress and we are actively soliciting feedback on the approach and the results. The content is provided here for reference, please feel free to submit feedback using the Github Issues, or by emailing ICF directly: fhir@icf.com
