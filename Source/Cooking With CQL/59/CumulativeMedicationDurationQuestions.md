1. There seems to be a discrepancy between the CMD Medication Dispensed approach described in QDM v5.6 guidance and in the CQL library.

QDM v5.6. Section 4.1.16 states “… to determine the number of days covered by a single dispensing event, use the daysSupplied attribute and the relevant dateTime of the event to determine when the dispensed medication will run out.”  QDM v5.6 Section 5.7.3.2 also states “CMD = the sum of all dispensing events with each event providing [relevant dateTime + # daysSupplied]”.

In the CMD QDM library, the function “MedicationDispensedPeriod” uses authored dateTime instead of relevant dateTime.

QDM v5.6: https://ecqi.healthit.gov/sites/default/files/QDM-v5.6-508.pdf

CMD-0.1.000.cql and CMD-1.0.000.md: https://github.com/cqframework/CQL-Formatting-and-Usage-Wiki/tree/master/Source/Libraries

2. Please consider the following Medication Dispensed scenarios.

Given a medication dispensing event on 1/1 with 7 days supplied (Event A), “MedicationDispensedPeriod” returns a period of 1/1-1/8 and “CumulativeDuration” returns 7 days.

If relevantPeriod is present, e.g., 1/1-1/8 (Event B), “MedicationDispensedPeriod” returns a period of 1/1-1/8 and “CumulativeDuration” returns 7 days.

It makes sense for 7 days supplied to be interpreted as 7 days of cumulative duration, but it’s unclear whether relevantPeriod of 1/1-1/8 should also be interpreted as 7 days of cumulative duration.

Should a relevantPeriod of 1/1-1/8 be interpreted as 8 days of cumulative duration instead (counting each day within the period)? If so, would the following adjustments make sense to implement? The “+1” in “CumulativeDuration” will count each day covered within the period (e.g., 1/1-1/8 = 8 days, 1/1-1/7 = 7 days); the “-1 day” in “MedicationDispensedPeriod” will assume that patients start taking medication on the day it is dispensed (e.g., 7 days supplied dispensed on 1/1 = 1/1-1/7 = 7 days).
