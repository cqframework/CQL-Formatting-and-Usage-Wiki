/*
@author: Bryn Rhodes
@description: This library defines functions to expose extensions defined
in USCore as fluent functions in CQL, as well as common terminology and functions
used in writing CQL with FHIR and USCore profiles.
*/
library USCoreCommon

using FHIR version '4.0.1'
using USCore version '7.0.0'

include fhir.uv.cql.FHIRHelpers version '2.0.0'
include fhir.uv.cql.FHIRCommon version '2.0.0'

codesystem "CVX": 'http://hl7.org/fhir/sid/cvx'
codesystem "ActCode": 'http://terminology.hl7.org/CodeSystem/v3-ActCode'
codesystem "USCoreConditionCategory": 'http://hl7.org/fhir/us/core/CodeSystem/condition-category'
codesystem "CDC Race and Ethnicity Codes": 'urn:oid:2.16.840.1.113883.6.238'
codesystem "CommunicationCategoryCodeSystem": 'http://terminology.hl7.org/CodeSystem/communication-category'
codesystem "IdentifierType": 'http://terminology.hl7.org/CodeSystem/v2-0203'

code "MedicalRecordNumber": 'MR' from "IdentifierType" display 'Medical record number'

// Encounter Class Codes
code "ambulatory": 'AMB' from ActCode display 'ambulatory'
code "emergency": 'EMER' from ActCode display 'emergency'
code "field": 'FLD' from ActCode display 'field'
code "home health": 'HH' from ActCode display 'home health'
code "inpatient encounter": 'IMP' from ActCode display 'inpatient encounter'
code "inpatient acute": 'ACUTE' from ActCode display 'inpatient acute'
code "inpatient non-acute": 'NONAC' from ActCode display 'inpatient non-acute'
code "observation encounter": 'OBSENC' from ActCode display 'observation encounter'
code "pre-admission": 'PRENC' from ActCode display 'pre-admission'
code "short stay": 'SS' from ActCode display 'short stay'
code "virtual": 'VR' from ActCode display 'VR'

// Condition Category Codes
code "health-concern": 'health-concern' from "USCoreConditionCategory" display 'Health Concern'

code "Systolic Blood Pressure": '8480-6' from FHIRCommon.LOINC
code "Diastolic Blood Pressure": '8462-4' from FHIRCommon.LOINC
code "BMI": '39156-5' from FHIRCommon.LOINC

context Patient

define fluent function race(patient Patient):
  (patient.ext('http://hl7.org/fhir/us/core/StructureDefinition/us-core-race')) E
    return {
      ombCategory: (E.exts('ombCategory')) o return o.value as FHIR.Coding,
      detailed: (E.exts('detailed')) d return d.value as FHIR.Coding,
      text: E.ext('text').value as FHIR.string
    }

define fluent function ethnicity(patient Patient):
  (patient.ext('http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity')) E
    return {
      ombCategory: E.ext('ombCategory').value as FHIR.Coding,
      detailed: (E.exts('detailed')) d return d.value as FHIR.Coding,
      text: E.ext('text').value as FHIR.string
    }

define fluent function tribalAffiliation(patient Patient):
  (patient.ext('http://hl7.org/fhir/us/core/StructureDefinition/us-core-tribal-affiliation')) E
    return {
      tribalAffiliation: E.ext('tribalAffiliation').value as CodeableConcept,
      isEnrolled: E.ext('isEnrolled').value as boolean
    }

define fluent function birthSex(patient Patient):
  patient.ext('http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex').value as FHIR.code

define fluent function systolic(bloodPressureProfile BloodPressureProfile):
  singleton from (
    bloodPressureProfile.component C
      where C.code ~ "Systolic Blood Pressure"
  )

define fluent function diastolic(bloodPressureProfile BloodPressureProfile):
  singleton from (
    bloodPressureProfile.component C
      where C.code ~ "Diastolic Blood Pressure"
  )

/*
@description: Returns true if the given condition is a health concern
*/
define fluent function isHealthConcern(condition FHIR.Condition):
  exists (condition.category C
    where C ~ "health-concern"
  )

