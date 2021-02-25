library HospitalHarmVTEPharmacoprophylaxisRelatedMajorBleeding version '0.1.055'

using QDM version '5.5'

include MATGlobalCommonFunctions version '6.2.000' called Global

codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'

valueset "Anticoagulants for Indications Other than VTE Prophylaxis": 'urn:oid:2.16.840.1.113762.1.4.1147.131'
valueset "Anticoagulants for VTE Prophylaxis": 'urn:oid:2.16.840.1.113762.1.4.1147.130'
valueset "Bleeding at Critical Site": 'urn:oid:2.16.840.1.113762.1.4.1147.135'
valueset "Bleeding at Non Critical Site": 'urn:oid:2.16.840.1.113762.1.4.1147.125'
valueset "Blood Transfusion Administration": 'urn:oid:2.16.840.1.113762.1.4.1029.209'
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Hemoglobin lab test": 'urn:oid:2.16.840.1.113762.1.4.1045.131'
valueset "Hospital based dialysis services": 'urn:oid:2.16.840.1.113762.1.4.1179.4'
valueset "Obstetrics": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.263'
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'

code "Birth date": '21112-8' from "LOINC" display 'Birth date'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Blood Transfusion Indicative of Bleeding Event":
  exists ( from
      ["Procedure, Performed": "Blood Transfusion Administration"] BloodTransfusion,
      ["Medication, Administered": "Anticoagulants for VTE Prophylaxis"] AnticoagulantMedication,
      "Qualifying Encounters" QualifyingEncounter
      where BloodTransfusion.relevantPeriod ends 120 hours or less after AnticoagulantMedication.relevantDatetime
        and BloodTransfusion.relevantPeriod during Global."HospitalizationWithObservation" ( QualifyingEncounter )
        and BloodTransfusion.relevantPeriod starts 48 hours or more after start of Global."HospitalizationWithObservation" ( QualifyingEncounter )
        and AnticoagulantMedication.relevantDatetime during Global."HospitalizationWithObservation" ( QualifyingEncounter )
  )

define "Denominator":
  "Initial Population"

define "Denominator Exclusions":
  "Encounters With Dialysis Procedure"
    union "Encounters With Pregnancy or Obstetric Care"
    union "Encounters With Anticoagulants for Other Indications"

define "Encounters With Anticoagulants for Other Indications":
  "Qualifying Encounters" QualifyingEncounter
    with ["Medication, Administered": "Anticoagulants for Indications Other than VTE Prophylaxis"] AnticoagsForOtherIndications
      such that AnticoagsForOtherIndications.relevantDatetime during Global."HospitalizationWithObservation" ( QualifyingEncounter )

define "Encounters With Anticoagulants For VTE Prophylaxis":
  "Qualifying Encounters" QualifyingEncounter
    with ["Medication, Administered": "Anticoagulants for VTE Prophylaxis"] AnticoagulantsForVTE
      such that AnticoagulantsForVTE.relevantDatetime during Global."HospitalizationWithObservation" ( QualifyingEncounter )

define "Encounters With Critical Bleeding Diagnosis":
  from
    "Qualifying Encounters" QualifyingEncounter,
    ["Diagnosis": "Bleeding at Critical Site"] BleedingDiagnosis,
    ["Medication, Administered": "Anticoagulants for VTE Prophylaxis"] AnticoagulantMedication
    where BleedingDiagnosis.prevalencePeriod during Global."HospitalizationWithObservation" ( QualifyingEncounter )
      and BleedingDiagnosis.prevalencePeriod starts 120 hours or less after AnticoagulantMedication.relevantDatetime
      and AnticoagulantMedication.relevantDatetime during Global."HospitalizationWithObservation" ( QualifyingEncounter )
    return QualifyingEncounter

define "Encounters With Dialysis Procedure":
  "Qualifying Encounters" QualifyingEncounter
    with ["Procedure, Performed": "Hospital based dialysis services"] Dialysis
      such that Dialysis.relevantPeriod overlaps Global."HospitalizationWithObservation" ( QualifyingEncounter )

define "Encounters With Pregnancy or Obstetric Care":
  "Qualifying Encounters" QualifyingEncounter
    with ["Diagnosis": "Obstetrics"] ObstetricCare
      such that ObstetricCare.prevalencePeriod overlaps Global."HospitalizationWithObservation" ( QualifyingEncounter )

define "Encounters With Two Bleeding Event Factors Without a Diagnosis of Bleeding":
  from
    "Qualifying Encounters" QualifyingEncounter,
    "Blood Transfusion Indicative of Bleeding Event" BloodTransfusion,
    "Hemoglobin Lab Tests Indicative of Bleeding Event" HemoglobinDecrease
    where ( BloodTransfusion isTrue )
      and ( HemoglobinDecrease isTrue )
    return QualifyingEncounter

