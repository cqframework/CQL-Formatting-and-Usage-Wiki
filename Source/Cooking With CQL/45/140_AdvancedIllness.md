# Advanced Illness

[CQM-4021](https://oncprojectracking.healthit.gov/support/browse/CQM-4021)
[CMS130v9](https://ecqi.healthit.gov/ecqm/ep/2021/cms130v9)
[CQL Style Guide](https://ecqi.healthit.gov/tool/cql-style-guide)

CQLIT-223 re CMS130v9: Denominator Exclusion criteria, Outpatient Encounters with Advanced Illness

## Question:
Consider the scenarios for patients listed below with Outpatient Encounters with Advanced Illness:

**Patient1**
Patient1 has Outpatient Encounters with Diagnosis.code in "Advanced Illness" where:
* OutpatientEncounter.relevantPeriod starts: 1/1/2019 2pm
* OutpatientEncounter.relevantPeriod ends: 1/1/2019 8pm

**Patient2**
Patient2 has Outpatient Encounters with Diagnosis.code in "Advanced Illness" where:**
* OutpatientEncounter.relevantPeriod starts: 1/1/2018 2pm
* OutpatientEncounter.relevantPeriod ends: 1/1/2018 8pm

Help us understand, which of the above two patients will satisfy "FrailtyLTI.Outpatient Encounters with Advanced Illness" criteria?

The expression is referenced as part of the "Denominator Exclusion" as follows:

```
define "Denominator Exclusions":
  Hospice."Has Hospice"
    or exists "Malignant Neoplasm"
    or exists "Total Colectomy Performed"
    or FrailtyLTI."Advanced Illness and Frailty Exclusion Not Including Over Age 80"
    or ( exists ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      where ( Global."CalendarAgeInYearsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) >= 65 )
        and FrailtyLTI."Long Term Care Periods Longer Than 90 Consecutive Days"
    )
```

Your question pertains to the `FrailtyLTI."Advanced Illness and Frailty Exclusion Not Including Over Age 80"` expression which is defined in the `AdvancedIllnessandFrailtyExclusionECQM version '5.5.000' called FrailtyLTI` library. This definition is used because the Colorectal Cancer Screening measure restricts the Initial Population to age >=50 and < 75 at start of measurement period.

```
define "Advanced Illness and Frailty Exclusion Not Including Over Age 80":
  //If the measure does NOT include populations age 80 and older, then use this logic:
  exists ( ["Patient Characteristic Birthdate": "Birth date"] BirthDate
    where Global."CalendarAgeInYearsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) >= 65
      and "Has Criteria Indicating Frailty"
      and ( Count("Outpatient Encounters with Advanced Illness")>= 2
        or exists ( "Inpatient Encounter with Advanced Illness" )
        or exists "Dementia Medications In Year Before or During Measurement Period"
      )
  )
```

Note that this definition has multiple criteria including age 65 yr and older at onset of measurement period and "Has Criteria Indicating Frailty" which is as follows:

```
define "Has Criteria Indicating Frailty":
  exists ( ["Device, Order": "Frailty Device"] FrailtyDeviceOrder
    where FrailtyDeviceOrder.authorDatetime during "Measurement Period"
  )
  or exists ( ["Device, Applied": "Frailty Device"] FrailtyDeviceApplied
    where FrailtyDeviceApplied.relevantPeriod overlaps "Measurement Period"
  )
  or exists ( ["Diagnosis": "Frailty Diagnosis"] FrailtyDiagnosis
    where FrailtyDiagnosis.prevalencePeriod overlaps "Measurement Period"
  )
  or exists ( ["Encounter, Performed": "Frailty Encounter"] FrailtyEncounter
    where FrailtyEncounter.relevantPeriod overlaps "Measurement Period"
  )
  or exists ( ["Symptom": "Frailty Symptom"] FrailtySymptom
    where FrailtySymptom.prevalencePeriod overlaps "Measurement Period"
  )
```

Note the timing association with the Measurement Period. All these criteria must be met in addition to the last definition combination criteria which accepts Outpatient, Inpatient and Dementia Medication criteria.
Since your question references Outpatient we will restrict our focus to that criteria.

```
Count("Outpatient Encounters with Advanced Illness")>= 2
```

This returns true if there are two or more Encounters that meet the following criteria:

```
define "Outpatient Encounters with Advanced Illness":
  ( ["Encounter, Performed": "Outpatient"]
    union ["Encounter, Performed": "Observation"]
    union ["Encounter, Performed": "ED"]
    union ["Encounter, Performed": "Nonacute Inpatient"]
  ) OutpatientEncounter
    where exists ( OutpatientEncounter.diagnoses Diagnosis
        where Diagnosis.code in "Advanced Illness"
      )
      and OutpatientEncounter.relevantPeriod starts 2 years or less on or before end of "Measurement Period"
```

To qualify, an encounter must fulfill the required type of encounter with a diagnosis code included in the valueset "Advanced Illness": 'urn:oid:2.16.840.1.113883.3.464.1003.110.12.1082' on VSAC and the Outpatient Encounter must have started 2 years or less before the end of the Measurement Period.

As per our initial assumption that you were referencing the CMS130v9 for the 2021 Measurement Period, then the OutpatientEncounter.relevantPeriod must start two years or less before the end of 12/31/2021 so dates before 1/1/2020 would not be returned from the "Outpatient Encounters with Advanced Illness" expression.

If we modified your example Advanced Illness encounters to 1/1/2019 (F) and 1/1/2020 (T) would count as 1 encounter for "Outpatient Encounters with Advanced Illness" but two or more such encounters are required in 1/1/2020 – 12/31/2021 to meet "Advanced Illness and Frailty Exclusion Not Including Over Age 80" so again would not be returned from the "Outpatient Encounters with Advanced Illness" expression.

As a result, neither example would result in an encounter returning from the "Outpatient Encounters with Advanced Illness" expression.

Response by Peter Muir, MD
