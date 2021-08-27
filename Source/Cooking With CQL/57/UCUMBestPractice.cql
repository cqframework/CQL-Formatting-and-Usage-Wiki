library UCUMBestPractice

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon called Common

codesystem ObservationCategoryCodes: 'http://terminology.hl7.org/CodeSystem/observation-category'
codesystem UCUM: 'http://unitsofmeasure.org'

valueset "BMI percentile": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.121.12.1012'

code "[in_i]": '[in_i]' from UCUM
code "[lb_av]": '[lb_av]' from UCUM
code "cm": 'cm' from UCUM
code "g": 'g' from UCUM
code "kg": 'kg' from UCUM
code "kg/m2": 'kg/m2' from UCUM

code "vital-signs": 'vital-signs' from ObservationCategoryCodes
code "Body mass index (BMI) [Ratio]": '39156-5' from Common.LOINC

parameter "Measurement Period" Interval<DateTime>

context Patient

define "BMI Percentile in Measurement Period":
  [Observation: "BMI percentile"] BMIPercentile
    where BMIPercentile.status in {'final', 'amended', 'corrected'}
      and BMIPercentile.effective during "Measurement Period"
      and BMIPercentile.value is not null
      and BMIPercentile.value.code = 'kg/m2'
