This topic discusses a potential approach to identifying whether a prescription was transmitted electronically to a pharmacy.

This question was raised in [CQLIT-575](https://oncprojectracking.healthit.gov/support/browse/CQLIT-575):

> Is there a standard computable way to identify that a prescription was trasmitted electronically to a pharmacy, as distinct from being printed or faxed? What resource should be used: MedicationRequest? AuditEvent? Communication?

In discussions with the Pharmacy Work Group, because the information is a prescription, the MedicationDispense resource is the resource that should be used, and although there is currently no element to represent this information in the MedicationDispense resource, there is an implementation guide that has defined an extension for this purpose in the US Realm:

* [US Prescription Drug Monitoring Program (PDMP)](http://hl7.org/fhir/us/pdmp)

Specifically, there is an [rx-transmission-method](https://hl7.org/fhir/us/pdmp/STU1/StructureDefinition-pdmp-extension-rx-transmission-method.html) extension that represents exactly what is being asked for, using the following possible values from the [Prescription Transmission Method](https://hl7.org/fhir/us/pdmp/STU1/ValueSet-pdmp-rx-transmission-method.html) value set:

| Code | Display |
|----|----|
| 01 | Written Prescription |
| 02 | Telephone Prescription |
| 03 | Telephone Emergency Prescription |
| 04 | Fax Prescription |
| 05 | Electronic Prescription |
| 06 | Transferred/Forwarded Prescription |
| 99 | Other |

This mechanism at least supports the representation of the required information. Whether or not this extension will be available is another question (and even whether MedicationDispense data will be available), but following this published implementation guide at least gives a target. 

The following declarations would support the use of this data element:

```cql
codesystem "Rx Transmission Method": 'http://terminology.hl7.org/CodeSystem/PMIXTransmissionFormRxOriginCodeType'

code "Written Prescription": 'Written Prescription' from "Rx Transmission Method" display 'Written Prescription'
code "Electronic Prescription": 'Electronic Prescription' from "Rx Transmission Method" display 'Electronic Prescription'

define fluent function transmissionMethod(medicationDispense MedicationDispense):
  medicationDispense.ext('http://hl7.org/fhir/us/pdmp/StructureDefinition/pdmp-extension-rx-transmission-method').value as Coding
```

With these declarations, a quality improvement artifact could look for evidence of an electronic transmission with the following:

```cql
define "Electronically Transmitted Prescriptions":
  [MedicationDispense] Prescription
    where Prescription.transmissionMethod() ~ "Electronic Prescription"
```

> NOTE: This data element has been proposed for addition to the CQL US IG: https://jira.hl7.org/browse/FHIR-57486