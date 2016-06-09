/*
Describing Initial Populations
Begin with a review of some of the age-related constructs presented last time.
*/

/*
Example 01
IP: Age and encounter (CMS117) (Patient-based Proportion Measure)

Initial Population =
  AND: "Birthdate : Patient Characteristic Birthdate" >= 1 year(s) starts before start of "Measurement Period"
  AND: "Birthdate : Patient Characteristic Birthdate" = 2 year(s) starts before end of "Measurement Period"
  AND: Union of:
    "Encounter, Performed: Office Visit"
    "Encounter, Performed: Face-to-Face Interaction"
    "Encounter, Performed: Home Healthcare Services"
    "Encounter, Performed: Preventive Care - Established Office Visit, 0 to 17"
    "Encounter, Performed: Preventive Care- Initial Office Visit, 0 to 17"
    during "Measurement Period"
*/

define "Birthdate":
  ["Birthdate": "Patient Characteristic Birthdate"]

define "Encounter During Measurement Period":
  (
    ["Encounter, Performed": "Office Visit"]
      union ["Encounter, Performed": "Face-to-Face Interaction"]
      union ["Encounter, Performed": "Home Healthcare Service"]
      union ["Encounter, Performed": "Preventive Care - Established Office Visit, 0 to 17"]
      union ["Encounter, Performed": "Preventive Care- Initial Office Visit, 0 to 17"]
  ) Encounter
    where Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime] during "Measurement Period"

define "Initial Population":
  CalculateAgeInYearsAt("Birthdate", start of "Measurement Period") >= 1
    and CalculateAgeInYearsAt("Birthdate", end of "Measurement Period") = 2
    and exists ("Encounter During Measurement Period")

/*
Example 02
IP: Age, sex, and encounter (CMS125) (Patient-based Proportion Measure)

Initial Population =
  AND: Age>= 51 year(s) at: "Measurement Period"
  AND: Age< 74 year(s) at: "Measurement Period"
  AND: "Patient Characteristic Sex: Female"
  AND: Union of:
    "Encounter, Performed: Office Visit"
    "Encounter, Performed: Face-to-Face Interaction"
    "Encounter, Performed: Preventive Care Services - Established Office Visit, 18 and Up"
    "Encounter, Performed: Preventive Care Services-Initial Office Visit, 18 and Up"
    "Encounter, Performed: Home Healthcare Services"
    "Encounter, Performed: Annual Wellness Visit"
    during "Measurement Period"
*/

define "Encounter During Measurement Period":
  (
    ["Encounter, Performed": "Office Visit"]
      union ["Encounter, Performed": "Face-to-Face Interaction"]
      union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
      union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
      union ["Encounter, Performed": "Home Healthcare Service"]
      union ["Encounter, Performed": "Annual Wellness Visit"]
  ) Encounter
    where Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime] during "Measurement Period"

define "Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 51
    and AgeInYearsAt(start of "Measurement Period") < 74
    and exists (["Patient Characteristic Sex": "Female"])
    and exists ("Encounter During Measurement Period")

/*
Example 03:
IP: Diagnosis overlaps MP and sex (CMS129) (Patient-based Proportion Measure)

Initial Population =
  AND: "Occurrence A of Diagnosis: Prostate Cancer" overlaps "Measurement Period"
  AND: "Patient Characteristic Sex: Male"
*/

define "Prostate Cancer Diagnosis":
  ["Diagnosis": "Prostate Cancer"] Diagnosis
    where Interval[Diagnosis.onsetDateTime, Diagnosis.abatementDateTime] overlaps "Measurement Period"

define "Initial Population":
  exists ("Prostate Cancer Diagnosis")
    and exists (["Patient Characteristic Sex": "Male"])

