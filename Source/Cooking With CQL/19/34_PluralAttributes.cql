using QDM version '5.0.2'

valueset "Atrial Fibrillation/Flutter": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.202' version 'urn:hl7:profile:Most%20Recent%20Code%20System%20Versions%20in%20VSAC' 

// Note: Using a simplified definition for illustration only
define "Encounter with Principle Diagnosis of Ischemic Stroke":
  ["Encounter, Performed"]

// In QDM 5.0.2
define "Current Diagnosis Atrial FibrillationFlutter": 
  "Encounter with Principle Diagnosis of Ischemic Stroke" NonElectiveEncounter
    where NonElectiveEncounter.diagnosis in "Atrial Fibrillation/Flutter"

// In QDM 5.3 - using exists
//define "Current Diagnosis Atrial FibrillationFlutter": 
//  "Encounter with Principle Diagnosis of Ischemic Stroke" NonElectiveEncounter
//    where exists (NonElectiveEncounter.diagnoses D where D in "Atrial Fibrillation/Flutter")

// QDM 5.0.2 version:
define function "Encounter Has Diagnosis"(Encounter "Encounter, Performed", ValueSet List<Code>):
  Encounter.diagnosis in ValueSet

// If all the measure logic uses this function, then the 5.3 change is isolated here:
//define function "Encounter Has Diagnosis"(Encounter "Encounter, Performed", ValueSet List<Code>):
//  exists (Encounter.diagnoses D where D in ValueSet)
  
// Can we isolate the change to a function?
define "Current Diagnosis Atrial FibrillationFlutter (QDM 5.3)":
  "Encounter with Principle Diagnosis of Ischemic Stroke" NonElectiveEncounter
    where "Encounter Has Diagnosis"(NonElectiveEncounter, "Atrial Fibrillation/Flutter")
    
