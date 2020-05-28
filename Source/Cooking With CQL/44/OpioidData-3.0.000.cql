library OpioidData version '3.0.000'

using QDM version '5.5'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "DrugIngredients":
  //This library uses the RxNorm code (drug code) of the opioid prescription medication to locate the ingredient code. The ingredient code is then used in calculating the MME of the opioid ingredient in the Opioid Logic.  Generated from LocalDataStore_RxNav_OpioidCds-2020-02-18.sqlite
  { {
    drugCode: 197696,
    drugName: '72 HR Fentanyl 0.075 MG/HR Transdermal System',
    doseFormCode: 316987,
    doseFormName: 'Transdermal System',
    ingredientCode: 4337,
    ingredientName: 'Fentanyl',
    strength: '0.075 MG/HR',
    strengthValue: 0.075,
    strengthUnit: 'MG/HR'
  }, {
    drugCode: 197873,
    drugName: 'Levorphanol 2 MG Oral Tablet',
    doseFormCode: 317541,
    doseFormName: 'Oral Tablet',
    ingredientCode: 6378,
    ingredientName: 'Levorphanol',
    strength: '2 MG',
    strengthValue: 2.0,
    strengthUnit: 'MG'
  }, {
    drugCode: 205533,
    drugName: '1 ML Buprenorphine 0.3 MG/ML Injection [Buprenex]',
    doseFormCode: 1649574,
    doseFormName: 'Injection',
    ingredientCode: 1819,
    ingredientName: 'Buprenorphine',
    strength: '0.3 MG/ML',
    strengthValue: 0.3,
    strengthUnit: 'MG/ML'
  }, {
    drugCode: 238129,
    drugName: '1 ML Buprenorphine 0.3 MG/ML Injection',
    doseFormCode: 1649574,
    doseFormName: 'Injection',
    ingredientCode: 1819,
    ingredientName: 'Buprenorphine',
    strength: '0.3 MG/ML',
    strengthValue: 0.3,
    strengthUnit: 'MG/ML'
  }
  // Snipped for brevity
 }
