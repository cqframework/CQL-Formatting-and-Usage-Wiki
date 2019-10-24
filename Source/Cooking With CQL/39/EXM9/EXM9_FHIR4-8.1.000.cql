//for 2020 reporting year. QDM to QI-4
//PC-05: Exclusive Breast Milk Feeding
//Author: TJC

/* Future changes -
1. to use MedicationAdminisration for TPN with new  SNOMED code in the medicinal product hierarchy - code will be available in Fall 2020
2. to use NutritionInake for Breast milk and Dietary intake - will be avaialbe in FHIR v5
*/

library EXM9_FHIR4 version '8.1.000'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include MATGlobalCommonFunctions_FHIR4 version '4.0.000' called Global
include SupplementalDataElements_FHIR4 version '1.0.0' called SDE

codesystem "SNOMEDCT": 'http://snomed.info/sct/731000124108'
codesystem "LOINC": 'http://loinc.org'
codesystem "ObservationCategoryCodes":  'http://terminology.hl7.org/CodeSystem/observation-category'
codesystem "ConditionClinicalStatusCodes": 'http://terminology.hl7.org/CodeSystem/condition-clinical'

valueset "Breast Milk": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.30'
valueset "Dietary Intake Other than Breast Milk": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.27'
valueset "Discharge To Acute Care Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.87'
valueset "Encounter Inpatient": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.666.5.307'
valueset "Galactosemia": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.35'
valueset "Neonatal Intensive Care Unit (NICU)": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1029.205'
valueset "Other Health Care Facility": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1029.67'
valueset "Parenteral Nutrition": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.38'
valueset "Patient Expired": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.309'
valueset "Single Live Born Newborn Born in Hospital": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.117.1.7.1.26'

code "Gestational age--at birth": '76516-4' from "LOINC" display 'Gestational age--at birth'
code "exam": 'exam' from "ObservationCategoryCodes" 

context Patient

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
	SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
	SDE."SDE Sex"

define "Initial Population":
  	"Single Live Birth Encounter With Gestational Age 37 Weeks or More"


  define "Single Live Birth Encounter With Gestational Age 37 Weeks or More":
    "Single Live Birth Encounter Without Galactosemia and Parenteral Nutrition" QualifyingSingleNewbornEncounter
	     with ["Observation": "Gestational age--at birth"] GestationalAge
		   such that exists (GestationalAge.category categories where FHIRHelpers.ToConcept(categories) ~ "exam")
            and GestationalAge.status = 'final'
			     and GestationalAge.value >= 37 weeks
           and GestationalAge.effective as dateTime during QualifyingSingleNewbornEncounter.period

      // NOTE: MedicationAdministration is replacing "procedure" in FHIR since TPN is documented on medication administraion record
      define "Single Live Birth Encounter Without Galactosemia and Parenteral Nutrition":
        "Single Live Birth Encounter" SingleLiveBirthEncounter
          without ["MedicationAdministration": "Parenteral Nutrition"] ParenteralNutrition
          such that ParenteralNutrition.effective as Period starts during SingleLiveBirthEncounter.period
          where not ( Global.EncounterDiagnosis(SingleLiveBirthEncounter).code in "Galactosemia"
                    )

          define "Single Live Birth Encounter":
              Global."Inpatient Encounter" InpatientEncounter
	             where Global.EncounterDiagnosis(InpatientEncounter).code in "Single Live Born Newborn Born in Hospital"


define "Denominator":
    "Initial Population"


define "Denominator Exclusions":
        "Single Live Birth Encounter With Newborn to NICU or Discharge to Acute Care or Other Health Care Facility or Expired"

    define "Single Live Birth Encounter With Newborn to NICU or Discharge to Acute Care or Other Health Care Facility or Expired":
      "Single Live Birth Encounter With Gestational Age 37 Weeks or More" QualifyingEncounter
    	   where exists (QualifyingEncounter.location Location
       				     where Global.GetLocation(Location.location).type in "Neonatal Intensive Care Unit (NICU)"
         			       and Location.period during QualifyingEncounter.period
         	           )
    		      or QualifyingEncounter.hospitalization.dischargeDisposition in "Patient Expired"
    		      or QualifyingEncounter.hospitalization.dischargeDisposition in "Discharge To Acute Care Facility"
    		      or QualifyingEncounter.hospitalization.dischargeDisposition in "Other Health Care Facility"


define "Numerator":
  "Single Live Birth Encounter With Newborn Fed Breast Milk Only Since Birth"

 //NOTE: Procedure needs to be replaced by NutritionInake once NutritionInake resource is avaialbe in FHIR
 //NOTE: use Procedure.usedCode to indicate Breask Milk and Diettary are not surgical procedures
  define "Single Live Birth Encounter With Newborn Fed Breast Milk Only Since Birth":
    "Single Live Birth Encounter With Gestational Age 37 Weeks or More" QualifyingEncounter
	     with ["Procedure": usedCode in "Breast Milk"] BreastMilkFeeding
		     such that BreastMilkFeeding.status = 'complete'
              and BreastMilkFeeding.performed as Period starts during QualifyingEncounter.period
	        without ["Procedure": usedCode in "Dietary Intake Other than Breast Milk"] OtherFeeding
		        such that OtherFeeding.status in {'complete', 'in progress'}
                and OtherFeeding.performed as Period starts during QualifyingEncounter.period
