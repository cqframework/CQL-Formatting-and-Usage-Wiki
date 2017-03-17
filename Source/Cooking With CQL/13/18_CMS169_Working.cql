library CMS169 version '0.0.002'

using QDM version '5.0.2'

/*
Data Criteria (QDM Data Elements)
  "Diagnosis: BH Condition Involving Bipolar Disorder" using "BH Condition Involving Bipolar Disorder Grouping Value Set (2.16.840.1.113883.3.1257.1.1504)"
  "Diagnosis: BH Condition Involving Unipolar Depression" using "BH Condition Involving Unipolar Depression Grouping Value Set (2.16.840.1.113883.3.1257.1.1505)"
  "Encounter, Performed: BH Outpatient encounter" using "BH Outpatient encounter Grouping Value Set (2.16.840.1.113883.3.464.1.49)"
  "Encounter, Performed: BH Outpatient Psychotherapy" using "BH Outpatient Psychotherapy Grouping Value Set (2.16.840.1.113883.3.1257.1.973)"
  "Medication, Active: BH Antidepressant Medication" using "BH Antidepressant Medication Grouping Value Set (2.16.840.1.113883.3.1257.1.972)"
  "Medication, Active: BH Mood Stabilizer Medication" using "BH Mood Stabilizer Medication Grouping Value Set (2.16.840.1.113883.3.1257.1.950)"
  "Medication, Order: BH Antidepressant Medication" using "BH Antidepressant Medication Grouping Value Set (2.16.840.1.113883.3.1257.1.972)"
  "Medication, Order: BH Mood Stabilizer Medication" using "BH Mood Stabilizer Medication Grouping Value Set (2.16.840.1.113883.3.1257.1.950)"
  "Procedure, Order: BH Counseling for Depression" using "BH Counseling for Depression Grouping Value Set (2.16.840.1.113883.3.1257.1.1616)"
  "Procedure, Order: BH Electroconvulsive Therapy" using "BH Electroconvulsive Therapy Grouping Value Set (2.16.840.1.113883.3.1257.1.1533)"
  "Procedure, Performed: BH Assessment for Alcohol or Other Drugs" using "BH Assessment for Alcohol or Other Drugs Grouping Value Set (2.16.840.1.113883.3.1257.1.1604)"
  "Procedure, Performed: BH Counseling for Depression" using "BH Counseling for Depression Grouping Value Set (2.16.840.1.113883.3.1257.1.1616)"
  "Procedure, Performed: BH Electroconvulsive Therapy" using "BH Electroconvulsive Therapy Grouping Value Set (2.16.840.1.113883.3.1257.1.1533)"

*/

valueset "BH Outpatient Psychotherapy": 'urn:oid:2.16.840.1.113883.3.1257.1.973'
valueset "BH Antidepressant Medication": 'urn:oid:2.16.840.1.113883.3.1257.1.972'
valueset "BH Assessment for Alcohol or Other Drugs": 'urn:oid:2.16.840.1.113883.3.1257.1.1604'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "BH Electroconvulsive Therapy": 'urn:oid:2.16.840.1.113883.3.1257.1.1533'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "BH Counseling for Depression": 'urn:oid:2.16.840.1.113883.3.1257.1.1616'
valueset "BH Mood Stabilizer Medication": 'urn:oid:2.16.840.1.113883.3.1257.1.950'
valueset "BH Condition Involving Bipolar Disorder": 'urn:oid:2.16.840.1.113883.3.1257.1.1504'
valueset "BH Outpatient encounter": 'urn:oid:2.16.840.1.113883.3.464.1.49'
valueset "BH Condition Involving Unipolar Depression": 'urn:oid:2.16.840.1.113883.3.1257.1.1505'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity": ["Patient Characteristic Ethnicity": "Ethnicity"]
define "SDE Payer": ["Patient Characteristic Payer": "Payer"]
define "SDE Race": ["Patient Characteristic Race": "Race"]
define "SDE Sex": ["Patient Characteristic Sex": "ONC Administrative Sex"]

