## High Risk Meds Numerator

CQLIT-226 re High Risk Medications Numerator Query:

[CQM-4022](https://oncprojectracking.healthit.gov/support/browse/CQM-4022)
[CMS156v9](https://ecqi.healthit.gov/ecqm/ep/2021/cms156v9)
[CQL Style Guide](https://ecqi.healthit.gov/tool/cql-style-guide)
[QDM](https://ecqi.healthit.gov/qdm)
[CQL Author's Guide](https://cql.hl7.org/02-authorsguide.html)

## Question:
With respect to one of the numerator criteria `Two High Risk Medications with Prolonged Duration`:

```
define "Two High Risk Medications With Prolonged Duration":
  ( "Cumulative Medication Duration"("AntiInfectives During Measurement Period") >= 90
      and "More than One AntiInfective Order")
  or ( "Cumulative Medication Duration"("Hypnotics During Measurement Period") >= 90
      and "More than One Nonbenzodiazepine Hypnotics Order"  )

define function Cumulative Medication Duration(Medication List<"Medication, Order">):
  Sum((collapse(Medication.relevantPeriod))CumulativeDosages
    return all duration in days of CumulativeDosages)

define "AntiInfectives During Measurement Period":
  ["Medication, Order": "Anti Infectives, other"] AntiInfectives
    where AntiInfectives.authorDatetime during "Measurement Period"
```

What is the result of this expression for the following cases:

**Patient 1:**
Patient 1 has “Medication, Order": "Anti Infectives, other” :
* Rx1: AuthorDatetime of order 2021-07-05. Start date 2021-07-05 and end date 2021-09-05 (62d)
* Rx2: AuthorDatetime of order 2021-12-10. Start date 2021-12-10 and end date 2022-01-10 (31d)

**Patient 2:**
Patient 2 has “Medication, Order": "Anti Infectives, other” :
* Rx1: AuthorDatetime of order 2021-07-05. Frequency 60 days (60d)
* Rx2: AuthorDatetime of order 2021-12-20. Frequency 30 days (30d)

Since frequency usually refers to the number of dosing times per day, we shall assume that you meant that the `"Medication, Order".relevantPeriod` duration is 60 days then 30 days respectively.

It would be helpful to go to the eCQI Resource Center and obtain the zip file for the measure, the most recent version of the CQL Style Guide, Quality Data Model Update (QDM 5.5) and CQL Author’s Guide:
https://ecqi.healthit.gov/ecqm/ep/2021/cms156v9 https://ecqi.healthit.gov/tool/cql-style-guide
https://ecqi.healthit.gov/qdm https://cql.hl7.org/02-authorsguide.html

The following snippet is from the UseofHighRiskMedicationsintheElderly-9.3.000.cql file contained within the CMS156v9.zip The `exists` operator will return true if the called definition has results.

```
define "Numerator":
  exists ( "Same High Risk Medications Ordered on Different Days" )
    or ( "Two High Risk Medications With Prolonged Duration" )
```

Following the latter pathway with two different medication families to Numerator:

```
define "Two High Risk Medications With Prolonged Duration":
  ( "Cumulative Medication Duration"("AntiInfectives During Measurement Period") >= 90
    and "More than One AntiInfective Order"
  )
    or ( "Cumulative Medication Duration"("Hypnotics During Measurement Period") >= 90
      and "More than One Nonbenzodiazepine Hypnotics Order"
  )
```

Parsing the CQL from left to right then top to bottom, we can see that the first half of the definition detects Anti-Infectives and the second checks for Nonbenzodiazepine Hypnotics. Both component expressions have a detection edge of >= 90 days as determined by the sum of the duration of the `"Medication, Order"` of the specified Medication Family. The `and` requires that the `"More than One"` definition must also be met for the component expression to be true. The `or` indicates that if either of the specified Medication families meet these criteria, then the Numerator will be met.

```
define function "Cumulative Medication Duration"(Medication List<"Medication, Order">):
  Sum((collapse(Medication.relevantPeriod))CumulativeDosages
    return all duration in days of CumulativeDosages
  )
```

The argument to the above function `(Medication List<"Medication, Order">)` uses `"AntiInfectives During Measurement Period"` or `"Hypnotics During Measurement Period"` for the calculation which just anchors the `"Medication, Order".authorDatetime` to the Measurement Period. Note that the `authorDatetime` is captured when the order is entered and saved. EHRs may have additional data elements for prescription printed/sent and for prescribed_elsewhere to record other medications that the patient is taking but not prescribed within the EHR network. Note that the order `relevantPeriod` is not restricted to the Measurement Period.

```
define "AntiInfectives During Measurement Period":
  ["Medication, Order": "Anti Infectives, other"] AntiInfectives
    where AntiInfectives.authorDatetime during "Measurement Period"

define "Hypnotics During Measurement Period":
  ["Medication, Order": "Nonbenzodiazepine hypnotics"] Hypnotics
    where Hypnotics.authorDatetime during "Measurement Period"
```

The `"Medication, Order": "Anti Infectives, other"` and `"Medication, Order": "Nonbenzodiazepine hypnotics"` use the appropriate VSAC value set to search for medication orders within the specified medication family.

The `collapse` operator combines consecutive medication renewals into a single set of non-overlapping periods, and then the length of each of those periods is summed together to calculate the cumulative medication duration. The `duration in days` expression determines the number of whole days present in each of the non-overlapping periods, and the `return all` ensures that if there are multiple non-overlapping periods that have the same number of days (e.g. two medications with non-overlapping periods that are both 30 days) that they will both be counted.

An example, for illustration but not from this measure:
```
duration in months between @2020-01-31 and @2020-02-01
difference in months between @2020-01-31 and @2020-02-01
```

The first expression returns `0` because there is less than one calendar month between the two dates. The second expression; however, returns `1`, because a month boundary was crossed between the two dates. For further information, please see the `Collapse` operator in "Lists of Intervals" Section 5.6.4 and the "Computing Durations and Differences" Section 5.4.5 in the HL7 CQL specification: https://cql.hl7.org/2020May/02-authorsguide.html

## Example 1:
In Example 1, the total duration of `"Medication, Order": "Anti Infectives, other".relevantPeriod` is 62 + 31 for a total duration of 93 days which will meet the Numerator if all other criteria are met.

## Example 2:
In Example 2, the total duration of `"Medication, Order": "Anti Infectives, other".relevantPeriod` is 60 + 30 for a total duration of 90 days which will also meet the Numerator if all other criteria are met.

However if Example 2 ended one day earlier for either `relevantPeriod` then the total duration would only be 89 days and the Numerator would not be met. Note that the measure does not restrict the `relevantPeriod` to the Measurement Period, it only restricts the prescribing `authorDatetime`.

Also, be aware that in EHR medication records, medication orders placed by Clinicians may have a prescribing date which is the default start date and a medication supply quantity perhaps with refills but leave the medication stop date empty. Such a null end date without a consideration of the quantity would be interpreted as an infinite duration. Therefore, the CQL expressions indicate that a 5 day supply of medication prescribed on July 5 without an end date and reordered at an office visit on September 2 would enter that as the stop date of the first prescription. If the September 2 prescription was again entered without an end date, then the total duration in days could be interpreted as more than 90 days since only the `relevantPeriod` is evaluated. However, the VSAC value set restricts `"Anti Infectives, other"` to nitrofurantoin and `"Nonbenzodiazepine hypnotics"` to eszopiclone, zaleplone and zolpidem; thereby limiting the number of medications where this might occur.

Response by Peter Muir, MD
