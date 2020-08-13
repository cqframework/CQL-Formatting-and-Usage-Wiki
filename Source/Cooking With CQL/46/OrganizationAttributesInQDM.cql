library OrganizationAttributesInQDM

using QDM version '5.5'

valueset "Inpatient": 'TBD'
valueset "ED": 'TBD'
valueset "Office Visit": 'TBD'
valueset "Blood Pressure": 'TBD'
valueset "Family": 'TBD'
valueset "Ambulatory Clinical Practice": 'TBD'
valueset "Ophthalmology": 'TBD'

context Patient

/*
# Organization Attributes in QDM

* using QDM attributes for Organization
* what string to use for namingSystem if the value is an NPI or some other formal identifier for organizations for QDM.Entity identifier.
* Check that org associated with a blood pressure is same as encounter

Naming System Identifiers for various formal identifiers:

* NPI: http://hl7.org/fhir/sid/us-npi
    * [US Core Practitioner](http://hl7.org/fhir/us/core/StructureDefinition-us-core-practitioner.html)
    * [US Core Organization](http://hl7.org/fhir/us/core/StructureDefinition-us-core-organization.html)
* EIN urn:oid:2.16.840.1.113883.4.4
    * [DEQM Organization](http://build.fhir.org/ig/HL7/davinci-deqm/StructureDefinition-organization-deqm.html)
* CCN: urn:oid:2.16.840.1.113883.4.336
    * Based on current QRDA
    * Based on [DEQM Organization](http://build.fhir.org/ig/HL7/davinci-deqm/StructureDefinition-organization-deqm.html)

Examples of using QDM attributes for Organization:

In this example, the eCQM defines a qualifying encounter as performed by an ambulatory clinical practice using the QDM Entity Organization and its type attribute:
*/

define "Qualifying Encounters":
  ["Encounter, Performed": "Office Visit"] Encounter
    where Encounter.participant is Organization
      and Encounter.participant.type in "Ambulatory Clinical Practice"

/*
In this example, the eCQM uses the QDM Entity Practitioner and its Specialty attribute to define a qualifying encounter as one performed by an ophthalmologist:
*/

define "Qualifying Encounters 2":
  ["Encounter, Performed": "Office Visit"] Encounter
    where Encounter.participant is Practitioner
      and Encounter.participant.specialty in "Ophthalmology"

/*
This example shows how to determine that the primary participant (performer) of an inpatient encounter is the same as the primary participant (performer) of an emergency department encounter using the organization entity. The example defines a function to identify the required identifier as a [CMS Certification Number (CCN)](https://www.cms.gov/regulations-and-guidance/guidance/transmittals/downloads/r29soma.pdf)
*/

define "Qualifying Encounters 3":
  ["Encounter, Performed": "Inpatient"] Encounter
    with ["Encounter, Performed": "ED"] ED
      such that ED.relevantPeriod ends 1 hour or less on or before start of Encounter.relevantPeriod
        and CCNOf(ED.participant.identifier) = CCNOf(Encounter.participant.identifier)

define "CCN Identifier System": 'urn:oid:2.16.840.1.113883.4.336'

define function CCNOf(identifier Identifier):
  identifier I where I.namingSystem = "CCN Identifier System" return I

/*
This example shows how to determine that a blood pressure examination was performed by a Care Partner (a person that is related to a patient, but who is not the direct target of care). “Family” in this instance would use a value set of potential family members as defined by a measure developer (e.g., mother, father, brother, sister, etc.).
*/

define "Care Partner Performed Blood Pressures":
  ["Physical Exam, Performed": "Blood Pressure"] BloodPressure
    where BloodPressure.performer is CarePartner
      and BloodPressure.performer.relationship in "Family"

/*
This example shows how to check that the organization associated with a blood pressure is the same as the encounter:
*/

define "Qualifying Blood Pressures":
  ["Physical Exam, Performed": "Blood Pressure"] BP
    with ["Encounter, Performed": "Office Visit"] Encounter
      such that BP.relevantPeriod during Encounter.relevantPeriod
        and EINOf(Encounter.participant.identifier) = EINOf(BP.performer.identifier)

define "EIN Identifier System": 'urn:oid:2.16.840.1.113883.4.4'

define function EINOf(identifier Identifier):
  identifier I where I.namingSystem = "EIN Identifier System" return I