/*
Population Criteria
  Initial Population =
    AND: Age>= 18 year(s) at: "Measurement Period"
    AND: Union of:
      $Treatments
      "Encounter, Performed: BH Outpatient Psychotherapy"
        <= 42 day(s) starts after start of Union of:
          Occurrence A of $BHEncounter
          Occurrence A of $BHOutptPsychotherapy
    AND NOT: Occurrence A of $BHEncounter < 180 day(s) starts after start of Union of:
      "Encounter, Performed: BH Outpatient encounter" satisfies any:
        during "Diagnosis: BH Condition Involving Bipolar Disorder"
        during "Diagnosis: BH Condition Involving Unipolar Depression"
        during "Medication, Active: BH Antidepressant Medication"
        during "Medication, Active: BH Mood Stabilizer Medication"
      "Encounter, Performed: BH Outpatient Psychotherapy" satisfies any:
        during "Diagnosis: BH Condition Involving Bipolar Disorder"
        during "Diagnosis: BH Condition Involving Unipolar Depression"
      Union of:
        "Diagnosis: BH Condition Involving Unipolar Depression"
        "Diagnosis: BH Condition Involving Bipolar Disorder"
        starts during Union of:
          "Encounter, Performed: BH Outpatient encounter"
          "Encounter, Performed: BH Outpatient Psychotherapy"
      $Treatments
    AND NOT: Occurrence A of $BHOutptPsychotherapy < 180 day(s) starts after start of Union of:
      "Encounter, Performed: BH Outpatient encounter" satisfies any:
        during "Diagnosis: BH Condition Involving Bipolar Disorder"
        during "Diagnosis: BH Condition Involving Unipolar Depression"
        during "Medication, Active: BH Antidepressant Medication"
        during "Medication, Active: BH Mood Stabilizer Medication"
      "Encounter, Performed: BH Outpatient Psychotherapy" satisfies any:
        during "Diagnosis: BH Condition Involving Bipolar Disorder"
        during "Diagnosis: BH Condition Involving Unipolar Depression"
      Union of:
        "Diagnosis: BH Condition Involving Unipolar Depression"
        "Diagnosis: BH Condition Involving Bipolar Disorder"
        starts during Union of:
          "Encounter, Performed: BH Outpatient encounter"
          "Encounter, Performed: BH Outpatient Psychotherapy"
      $Treatments

Denominator =
  AND: Initial Population

Denominator Exclusions =
  None

Numerator =
  AND: "Procedure, Performed: BH Assessment for Alcohol or Other Drugs" satisfies all:
    starts after or concurrent with start of Union of:
      Occurrence A of $BHEncounter
      Occurrence A of $BHOutptPsychotherapy
      ends before or concurrent with start of (Union of:
        First: $Treatments
        "Encounter, Performed: BH Outpatient Psychotherapy"
        <= 42 day(s) starts after start of Union of:
          Occurrence A of $BHEncounter
          Occurrence A of $BHOutptPsychotherapy) 

Numerator Exclusions =
  None

Denominator Exceptions =
  None

Stratification =
  None

/*
Data Criteria (QDM Variables)
*/

/*
  $BHEncounter =
    "Encounter, Performed: BH Outpatient encounter" satisfies all:
      >= 42 day(s) starts before end of "Measurement Period"
      starts after start of "Measurement Period"
      satisfies any:
        satisfies all:
          starts before or concurrent with start of "Diagnosis: BH Condition Involving Unipolar Depression"
          overlaps "Diagnosis: BH Condition Involving Unipolar Depression"
        satisfies all:
          starts before or concurrent with start of "Diagnosis: BH Condition Involving Bipolar Disorder"
          overlaps "Diagnosis: BH Condition Involving Bipolar Disorder"
*/

define "Diagnosis: BH Condition Involving Unipolar Depression or Bipolar Disorder":
  ["Diagnosis": "BH Condition Involving Unipolar Depression"]
    union ["Diagnosis": "BH Condition Involving Bipolar Disorder"]

define "BHEncounter":
  ["Encounter, Performed": "BH Outpatient encounter"] E
    with "Diagnosis: BH Condition Involving Unipolar Depression or Bipolar Disorder" D
      such that E.relevantPeriod overlaps before D.prevalencePeriod
    where E.relevantPeriod starts 42 days or more before end of "Measurement Period"
      and E.relevantPeriod starts after start of "Measurement Period"

define "BHEncounter":
  "Encounter, Performed: BH Outpatient encounter" E
    where E.relevantPeriod starts 42 days or more before end of "Measurement Period"
      and E.relevantPeriod starts after start of "Measurement Period"
      and (
        exists (
          "Diagnosis: BH Condition Involving Unipolar Depression" D
            where E.relevantPeriod starts before start of D.prevalencePeriod
              and E.relevantPeriod overlaps D.prevalencePeriod
        ) or exists (
          "Diagnosis: BH Condition Involving Bipolar Disorder" D
            where E.relevantPeriod starts before start of D.prevalencePeriod
              and E.relevantPeriod overlaps D.prevalencePeriod
        )
      )