/*
Example 04:
IP: Diagnosis overlaps encounter (CMS53) (Episode-of-care Proportion Measure)

Initial Population =
  AND: Age>= 18 year(s) at: Occurrence A of $EncounterInpatient
  AND: Intersection of:
    Occurrence A of $EncounterInpatient
    "Encounter, Performed: Encounter Inpatient (principal diagnosis: Acute Myocardial Infarction (AMI))"

$EncounterInpatient =
  "Encounter, Performed: Encounter Inpatient" satisfies all:
    (length of stay <= 120 day(s))
    ends during "Measurement Period"
*/

define "Inpatient Encounter":
  ["Encounter, Performed": "Encounter Inpatient"] Encounter
    where Encounter.lengthOfStay <= 120 days
      and Encounter.dischargeDateTime during "Measurement Period"

define "Encounter with Principal Diagnosis of AMI":
  "Inpatient Encounter" Encounter
    where Encounter.principalDiagnosis in "Acute Myocardial Infarction (AMI)"
      and AgeInYearsAt(Encounter.admissionDateTime) >= 18

define "Initial Population":
  "Encounter with Principal Diagnosis of AMI"

/*
Example 05:
IP: Encounter relative to another encounter (CMS55) (Episode-of-care Continuous Variable Measure)

Initial Population =
  AND: "Occurrence A of Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient

$EncounterInpatient =
  "Encounter, Performed: Encounter Inpatient" satisfies all:
    (length of stay <= 120 day(s))
    ends during "Measurement Period"
*/

define "Inpatient Encounter":
  ["Encounter, Performed": "Encounter Inpatient"] Encounter
    where Encounter.lengthOfStay <= 120 days
      and Encounter.dischargeDateTime during "Measurement Period"

define "Emergency Encounter":
  ["Encounter, Performed": "Emergency Department Visit"] EmergencyEncounter
    with "Inpatient Encounter" InpatientEncounter
      such that EmergencyEncounter.dischargeDateTime 1 hour or less before InpatientEncounter.admissionDateTime

define "Initial Population":
  "Emergency Encounter"

/*
Example 06:
IP: Encounter relative to another encounter (CMS111) (Episode-of-care Continuous Variable Measure)

Initial Population =
  AND: "Occurrence A of Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatient
  AND: "Occurrence A of Encounter, Order: Decision to Admit to Hospital Inpatient" starts during "Occurrence A of Encounter, Performed: Emergency Department Visit"

$EncounterInpatient =
  "Encounter, Performed: Encounter Inpatient" satisfies all:
    (length of stay <= 120 day(s))
    ends during "Measurement Period"
*/

define "Inpatient Encounter":
  ["Encounter, Performed": "Encounter Inpatient"] Encounter
    where Encounter.lengthOfStay <= 120 days
      and Encounter.dischargeDateTime during "Measurement Period"

define "Emergency Encounter":
  ["Encounter, Performed": "Emergency Department Visit"] EmergencyEncounter
    with "Inpatient Encounter" InpatientEncounter
      such that EmergencyEncounter.dischargeDateTime 1 hour or less before InpatientEncounter.admissionDateTime

define "Initial Population":
  "Emergency Encounter" EmergencyEncounter
    with ["Encounter, Order": "Decision to Admit to Hospital Inpatient"] AdmissionOrder
      such that AdmissionOrder.startDateTime during Interval[EmergencyEncounter.admissionDateTime, EmergencyEncounter.dischargeDateTime]

/*
Example 07:
IP: Procedure during encounter (CMS113) (Episode-of-care Proportion Measure)

Initial Population =
  AND: Age>= 8 year(s) at: Occurrence A of $EncounterInpatient
  AND: Age< 65 year(s) at: Occurrence A of $EncounterInpatient
  AND: "Procedure, Performed: Delivery Procedures" starts during Occurrence A of $EncounterInpatient

$EncounterInpatient =
  "Encounter, Performed: Encounter Inpatient" satisfies all:
    (length of stay <= 120 day(s))
    ends during "Measurement Period"
*/

