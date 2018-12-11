library HypoglycemiaRisk

// Working definition of a denonimator for this measure:

/*
Patients 65 and older with type 2 diabetes whose diabetes started at least 90 days 
before the start of the measurement period (MP) who are on an antihyperglycemic 
medication other than metformin monotherapy and who have complex clinical status* 
or risks for hypoglycemia with a visit during the MP

*Complex clinical status includes having at least one of the conditions listed below:

****       Taking at least two antihyperglycemics including insulin or sulfonylureas in MP
·          Blindness in MP
·          Diabetic peripheral neuropathy in MP,
·          History of amputation of lower extremity
·          History of coronary artery bypass grafting, percutaneous coronary intervention, myocardial infarction, or stroke
·          Ischemic vascular disease in MP
****       At least three chronic conditions in MP: chronic heart failure, chronic kidney disease, dementia without complications, arthritis, cancer, depression, falls, hypertension
·          Oxygen dependent lung disease in MP
·          Chronic kidney disease requiring dialysis, or end state renal disease in MP
·          Hospice care in MP
·          Dementia and/or cognitive impairment with complications in MP
·          History of hypoglycemia requiring treatment
·          Last A1c >8.6% in year prior to MP
·          Last A1c >9.1% in year prior to MP
·          BMI < 26 in MP
·          Identified with macroalbuminuria (albumin to creatinine ratio > 300) in MP
·          Last serum creatinine concentration > 114.9 uMol/l in MP 
*/


/*
1. Taking at least two antihyperglycemics including insulin or sulfonylureas in MP
*/

valueset "Insulin": 'XXX'
valueset "Sulfonylureas": 'XXX'
valueset "Antihyperglycemics": 'XXX' // Including Insulin and Sulfonylureas
valueset "Antihyperglycemics Other Than Insulin or Sulfonylureas": 'XXX'

// Two potential approaches:

// 1) Define value sets that exclude the concepts and use that to identify:
define "Taking Antihyperglycemics Other Than Insulin or Sulfonylureas":
  ["Medication, Administered": 'Antihyperglycemics Other Than Insulin or Sulfonylureas']
  
// 2) Use except to remove Insuling and Sulfonylureas:
define "Taking Antihyperglycemics Other Than Insulin or Sulfonylureas":
  ["Medication, Administered": 'Antihyperglycemics']
    except ["Medication, Administered": 'Insulin']
    except ["Medication, Administered": 'Sulfonylureas']
    
define "Taking At Least Two Antihyperglycemics Including Insulin or Sulfonylureas":
  Count(
    "Taking Antihyperglycemics Other Than Insulin or Sulfonylureas"
      union "Taking Insulin"
      union "Taking Sulfonylureas"
  ) >= 2

/*
2. At least 3 chronic conditions in MP.  I think the diagnosis will be overlaps, so:
  a. Diagnosis: Chronic heart failure overlaps MP
  b. Diagnosis: Chronic kidney disease overlaps MP
  c. Diagnosis: Dementia without complications overlaps MP
  d. Diagnosis: Arthritis overlaps MP
  e. Diagnosis: Cancer overlaps MP
  f. Diagnosis: Hypertension overlaps MP
* g. Diagnosis: Depression – there could be multiple episodes, but we want at least one episode in the MP.  If the person has 2 episodes, we only want to count them once toward the total of 3.
* h. Assessment Result (maybe), maybe diagnosis: Falls – there could be multiple falls, but we want at least one fall in the MP (we are toying with the MP and the year prior).  If the person has multiple falls, we only want to count this once toward the total of 3.
*/

define "Depression Periods During Measurement Period": 
  collapse (
    ["Diagnosis": "Depression"] D
      return D.prevalencePeriod intersect "Measurement Period"
  )

/*  
|------------------------------------|
              |-------------------------------------------->
              |----------------------|
              
Interval[@2018-06-01, null]
*/
  
define "First Depression Period During Measurement Period":
  "Depression Periods During Measurement Period" P
    where P = First("Depression Periods During Measurement Period")
    
// Note that we purposely omit a sort by because we're not interested in which one, only that there is one.
// This lets the underlying system determine the most effecient way to return the results
    
First({ 3, 2, 1 })
// 3

First(( { 3, 2, 1 }) X sort by X)
// 1

define "Falls During Measurement Period":
  (
    ["Assessment, Performed": "Fall"] A
      where A.relevantPeriod during "Measurement Period"
  )
    union (
      ["Diagnosis": "Fall"] D
        where D.prevalencePeriod during "Measurement Period"
    )

define "First Fall During Measurement Period":
  "Falls During Measurement Period" F
    where F ~ First("Falls During Measurement Period") 

define "Chronic Conditions":
  "Chronic Diagnoses Overlapping Measurement Period"
    union "First Depression Period During Measurement Period"
    union "First Fall During Measurement Period"
    
define "At Least 3 Chronic Conditions":
  Count("Chronic Conditions") >= 3

