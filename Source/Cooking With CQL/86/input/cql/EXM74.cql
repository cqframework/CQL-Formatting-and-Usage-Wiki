/*
@source: https://github.com/cqframework/ecqm-content-qicore-2024-subset/blob/main/input/cql/PrimaryCariesPreventionasOfferedbyDentistsFHIR.cql
*/
library EXM74 version '0.0.002'

using QICore version '4.1.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include SupplementalDataElements version '3.5.000' called SDE
include QICoreCommon version '2.1.000' called QICoreCommon
include Status version '1.8.000' called Status

valueset "Clinical Oral Evaluation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.125.12.1003'
valueset "Discharged to Health Care Facility for Hospice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.207'
valueset "Discharged to Home for Hosice Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.209'
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'
valueset "Fluoride Varnish Application for Children": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.125.12.1002'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2025-01-01T00:00:00.000Z, @2025-12-31T23:59:59.999Z]

context Patient

define "Initial Population":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[1, 20]
    and exists ( "Qualifying Encounters" )

define "Qualifying Encounters":
  ( ( [Encounter: "Clinical Oral Evaluation"] ).isEncounterPerformed ( ) ) ValidEncounter
    where ValidEncounter.period during day of "Measurement Period"

define "Denominator":
  "Initial Population"

define "Numerator":
  Count((([Procedure: "Fluoride Varnish Application for Children"]).isProcedurePerformed()) FluorideApplication
      where FluorideApplication.performed.toInterval() ends during day of "Measurement Period"
      return distinct date from 
      end of FluorideApplication.performed.toInterval()
  ) >= 2

define "Stratification 1":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[1, 5]

define "Stratification 2":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[6, 12]

define "Stratification 3":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[13, 20]

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"