define "Inpatient Encounter":
  ["Encounter, Performed": "Encounter Inpatient"] Encounter
    where Encounter.lengthOfStay <= 120 days
      and Encounter.dischargeDateTime during "Measurement Period"

define "Initial Population":
  "Inpatient Encounter" Encounter
    with ["Procedure, Performed": "Delivery Procedures"] Procedure
      such that Procedure.startDateTime during Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime]
    where AgeInYearsAt(Encounter.admissionDateTime) >= 8
      and AgeInYearsAt(Encounter.admissionDateTime) < 65

/*
Example 08:
IP: Procedure relative to MP end (CMS133) (Procedure-based Proportion Measure)

Initial Population =
  AND: Age>= 18 year(s) at: "Measurement Period"
  AND: "Occurrence A of Procedure, Performed: Cataract Surgery" during "Measurement Period"
  AND: "Occurrence A of Procedure, Performed: Cataract Surgery" > 92 day(s) starts before end of "Measurement Period"
*/

define "Initial Population":
  ["Procedure, Performed": "Cataract Surgery"] Procedure
    where AgeInYearsAt(start of "Measurement Period") >= 18
      and Interval[Procedure.startDateTime, Procedure.stopDateTime] during "Measurement Period"
      and Procedure.startDateTime 92 days or more before end of "Measurement Period"

/*
Example 09:
IP: Count of encounters (CMS138) (Patient-based Proportion Measure)

Initial Population =
  AND: Age>= 18 year(s) at: "Measurement Period"
  AND:
    OR: Count>= 2 : Union of:
      "Encounter, Performed: Psych Visit - Diagnostic Evaluation"
      "Encounter, Performed: Health and Behavioral Assessment - Initial"
      "Encounter, Performed: Health and Behavioral Assessment, Reassessment"
      "Encounter, Performed: Health & Behavioral Assessment - Individual"
      "Encounter, Performed: Occupational Therapy Evaluation"
      "Encounter, Performed: Office Visit"
      "Encounter, Performed: Psych Visit - Psychotherapy"
      "Encounter, Performed: Psychoanalysis"
      "Encounter, Performed: Ophthalmological Services"
      "Encounter, Performed: Home Healthcare Services"
      during "Measurement Period"
    OR: Count>= 1 : Union of:
      "Encounter, Performed: Preventive Care Services - Group Counseling"
      "Encounter, Performed: Preventive Care Services - Other"
      "Encounter, Performed: Preventive Care Services-Initial Office Visit, 18 and Up"
      "Encounter, Performed: Preventive Care Services - Established Office Visit, 18 and Up"
      "Encounter, Performed: Preventive Care Services-Individual Counseling"
      "Encounter, Performed: Face-to-Face Interaction"
      "Encounter, Performed: Annual Wellness Visit"
      "Encounter, Performed: Speech and Hearing Evaluation"
      during "Measurement Period"
*/

define "Behavioral Visits":
  distinct
  (
    ["Encounter, Performed": "Psych Visit - Diagnostic Evaluation"]
      union ["Encounter, Performed": "Health and Behavioral Assessment - Initial"]
      union ["Encounter, Performed": "Health and Behavioral Assessment, Reassessment"]
      union ["Encounter, Performed": "Health & Behavioral Assessment - Individual"]
      union ["Encounter, Performed": "Occupational Therapy Evaluation"]
      union ["Encounter, Performed": "Office Visit"]
      union ["Encounter, Performed": "Psych Visit - Psychotherapy"]
      union ["Encounter, Performed": "Psychoanalysis"]
      union ["Encounter, Performed": "Ophthalmological Services"]
      union ["Encounter, Performed": "Home Healthcare Services"]
  ) Visit
    where Interval[Visit.admissionDateTime, Visit.dischargeDateTime] during "Measurement Period"

