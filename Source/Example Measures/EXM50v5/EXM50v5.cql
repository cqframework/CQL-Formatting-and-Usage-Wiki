/*
This example is a work in progress and should not be considered a final specification
or recommendation for guidance. This example will help guide and direct the process
of finding conventions and usage patterns that meet the needs of the various stakeholders
in the measure development community.
*/

/*

Population Criteria

    Initial Population =
        AND: First: "Occurrence A of Intervention, Performed: Referral" during "Measurement Period"
        AND: Union of:
            "Encounter, Performed: Preventive Care- Initial Office Visit, 0 to 17"
            "Encounter, Performed: Preventive Care - Established Office Visit, 0 to 17"
            "Encounter, Performed: Preventive Care Services - Established Office Visit, 18 and Up"
            "Encounter, Performed: Preventive Care Services-Initial Office Visit, 18 and Up"
            "Encounter, Performed: Office Visit"
            "Encounter, Performed: Face-to-Face Interaction"
            "Encounter, Performed: Ophthalmological Services"
            during "Measurement Period"
    Denominator =
        AND: Initial Population
    Denominator Exclusions =
        None
    Numerator =
        AND: "Communication: From Provider to Provider: Consultant Report" satisfies all:
            fulfills "Occurrence A of Intervention, Performed: Referral"
            starts after start of "Occurrence A of Intervention, Performed: Referral"
    Numerator Exclusions =
        None
    Denominator Exceptions =
        None
    Stratification =
        None

Data Criteria (QDM Variables)

    None

Data Criteria (QDM Data Elements)

    "Communication: From Provider to Provider: Consultant Report" using "Consultant Report Grouping Value Set (2.16.840.1.113883.3.464.1003.121.12.1006)"
    "Encounter, Performed: Face-to-Face Interaction" using "Face-to-Face Interaction Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1048)"
    "Encounter, Performed: Office Visit" using "Office Visit Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1001)"
    "Encounter, Performed: Ophthalmological Services" using "Ophthalmological Services Grouping Value Set (2.16.840.1.113883.3.526.3.1285)"
    "Encounter, Performed: Preventive Care - Established Office Visit, 0 to 17" using "Preventive Care - Established Office Visit, 0 to 17 Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1024)"
    "Encounter, Performed: Preventive Care Services - Established Office Visit, 18 and Up" using "Preventive Care Services - Established Office Visit, 18 and Up Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1025)"
    "Encounter, Performed: Preventive Care Services-Initial Office Visit, 18 and Up" using "Preventive Care Services-Initial Office Visit, 18 and Up Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1023)"
    "Encounter, Performed: Preventive Care- Initial Office Visit, 0 to 17" using "Preventive Care- Initial Office Visit, 0 to 17 Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1022)"
    "Intervention, Performed: Referral" using "Referral Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1046)"

Supplemental Data Elements

    "Patient Characteristic Ethnicity: Ethnicity" using "Ethnicity CDCREC Value Set (2.16.840.1.114222.4.11.837)"
    "Patient Characteristic Payer: Payer" using "Payer SOP Value Set (2.16.840.1.114222.4.11.3591)"
    "Patient Characteristic Race: Race" using "Race CDCREC Value Set (2.16.840.1.114222.4.11.836)"
    "Patient Characteristic Sex: ONC Administrative Sex" using "ONC Administrative Sex AdministrativeGender Value Set (2.16.840.1.113762.1.4.1)"

Risk Adjustment Variables

    None

*/
