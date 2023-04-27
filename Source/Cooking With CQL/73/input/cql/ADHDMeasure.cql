/*
NOTE: This library is based on in-progress work on an ADHD measure. 
The logic is known incomplete and the value sets have not been committed to the repository. 
To run these examples, the appropriate value sets would need to be retrieved and housed 
locally in the vocabulary/valueset/external folder.
*/
library ADHDMeasure version '0.0.001'

using QICore version '4.1.1'

include FHIRHelpers version '4.2.000' called FHIRHelpers
include SupplementalDataElements version '3.2.000' called SDE
include QICoreCommon version '1.3.000' called QICoreCommon
include CQMCommon version '1.1.000' called CQMCommon
include Hospice version '6.4.000' called Hospice
include CumulativeMedicationDuration version '3.1.000' called CMD

codesystem "RXNORM": 'http://www.nlm.nih.gov/research/umls/rxnorm' 

valueset "Ambulatory": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.122.12.1003' 
valueset "Atomoxetine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1170' 
valueset "Behavioral Health Follow up Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1054' 
valueset "Clonidine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1171' 
valueset "Dexmethylphenidate": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1172' 
valueset "Dextroamphetamine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1173' 
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307' 
valueset "Guanfacine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.196.11.1252' 
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016' 
valueset "Initial Hospital Observation Care": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1002' 
valueset "Lisdexamfetamine": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1174' 
valueset "Mental Behavioral and Neurodevelopmental Disorders": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.105.12.1203' 
valueset "Methylphenidate": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.1176' 
valueset "Narcolepsy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.114.12.1011' 
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089' 
valueset "Outpatient Consultation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1008' 
valueset "Preventive Care Services Group Counseling": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1027' 
valueset "Preventive Care Services Individual Counseling": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1026' 
valueset "Preventive Care Services, Initial Office Visit, 0 to 17": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1022' 
valueset "Preventive Care, Established Office Visit, 0 to 17": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1024' 
valueset "Psych Visit Diagnostic Evaluation": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1492' 
valueset "Psych Visit Psychotherapy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1496' 
valueset "Psychotherapy and Pharmacologic Management": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1055' 
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080' 

code "24 HR dexmethylphenidate hydrochloride 40 MG Extended Release Oral Capsule": '1006608' from "RXNORM" display '24 HR dexmethylphenidate hydrochloride 40 MG Extended Release Oral Capsule'
code "methamphetamine hydrochloride 5 MG Oral Tablet": '977860' from "RXNORM" display 'methamphetamine hydrochloride 5 MG Oral Tablet'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2024-01-01T00:00:00.0, @2025-01-01T00:00:00.0)

context Patient

define "Intake Period":
  Interval["March 1 of Year Prior to Measurement Period", "Last Calendar Day of February of Measurement Period"]
    
define "Last Calendar Day of February of Measurement Period":
  ( DateTime(year from start of "Measurement Period", 3, 1, 23, 59, 59, 0, 0)) - 1 day
    
define "March 1 of Year Prior to Measurement Period":
  DateTime((year from start of "Measurement Period" - 1), 3, 1, 0, 0, 0, 0, 0)

// PJM DISPLAY ONLY Age
define "Display Age in years at start of Intake Period":
  AgeInYearsAt(date from start of "Intake Period")

//PJM
define "DISPLAY ALL ADHD Medication Prescribed":
  ( ["MedicationRequest": "Atomoxetine"]
    union ["MedicationRequest": "Clonidine"]
    union ["MedicationRequest": "Dexmethylphenidate"]
    union ["MedicationRequest": "Dextroamphetamine"]
//    union ["MedicationRequest": "Lisdexamfetamine"]
//    union ["MedicationRequest": "methamphetamine hydrochloride 5 MG Oral Tablet"]
//    union ["MedicationRequest": "Methylphenidate"]
//    union ["MedicationRequest": "Guanfacine"] 
  ) ADHDMedRequest
    where ADHDMedRequest is not null
    return Tuple {
      AuthorDate: ADHDMedRequest.authoredOn,
      RxPeriod: CMD."MedicationRequestPeriod"(ADHDMedRequest),
      SupplyDuration: ADHDMedRequest.dispenseRequest.expectedSupplyDuration,
      Rx: ADHDMedRequest.medication,
      RequestId: ADHDMedRequest.id
    } sort by AuthorDate

define "Active ADHD Medication Prescription":
  (["MedicationRequest": "Atomoxetine"]
      union ["MedicationRequest": "Clonidine"]
      union ["MedicationRequest": "Dexmethylphenidate"]
      union ["MedicationRequest": "Dextroamphetamine"]
  ) ADHDMedications
  where ADHDMedications.status in { 'active', 'completed' }
      and ADHDMedications.intent in { 'order', 'original-order', 'reflex-order', 'filler-order', 'instance-order' }
      and ADHDMedications.doNotPerform is not true

/*Note relevantPeriod.low represents the interval's lower boundary and its usage is to ensure appropriate evaluation of the coalesce.*/
define "ADHD Medication Prescribed During Intake Period and Not Previously on ADHD Medication":
 ( ( "Active ADHD Medication Prescription" ADHDMedications
      where CMD."MedicationRequestPeriod"(ADHDMedications) starts during "Intake Period" ) ADHDMedicationOrder
      without "Active ADHD Medication Prescription" ActiveADHDMedication
        such that CMD."MedicationRequestPeriod"(ActiveADHDMedication) ends 120 days or more before start of CMD."MedicationRequestPeriod"(ADHDMedicationOrder)
  ) QualifyingMed
    return all {
        startDate: start of CMD."MedicationRequestPeriod"(QualifyingMed) 
      } sort by startDate asc 

/*
Good Scenario                      Intake    |--------------------------------------------------------------|
    |------------------------|                     |------------------------------------------|
                                                                             |---------------------------------------------------|


Rule out Scenario
    |-------------------------------------------------------|      
                                                |------------------------------------------|
                                                                             |---------------------------------------------------|
*/

/*Index Prescription Start Date (IPSD)*/
define "IPSD":
 "First ADHD Medication Prescribed During Intake Period"
     
define "First ADHD Medication Prescribed During Intake Period":
  First("ADHD Medication Prescribed During Intake Period and Not Previously on ADHD Medication".startDate)

define "Qualifying Encounter":
  ( ["Encounter": "Office Visit"]
    union ["Encounter": "Home Healthcare Services"]
    union ["Encounter": "Preventive Care, Established Office Visit, 0 to 17"]
    union ["Encounter": "Preventive Care Services, Initial Office Visit, 0 to 17"] ) ValidEncounters
    where QICoreCommon."ToInterval" ( ValidEncounters.period ) during day of Interval["IPSD" - 6 months, "IPSD"]
  
define "Initial Population 1":
    AgeInYearsAt(date from start of "Intake Period")>= 6
        and AgeInYearsAt(date from 
          end of "Intake Period"
        )<= 12
        and exists "Qualifying Encounter"
//          and "First ADHD Medication Prescribed During Intake Period" is not null
//          and not exists "Inpatient Stay with Qualifying Diagnosis During Initiation Phase"

     