define "Counseling Visits":
  distinct
  (
    ["Encounter, Performed": "Preventive Care Services - Group Counseling"]
      union ["Encounter, Performed": "Preventive Care Services - Other"]
      union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
      union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
      union ["Encounter, Performed": "Preventive Care Services-Individual Counseling"]
      union ["Encounter, Performed": "Face-to-Face Interaction"]
      union ["Encounter, Performed": "Annual Wellness Visit"]
      union ["Encounter, Performed": "Speech and Hearing Evaluation"]
  ) Visit
    where Interval[Visit.admissionDateTime, Visit.dischargeDateTime] during "Measurement Period"

define "Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 18
    and (
      Count("Behavioral Visits") >= 2
        or Count("Counseling Visits") >= 1
    )

/*
Example 10:
IP: Count of encounters with diagnosis (CMS135) (Patient-based Proportion)

Initial Population =
  AND: Age>= 18 year(s) at: "Measurement Period"
  AND:
    OR: Count>= 2 : Union of:
      "Encounter, Performed: Care Services in Long-Term Residential Facility"
      "Encounter, Performed: Home Healthcare Services"
      "Encounter, Performed: Nursing Facility Visit"
      "Encounter, Performed: Office Visit"
      "Encounter, Performed: Outpatient Consultation"
      "Encounter, Performed: Patient Provider Interaction"
      during "Measurement Period"
    OR: "Encounter, Performed: Discharge Services - Hospital Inpatient" during "Measurement Period"
  AND: "Diagnosis: Heart Failure" overlaps Occurrence A of $HFEncounters135

$HFEncounters135 =
  Union of:
    "Encounter, Performed: Care Services in Long-Term Residential Facility"
    "Encounter, Performed: Home Healthcare Services"
    "Encounter, Performed: Nursing Facility Visit"
    "Encounter, Performed: Office Visit"
    "Encounter, Performed: Outpatient Consultation"
    "Encounter, Performed: Face-to-Face Interaction"
    "Encounter, Performed: Discharge Services - Hospital Inpatient"
    during "Measurement Period"
*/

define "HF Encounters":
  distinct
  (
    ["Encounter, Performed": "Care Services in Long-Term Residential Facility"]
      union ["Encounter, Performed": "Home Healthcare Services"]
      union ["Encounter, Performed": "Nursing Facility Visit"]
      union ["Encounter, Performed": "Office Visit"]
      union ["Encounter, Performed": "Outpatient Consultation"]
      union ["Encounter, Performed": "Face-to-Face Interaction"]
      union ["Encounter, Performed": "Discharge Services - Hospital Inpatient"]
  ) Encounter
    where Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime] during "Measurement Period"

define "HF Encounters Without Discharge":
  distinct
  (
    ["Encounter, Performed": "Care Services in Long-Term Residential Facility"]
      union ["Encounter, Performed": "Home Healthcare Services"]
      union ["Encounter, Performed": "Nursing Facility Visit"]
      union ["Encounter, Performed": "Office Visit"]
      union ["Encounter, Performed": "Outpatient Consultation"]
      union ["Encounter, Performed": "Patient Provider Interaction"]
  ) Encounter
    where Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime] during "Measurement Period"

define "Discharge Services":
  ["Encounter, Performed": "Discharge Services - Hospital Inpatient"] Encounter
    where Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime] during "Measurement Period"

define "Heart Failure Diagnosis":
  ["Diagnosis": "Heart Failure"] Diagnosis
    with "HF Encounters" Encounter
      such that Interval[Diagnosis.onsetDateTime, Diagnosis.abatementDateTime]
        overlaps Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime]

define "Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 18
    and (
      Count("HF Encounters") >= 2
        or exists ("Discharge Services")
    )
    and exists ("Heart Failure Diagnosis")

