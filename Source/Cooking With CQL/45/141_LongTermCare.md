# Long Term Care

[CQM-4019](https://oncprojectracking.healthit.gov/support/browse/CQM-4019)
[CMS130v9](https://ecqi.healthit.gov/ecqm/ep/2021/cms130v9)
[CQL Style Guide](https://ecqi.healthit.gov/tool/cql-style-guide)
[CQL Author's Guide](https://cql.hl7.org/2020May/02-authorsguide.html)

CQLIT-222 re CMS130v9: Denominator Exclusion criteria - Long Term Care Periods Longer Than 90 Consecutive Days

## Question:
Consider the scenarios for patients listed below:
We are referring to CMS 130 version 9 which is for Reporting year 2021

**Measurement period 1 Jan 2021 to 31 Dec 2021**

**Patient 1**
* LongTermFacilityEncounter.relevantPeriod starts:31 Dec 2020
* LongTermFacilityEncounter.relevantPeriod ends:2 April 2021 CQL calculates as 1/1-4/2 > 90

**Patient 2**
* LongTermFacilityEncounter.relevantPeriod starts:1 Jan 2021
* LongTermFacilityEncounter.relevantPeriod ends:28 Feb 2021 CQL calculates as 1/1-2/28 < 90
* LongTermFacilityEncounter.relevantPeriod starts:1 March 2021
* LongTermFacilityEncounter.relevantPeriod ends:15 March 2021 CQL calculates as 3/1-3/15 < 90
* LongTermFacilityEncounter.relevantPeriod starts:1 March 2021
* LongTermFacilityEncounter.relevantPeriod ends:31 March 2021 CQL calculates as 3/1-3/31 < 90

**Patient 3**
* LongTermFacilityEncounter.relevantPeriod starts:1 Jan 2021
* LongTermFacilityEncounter.relevantPeriod ends:28 Feb 2021 CQL calculates as 1/1-2/28 < 90
* LongTermFacilityEncounter.relevantPeriod starts:1 March 2021
* LongTermFacilityEncounter.relevantPeriod ends:15 March 2021 CQL calculates as 3/1-3/15 < 90
* LongTermFacilityEncounter.relevantPeriod starts:1 March 2021
* LongTermFacilityEncounter.relevantPeriod ends:25 March 2021 CQL calculates as 3/1-3/25 < 90

**Query 1**
As the definition of Long Term Care Periods Longer Than 90 Consecutive Days states that its relevant period should overlap Measurement period and also intersect Measurement period. Which of the patient will qualify?

**Query 2**
How do we calculate overlapping days ?

It would be helpful to go to the eCQI Resource Center and obtain the zip file for the measure plus the most recent version of the CQL Style Guide and the CQL Author’s Guide:
https://ecqi.healthit.gov/ecqm/ep/2021/cms130v9 https://ecqi.healthit.gov/tool/cql-style-guide
https://ecqi.healthit.gov/cql https://cql.hl7.org/2020May/02-authorsguide.html

The human readable HTML is contained within the zip along with the CQL of the measure and measure libraries. These may be viewed with a text editor but are easiest to view in the Atom editor with the cql language add-in.
If you view the ColorectalCancerScreening-9.2.000.cql file, it lists the version number, QDM version, the included libraries with aliases, value sets and codes at the beginning of the file.
The "Long Term Facility Encounter" expression is referenced within the "Long Term Care Periods Longer Than 90 Consecutive Days" criteria, referenced within the "Denominator Exclusion" criteria for the measure:

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

Your question pertains to the FrailtyLTI."Long Term Care Periods Longer Than 90 Consecutive Days" expression which is defined in the `AdvancedIllnessandFrailtyExclusionECQM version '5.5.000' called FrailtyLTI` library:

```
define "Long Term Care Periods Longer Than 90 Consecutive Days":
  exists ( "Long Term Care Periods During Measurement Period" LongTermCareDuringMP
    where duration in days of LongTermCareDuringMP > 90
)
```

Note that the measure restricts patients to age >=50 and < 75 at start of Measurement Period and the preceding expression further restricts to those patients 65 years and older at the start of the Measurement Period. Note also that this definition calls the "Long Term Care Periods During Measurement Period":

```
define "Long Term Care Periods During Measurement Period":
  ( ["Encounter, Performed": "Care Services in Long-Term Residential Facility"]
    union ["Encounter, Performed": "Nursing Facility Visit"]
  ) LongTermFacilityEncounter
    where LongTermFacilityEncounter.relevantPeriod overlaps "Measurement Period"
    return LongTermFacilityEncounter.relevantPeriod intersect "Measurement Period"
```

Note the timing association with the Measurement Period. The `overlaps` operator requires the `relevantPeriod` to include the Measurement Period and the `intersect` operator restricts the evaluated `relevantPeriod` to only that portion of the period contained within the Measurement Period.

For further explanation, please refer to the CQL Author’s Guide "Comparing Intervals" Section 5.5.2 and "Computing Intervals" Section 5.5.4 of the CQL Author's Guide.

The `"Long Term Care Periods Longer Than 90 Consecutive Days"` definition evaluates each returned `LongTermFacilityEncounter.relevantPeriod intersect "Measurement Period"` period by calculating the duration in days of the resulting period. If any of the returned periods have a calculated duration that exceeds 90 days, then the definition would evaluate as true.

So in answer to your question, only example 1 would return true from the "Long Term Care Periods Longer Than 90 Consecutive Days" expression. Examples 2 and 3 contain overlapping dates but, since the evaluation is applied separately to each relevantPeriod, only a relevant period of greater than 90 days within the measurement period would evaluate as true.

For further illustration, if your example 1 started and ended 1 month earlier (11/30-3/2) it would fail since the duration would be calculated on 1/1-3/2 which is less than 90 days.

Example 2 does include coverage from 1/1 through 3/31 for a total of 31+28+31=90 so would fail to exceed 90 days. If we took Example 2 that is spread over three relevantPeriods (1/1-2/28, 3/1-3/15, 3/1-3/31) and modified the final entry to (1/1-2/28, 3/1-3/15, 3/1-4/10) so that the cumulative total is 100 days, the CQL indicates that each relevantPeriod is calculated individually and since none of the individual durations exceed 90, the definition would return false.

Response by Peter Muir, MD
