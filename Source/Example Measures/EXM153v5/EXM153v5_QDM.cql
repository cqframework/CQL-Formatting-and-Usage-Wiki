library EXM153 version '5'

/*
Based on CMS 153v5
Chlamydia Screening for Women

Patient-based Proportion Measure with Stratification

This example is a work in progress and should not be considered a final specification
or recommendation for guidance. This example will help guide and direct the process
of finding conventions and usage patterns that meet the needs of the various stakeholders
in the measure development community.

Population Criteria

    Initial Population =
        AND: Age>= 16 year(s) at: "Measurement Period"
        AND: Age< 24 year(s) at: "Measurement Period"
        AND: "Patient Characteristic Sex: Female"
        AND: Union of:
            "Encounter, Performed: Office Visit"
            "Encounter, Performed: Face-to-Face Interaction"
            "Encounter, Performed: Preventive Care Services - Established Office Visit, 18 and Up"
            "Encounter, Performed: Preventive Care Services-Initial Office Visit, 18 and Up"
            "Encounter, Performed: Preventive Care - Established Office Visit, 0 to 17"
            "Encounter, Performed: Preventive Care- Initial Office Visit, 0 to 17"
            "Encounter, Performed: Home Healthcare Services"
            during "Measurement Period"
        AND:
            OR: Union of:
                "Diagnosis: Other Female Reproductive Conditions"
                "Diagnosis: Genital Herpes"
                "Diagnosis: Gonococcal Infections and Venereal Diseases"
                "Medication, Active: Contraceptive Medications"
                "Diagnosis: Inflammatory Diseases of Female Reproductive Organs"
                "Diagnosis: Chlamydia"
                "Diagnosis: HIV"
                "Diagnosis: Syphilis"
                "Diagnosis: Complications of Pregnancy, Childbirth and the Puerperium"
                overlaps "Measurement Period"
            OR: Union of:
                "Laboratory Test, Order: Pregnancy Test"
                "Laboratory Test, Order: Pap Test"
                "Procedure, Performed: Delivery Live Births"
                "Laboratory Test, Order: Lab Tests During Pregnancy"
                "Laboratory Test, Order: Lab Tests for Sexually Transmitted Infections"
                "Medication, Order: Contraceptive Medications"
                "Diagnostic Study, Order: Diagnostic Studies During Pregnancy"
                "Procedure, Performed: Procedures During Pregnancy"
                "Procedure, Performed: Procedures Involving Contraceptive Devices"
                during "Measurement Period"
    Denominator =
        AND: Initial Population
    Denominator Exclusions =
        OR:
            AND: Union of:
                "Medication, Order: Isotretinoin"
                "Diagnostic Study, Order: X-Ray Study (all inclusive)"
                <= 7 day(s) starts after end of ("Laboratory Test, Order: Pregnancy Test" during "Measurement Period" )
            AND NOT: Union of:
                Union of:
                    "Diagnosis: Other Female Reproductive Conditions"
                    "Diagnosis: Genital Herpes"
                    "Diagnosis: Gonococcal Infections and Venereal Diseases"
                    "Medication, Active: Contraceptive Medications"
                    "Diagnosis: Inflammatory Diseases of Female Reproductive Organs"
                    "Diagnosis: Chlamydia"
                    "Diagnosis: HIV"
                    "Diagnosis: Syphilis"
                    "Diagnosis: Complications of Pregnancy, Childbirth and the Puerperium"
                    overlaps "Measurement Period"
                Union of:
                    "Laboratory Test, Order: Pap Test"
                    "Procedure, Performed: Delivery Live Births"
                    "Laboratory Test, Order: Lab Tests During Pregnancy"
                    "Laboratory Test, Order: Lab Tests for Sexually Transmitted Infections"
                    "Medication, Order: Contraceptive Medications"
                    "Diagnostic Study, Order: Diagnostic Studies During Pregnancy"
                    "Procedure, Performed: Procedures During Pregnancy"
                    "Procedure, Performed: Procedures Involving Contraceptive Devices"
                    during "Measurement Period"
    Numerator =
        AND: "Laboratory Test, Performed: Chlamydia Screening (result)" during "Measurement Period"
    Numerator Exclusions =
        None
    Denominator Exceptions =
        None
    Stratifications =
        Stratification 1 =
            AND: Age>= 16 year(s) at: "Measurement Period"
            AND: Age< 20 year(s) at: "Measurement Period"
        Stratification 2 =
            AND: Age>= 20 year(s) at: "Measurement Period"
            AND: Age< 24 year(s) at: "Measurement Period"

Data Criteria (QDM Variables)

    None

Data Criteria (QDM Data Elements)

    "Diagnosis: Chlamydia" using "Chlamydia Grouping Value Set (2.16.840.1.113883.3.464.1003.112.12.1003)"
    "Diagnosis: Complications of Pregnancy, Childbirth and the Puerperium" using "Complications of Pregnancy, Childbirth and the Puerperium Grouping Value Set (2.16.840.1.113883.3.464.1003.111.12.1012)"
    "Diagnosis: Genital Herpes" using "Genital Herpes Grouping Value Set (2.16.840.1.113883.3.464.1003.110.12.1049)"
    "Diagnosis: Gonococcal Infections and Venereal Diseases" using "Gonococcal Infections and Venereal Diseases Grouping Value Set (2.16.840.1.113883.3.464.1003.112.12.1001)"
    "Diagnosis: HIV" using "HIV Grouping Value Set (2.16.840.1.113883.3.464.1003.120.12.1003)"
    "Diagnosis: Inflammatory Diseases of Female Reproductive Organs" using "Inflammatory Diseases of Female Reproductive Organs Grouping Value Set (2.16.840.1.113883.3.464.1003.112.12.1004)"
    "Diagnosis: Other Female Reproductive Conditions" using "Other Female Reproductive Conditions Grouping Value Set (2.16.840.1.113883.3.464.1003.111.12.1006)"
    "Diagnosis: Syphilis" using "Syphilis Grouping Value Set (2.16.840.1.113883.3.464.1003.112.12.1002)"
    "Diagnostic Study, Order: Diagnostic Studies During Pregnancy" using "Diagnostic Studies During Pregnancy Grouping Value Set (2.16.840.1.113883.3.464.1003.111.12.1008)"
    "Diagnostic Study, Order: X-Ray Study (all inclusive)" using "X-Ray Study (all inclusive) Grouping Value Set (2.16.840.1.113883.3.464.1003.198.12.1034)"
    "Encounter, Performed: Face-to-Face Interaction" using "Face-to-Face Interaction Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1048)"
    "Encounter, Performed: Home Healthcare Services" using "Home Healthcare Services Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1016)"
    "Encounter, Performed: Office Visit" using "Office Visit Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1001)"
    "Encounter, Performed: Preventive Care - Established Office Visit, 0 to 17" using "Preventive Care - Established Office Visit, 0 to 17 Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1024)"
    "Encounter, Performed: Preventive Care Services - Established Office Visit, 18 and Up" using "Preventive Care Services - Established Office Visit, 18 and Up Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1025)"
    "Encounter, Performed: Preventive Care Services-Initial Office Visit, 18 and Up" using "Preventive Care Services-Initial Office Visit, 18 and Up Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1023)"
    "Encounter, Performed: Preventive Care- Initial Office Visit, 0 to 17" using "Preventive Care- Initial Office Visit, 0 to 17 Grouping Value Set (2.16.840.1.113883.3.464.1003.101.12.1022)"
    "Laboratory Test, Order: Lab Tests During Pregnancy" using "Lab Tests During Pregnancy Grouping Value Set (2.16.840.1.113883.3.464.1003.111.12.1007)"
    "Laboratory Test, Order: Lab Tests for Sexually Transmitted Infections" using "Lab Tests for Sexually Transmitted Infections Grouping Value Set (2.16.840.1.113883.3.464.1003.110.12.1051)"
    "Laboratory Test, Order: Pap Test" using "Pap Test Grouping Value Set (2.16.840.1.113883.3.464.1003.108.12.1017)"
    "Laboratory Test, Order: Pregnancy Test" using "Pregnancy Test Grouping Value Set (2.16.840.1.113883.3.464.1003.111.12.1011)"
    "Laboratory Test, Performed: Chlamydia Screening" using "Chlamydia Screening Grouping Value Set (2.16.840.1.113883.3.464.1003.110.12.1052)"
    "Medication, Active: Contraceptive Medications" using "Contraceptive Medications Grouping Value Set (2.16.840.1.113883.3.464.1003.196.12.1080)"
    "Medication, Order: Contraceptive Medications" using "Contraceptive Medications Grouping Value Set (2.16.840.1.113883.3.464.1003.196.12.1080)"
    "Medication, Order: Isotretinoin" using "Isotretinoin Grouping Value Set (2.16.840.1.113883.3.464.1003.196.12.1143)"
    "Patient Characteristic Sex: Female" using "Female AdministrativeGender Value Set (2.16.840.1.113883.3.560.100.2)"
    "Procedure, Performed: Delivery Live Births" using "Delivery Live Births Grouping Value Set (2.16.840.1.113883.3.464.1003.111.12.1015)"
    "Procedure, Performed: Procedures During Pregnancy" using "Procedures During Pregnancy Grouping Value Set (2.16.840.1.113883.3.464.1003.111.12.1009)"
    "Procedure, Performed: Procedures Involving Contraceptive Devices" using "Procedures Involving Contraceptive Devices Grouping Value Set (2.16.840.1.113883.3.464.1003.111.12.1010)"

Supplemental Data Elements

    "Patient Characteristic Ethnicity: Ethnicity" using "Ethnicity CDCREC Value Set (2.16.840.1.114222.4.11.837)"
    "Patient Characteristic Payer: Payer" using "Payer SOP Value Set (2.16.840.1.114222.4.11.3591)"
    "Patient Characteristic Race: Race" using "Race CDCREC Value Set (2.16.840.1.114222.4.11.836)"
    "Patient Characteristic Sex: ONC Administrative Sex" using "ONC Administrative Sex AdministrativeGender Value Set (2.16.840.1.113762.1.4.1)"

Risk Adjustment Variables

    None

*/

using QDM version '5'

parameter "Measurement Period" Interval<DateTime>