define "BHEncounter":
  "Encounter, Performed: BH Outpatient encounter" E
    where E starts 42 days or more before end of "Measurement Period"
      and E starts after start of "Measurement Period"
      and (
        exists (
          "Diagnosis: BH Condition Involving Unipolar Depression" D
            where E starts before start of D
              and E overlaps D
        ) or exists (
          "Diagnosis: BH Condition Involving Bipolar Disorder" D
            where E starts before start of D
              and E overlaps D
        )
      )

define "BHEncounter":
  "Encounter, Performed: BH Outpatient encounter" E
    where E starts 42 days or more before end of "Measurement Period"
      and E starts after start of "Measurement Period"
      and ((
          E starts before start of "Diagnosis: BH Condition Involving Unipolar Depression"
            and E overlaps "Diagnosis: BH Condition Involving Unipolar Depression"
        )
        or (
          E starts before start of "Diagnosis: BH Condition Involving Bipolar Disorder"
            and E overlaps "Diagnosis: BH Condition Involving Bipolar Disorder"
        )
      )

define "BHEncounter":
  "Encounter, Performed: BH Outpatient encounter" starts 42 days or more before end of "Measurement Period"

  "Encounter, Performed: BH Outpatient encounter" starts before start of "Diagnosis: BH Condition Involving Bipolar Disorder"

define "BHEncounter":
  "Encounter, Performed: BH Outpatient encounter" satisfies all (
    starts 42 days or more before end of "Measurement Period",
    starts after start of "Measurement Period"
    satisfies any (
      satisfies all (
        starts before start of "Diagnosis: BH Condition Involving Unipolar Depression",
        overlaps "Diagnosis: BH Condition Involving Unipolar Depression"
      ),
      satisfies all (
        starts before start of "Diagnosis: BH COndition Involving Bipolar Disorder",
        overlaps "Diagnosis: BH Condition Involving Bipolar Disorder"
      )
    )
  )

// Human Readable Rendering:
/*
  "Encounter, Performed: BH Outpatient encounter" satisfies all:
    starts 42 days or more before end of "Measurement Period"
    starts after start of "Measurement Period"
    satisfies any:
      satisfies all:
        starts before start of "Diagnosis: BH Condition Involving Unipolar Depression"
        overlaps "Diagnosis: BH Condition Involving Unipolar Depression"
      satisfies all:
        starts before start of "Diagnosis: BH Condition Involving Bipolar Disorder"
        overlaps "Diagnosis: BH Condition Involving Unipolar Depression"
*/

/*
  starts 42 days or more before ...
  starts >= 42 days
  starts > 42 days
  starts < 42 days
  starts <= 42 days
*/

/*
  $BHOutptPsychotherapy =
    "Encounter, Performed: BH Outpatient Psychotherapy" satisfies all:
      >= 42 day(s) starts before end of "Measurement Period"
      starts after start of "Measurement Period"
      satisfies any:
        satisfies all:
          starts before or concurrent with start of "Diagnosis: BH Condition Involving Unipolar Depression"
          overlaps "Diagnosis: BH Condition Involving Unipolar Depression"
        satisfies all:
          starts before or concurrent with start of "Diagnosis: BH Condition Involving Bipolar Disorder"
          overlaps "Diagnosis: BH Condition Involving Bipolar Disorder"
*/

/*
  $Treatments =
    Union of:
      "Procedure, Performed: BH Electroconvulsive Therapy"
      "Procedure, Order: BH Electroconvulsive Therapy"
      "Medication, Order: BH Antidepressant Medication"
      "Medication, Order: BH Mood Stabilizer Medication"
      "Procedure, Performed: BH Counseling for Depression"
      "Procedure, Order: BH Counseling for Depression"
*/

define "Treatments":
  ["Procedure, Performed": "BH Electroconvulsive Therapy"]
    union ["Procedure, Order": "BH Electroconvulsive Therapy"]
    union ["Medication, Order": "BH Antidepressant Medication"]
    union ["Medication, Order": "BH Mood Stabilizer Medication"]
    union ["Procedure, Performed": "BH Counseling for Depression"]
    union ["Procedure, Order": "BH Counseling for Depression"]
