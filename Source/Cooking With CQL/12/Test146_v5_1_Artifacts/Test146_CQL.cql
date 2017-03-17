library Test146 version '0.0.001'

using QDM version '5.0.2'

valueset "Acute Tonsillitis": 'urn:oid:2.16.840.1.113883.3.464.1003.102.12.1012'

valueset "Ambulatory/ED Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1061'

valueset "Acute Pharyngitis": 'urn:oid:2.16.840.1.113883.3.464.1003.102.12.1011'

valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'

valueset "Antibiotic Medications for Pharyngitis": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1001'

valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'

valueset "Group A Streptococcus Test": 'urn:oid:2.16.840.1.113883.3.464.1003.198.12.1012'

valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity": ["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer": ["Patient Characteristic Payer": "Payer"]

define "SDE Race": ["Patient Characteristic Race": "Race"]

define "SDE Sex": ["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Diagnosis: Acute Tonsillitis": ["Diagnosis": "Acute Tonsillitis"]

define "Diagnosis: Acute Pharyngitis": ["Diagnosis": "Acute Pharyngitis"]

define "Encounter, Performed: Ambulatory or ED Visit": ["Encounter, Performed": "Ambulatory/ED Visit"]

define "Laboratory Test, Performed: Group A Streptococcus Test": ["Laboratory Test, Performed": "Group A Streptococcus Test"]

define "Medication, Active: Antibiotic Medications for Pharyngitis": ["Medication, Active": "Antibiotic Medications for Pharyngitis"]

define "Medication, Order: Antibiotic Medications for Pharyngitis": ["Medication, Order": "Antibiotic Medications for Pharyngitis"]

define "Initial Population": "Occurrence A of Encounter, Performed: Ambulatory or ED Visit" E
    where AgeInYearsAt(start of "Measurement Period") >= 3
      and AgeInYearsAt(start of "Measurement Period") < 18
      and exists (
        "Occurrence A of Diagnosis: Acute Pharyngitis"
          union "Occurrence A of Diagnosis: Acute Tonsillitis"
      )

define "Occurrence A of Encounter, Performed: Ambulatory or ED Visit": "Encounter, Performed: Ambulatory or ED Visit" E
    with "Medication, Order: Antibiotic Medications for Pharyngitis" M
      such that M.activeDatetime 3 days or less after start of E.relevantPeriod
    where E.relevantPeriod during "Measurement Period"

define "Occurrence A of Diagnosis: Acute Pharyngitis": "Diagnosis: Acute Pharyngitis" D
    with "Occurrence A of Encounter, Performed: Ambulatory or ED Visit" E
      such that D.prevalencePeriod starts during E.relevantPeriod
        or D.prevalencePeriod includes E.relevantPeriod

define "Occurrence A of Diagnosis: Acute Tonsillitis": "Diagnosis: Acute Tonsillitis" D
    with "Occurrence A of Encounter, Performed: Ambulatory or ED Visit" E
      such that D.prevalencePeriod starts during E.relevantPeriod
        or D.prevalencePeriod includes E.relevantPeriod

define "Denominator": "Initial Population"

define "Denominator Exclusions": "Occurrence A of Encounter, Performed: Ambulatory or ED Visit" E
    where exists (
      "Medication, Active: Antibiotic Medications for Pharyngitis" M
        with ("Occurrence A of Diagnosis: Acute Pharyngitis" union "Occurrence A of Diagnosis: Acute Tonsillitis") D
          such that M.relevantPeriod starts 29 days or less before start of D.prevalencePeriod
    )
    or exists (
      "Medication, Active: Antibiotic Medications for Pharyngitis" M
        with ("Occurrence A of Diagnosis: Acute Pharyngitis" union "Occurrence A of Diagnosis: Acute Tonsillitis") D
          such that M.relevantPeriod starts 29 days or more before start of D.prevalencePeriod
            and not (M.relevantPeriod ends 29 days or more before start of D.prevalencePeriod)
    )

define "Numerator": "Occurrence A of Encounter, Performed: Ambulatory or ED Visit" E
    with "Laboratory Test, Performed: Group A Streptococcus Test (result)" L
      such that L.relevantPeriod starts within 3 days of end of E.relevantPeriod

define "Laboratory Test, Performed: Group A Streptococcus Test (result)": "Laboratory Test, Performed: Group A Streptococcus Test" L
    where L.result is not null