/*
Example 11:
IP: Cumulative medication (CMS136) (Patient-based Proportion)

Initial Population =
  AND: $InitialADHDMedication
  AND: Sum>= 210 day(s): "Medication, Active: ADHD Medications (cumulative medication duration)" <= 300 day(s) starts after or concurrent with start of $InitialADHDMedication
  AND: Age>= 6 year(s) at: "Measurement Period"
  AND: Age< 12 year(s) at: "Measurement Period"
  AND: $Encounter

$InitialADHDMedication =
  First: Union of:
    "Medication, Dispensed: ADHD Medications" <= 60 day(s) starts after start of "Measurement Period"
    "Medication, Dispensed: ADHD Medications" <= 90 day(s) starts before or concurrent with start of "Measurement Period"

$Encounter =
  Union of:
    "Encounter, Performed: Office Visit"
    "Encounter, Performed: Face-to-Face Interaction"
    "Encounter, Performed: Home Healthcare Services"
    "Encounter, Performed: Preventive Care - Established Office Visit, 0 to 17"
    "Encounter, Performed: Preventive Care- Initial Office Visit, 0 to 17"
    during "Measurement Period"
*/

define "Encounter":
  distinct
  (
    ["Encounter, Performed": "Office Visit"]
      union ["Encounter, Performed": "Face-to-Face Interaction"]
      union ["Encounter, Performed": "Home Healthcare Services"]
      union ["Encounter, Performed": "Preventive Care - Established Office Visit, 0 to 17"]
      union ["Encounter, Performed": "Preventive Care- Initial Office Visit, 0 to 17"]
  ) Encounter
    where Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime] during "Measurement Period"

define "Initial ADHD Medication":
  First(
    ["Medication, Dispensed": "ADHD Medications"] Medication
      where Medication.startDateTime
        during Interval[start of "Measurement Period" - 90 days, start of "Measurement Period" + 60 days]
  )

define "ADHD Medication Intervals":
  collapse (
    ["Medication, Dispensed": "ADHD Medications"] Medication
      with "Initial ADHD Medication" InitialMedication
        such that Medication.startDateTime 300 days or less after start of InitialMedication.startDateTime
      return Interval[Medication.startDateTime, Medication.stopDateTime]
  )

define "ADHD Medication Days":
  "ADHD Medication Intervals" I return duration in days of I

define "Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 6
    and AgeInYearsAt(start of "Measurement Period") < 12
    and exists ("Encounter")
    and exists ("Initial ADHD Medication")
    and Sum("ADHD Medication Days") >= 210

/*
Example 12:
IP: First occurrence (CMS140) (Patient-based Proportion Measure)

Initial Population =
  AND: (First: "Occurrence A of Diagnosis: Breast Cancer" ) <= 5 year(s) starts before end of Occurrence A of $OVorF2FEncounter
  AND: Age>= 18 year(s) at: "Measurement Period"
  AND: Count>= 2 : Union of:
    "Encounter, Performed: Office Visit"
    "Encounter, Performed: Patient Provider Interaction"
    during "Measurement Period"
  AND: "Patient Characteristic Sex: Female"

$OVorF2FEncounter =
  Union of:
    "Encounter, Performed: Office Visit"
    "Encounter, Performed: Face-to-Face Interaction"
    during "Measurement Period"
*/

define "Office Visit or Face-to-Face Encounter":
  distinct
  (
    ["Encounter, Performed": "Office Visit"]
      union ["Encounter, Performed": "Face-to-Face Interaction"]
  ) Encounter
    where Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime] during "Measurement Period"

define "First Breast Cancer Diagnosis":
First(
  ["Diagnosis": "Breast Cancer"] Diagnosis
    sort by onsetDateTime
)

define "Initial Population":
  exists (
      "First Breast Cancer Diagnosis" Diagnosis
        with "Office Visit or Face-to-Face Encounter" Encounter
          such that Diagnosis.onsetDateTime 5 years or less before Encounter.dischargeDateTime
      )
    and AgeInYearsAt(start of "Measurement Period") >= 18
    and Count("Office Visit or Face-to-Face Encounter") >= 2
    and exists (["Patient Characteristic Sex": "Female"])

