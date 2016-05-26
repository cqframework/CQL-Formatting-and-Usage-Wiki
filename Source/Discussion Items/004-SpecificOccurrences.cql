/*
  AND: "Occurrence A of Encounter, Performed: BH Outpatient encounter" >=
    42 day(s) starts before start of "Measurement End Date"
  AND: "Occurrence A of Encounter, Performed: BH Outpatient encounter"
    starts after start of "Measurement Start Date"
*/

define "Valid Encounters":
  ["Encounter, Performed": "BH Outpatient encounter"] Encounter
    where Encounter.admissionDateTime occurs 42 days or less before end of "Measurement Period"
      and Encounter.admissionDateTime occurs after start of "Measurement Period"

/*
  AND: "Occurrence A of Encounter, Performed: HIV Visit" during "Measurement Period"
  AND: "Occurrence B of Encounter, Performed: HIV Visit" during "Measurement Period"
  AND: "Occurrence B of Encounter, Performed: HIV Visit" >= 90 day(s)
    starts after end of "Occurrence A of Encounter, Performed: HIV Visit"
*/

define "HIV Visits During Measurement Period":
  ["Encounter, Performed": "HIV Visit"] Encounter
    where Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime] during "Measurement Period"

Visit { admissionDateTime: 2015-01-01 }
Visit { admissionDateTime: 2015-03-01 }
Visit { admissionDateTime: 2015-06-01 }

define "HIV Followup Visits":
  "HIV Visits During Measurement Period" FollowupVisit
    with "HIV Visits During Measurement Period" PriorVisit
      such that FollowupVisit.admissionDateTime occurs 90 days or more after PriorVisit.dischargeDateTime

Visit { admissionDateTime: 2015-03-01 }
Visit { admissionDateTime: 2015-06-01 }

define "Most Recent HIV Followup Visit":
  First("HIV Followup Visits" Visit sort by { Visit.admissionDateTime desc })

/*
  AND: "Occurrence A of Medication, Order: Dapsone and pyrimethamine" <=
    3 month(s) starts after end of "Occurrence A of Laboratory Test, Performed: CD4+ Count (result)"
  AND: "Occurrent A of Medication, Order: Leucovorin" <= 3 month(s)
    starts after end of "Occurrence A of Laboratory Test, Performed:
      CD4+ Count (result)"
*/

define "CD4+ Count With Results and Medications":
  ["Laboratory Test, Performed": "CD4+ Count"] CD4Count
    with ["Medication, Order": "Dapsone and pyrimethamine"] DapsoneOrder
      such that DapsoneOrder.signedDatetime occurs 3 months or less after CD4Count.stopDateTime
    with ["Medication, Order": "Leucovorin"] LeucovorinOrder
      such that LeucovorinOrder.signedDatetime occurs 3 months or less after CD4Count.stopDateTime
    where CD4Count.result is not null

define "CD4+ Count With Results and Medications":
  ["Laboratory Test, Performed": "CD4+ Count"] CD4Count
    with ["Medication, Order": "Dapsone and pyrimethamine"] DapsoneOrder
      such that DapsoneOrder.signedDatetime occurs 3 months or less after CD4Count.stopDateTime

define "Dapsone and pyrimethamine Orders with CD4+ Count Laboratory Tests"
  ["Medication, Order": "Dapsone and pyrimethamine"] DapsoneOrder
    with ["Laboratory Test, Performed": "CD4+ Count"] CD4Count
      such that DpasoneOrder.signedDatetime occurs 3 months or less after CD4Count.stopDateTime