define "Follow Up Hemoglobin Lab Tests Within 5 Days of Anticoagulant Medication":
  exists ( from
      ["Laboratory Test, Performed": "Hemoglobin lab test"] FirstHemoglobinLabResult,
      ["Laboratory Test, Performed": "Hemoglobin lab test"] SecondHemoglobinLabResult,
      "Qualifying Encounters" QualifyingEncounter,
      ["Medication, Administered": "Anticoagulants for VTE Prophylaxis"] AnticoagulantMedication
      where FirstHemoglobinLabResult.relevantDatetime 120 hours or less after AnticoagulantMedication.relevantDatetime
        and SecondHemoglobinLabResult.relevantDatetime 120 hours or less after AnticoagulantMedication.relevantDatetime
        and AnticoagulantMedication.relevantDatetime during Global."HospitalizationWithObservation" ( QualifyingEncounter )
        and FirstHemoglobinLabResult.id != SecondHemoglobinLabResult.id
  )

define "Hemoglobin Lab Tests Indicative of Bleeding Event":
  exists ( from
      "Follow Up Hemoglobin Lab Tests Within 5 Days of Anticoagulant Medication" HemoglobinLabAntiCoagulant,
      "Absolute Decrease of 2 g dL Between Hemoglobin Lab Tests" HemoglobinLabAbsoluteDecrease,
      "Qualifying Encounters" QualifyingEncounter
      where ( HemoglobinLabAntiCoagulant isTrue )
        and ( HemoglobinLabAbsoluteDecrease isTrue )
  )

define "Initial Population":
  "Encounters With Anticoagulants For VTE Prophylaxis"

define "Numerator":
  "Encounters With Critical Bleeding Diagnosis"
    union "Encounters With Two Bleeding Event Factors Without a Diagnosis of Bleeding"
    union "Encounters With One Bleeding Event Factor With Diagnosis of Non Critical Bleeding"

define "SDE Ethnicity":
  ["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer":
  ["Patient Characteristic Payer": "Payer"]

define "SDE Race":
  ["Patient Characteristic Race": "Race"]

define "SDE Sex":
  ["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Qualifying Encounters":
  ["Encounter, Performed": "Encounter Inpatient"] InpatientEncounter
    with ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      such that InpatientEncounter.relevantPeriod ends during "Measurement Period"
        and Global."CalendarAgeInYearsAt" ( BirthDate.birthDatetime, start of Global."HospitalizationWithObservation" ( InpatientEncounter ) ) >= 18

define "Absolute Decrease of 2 g dL Between Hemoglobin Lab Tests":
  exists ( from
      ["Laboratory Test, Performed": "Hemoglobin lab test"] FirstHemoglobinLabResult,
      ["Laboratory Test, Performed": "Hemoglobin lab test"] SecondHemoglobinLabResult,
      "Qualifying Encounters" QualifyingEncounter
      where ( ( FirstHemoglobinLabResult.result as Quantity ) - ( SecondHemoglobinLabResult.result as Quantity ) ) >= 2 'g/dL'
        and FirstHemoglobinLabResult.relevantDatetime 48 hours or less before or on SecondHemoglobinLabResult.relevantDatetime
        and FirstHemoglobinLabResult.relevantDatetime during Global."HospitalizationWithObservation" ( QualifyingEncounter )
        and SecondHemoglobinLabResult.relevantDatetime during Global."HospitalizationWithObservation" ( QualifyingEncounter )
        and FirstHemoglobinLabResult.relevantDatetime 24 hours or more after start of Global."HospitalizationWithObservation" ( QualifyingEncounter )
        and FirstHemoglobinLabResult.id != SecondHemoglobinLabResult.id
  )

define "Non Critical Bleeding Diagnosis Within 5 Days of Anticoagulant Medication":
  exists ( from
      ["Medication, Administered": "Anticoagulants for VTE Prophylaxis"] AnticoagulantMedication,
      ["Diagnosis": "Bleeding at Non Critical Site"] NonCriticalBleedingDiagnosis,
      "Qualifying Encounters" QualifyingEncounter
      where NonCriticalBleedingDiagnosis.prevalencePeriod starts 120 hours or less after AnticoagulantMedication.relevantDatetime
        and NonCriticalBleedingDiagnosis.prevalencePeriod during Global."HospitalizationWithObservation" ( QualifyingEncounter )
        and AnticoagulantMedication.relevantDatetime during Global."HospitalizationWithObservation" ( QualifyingEncounter )
  )

define "Encounters With One Bleeding Event Factor With Diagnosis of Non Critical Bleeding":
  from
    "Qualifying Encounters" QualifyingEncounter,
    "Non Critical Bleeding Diagnosis Within 5 Days of Anticoagulant Medication" NonCriticalBleedingDiagnosis,
    "Blood Transfusion Indicative of Bleeding Event" BloodTransfusion,
    "Hemoglobin Lab Tests Indicative of Bleeding Event" HemoglobinDecrease
    where ( NonCriticalBleedingDiagnosis isTrue )
      and ( ( HemoglobinDecrease isTrue )
          or ( BloodTransfusion isTrue )
      )
    return QualifyingEncounter