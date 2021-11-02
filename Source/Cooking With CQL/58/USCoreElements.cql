/*
@author: Bryn Rhodes
@description: This library defines functions to expose extensions defined
in USCore as fluent functions in CQL.
*/
library USCoreElements version '3.1.1'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '4.0.1' called FC

context Patient

/*
@description: Surfaces the [ethnicity](http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity)
extension defined in USCore.
@comment: This function returns a tuple with elements for each subextension (ombCategory, detailed, and text).
@extension: http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity
*/
define fluent function ethnicity(patient Patient):
  patient P
    let ethnicityEx: FC.Extension(P, 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity')
    return
      {
        ombCategory: FC.Extension(ethnicityEx, 'ombCategory').value as Coding,
        detailed:
          (FC.Extensions(ethnicityEx, 'detailed')) E
            return E.value as Coding,
        text: FC.Extension(ethnicityEx, 'text').value as string
      }

/*
@description: Surfaces the [race](http://hl7.org/fhir/us/core/StructureDefinition/us-core-race) extension defined in USCore.
@comment: This function returns a tuple with elements for each subextension (ombCategory, detailed, and text).
@extension: http://hl7.org/fhir/us/core/StructureDefinition/us-core-race
*/
define fluent function race(patient Patient):
  patient P
    let raceEx: FC.Extension(P, 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race')
    return
      {
        ombCategory:
          (FC.Extensions(raceEx, 'ombCategory')) E
            return E.value as Coding,
        detailed:
          (FC.Extensions(raceEx, 'detailed')) E
            return E.value as Coding,
        text: FC.Extension(raceEx, 'text').value as string
      }

/*
@description: Surfaces the [birthsex](http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex) extension defined in USCore.
@comment: This function returns the value of the birthsex extension as a code
@extension: http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex
*/
define fluent function birthsex(patient Patient):
  FC.Extension(patient, 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex').value as code

/*
@description: Surfaces the [direct](http://hl7.org/fhir/us/core/StructureDefinition/us-core-direct) extension defined in USCore.
@comment: This function returns the value of the direct extension as a boolean
@extension: http://hl7.org/fhir/us/core/StructureDefinition/us-core-direct
*/
define fluent function direct(contactPoint ContactPoint):
  FC.Extension(contactPoint, 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-direct').value as boolean
