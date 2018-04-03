// QDM to CQL Walkthrough
// CMS105v6 - From the 2017 Annual Update
// CMS105 DRAFT - From the February 2018 Public Draft Review

/*
  Initial Population =
      AND: Age>= 18 year(s) at: Occurrence A of $EncounterInpatientNonElective
      AND:
          OR: Intersection of:
              Occurrence A of $EncounterInpatientNonElective
              "Encounter, Performed: Non-Elective Inpatient Encounter (principal diagnosis: Ischemic Stroke)"
          OR: Intersection of:
              Occurrence A of $EncounterInpatientNonElective
              "Encounter, Performed: Non-Elective Inpatient Encounter (principal diagnosis: Hemorrhagic Stroke)"
*/

/*
    Initial Population
            TJC."Encounter with Principal Diagnosis and Age"
*/

/*
  Denominator =
      AND: Initial Population
      AND: Intersection of:
          Occurrence A of $EncounterInpatientNonElective
          "Encounter, Performed: Non-Elective Inpatient Encounter (principal diagnosis: Ischemic Stroke)"
*/

/*         
    Denominator
            TJC."Ischemic Stroke Encounter"
*/

/*
  Denominator Exclusions =
      OR: "Laboratory Test, Performed: LDL-c" satisfies all:
          (result < 70 mg/dL)
          satisfies any:
              <= 30 day(s) ends before start of Occurrence A of $EncounterInpatientNonElective
              starts during Occurrence A of $EncounterInpatientNonElective
      OR: Intersection of:
          Occurrence A of $EncounterInpatientNonElective
          "Encounter, Performed: Non-Elective Inpatient Encounter" satisfies any:
              (discharge status: Discharge To Acute Care Facility)
              (discharge status: Left Against Medical Advice)
              (discharge status: Patient Expired)
              (discharge status: Discharged to Home for Hospice Care)
              (discharge status: Discharged to Health Care Facility for Hospice Care)
      OR: $InterventionComfortMeasures starts during ("Encounter, Performed: Emergency Department Visit" <= 1 hour(s) ends before or concurrent with start of Occurrence A of $EncounterInpatientNonElective )
      OR: $InterventionComfortMeasures starts during Occurrence A of $EncounterInpatientNonElective
*/

/*         
    Denominator Exclusions
            ( ( TJC."Ischemic Stroke Encounters with Discharge Status" )
            		union TJC."Comfort Measures during Hospitalization"
            )
*/

/*
  Numerator =
      AND: "Medication, Discharge: Statin Grouper" starts during Occurrence A of $EncounterInpatientNonElective
*/

/*         
    Numerator
            TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
            	with "Statin at Discharge" DischargeStatin
            		such that DischargeStatin.authorDatetime during IschemicStrokeEncounter.relevantPeriod
*/

/*
  Numerator Exclusions =
      None
*/

/*
  Denominator Exceptions =
      OR: "Medication, Allergy: Statin Allergen" starts before or concurrent with end of Occurrence A of $EncounterInpatientNonElective
      OR: Union of:
          "Medication, Discharge not done: Patient Refusal" for "Statin Grouper"
          "Medication, Discharge not done: Medical Reason" for "Statin Grouper"
          starts during Occurrence A of $EncounterInpatientNonElective
*/

/*         
    Denominator Exceptions
            ( ( TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
            			with "Statin Not Given at Discharge" NoDischargeStatin
            				such that NoDischargeStatin.authorDatetime during IschemicStrokeEncounter.relevantPeriod
            	)
            		union ( TJC."Ischemic Stroke Encounter" IschemicStrokeEncounter
            				with "Statin Allergy" StatinAllergy
            					such that StatinAllergy.prevalencePeriod starts on or before end of IschemicStrokeEncounter.relevantPeriod
            		)
            		union "Encounter with Max LDL less than 70 mg per dL"
            )
*/

/*
  Stratification =
      None
*/

