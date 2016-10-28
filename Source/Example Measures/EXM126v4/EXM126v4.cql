library EXM126_QDM version '4'

/*
This example is a work in progress and should not be considered a final specification
or recommendation for guidance. This example will help guide and direct the process
of finding conventions and usage patterns that meet the needs of the various stakeholders
in the measure development community.
*/

using QDM

valueset "Acute Respiratory Failure": '2.16.840.1.113883.3.464.1003.102.12.1018'
valueset "Chronic Obstructive Pulmonary Disease": '2.16.840.1.113883.3.464.1003.102.12.1007'
valueset "Cystic Fibrosis": '2.16.840.1.113883.3.464.1003.102.12.1002'
valueset "Emphysema": '2.16.840.1.113883.3.464.1003.102.12.1004'
valueset "Persistent Asthma": '2.16.840.1.113883.3.464.1003.102.12.1023'
valueset "Face-to-Face Interaction": '2.16.840.1.113883.3.464.1003.101.12.1048'
valueset "Home Healthcare Services": '2.16.840.1.113883.3.464.1003.101.12.1016'
valueset "Office Visit": '2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Preventive Care - Established Office Visit, 0 to 17": '2.16.840.1.113883.3.464.1003.101.12.1024'
valueset "Preventive Care Services - Established Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1023'
valueset "Preventive Care- Initial Office Visit, 0 to 17": '2.16.840.1.113883.3.464.1003.101.12.1022'
valueset "Preferred Asthma Therapy": '2.16.840.1.113883.3.464.1003.196.12.1212'

parameter MeasurementPeriod Interval<DateTime>

context Patient

define AcuteRespiratoryFailureDiagnoses: ["Diagnosis, Active": "Acute Respiratory Failure"]
define ChronicObstructivePulmonaryDiseaseDiagnoses: ["Diagnosis, Active": "Chronic Obstructive Pulmonary Disease"]
define CysticFibrosisDiagnoses: ["Diagnosis, Active": "Cystic Fibrosis"]
define EmphysemaDiagnoses: ["Diagnosis, Active": "Emphysema"]
define PersistentAsthmaDiagnoses: ["Diagnosis, Active": "Persistent Asthma"]
define FaceToFaceEncounter: ["Encounter, Performed": "Face-to-Face Interaction"]
define HomeHealthcareEncounter: ["Encounter, Performed": "Home Healthcare Services"]
define OfficeVisitEncounter: ["Encounter, Performed": "Office Visit"]
define EstablishedPreventiveCareForMinorEncounter: ["Encounter, Performed": "Preventive Care - Established Office Visit, 0 to 17"]
define EstablishedPreventiveCareForAdultEncounter: ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
define InitialPreventiveCareForAdultEncounter: ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
define InitialPreventiveCareForMinorEncounter: ["Encounter, Performed": "Preventive Care- Initial Office Visit, 0 to 17"]
define PreferredAsthmaTherapy: ["Medication, Dispensed": "Preferred Asthma Therapy"]

define InDemographic:
	AgeInYearsAt(start of MeasurementPeriod) >= 5
    and AgeInYearsAt(start of MeasurementPeriod) < 64

define ActivePersistentAsthmaDiagnosis:
  PersistentAsthmaDiagnoses A where Interval[A."start datetime", A."stop datetime"] overlaps MeasurementPeriod

define ValidEncounters:
  OfficeVisitEncounter
		union HomeHealthcareEncounter
		union FaceToFaceEncounter
		union EstablishedPreventiveCareForMinorEncounter
		union EstablishedPreventiveCareForAdultEncounter
		union InitialPreventiveCareForAdultEncounter
    union InitialPreventiveCareForMinorEncounter

define EncountersDuringMeasurementPeriod:
	ValidEncounters E where Interval[E."start datetime", E."stop datetime"] during MeasurementPeriod

define InitialPopulation:
  InDemographic
    and exists (ActivePersistentAsthmaDiagnosis)
    and exists (EncountersDuringMeasurementPeriod)

define Denominator:
  InitialPopulation

define ActiveDiagnoses:
  ChronicObstructivePulmonaryDiseaseDiagnoses
    union EmphysemaDiagnoses
    union CysticFibrosisDiagnoses
    union AcuteRespiratoryFailureDiagnoses

define ActiveDiagnosesDuringMeasurementPeriod:
  ActiveDiagnoses D where Interval[D."start datetime", D."stop datetime"] overlaps MeasurementPeriod

define DenominatorExclusions:
  exists (ActiveDiagnosesDuringMeasurementPeriod)

define Numerator:
  PreferredAsthmaTherapy P where Interval[P."start datetime", P."stop datetime"] during MeasurementPeriod

define Stratification1:
  AgeInYearsAt(start of MeasurementPeriod) >= 5
    and AgeInYearsAt(start of MeasurementPeriod) < 11

define Stratification2:
  AgeInYearsAt(start of MeasurementPeriod) >= 11
    and AgeInYearsAt(start of MeasurementPeriod) < 18

define Stratification3:
  AgeInYearsAt(start of MeasurementPeriod) >= 18
    and AgeInYearsAt(start of MeasurementPeriod) < 50

define Stratification4:
  AgeInYearsAt(start of MeasurementPeriod) >= 50
    and AgeInYearsAt(start of MeasurementPeriod) < 64
