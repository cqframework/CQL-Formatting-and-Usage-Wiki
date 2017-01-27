library CMS53 version '4.0.0'

using QDM version '5.0.2'

valueset "Cardiopulmonary arrest Grouping Value Set": 'urn:oid:2.16.840.1.113883.3.666.5.748'
valueset "Electrocardiogram (ECG) Grouping Value Set": 'urn:oid:2.16.840.1.113883.3.666.5.735'
valueset "Emergency Department Visit SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'
valueset "Encounter Inpatient SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Fibrinolytic Therapy RXNORM Value Set": 'urn:oid:2.16.840.1.113883.3.666.5.736'
valueset "Aortic balloon pump insertion SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113883.3.666.5.1151'
valueset "Endotracheal Intubation Grouping Value Set": 'urn:oid:2.16.840.1.113762.1.4.1045.69'
valueset "PCI Grouping Value Set": 'urn:oid:2.16.840.1.113762.1.4.1045.67'
valueset "Ventricular Assist Device placement Grouping Value Set": 'urn:oid:2.16.840.1.113883.3.666.5.3015'
valueset "Ambulatory surgical center SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113883.3.666.5.687'
valueset "Transfer From Emergency Department (ED) Locations SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113883.3.666.5.3006'
valueset "Transfer From Inpatient SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113883.3.666.5.3013'
valueset "Transfer From Outpatient SNOMEDCT Value Set": 'urn:oid:2.16.840.1.113883.3.67.1.101.950'
valueset "STEMI Exclusions Grouping Value Set": 'urn:oid:2.16.840.1.113762.1.4.1045.36'
valueset "Acute Myocardial Infarction (AMI) Grouping Value Set": 'urn:oid:2.16.840.1.113883.3.666.5.3011'
valueset "Acute or Evolving MI Grouping Value Set": 'urn:oid:2.16.840.1.113883.3.666.5.3022'

valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
Population Criteria

    Initial Population =
        AND: Age>= 18 year(s) at: Occurrence A of $EncounterInpatient
        AND: Intersection of:
            Occurrence A of $EncounterInpatient
            "Encounter, Performed: Encounter Inpatient (principal diagnosis: Acute Myocardial Infarction (AMI))"
    Denominator =
        AND: Initial Population
        AND:
            OR:
                AND: "Occurrence A of Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient
                AND:
                    OR: Most Recent: "Occurrence A of Diagnostic Study, Performed: Electrocardiogram (ECG)" <= 1 hour(s) starts before start of "Occurrence A of Encounter, Performed: Emergency Department Visit"
                    OR: First: "Occurrence A of Diagnostic Study, Performed: Electrocardiogram (ECG)" starts during "Occurrence A of Encounter, Performed: Emergency Department Visit"
                    OR: First: "Occurrence A of Diagnostic Study, Performed: Electrocardiogram (ECG)" starts during Occurrence A of $EncounterInpatient
            OR:
                AND NOT: "Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient
                AND:
                    OR: Most Recent: "Occurrence A of Diagnostic Study, Performed: Electrocardiogram (ECG)" <= 1 hour(s) starts before start of Occurrence A of $EncounterInpatient
                    OR: First: "Occurrence A of Diagnostic Study, Performed: Electrocardiogram (ECG)" starts during Occurrence A of $EncounterInpatient
        AND: "Occurrence A of Diagnostic Study, Performed: Electrocardiogram (ECG) (result: Acute or Evolving MI)"
        AND NOT: "Occurrence A of Diagnostic Study, Performed: Electrocardiogram (ECG) (result: STEMI Exclusions)"
        AND:
            OR:
                AND: First: "Occurrence A of Procedure, Performed: PCI" <= 1440 minute(s) starts after start of Occurrence A of $EncounterInpatient
                AND NOT: "Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient
                AND NOT: "Occurrence A of Procedure, Performed: PCI" starts after start of ("Medication, Administered: Fibrinolytic Therapy" during Occurrence A of $EncounterInpatient )
            OR:
                AND: "Occurrence A of Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient
                AND: First: "Occurrence A of Procedure, Performed: PCI" <= 1440 minute(s) starts after start of "Occurrence A of Encounter, Performed: Emergency Department Visit"
                AND NOT: "Occurrence A of Procedure, Performed: PCI" starts after start of ("Medication, Administered: Fibrinolytic Therapy" starts after start of "Occurrence A of Encounter, Performed: Emergency Department Visit" )
    Denominator Exclusions =
        OR: $AnotherHospitalOrHealthcareFacility <= 1 day(s) starts before or concurrent with start of ("Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient )
        OR:
            AND: $AnotherHospitalOrHealthcareFacility <= 1 day(s) starts before or concurrent with start of Occurrence A of $EncounterInpatient
            AND NOT: "Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient
    Numerator =
        AND:
            OR:
                AND: "Occurrence A of Procedure, Performed: PCI" <= 90 minute(s) starts after start of Occurrence A of $EncounterInpatient
                AND NOT: "Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient
            OR: "Occurrence A of Procedure, Performed: PCI" <= 90 minute(s) starts after start of ("Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient )
    Numerator Exclusions =
        None
    Denominator Exceptions =
        OR: $ReasonForNoPCI <= 90 minute(s) starts after start of ("Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient )
        OR:
            AND: $ReasonForNoPCI <= 90 minute(s) starts after start of Occurrence A of $EncounterInpatient
            AND NOT: "Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient
    Stratification =
        None

Data Criteria (QDM Variables)

    $AnotherHospitalOrHealthcareFacility =
        Union of:
            "Transfer From: Ambulatory surgical center"
            "Transfer From: Transfer From Outpatient"
            "Transfer From: Transfer From Emergency Department (ED) Locations"
            "Transfer From: Transfer From Inpatient"
    $EncounterInpatient =
        "Encounter, Performed: Encounter Inpatient" satisfies all:
            (length of stay <= 120 day(s))
            ends during "Measurement Period"
    $ReasonForNoPCI =
        Union of:
            "Diagnosis: Cardiopulmonary arrest"
            "Procedure, Performed: Endotracheal Intubation"
            "Procedure, Performed: Aortic balloon pump insertion"
            "Procedure, Performed: Ventricular Assist Device placement"

Data Criteria (QDM Data Elements)

    "Diagnosis: Cardiopulmonary arrest" using "Cardiopulmonary arrest Grouping Value Set (2.16.840.1.113883.3.666.5.748)"
    "Diagnostic Study, Performed: Electrocardiogram (ECG)" using "Electrocardiogram (ECG) Grouping Value Set (2.16.840.1.113883.3.666.5.735)"
    "Encounter, Performed: Emergency Department Visit" using "Emergency Department Visit SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.292)"
    "Encounter, Performed: Encounter Inpatient" using "Encounter Inpatient SNOMEDCT Value Set (2.16.840.1.113883.3.666.5.307)"
    "Medication, Administered: Fibrinolytic Therapy" using "Fibrinolytic Therapy RXNORM Value Set (2.16.840.1.113883.3.666.5.736)"
    "Procedure, Performed: Aortic balloon pump insertion" using "Aortic balloon pump insertion SNOMEDCT Value Set (2.16.840.1.113883.3.666.5.1151)"
    "Procedure, Performed: Endotracheal Intubation" using "Endotracheal Intubation Grouping Value Set (2.16.840.1.113762.1.4.1045.69)"
    "Procedure, Performed: PCI" using "PCI Grouping Value Set (2.16.840.1.113762.1.4.1045.67)"
    "Procedure, Performed: Ventricular Assist Device placement" using "Ventricular Assist Device placement Grouping Value Set (2.16.840.1.113883.3.666.5.3015)"
    "Transfer From: Ambulatory surgical center" using "Ambulatory surgical center SNOMEDCT Value Set (2.16.840.1.113883.3.666.5.687)"
    "Transfer From: Transfer From Emergency Department (ED) Locations" using "Transfer From Emergency Department (ED) Locations SNOMEDCT Value Set (2.16.840.1.113883.3.666.5.3006)"
    "Transfer From: Transfer From Inpatient" using "Transfer From Inpatient SNOMEDCT Value Set (2.16.840.1.113883.3.666.5.3013)"
    "Transfer From: Transfer From Outpatient" using "Transfer From Outpatient SNOMEDCT Value Set (2.16.840.1.113883.3.67.1.101.950)"
    Attribute: "Result: STEMI Exclusions" using "STEMI Exclusions Grouping Value Set (2.16.840.1.113762.1.4.1045.36)"
    Attribute: "Principal diagnosis: Acute Myocardial Infarction (AMI)" using "Acute Myocardial Infarction (AMI) Grouping Value Set (2.16.840.1.113883.3.666.5.3011)"
    Attribute: "Result: Acute or Evolving MI" using "Acute or Evolving MI Grouping Value Set (2.16.840.1.113883.3.666.5.3022)"

Supplemental Data Elements

    "Patient Characteristic Ethnicity: Ethnicity" using "Ethnicity CDCREC Value Set (2.16.840.1.114222.4.11.837)"
    "Patient Characteristic Payer: Payer" using "Payer SOP Value Set (2.16.840.1.114222.4.11.3591)"
    "Patient Characteristic Race: Race" using "Race CDCREC Value Set (2.16.840.1.114222.4.11.836)"
    "Patient Characteristic Sex: ONC Administrative Sex" using "ONC Administrative Sex AdministrativeGender Value Set (2.16.840.1.113762.1.4.1)"

Risk Adjustment Variables

    None
*/

define "SDE Ethnicity":
  ["Patient Characteristic Ethnicity": "Ethnicity"] Characteristic
    return Characteristic.code

define "SDE Payer":
  ["Patient Characteristic Payer": "Payer"] Characteristic
    return Characteristic.code

define "SDE Race":
  ["Patient Characteristic Race": "Race"] Characteristic
    return Characteristic.code

define "SDE Sex":
  ["Patient Characteristic Sex": "ONC Administrative Sex"] Characteristic
    return Characteristic.code
