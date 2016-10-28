library EXM52 version '5'

/*
This example is a work in progress and should not be considered a final specification
or recommendation for guidance. This example will help guide and direct the process
of finding conventions and usage patterns that meet the needs of the various stakeholders
in the measure development community.
*/

using QDM // version '4.2'

/*

Initial Population =

    AND: Age>= 6 year(s) at: "Measurement Period"
    AND: "Diagnosis: HIV 1" starts before end of "Measurement Period"
    AND: $HIVvisit >= 90 day(s) starts after end of $HIVvisit
    AND: "Occurrence A of Laboratory Test, Performed: CD4+ Count (result < 200 per mm3)" < 9 month(s) ends after start of "Measurement Period"

Denominator =

    AND: Initial Population

Denominator Exclusions =

    None

Numerator =

    AND:
        OR: "Medication, Order: Pneumocystis Jiroveci Pneumonia (PCP) Prophylaxis" < 3 month(s) starts after end of "Occurrence A of Laboratory Test, Performed: CD4+ Count"
        OR:
            AND: "Occurrence A of Medication, Order: Dapsone and pyrimethamine" < 3 month(s) starts after end of "Occurrence A of Laboratory Test, Performed: CD4+ Count"
            AND: "Occurrence A of Medication, Order: Leucovorin" < 3 month(s) starts after end of "Occurrence A of Laboratory Test, Performed: CD4+ Count"
            AND: Union of:
                "Occurrence A of Medication, Order: Dapsone and pyrimethamine" < 1 day(s) starts before or concurrent with start of "Occurrence A of Medication, Order: Leucovorin"
                "Occurrence A of Medication, Order: Leucovorin" < 1 day(s) starts before or concurrent with start of "Occurrence A of Medication, Order: Dapsone and pyrimethamine"

Numerator Exclusions =

    None

Denominator Exceptions =

    OR: "Laboratory Test, Performed: CD4+ Count (result >= 200 per mm3)" < 3 month(s) ends after end of "Occurrence A of Laboratory Test, Performed: CD4+ Count"

Stratification =

    None


$HIVvisit =

    Union of:
        "Encounter, Performed: Office Visit"
        "Encounter, Performed: Face-to-Face Interaction"
        "Encounter, Performed: Preventive Care Services - Established Office Visit, 18 and Up"
        "Encounter, Performed: Preventive Care Services-Initial Office Visit, 18 and Up"
        "Encounter, Performed: Preventive Care - Established Office Visit, 0 to 17"
        "Encounter, Performed: Preventive Care- Initial Office Visit, 0 to 17"
        "Encounter, Performed: Outpatient Consultation"
        during "Measurement Period"


Data Criteria (QDM Data Elements)

    "Diagnosis: HIV 1" using "HIV 1 Grouping Value Set (2.16.840.1.113883.3.464.1003.120.12.1004)"
    "Encounter, Performed: Face-to-Face Interaction" using "Face-to-Face Interaction Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1048)"
    "Encounter, Performed: Office Visit" using "Office Visit Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1001)"
    "Encounter, Performed: Outpatient Consultation" using "Outpatient Consultation Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1008)"
    "Encounter, Performed: Preventive Care - Established Office Visit, 0 to 17" using "Preventive Care - Established Office Visit, 0 to 17 Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1024)"
    "Encounter, Performed: Preventive Care Services - Established Office Visit, 18 and Up" using "Preventive Care Services - Established Office Visit, 18 and Up Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1025)"
    "Encounter, Performed: Preventive Care Services-Initial Office Visit, 18 and Up" using "Preventive Care Services-Initial Office Visit, 18 and Up Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1023)"
    "Encounter, Performed: Preventive Care- Initial Office Visit, 0 to 17" using "Preventive Care- Initial Office Visit, 0 to 17 Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1022)"
    "Laboratory Test, Performed: CD4+ Count" using "CD4+ Count Grouping Value Set (2.16.840.1.113883.3.464.1003.121.12.1004)"
    "Laboratory Test, Performed: CD4+ Percentage" using "CD4+ Percentage Grouping Value Set (2.16.840.1.113883.3.464.1003.121.12.1005)"
    "Medication, Order: Dapsone and pyrimethamine" using "Dapsone and pyrimethamine Grouping Value Set (2.16.840.1.113883.3.464.1003.196.12.1202)"
    "Medication, Order: Leucovorin" using "Leucovorin Grouping Value Set (2.16.840.1.113883.3.464.1003.196.12.1205)"
    "Medication, Order: Pneumocystis Jiroveci Pneumonia (PCP) Prophylaxis" using "Pneumocystis Jiroveci Pneumonia (PCP) Prophylaxis Grouping Value Set (2.16.840.1.113883.3.464.1003.196.12.1076)"

Supplemental Data Elements

    "Patient Characteristic Ethnicity: Ethnicity" using "Ethnicity CDCREC Value Set (2.16.840.1.114222.4.11.837)"
    "Patient Characteristic Payer: Payer" using "Payer SOP Value Set (2.16.840.1.114222.4.11.3591)"
    "Patient Characteristic Race: Race" using "Race CDCREC Value Set (2.16.840.1.114222.4.11.836)"
    "Patient Characteristic Sex: ONC Administrative Sex" using "ONC Administrative Sex AdministrativeGender Value Set (2.16.840.1.113762.1.4.1)"

Risk Adjustment Variables

    None

*/

