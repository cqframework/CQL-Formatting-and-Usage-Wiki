// Numerator with lots of nested ORs and ANDs (CMS22)

library CMS22

using QDM version '5.0'

valueset "BP Screening Encounter Codes": 'BP Screening Encounter Codes'
valueset "Diastolic Blood Pressure": 'Diastolic Blood Pressure'
valueset "Systolic Blood Pressure": 'Systolic Blood Pressure'

parameter "Measurement Period" Interval<DateTime>

/*
Numerator =
  AND: Most Recent:
    "Occurrence A of Encounter, Performed: BP Screening Encounter Codes" satisfies all:
      overlaps "Physical Exam, Performed: Diastolic Blood Pressure (result)"
      overlaps "Physical Exam, Performed: Systolic Blood Pressure (result)"
  AND:
    OR:
      AND: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
        Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
        (result < 120 mmHg)
      AND: "Physical Exam, Performed: Diastolic Blood Pressure" satisfies all:
        Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
        (result < 80 mmHg)
    OR:
      AND:
        OR:
          AND: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
            Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
            (result >= 120 mmHg)
            (result < 140 mmHg)
          AND: "Physical Exam, Performed: Diastolic Blood Pressure" satisfies all:
            Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
            (result < 90 mmHg)
        OR:
          AND: "Physical Exam, Performed: Diastolic Blood Pressure" satisfies all:
            Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
            (result >= 80 mmHg)
            (result < 90 mmHg)
          AND: "Physical Exam, Performed: Systolic Blood Pressure" satisfies all:
            Most Recent: during "Occurrence A of Encounter, Performed: BP Screening Encounter Codes"
            (result < 140 mmHg)
*/
