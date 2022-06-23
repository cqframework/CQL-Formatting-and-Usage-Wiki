/*
Decision Support

[USPSTF's recommendation on Lung Cancer Screening](https://www.uspreventiveservicestaskforce.org/Page/Document/RecommendationStatementFinal/lung-cancer-screening)

Recommendation Statement:

​The USPSTF recommends annual screening for lung cancer with low-dose computed
tomography (LDCT) in adults aged 55 to 80 years who have a 30 pack-year smoking
history and currently smoke or have quit within the past 15 years. Screening
should be discontinued once a person has not smoked for 15 years or develops
a health problem that substantially limits life expectancy or the ability or
willingness to have curative lung surgery

Expected Testing Results:
Former-Smoker: Recommendation is applicable, former smoker who quit within past 15 years
Heavy-Smoker: Recommendation not applicable, diagnosis of lung cancer
Never-Smoker: Recommendation not application, never-smoker

NOTE: This example is for instructional purposes only and is dervied from work in progress.
It should in no way be considered a final specification or recommendation for guidance.
The example is derived from work in progress at the University of Utah, see the
original project repository for more information: https://github.com/cqframework/lcs-cds

*/
library LungCancerScreening

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include FHIRCommon version '4.0.1' called FC

codesystem "SNOMED": 'http://snomed.info/sct'
codesystem "LOINC": 'http://loinc.org'

valueset "Lung Cancer":  'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1116.89'
valueset "Smoking Status": 'http://hl7.org/fhir/us/core/ValueSet/us-core-observation-smokingstatus'
valueset "Current Smoker": 'http://example.org/fhir/ValueSet/currentsmoker'
valueset "Chest CT": 'http://example.org/fhir/ValueSet/chest-ct-procedure'
valueset "Condition Clinical Status Active": 'http://example.org/fhir/ValueSet/conditionclinicalstatusactive'

code "Tobacco Smoking Status": '72166-2' from "LOINC"
code "Former Smoker": '8517006' from "SNOMED"
code "PACKS A DAY": '8663-7' from "LOINC" display 'packs per day'

context Patient

/*
Build expressions for the required data elements:

Patient age in years based on date of birth
Smoking status observation
Lung cancer diagnosis
Chest CT procedure

Inclusion criteria:
Patient is 55 through 80
Patient is a current smoker
Patient is a former smoker who quit within the past 15 years
Patient has a 30 pack-year smoking history

Exclusion criteria
Patient has lung cancer
Patient had a chest-ct within the last year
*/
