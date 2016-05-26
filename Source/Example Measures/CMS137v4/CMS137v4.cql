library CMS137_QDM version '4'

using QDM

valueset "Drug Dependence": '2.16.840.1.113883.3.464.1003.106.12.1001'
valueset "Alcohol and Drug Dependence Treatment": '2.16.840.1.113883.3.464.1003.106.12.1005'
valueset "Detoxification Visit": '2.16.840.1.113883.3.464.1003.101.12.1059'
valueset "Discharge Services - Hospital Inpatient": '2.16.840.1.113883.3.464.1003.101.12.1007'
valueset "Discharge Services - Hospital Inpatient Same Day Discharge": '2.16.840.1.113883.3.464.1003.101.12.1006'
valueset "Emergency Department Visit": '2.16.840.1.113883.3.464.1003.101.12.1010'
valueset "Face-to-Face Interaction": '2.16.840.1.113883.3.464.1003.101.12.1048'
valueset "Hospital Inpatient Visit - Initial": '2.16.840.1.113883.3.464.1003.101.12.1004'
valueset "Hospital Observation Care - Initial": '2.16.840.1.113883.3.464.1003.101.12.1002'
valueset "Office Visit": '2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Psych Visit - Psychotherapy": '2.16.840.1.113883.3.526.3.1496'

parameter MeasurementPeriod Interval<DateTime>

context Patient

define InDemographic:
  AgeInYearsAt(start of MeasurementPeriod) >= 13

define ValidEncounters:
  ["Encounter, Performed: Office Visit"]
    union ["Encounter, Performed": "Emergency Department Visit"]
    union ["Encounter, Performed": "Detoxification Visit"]
    union ["Encounter, Performed": "Hospital Observation Care - Initial"]
    union ["Encounter, Performed": "Hospital Inpatient Visit - Initial"]
    union ["Encounter, Performed": "Discharge Services - Hospital Inpatient Same Day Discharge"]
    union ["Encounter, Performed": "Discharge Services - Hospital Inpatient"]
    union ["Encounter, Performed": "Face-to-Face Interaction"]

define EncountersDuringMeasurementPeriod:
  ValidEncounters E where Interval[E."start datetime", E."stop datetime"] during MeasurementPeriod

define ActiveAlcoholAndDrugDependenceDiagnosis:
    ["Diagnosis, Active": "Alcohol and Drug Dependence"]

define FirstAlcoholDrugDependenceInterval:
  Interval[start of MeasurementPeriod, start of MeasurementPeriod + 10 months]

define FirstAlcoholDrugDependence:
  First(
    ActiveAlcoholAndDrugDependenceDiagnosis A
      where A."start datetime" during FirstAlcoholDrugDependenceInterval
      sort by A."start datetime"
   )

define FirstAlcoholDrugDependenceDx:
  FirstAlcoholDrugDependence F
    where exists (
      EncountersDuringMeasurementPeriod E
        where Interval[F."start datetime", F."stop datetime"] intersect Interval[E."start datetime", E."stop datetime"]
     )

define InitialPopulation1:
  InDemographic
    and exists (FirstAlcoholDrugDependenceDx)

define Denominator1:
  InitialPopulation1

define DrugDependenceTreatmentOrPsychEncounters:
  ["Encounter, Performed": "Alcohol and Drug Dependence Treatment"]
    union ["Encounter, Performed": "Psych Visit - Psychotherapy"]

define DrugDependenceTreatmentOrPsychVisit:
  DrugDependenceTreatmentOrPsychEncounters D
    where exists (
      FirstAlcoholDrugDependenceDx F
        where Interval[F."start datetime", F."stop datetime"] starts 14 days or less after D."start datetime"
     )

define DenominatorExclusions1:
  ["Diagnosis, Active": "Alcohol and Drug Dependence"] D
    where exists (
      FirstAlcoholDrugDependenceDx F
        where Interval[D."start datetime", D."stop datetime"] starts 60 days or less after F."start datetime"

define Numerator1:
  DrugDependenceTreatmentOrPsychVisit

define Stratification1:
  AgeInYearsAt(start of MeasurementPeriod) >= 13
    and AgeInYearsAt(start of MeasurementPeriod) < 18

define Stratification2:
  AgeInYearsAt(start of MeasurementPeriod) >= 18

define InitialPopulation2:
  InDemographic
    and exists (FirstAlcoholDrugDependenceDx)

define Denominator2:
  InitialPopulation2

define DenominatorExclusions2:
  ["Diagnosis, Active": "Alcohol and Drug Dependence"] D
    where exists (
      FirstAlcoholDrugDependenceDx F
        where Interval[D."start datetime", D."stop datetime"] starts 60 days or less after F."start datetime"

define DrugDependenceTreatmentEncountersAMonthAfterDiagnosis:
  DrugDependenceTreatmentOrPsychEncounters D
    where exists (
      DrugDependenceTreatmentOrPsychVisit V
        where Interval[V."start datetime", V."stop datetime"] starts 30 days or less after D."start datetime"
     )

define Numerator2:
  Numerator1
    and Count(DrugDependenceTreatmentEncountersAMonthAfterDiagnosis) >= 2
