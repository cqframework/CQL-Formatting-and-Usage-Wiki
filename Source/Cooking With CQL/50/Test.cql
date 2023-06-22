library Test

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

context Patient

define "Medication Using Reference":
  exists ([Medication] Med
       where "Was Administered"(Med))

define function "Was Administered"(medication Medication):
  exists ([MedicationAdministration: medication = GetReference(medication)])

define function GetReference(medication Medication):
  Reference { reference: string { value: 'Medication/' + medication.id } }
