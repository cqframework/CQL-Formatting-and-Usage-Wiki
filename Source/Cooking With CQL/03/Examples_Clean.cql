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

/*
Example 03:
IP: Diagnosis overlaps MP and sex (CMS129) (Patient-based Proportion Measure)

Initial Population =
  AND: "Occurrence A of Diagnosis: Prostate Cancer" overlaps "Measurement Period"
  AND: "Patient Characteristic Sex: Male"
*/

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

/*
Example 08:
IP: Procedure relative to MP end (CMS133) (Procedure-based Proportion Measure)

Initial Population =
  AND: Age>= 18 year(s) at: "Measurement Period"
  AND: "Occurrence A of Procedure, Performed: Cataract Surgery" during "Measurement Period"
  AND: "Occurrence A of Procedure, Performed: Cataract Surgery" > 92 day(s) starts before end of "Measurement Period"
*/

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
