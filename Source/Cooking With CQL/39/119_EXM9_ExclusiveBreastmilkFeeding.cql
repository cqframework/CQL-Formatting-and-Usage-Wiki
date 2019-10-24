/*
Review of the draft FHIR expression of PC-05 (CMS09)
*/

// NOTE: MedicationAdministration is replacing "procedure" in FHIR since TPN is documented on medication administraion record
// NOTE: The use of Global.EncounterDiagnosis here is actually returning a list of diagnoses, should be a not exists here:
define "Single Live Birth Encounter Without Galactosemia and Parenteral Nutrition":
  "Single Live Birth Encounter" SingleLiveBirthEncounter
    without ["MedicationAdministration": "Parenteral Nutrition"] ParenteralNutrition
    	such that ParenteralNutrition.effective as Period starts during SingleLiveBirthEncounter.period
    //where not (Global.EncounterDiagnosis(SingleLiveBirthEncounter).code in "Galactosemia")
		where not exists (
			(Global.EncounterDiagnosis(SingleLiveBirthEncounter)) EncounterDiagnosis
		    where EncounterDiagnosis.code in "Galactosemia"
		)

//NOTE: Procedure needs to be replaced by NutritionInake once NutritionInake resource is avaialbe in FHIR
//NOTE: use Procedure.usedCode to indicate Breask Milk and Dietary are not surgical procedures
//NOTE: Should the procedure have a code of something like "Feeding"?
//NOTE: Will this procedure be recorded for the mother, or the infant?
define "Single Live Birth Encounter With Newborn Fed Breast Milk Only Since Birth":
  "Single Live Birth Encounter With Gestational Age 37 Weeks or More" QualifyingEncounter
    with ["Procedure": usedCode in "Breast Milk"] BreastMilkFeeding
	    such that BreastMilkFeeding.status = 'complete'
        and BreastMilkFeeding.performed as Period starts during QualifyingEncounter.period
    without ["Procedure": usedCode in "Dietary Intake Other than Breast Milk"] OtherFeeding
      such that OtherFeeding.status in {'complete', 'in progress'}
        and OtherFeeding.performed as Period starts during QualifyingEncounter.period

