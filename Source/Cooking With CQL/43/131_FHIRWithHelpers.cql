library TestFHIR

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

codesystem "LOINC": 'http://loinc.org'
codesystem "Marital Status Codes": 'http://terminology.hl7.org/CodeSystem/v3-MaritalStatus'
codesystem "CDC Race and Ethnicity Codes": 'urn:oid:2.16.840.1.113883.6.238'

valueset "Marital Status": 'http://hl7.org/fhir/ValueSet/marital-status'

code "Marital Status - Married": 'M' from "Marital Status Codes"
code "American Indian or Alaska Native": '1002-5' from "CDC Race and Ethnicity Codes"
code "Alaska Native": '1735-0' from "CDC Race and Ethnicity Codes"
code "Blood pressure": '85354-9' from "LOINC" display 'blood pressure'
code "Diastolic blood pressure": '8462-4' from "LOINC" display 'Diastolic blood pressure'
code "Systolic blood pressure": '8480-6' from "LOINC" display 'Systolic blood pressure'

context Patient

define TestPrimitives:
  Patient P
    where P.gender = 'male'
      and P.active is true
      and P.birthDate before Today()
      and P.maritalStatus in "Marital Status"
      and P.maritalStatus ~ "Marital Status - Married"

define TestChoice:
  Patient P
    where P.deceased is false
      or P.deceased before Today()

define TestSlices:
  [Observation: "Blood pressure"] BP
    let
      SystolicBP: singleton from (BP.component C where C.code ~ "Systolic blood pressure"),
      DiastolicBP: singleton from (BP.component C where C.code ~ "Diastolic blood pressure")
    where SystolicBP.value < 140 'mm[Hg]'
      and DiastolicBP.value < 90 'mm[Hg]'

define TestSimpleExtensions:
  Patient P
    let birthsex: singleton from (P.extension E
      where E.url = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex')
    where birthsex.value = 'M'

define TestComplexExtensions:
  Patient P
    let
      race: singleton from (P.extension E
        where E.url = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race'),
      ombCategory: race.extension E where E.url = 'ombCategory',
      detailed: race.extension E where E.url = 'detailed'
    where exists (ombCategory O where O.value ~ "American Indian or Alaska Native")
      and exists (detailed D where D.value ~ "Alaska Native")
