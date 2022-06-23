library FHIRCommonTests

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '4.0.1'

context Patient

/*
define function ToInterval(choice Choice<FHIR.dateTime, FHIR.Period, FHIR.Timing, FHIR.instant, FHIR.string, FHIR.Age, FHIR.Range>):
define function ToAbatementInterval(condition Condition):
define function ToPrevalenceInterval(condition Condition):
define function Extensions(domainResource DomainResource, url String):
define function Extension(domainResource DomainResource, url String):
define function Extensions(element Element, url String):
define function Extension(element Element, url String):
define function ModifierExtensions(domainResource DomainResource, url String):
define function ModifierExtension(domainResource DomainResource, url String):
define function ModifierExtensions(element BackboneElement, url String):
define function ModifierExtension(element BackboneElement, url String):
define function BaseExtensions(domainResource DomainResource, id String):
define function BaseExtension(domainResource DomainResource, id String):
define function BaseExtensions(element Element, id String):
define function BaseExtension(element Element, id String):
define function BaseModifierExtensions(domainResource DomainResource, id String):
define function BaseModifierExtension(domainResource DomainResource, id String):
define function BaseModifierExtensions(element BackboneElement, id String):
define function BaseModifierExtension(element BackboneElement, id String):
define function USExtensions(domainResource DomainResource, id String):
define function USExtension(domainResource DomainResource, id String):
define function USExtensions(element Element, id String):
define function USExtension(element Element, id String):
define function USModifierExtensions(domainResource DomainResource, id String):
define function USModifierExtension(domainResource DomainResource, id String):
define function USModifierExtensions(element BackboneElement, id String):
define function USModifierExtension(element BackboneElement, id String):
define function QIExtensions(domainResource DomainResource, id String):
define function QIExtension(domainResource DomainResource, id String):
define function QIExtensions(element Element, id String):
define function QIExtension(element Element, id String):
define function QIModifierExtensions(domainResource DomainResource, id String):
define function QIModifierExtension(domainResource DomainResource, id String):
define function QIModifierExtensions(element BackboneElement, id String):
define function QIModifierExtension(element BackboneElement, id String):
*/
