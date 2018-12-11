/*
  ACO 38 - Risk-Standardized Acute Admission Rates for Patients With Multiple Chronic Conditions
  https://www.cms.gov/Medicare/Medicare-Fee-for-Service-Payment/sharedsavingsprogram/Downloads/ACO-38.pdf

  We are hoping to model a measure that looks for a logical "AND" between elements in a Risk Adjustment variable.
  So, as our example, we want to create a risk-adjustment variable that identifies whether the patient meets
  these criteria:

    <59 years old
    >=50 years old
    Female
*/

define "Some Reasonable Name for a Risk Adjustment Factor":
  Global.CalculateAgeInYearsAt(Patient.birthDatetime, start of "Measurement Period") < 59
    or (
      Global.CalculateAgeInYearsAt(Patient.birthDatetime, start of "Measurement Period") >= 50
        and exists ["Patient Characterstic Sex": "Female"]
    )
    
/*
This creates a risk adjustment variable that simply returns a yes or no based on the given criteria
*/

