library RelatedToGestationalAge

using QDM version '5.0'

valueset "Inpatient Encounter Codes": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Estimated Due Date Codes": 'TBD'
valueset "Time of Delivery Codes": 'TBD'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
This comes from our PC-01 (CMS113) measure denominator:

Patients delivering newborns with >= 37 and < 39 weeks of gestation completed

Currently expressed in QDM like this:

    Denominator =
        AND: Initial Population
        AND: "Physical Exam, Performed: Estimated Gestational Age at Delivery" satisfies all:
            (result >= 37 week(s))
            (result < 39 week(s))
            < 1 day(s) starts before start of ("Physical Exam, Performed: Time of Delivery" starts during Occurrence A of $EncounterInpatient )

We actually want to use the Assessment, Performed datatype to express Time of Delivery,
and would expect the Time of Delivery to be a Result that is a date/time stamp.
The timing logic of < 1 day starts before start … would then be based off of the
Result Date/time (not the author time of the assessment).

For the Estimated Gestational Age at Delivery, please use the calculated gestational
age using ACOG ReVITALize guidelines with Estimated Due Date (EDD).

Please let me know if you have any questions or need additional information.

*/
