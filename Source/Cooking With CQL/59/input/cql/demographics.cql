library demographics version '1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0'

context Patient

define "first_name": Patient.name[0].given[0]
define "last_name": Patient.name[0].family
define "date_of_birth": Patient.birthDate
define "age": AgeInYears()
define "gender": Patient.gender
define "race": Patient.valueOmbCategoryRace()
define "ethnicity": Patient.valueOmbCategoryEthnicity()
define "birthsex": Patient.valueUSCoreBirthSex()
define "zip": Patient.address.postalCode[0]
define "state": Patient.address.state[0]

// Helper Functions from FHIRCommon
define function Extensions(domainResource DomainResource, url String):
  domainResource.extension E
      where E.url = url
        return E
define function Extensions(element Element, url String):
  element.extension E
      where E.url = url
        return E
define function Extension(domainResource DomainResource, url String):
  singleton from "Extensions"(domainResource, url)
define function Extension(element Element, url String):
  singleton from Extensions(element, url)

define fluent function valueOmbCategoryRace(patient Patient):
  Extension(Extension(patient, 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race'), 'ombCategory').value
define fluent function valueOmbCategoryEthnicity(patient Patient):
  Extension(Extension(patient, 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity'), 'ombCategory').value
define fluent function valueUSCoreBirthSex(patient Patient):
  Extension(patient, 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex').value
