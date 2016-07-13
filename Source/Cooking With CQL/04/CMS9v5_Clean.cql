/*
Population Criteria

    Initial Population =
        AND: "Physical Exam, Performed: Estimated Gestational Age at Birth (result >= 37 week(s))" starts during Occurrence A of $EncounterInpatient
        AND:
            OR: Intersection of:
                Occurrence A of $EncounterInpatient
                "Encounter, Performed: Encounter Inpatient" satisfies any:
                    (diagnosis: Single Live Birth)
                    (diagnosis: Single Live Born Newborn Born in Hospital)
            OR: Union of:
                "Diagnosis: Single Live Birth"
                "Diagnosis: Single Live Born Newborn Born in Hospital"
                starts during Occurrence A of $EncounterInpatient
        AND NOT: Union of:
            "Diagnosis: Galactosemia" starts during Occurrence A of $EncounterInpatient
            Intersection of:
                Occurrence A of $EncounterInpatient
                "Encounter, Performed: Encounter Inpatient (diagnosis: Galactosemia)"
        AND NOT: "Procedure, Performed: Parenteral Nutrition" starts during Occurrence A of $EncounterInpatient
    Denominator =
        AND: Initial Population
    Denominator Exclusions =
        OR: Intersection of:
            Occurrence A of $EncounterInpatient
            "Encounter, Performed: Encounter Inpatient" satisfies any:
                (facility location: Neonatal Intensive Care Unit (NICU))
                (discharge status: Patient Expired)
                (discharge status: Discharge To Acute Care Facility)
    Numerator =
        AND: "Substance, Administered: Breast Milk" starts during Occurrence A of $EncounterInpatient
        AND NOT: "Substance, Administered: Dietary Intake Other than Breast Milk" starts during Occurrence A of $EncounterInpatient
    Numerator Exclusions =
        None
    Denominator Exceptions =
        None
    Stratification =
        None

Data Criteria (QDM Variables)

    $EncounterInpatient =
        "Encounter, Performed: Encounter Inpatient" satisfies all:
            (length of stay <= 120 day(s))
            ends during "Measurement Period"

Data Criteria (QDM Data Elements)

    "Diagnosis: Galactosemia" using "Galactosemia Grouping Value Set (2.16.840.1.113883.3.117.1.7.1.35)"
    "Diagnosis: Single Live Birth" using "Single Live Birth SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.25)"
    "Diagnosis: Single Live Born Newborn Born in Hospital" using "Single Live Born Newborn Born in Hospital Grouping Value Set (2.16.840.1.113883.3.117.1.7.1.26)"
    "Encounter, Performed: Encounter Inpatient" using "Encounter Inpatient SNOMEDCT Value Set (2.16.840.1.113883.3.666.5.307)"
    "Physical Exam, Performed: Estimated Gestational Age at Birth" using "Estimated Gestational Age at Birth SNOMEDCT Value Set (2.16.840.1.113762.1.4.1045.47)"
    "Procedure, Performed: Parenteral Nutrition" using "Parenteral Nutrition Grouping Value Set (2.16.840.1.113883.3.117.1.7.1.38)"
    "Substance, Administered: Breast Milk" using "Breast Milk SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.30)"
    "Substance, Administered: Dietary Intake Other than Breast Milk" using "Dietary Intake Other than Breast Milk SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.27)"
    Attribute: "Facility location: Neonatal Intensive Care Unit (NICU)" using "Neonatal Intensive Care Unit (NICU) SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.75)"
    Attribute: "Discharge status: Patient Expired" using "Patient Expired SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.309)"
    Attribute: "Discharge status: Discharge To Acute Care Facility" using "Discharge To Acute Care Facility SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.87)"
    Attribute: "Diagnosis: Single Live Born Newborn Born in Hospital" using "Single Live Born Newborn Born in Hospital Grouping Value Set (2.16.840.1.113883.3.117.1.7.1.26)"
    Attribute: "Diagnosis: Single Live Birth" using "Single Live Birth SNOMEDCT Value Set (2.16.840.1.113883.3.117.1.7.1.25)"
    Attribute: "Diagnosis: Galactosemia" using "Galactosemia Grouping Value Set (2.16.840.1.113883.3.117.1.7.1.35)"

Supplemental Data Elements

    "Patient Characteristic Ethnicity: Ethnicity" using "Ethnicity CDCREC Value Set (2.16.840.1.114222.4.11.837)"
    "Patient Characteristic Payer: Payer" using "Payer SOP Value Set (2.16.840.1.114222.4.11.3591)"
    "Patient Characteristic Race: Race" using "Race CDCREC Value Set (2.16.840.1.114222.4.11.836)"
    "Patient Characteristic Sex: ONC Administrative Sex" using "ONC Administrative Sex AdministrativeGender Value Set (2.16.840.1.113762.1.4.1)"

Risk Adjustment Variables

    None
*/
