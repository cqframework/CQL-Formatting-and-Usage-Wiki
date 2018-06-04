library NegationRedux

using QDM version '5.3'

valueset "Long Acting Reversible Contraceptive (LARC) Methods": 'TBD'

context Patient

// Consider this numerator expression
define "Numerator":
     exists ( ["Intervention, Order": "Long Acting Reversible Contraceptive (LARC) Methods"] ) LARC
           where LARC.negationRationale is null

// Note that the check for negationRationale is redundant

// This returns all intervention orders
define "Interventions Ordered": ["Intervention, Order"]

// This returns all interventions _not_ ordered
define "Interventions Not Ordered": ["Intervention, Not Ordered"]

// negationRationale is only provided for interventions (or events in general) that were
// not ordered, so the element will be null for any positive event.

// Section 2.8.1 of the CQL-Based HQMF IG specifies the negated names for QDM Data Types:

QDM Data Type  Names	Negated Name
"Adverse Event"	N/A
"Allergy/Intolerance"	N/A
"Assessment, Recommended"	"Assessment, Not Recommended"
"Assessment, Performed"	"Assessment, Not Performed"
"Care Goal"	N/A
"Communication:	From Patient To Provider"	"Communication:	From Patient To Provider, Not Done"
"Communication:	From Provider To Patient"	"Communication:	From Provider To Patient, Not Done"
"Communication:	From Provider To Provider"	"Communication:	From Provider To Provider, Not Done"
"Device, Order"	"Device, Not Ordered"
"Device, Recommended"	"Device, Not Recommended"
"Device, Applied"	"Device, Not Applied"
"Diagnosis"	N/A
"Diagnostic Study, Order"	"Diagnostic Study, Not Ordered"
"Diagnostic Study, Recommended"	"Diagnostic Study, Not Recommended"
"Diagnostic Study, Performed"	"Diagnostic Study, Not Performed"
"Encounter, Active"	N/A
"Encounter, Order"	"Encounter, Not Ordered"
"Encounter, Recommended"	"Encounter, Not Recommended"
"Encounter, Performed"	"Encounter, Not Performed"
"Family History"	N/A
"Immunization, Order"	"Immunization, Not Ordered"
"Immunization, Administered"	"Immunization, Not Administered"
"Intervention, Order"	"Intervention, Not Ordered"
"Intervention, Recommended"	"Intervention, Not Recommended"
"Intervention, Performed"	"Intervention, Not Performed"
"Laboratory Test, Order"	"Laboratory Test, Not Ordered"
"Laboratory Test, Recommended"	"Laboratory Test, Not Recommended"
"Laboratory Test, Performed"	"Laboratory Test, Not Performed"
"Medication, Active"	N/A
"Medication, Administered"	"Medication, Not Administered"
"Medication, Dispensed"	"Medication, Not Dispensed"
"Medication, Discharge"	"Medication, Not Discharged"
"Medication, Order"	"Medication, Not Ordered"
"Patient Care Experience"	N/A
"Patient Characteristic"	N/A
"Patient Characteristic Birthdate"	N/A
"Patient Characteristic Clinical Trial Participant"	N/A
"Patient Characteristic Ethnicity"	N/A
"Patient Characteristic Expired"	N/A
"Patient Characteristic Payer"	N/A
"Patient Characteristic Race"	N/A
"Patient Characteristic Sex"	N/A
"Provider Characteristic"	N/A
"Provider Care Experience"	N/A
"Physical Exam, Order"	"Physical Exam, Not Ordered"
"Physical Exam, Recommended"	"Physical Exam, Not Recommended"
"Physical Exam, Performed"	"Physical Exam, Not Performed"
"Procedure, Order"	"Procedure, Not Ordered"
"Procedure, Recommended"	"Procedure, Not Recommended"
"Procedure, Performed"	"Procedure, Not Performed"
"Substance, Order"	"Substance, Not Ordered"
"Substance, Recommended"	"Substance, Not Recommended"
"Substance, Administered"	"Substance, Not Administered"
"Symptom"	N/A
