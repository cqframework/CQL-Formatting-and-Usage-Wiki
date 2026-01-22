The FHIR IG Publisher now supports measure refresh processing, including creation of effective data requirements.

## Setup Steps

1. Ensure you are using the latest version of the publish by running the _updatePublisher script
2. Set the [path-binary](https://hl7.org/fhir/tools/CodeSystem-ig-parameters.html#ig-parameters-path-binary) implementation guide parameter to the `input/cql` directory in your IG
3. Set the `content` element of the FHIR Library resource to reference the CQL file (e.g. `"id": "ig-loader-MyLibrary.cql"`)

### Set the path-binary parameter

For example, in the [US CQL IG](https://github.com/HL7/us-cql-ig/blob/main/input/cql-us.xml#L255), set the parameter in the source for the implementation guide:

```xml
<parameter>
  <code value="path-binary"/>
  <value value="input/cql"/>
</parameter>
```

### Set the Library content id:

Next, for each CQL library, ensure there is a FHIR Library resource, and that it has a `content` element that has only an `id` referencing the CQL source file:

```json
{
  "resourceType": "Library",
  "id": "CumulativeMedicationDuration",
  "url": "http://hl7.org/fhir/us/cql/Library/CumulativeMedicationDuration",
  "name": "CumulativeMedicationDuration",
  "title": "Cumulative Medication Duration",
  "status": "active",
  "experimental": false,
  "type": {
    "coding": [ {
      "system": "http://terminology.hl7.org/CodeSystem/library-type",
      "code": "logic-library"
    } ]
  },
  "description": "This library provides cumulative medication duration calculation logic for use with FHIR medication prescription, administration, and dispensing resources. The logic here follows the guidance provided as part of the 5.6 version of Quality Data Model.",
  "usage": "Note that the logic here assumes single-instruction dosing information. Split-dosing, tapering, and other more complex dosing instructions are not handled.",
  "content": [ {
    "id": "ig-loader-CumulativeMedicationDuration.cql"
  } ]
}
```

The `content` element will be replaced with the base-64 encoded CQL, and the base-64 encoded ELM XML and/or JSON, depending on the settings in the `cql-options.json` file in the CQL directory.

Any Measure resources in the IG that have `library` elements referencing CQL libraries processed in this way will have effective data requirements calculated.

### Model Info Processing

In addition, the publisher supports model info processing as well in the same way. For example:

```json
{
  "resourceType": "Library",
  "id": "USCore-ModelInfo",
  "url": "http://hl7.org/fhir/us/cql/Library/USCore-ModelInfo",
  "version": "7.0.0",
  "name": "USCore",
  "title": "US Core Model Information",
  "status": "active",
  "experimental": false,
  "type": {
    "coding": [ {
      "system": "http://terminology.hl7.org/CodeSystem/library-type",
      "code": "model-definition"
    } ]
  },
  "description": "CQL model information for the US Core version 7.0.0 implementation guide.",
  "content": [ {
    "id": "ig-loader-uscore-modelinfo-7.0.0.xml"
  } ]
}
```

For more details, see the [Binary Adjunct Files](https://build.fhir.org/ig/FHIR/ig-guidance/binaries.html) topic in FHIR IG Guidance.

