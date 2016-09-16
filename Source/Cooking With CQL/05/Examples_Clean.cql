/* Negation Rationale */

// QDM 4.2
// Positive expression: Antithrombotic medications administered
define "Antithrombotic Administered":
    ["Medication, Administered": "Antithrombotic Therapy"] Medication
        where Medication.negationRationale is null

// Negative expression: Antithrombotic medications not administered for medical reason
define "Antithrombotic Not Administered":
    ["Medication, Administered": "Antithrombotic Therapy"] Medication
        where Medication.negationRationale in "Medical Reason"

// QDM 5.0
// Positive expression: Antithrombotic medications administered
define "Antithrombotic Administered":
  ["Medication, Administered": "Antithrombotic Therapy"]

// Negative expression: Antithrombotic medications not administered for any reason
define "Antithrombotic Not Administered":
  ["Medication, Not Administered": "Antithrombotic Therapy"]

// Negative expression: Antithrombotic medications not administered for medical reason
define "Antithrombotic Not Administered":
  ["Medication, Not Administered": "Antithrombotic Therapy"] Medication
    where Medication.negationRationale in "Medical Reason"

/* Assessment Result Types */

// Estimated gestational age at delivery
define "Denominator":
  ["Assessment, Performed": "Estimated Gestational Age at Delivery"] Assessment
    with ["Assessment, Performed": "Time of Delivery"] DeliveryTime
      such that DeliveryTime.result 1 day or less before start of Assessment.relevantPeriod
    where Assessment.result in Interval[37 weeks, 39 weeks)

/* Care Goal */

// Weight Target
define "Weight Target Achieved":
  ["Care Goal": "Weight Loss Target"] CareGoal
    with ["Physical Exam, Performed": "Weight Loss Percentage"] Weight
      such that Weight.relevantPeriod starts within 3 days of end of CareGoal.relevantPeriod
        and Weight.result >= CareGoal.targetOutcome

/* Transfer From, Transfer To */
/*
QDM
  "Transfer To: Acute care hospital" <= 6 hour(s) starts after or concurrent with end of
    "Occurrence A of Encounter, Performed: Emergency Department Visit"
*/

define "Transfer to Acute Care Hospital":
  ["Encounter, Performed": "Emergency Department Visit"] Encounter
    where Encounter.dischargeDisposition in "Acute care hospital"

/* Cumulative Medication Duration */

define "Warfarin Usage Periods":
  collapse (["Medication, Active": "Warfarin"] Medication return relevantPeriod)

define "Cumulative Warfarin Days":
  Sum("Warfarin Usage Periods" Period return duration in days of Period)

/* Allergy and AdverseEvent */

define "Allergy to Latex":
  ["Allergy": "Latex"]

define "Reaction to Latex":
  ["Adverse Event/Intolerance": "Latex"]

/* Timing Periods */

// Medication start/stop
// QDM 4.2:
define "Medication Administrations during Measurement Period":
  ["Medication, Administered": "Antithrombotic"] Medication
    where Interval[Medication.startDateTime, Medication.stopDateTime]
      during "Measurement Period"

// QDM 5.0:
define "Medication Administrations during Measurement Period":
  ["Medication, Administered": "Antithrombotic"] Medication
    where Medication.relevantPeriod during "Measurement Period"