valueset "HIV 1": '2.16.840.1.113883.3.464.1003.120.12.1004'
valueset "Face-to-Face Interaction": '2.16.840.1.113883.3.464.1003.101.12.1048'
valueset "Office Visit": '2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Outpatient Consultation": '2.16.840.1.113883.3.464.1003.101.12.1008'
valueset "Preventive Care - Established Office Visit, 0 to 17": '2.16.840.1.113883.3.464.1003.101.12.1024'
valueset "Preventive Care Services - Established Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1023'
valueset "Preventive Care- Initial Office Visit, 0 to 17": '2.16.840.1.113883.3.464.1003.101.12.1022'
valueset "CD4+ Count": '2.16.840.1.113883.3.464.1003.121.12.1004'
valueset "CD4+ Percentage": '2.16.840.1.113883.3.464.1003.121.12.1005'
valueset "Dapsone and pyrimethamine": '2.16.840.1.113883.3.464.1003.196.12.1202'
valueset "Leucovorin": '2.16.840.1.113883.3.464.1003.196.12.1205'
valueset "Pneumocystis Jiroveci Pneumonia (PCP) Prophylaxis": '2.16.840.1.113883.3.464.1003.196.12.1076'

valueset "Ethnicity": '2.16.840.1.114222.4.11.837'
valueset "Payer": '2.16.840.1.114222.4.11.3591'
valueset "Race": '2.16.840.1.114222.4.11.836'
valueset "ONC Administrative Sex": '2.16.840.1.113762.1.4.1'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
Initial Population =

    AND: Age>= 6 year(s) at: "Measurement Period"
    AND: "Diagnosis: HIV 1" starts before end of "Measurement Period"
    AND: $HIVvisit >= 90 day(s) starts after end of $HIVvisit
    AND: "Occurrence A of Laboratory Test, Performed: CD4+ Count (result < 200 per mm3)" < 9 month(s) ends after start of "Measurement Period"
*/

define "In Demographic":
  AgeInYearsAt(start of "Measurement Period") >= 6

define "Diagnosis":
  ["Diagnosis": "HIV 1"]

  List<Diagnosis>


define "HIV Diagnosis":
  ["Diagnosis": "HIV 1"] Diagnosis
    where Diagnosis.onsetDatetime starts before end of "Measurement Period"

define "Followup HIV Visit":
  "HIV Visit" FollowupVisit
    with "HIV Visit" PriorVisit such that FollowupVisit.admissionDatetime 90 days or more after PriorVisit.dischargeDatetime

define "CD4+ Count < 200 per mm3":
  ["Laboratory Test, Performed": "CD4+ Count"] CD4Count
    where (CD4Count.result as Quantity) < 200 'per mm3'
      and CD4Count.stopDatetime 9 months or less after start of "Measurement Period"

/*
$HIVvisit =

    Union of:
        "Encounter, Performed: Office Visit"
        "Encounter, Performed: Face-to-Face Interaction"
        "Encounter, Performed: Preventive Care Services - Established Office Visit, 18 and Up"
        "Encounter, Performed: Preventive Care Services-Initial Office Visit, 18 and Up"
        "Encounter, Performed: Preventive Care - Established Office Visit, 0 to 17"
        "Encounter, Performed: Preventive Care- Initial Office Visit, 0 to 17"
        "Encounter, Performed: Outpatient Consultation"
        during "Measurement Period"
*/

define "HIV Visit":
  (["Encounter, Performed": "Face-to-Face Interaction"]
    union ["Encounter, Performed": "Office Visit"]
    union ["Encounter, Performed": "Outpatient Consultation"]
    union ["Encounter, Performed": "Preventive Care - Established Office Visit, 0 to 17"]
    union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
    union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
    union ["Encounter, Performed": "Preventive Care- Initial Office Visit, 0 to 17"]
  ) Encounter
    where Encounter.admissionDatetime during "Measurement Period"


/*

["Laboratory Test, Performed": "CD4+ Count"]
["Laboratory Test, Performed": "CD4+ Percentage"]

["Patient Characteristic Ethnicity": "Ethnicity"]
["Patient Characteristic Payer": "Payer"]
["Patient Characteristic Race": "Race"]
["Patient Characteristic Sex": "ONC Administrative Sex"]

*/
