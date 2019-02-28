library AgeBasedRiskFactors

/*
This example is based on CMS249v1 - Appropriate Use of DXA Scans in Women Under 65 Years Who Do Not Meet the Risk Factor Profile for Osteoporotic Fracture
The example illustrates an age-based determination of a number of risk factors
*/

using QDM version '5.3'

include MATGlobalCommonFunctions version '2.0.000' called Global

codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'

valueset "Average Number of Drinks per Drinking Day": 'urn:oid:2.16.840.1.113883.3.464.1003.106.12.1018'
valueset "BMI Ratio": 'urn:oid:2.16.840.1.113883.3.600.1.1490'
valueset "Chronic Liver Disease": 'urn:oid:2.16.840.1.113883.3.464.1003.199.12.1035'
valueset "Chronic Malnutrition": 'urn:oid:2.16.840.1.113883.3.464.1003.199.12.1036'
valueset "Current Tobacco Smoker": 'urn:oid:2.16.840.1.113883.3.600.2390'
valueset "Glucocorticoids (oral only)": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1266'
valueset "History of hip fracture in parent": 'urn:oid:2.16.840.1.113883.3.464.1003.113.12.1040'
valueset "Hyperthyroidism": 'urn:oid:2.16.840.1.113883.3.464.1003.117.12.1015'
valueset "Malabsorption Syndromes": 'urn:oid:2.16.840.1.113883.3.464.1003.199.12.1050'
valueset "Osteopenia": 'urn:oid:2.16.840.1.113883.3.464.1003.113.12.1049'
valueset "Osteoporotic Fractures": 'urn:oid:2.16.840.1.113883.3.464.1003.113.12.1050'
valueset "Rheumatoid Arthritis": 'urn:oid:2.16.840.1.113883.3.464.1003.113.12.1005'
valueset "Tobacco Use Screening": 'urn:oid:2.16.840.1.113883.3.526.3.1278'
valueset "White": 'urn:oid:2.16.840.1.113883.3.464.1003.123.12.1007'

code "Birthdate": '21112-8' from "LOINC" display 'Birth date'

parameter "Measurement Period" Interval<DateTime>

context Patient

define function "Has Age Dependent Risk Factors"():
	singleton from ( ["Patient Characteristic Birthdate": "Birthdate"] BirthDate
			let Age: Global."CalendarAgeInYearsAt"(BirthDate.birthDatetime, start of "Measurement Period"),
			NumberOfRiskFactors: Count("Age Dependent Combination Risk Factors")
			return ( ( Age between 50 and 54
						and NumberOfRiskFactors >= 4
				)
					or ( Age between 55 and 59
							and NumberOfRiskFactors >= 3
					)
					or ( Age between 60 and 63
							and NumberOfRiskFactors >= 2
					)
			)
	)
  
define "Age Dependent Combination Risk Factors":
	"Combination Risk Factors Applicable Any Time"
		union "Osteoporotic Fracture From Patient History"
		union "Parent History of Hip Fracture"
		union "Osteopenia Before Measurement Period"
		union "Current Tobacco User"
		union "Average of More Than Two Drinks Per Drinking Day"
		union "Glucocorticoid Medication Duration Greater Than or Equal to 90 Days"
		union "First BMI in Measurement Period Less Than or Equal to 20 kg m2"
		union ["Patient Characteristic Race": "White"]

define "Combination Risk Factors Applicable Any Time":
	( ["Diagnosis": "Rheumatoid Arthritis"]
		union ["Diagnosis": "Hyperthyroidism"]
		union ["Diagnosis": "Malabsorption Syndromes"]
		union ["Diagnosis": "Chronic Liver Disease"]
		union ["Diagnosis": "Chronic Malnutrition"] ) CombinationRiskDiagnosis
		where CombinationRiskDiagnosis.prevalencePeriod starts before end "Measurement Period"

define "Osteoporotic Fracture From Patient History":
	( ["Diagnosis": "Osteoporotic Fractures"] PathologicalFracture
			where PathologicalFracture.prevalencePeriod starts before start "Measurement Period"
	)

define "Parent History of Hip Fracture":
	["Assessment, Performed": "History of hip fracture in parent"] ParentFractureHistory
		where ParentFractureHistory.authorDatetime before start of "Measurement Period"

define "Osteopenia Before Measurement Period":
	["Diagnosis": "Osteopenia"] OsteopeniaDiagnosis
		where OsteopeniaDiagnosis.prevalencePeriod starts before start "Measurement Period"

define "Current Tobacco User":
	{ First(["Assessment, Performed": "Tobacco Use Screening"] TobaccoScreen
			where TobaccoScreen.result in "Current Tobacco Smoker"
				and TobaccoScreen.authorDatetime during "Measurement Period"
			sort by authorDatetime
	)}

define "Average of More Than Two Drinks Per Drinking Day":
	{ First(["Assessment, Performed": "Average Number of Drinks per Drinking Day"] AverageDrinks
			where AverageDrinks.authorDatetime during "Measurement Period"
				and AverageDrinks.result > 2 '{drinks}/d'
			sort by authorDatetime
	)}
  
define "Glucocorticoid Medication Duration Greater Than or Equal to 90 Days":
	"Cumulative Glucocorticoid Medication Duration" CumulativeGlucocorticoidMedication
		where CumulativeGlucocorticoidMedication.Duration >= 90

define "Cumulative Glucocorticoid Medication Duration":
	{ Tuple {
		Duration: "Cumulative Medication Duration"("Glucocorticoid Medication Active")
	} }

define "Glucocorticoid Medication Active":
	["Medication, Active": "Glucocorticoids (oral only)"] Glucocorticoid
		where Glucocorticoid.relevantPeriod starts before start of "Measurement Period"

define function "Cumulative Medication Duration"(Medication List<"Medication, Active">):
	Sum((collapse(Medication.relevantPeriod))CumulativeMedication
			return all duration in days of CumulativeMedication
	)

define "First BMI in Measurement Period Less Than or Equal to 20 kg m2":
	"First BMI in Measurement Period" FirstBMI
		where FirstBMI.result <= 20 'kg/m2'

define "First BMI in Measurement Period":
	{ First(["Physical Exam, Performed": "BMI Ratio"] BMI
			where BMI.relevantPeriod during "Measurement Period"
				and BMI.result is not null
			sort by start of relevantPeriod
	)}

