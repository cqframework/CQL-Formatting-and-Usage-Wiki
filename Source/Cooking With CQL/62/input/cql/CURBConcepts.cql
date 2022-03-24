library CURBConcepts

codesystem SNOMED: 'http://snomed.info/sct'
codesystem LOINC: 'http://loinc.org'

//valueset "Community Acquired Pneumonia": 'http://example.org/fhir/ValueSet/community-acquired-pneumonia'
code "Community Acquired Pneumonia": '385093006' from SNOMED display 'Community acquired pneumonia (disorder)'
//valueset "Confusion": 'http://example.org/fhir/ValueSet/confusion'
code "Confusion": '42849-0' from LOINC display 'Confusion [CCC]'
// { LA65-8 Improved, LA66-6 Deteriorated, LA6635-2 Stabilized }
//valueset "Blood urea nitrogen": 'http://example.org/fhir/ValueSet/blood-urea-nitrogen'
code "Blood urea nitrogen": '12962-7' from LOINC display 'Urea nitrogen [Mass/volume] in Venous blood'
//valueset "Respiratory rate": 'http://example.org/fhir/ValueSet/respiratory-rate'
code "Respiratory rate": '9279-1' from LOINC display 'Respiratory rate'
//valueset "Blood pressure": 'http://example.org/fhir/ValueSet/blood-pressure'
code "Blood pressure": '85354-9' from LOINC display 'Blood pressure panel with all children optional'
//valueset "Systolic blood pressure": 'http://example.org/fhir/ValueSet/systolic-blood-pressure'
code "Systolic blood pressure": '8480-6' from LOINC display 'Systolic blood pressure'
//valueset "Diastolic blood pressure": 'http://example.org/fhir/ValueSet/diastolic-blood-pressure'
code "Diastolic blood pressure": '8462-4' from LOINC display 'Diastolic blood pressure'