/*
Example 13:
IP: Satisfies any with satisfies all (CMS154) (Patient-based Proportion Measure)

Initial Population =
  AND: Age>= 3 month(s) at: "Measurement Period"
  AND: Age< 18 year(s) at: "Measurement Period"
  AND: "Occurrence A of Diagnosis: Upper Respiratory Infection" satisfies any:
    starts during Occurrence A of $URIEncounter
    satisfies all:
      starts before or concurrent with start of Occurrence A of $URIEncounter
      ends after or concurrent with end of Occurrence A of $URIEncounter

$URIEncounter =
  Union of:
    "Encounter, Performed: Office Visit"
    "Encounter, Performed: Emergency Department Visit"
    "Encounter, Performed: Preventive Care- Initial Office Visit, 0 to 17"
    "Encounter, Performed: Preventive Care - Established Office Visit, 0 to 17"
    "Encounter, Performed: Hospital Observation Care - Initial"
    "Encounter, Performed: Face-to-Face Interaction"
    during "Measurement Period"
*/

define "URI Encounter":
  distinct
  (
    ["Encounter, Performed": "Office Visit"]
      union ["Encounter, Performed": "Emergency Department Visit"]
      union ["Encounter, Performed": "Preventive Care- Initial Office Visit, 0 to 17"]
      union ["Encounter, Performed": "Preventive Care - Established Office Visit, 0 to 17"]
      union ["Encounter, Performed": "Hospital Observation Care - Initial"]
      union ["Encounter, Performed": "Face-to-Face Interaction"]
  ) Encounter
    where Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime] during "Measurement Period"

define "URI Diagnosis During Encounter":
  ["Diagnosis": "Upper Respiratory Infection"] Diagnosis
    with "URI Encounter" Encounter
      such that Diagnosis.onsetDateTime during Interval[Encounter.admissionDateTime, Encounter.dischargeDateTime]

define "URI Diagnosis Before Or After Encounter":
  ["Diagnosis": "Upper Respiratory Infection"] Diagnosis
    with "URI Encounter" Encounter
      such that Diagnosis.onsetDateTime same or before Encounter.admissionDateTime
        and Diagnosis.abatementDateTime same or after Encounter.dischargeDateTime

define "Initial Population":
  AgeInMonthsAt(start of "Measurement Period") >= 3
    and AgeInYearsAt(start of "Measurement Period") < 18 years
    and (
        exists ("URI Diagnosis During Encounter")
          or exists ("URI Diagnosis Before Or After Encounter")
    )

/*
Example 14:
IP: Timing, diagnoses, satisfies – oh my! (CMS159)

Initial Population =
  AND: Age>= 18 year(s) at: $DepressionIndex

$DepressionEncounter =
  "Encounter, Performed: Office Visit" satisfies all:
    < 12 month(s) ends before start of "Measurement Period"
    > 0 month(s) ends before start of "Measurement Period"
    satisfies any:
      overlaps "Diagnosis: Major Depression Including Remission"
      overlaps "Diagnosis: Dysthymia"

$DepressionEncounterBH =
  "Encounter, Performed: Psych Visit" satisfies all:
    < 12 month(s) ends before start of "Measurement Period"
    > 0 month(s) ends before start of "Measurement Period"
  satisfies any:
    (principal diagnosis: Major Depression Including Remission)
    (principal diagnosis: Dysthymia)

$DepressionF2FSnomed =
  "Encounter, Performed: Face to Face Interaction - No ED" satisfies all:
    < 12 month(s) ends before start of "Measurement Period"
    > 0 month(s) ends before start of "Measurement Period"
  satisfies any:
    overlaps "Diagnosis: Major Depression Including Remission"
    overlaps "Diagnosis: Dysthymia"

$DepressionIndex =
  "Risk Category Assessment: PHQ-9 Tool (result > 9 )" during Union of:
    $DepressionEncounter
    $DepressionEncounterBH
    $DepressionF2FSnomed
*/
