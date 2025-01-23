library SupplementalDataElementsSTU6Prototype version '0.1.000'

using QICore version '6.0.0'

include FHIRHelpers version '4.4.000' called FHIRHelpers

codesystem "AdministrativeGender": 'http://hl7.org/fhir/administrative-gender'

valueset "Ethnicity": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.837'
valueset "ONC Administrative Sex": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1'
valueset "Payer Type": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.3591'
valueset "Race": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.114222.4.11.836'

code "M": 'M' from "AdministrativeGender" display 'Male'
code "F": 'F' from "AdministrativeGender" display 'Female'

context Patient

define "SDE Ethnicity":
  Patient.extension E
    where E.url = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity' 
    return Tuple {
      codes: { 
        E.extension e
          where e.url = 'ombCategory'
          return e.value as Code
      } 
      union {
        E.extension e
          where e.url = 'detailed'
          return e.value as Code
      },
      display: E.value
    }

define "SDE Payer":
  [Coverage: type in "Payer Type"] Payer
    return {
      code: Payer.type,
      period: Payer.period
    }

define "SDE Race":
  Patient.extension E
    where E.url = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race' 
    return Tuple {
      codes: { 
        E.extension e
          where e.url = 'ombCategory'
          return e.value as Code
      } 
      union {
        E.extension e
          where e.url = 'detailed'
          return e.value as Code
      },
      display: E.value
    }

define "SDE Sex":
  case
    when Patient.gender = 'male' then "M"
    when Patient.gender = 'female' then "F"
    else null
  end