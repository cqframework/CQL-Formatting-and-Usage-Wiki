// Negation Discussion

"Encounter, Performed: Inpatient Encounter"
"Encounter, Performed" (negation rationale: Reason Not Performed)


1. Explicit Semantics
	a. ["Encounter, Performed"] – All encounters, whether they were performed or not

  ["Encounter, Performed"] E where E.negationRationale is null
	["Encounter, Performed"] E where E.negationRationale in "Reason Not Done"


	["Encounters"] E where E.negationRationale is null
	["Encounters"] E where E.negationRationale in "Reason Not Done"


2. New Types
	a. ["Encounter, Performed"] – Only the encounters that were performed
	b. ["Encounter, Not Performed"] – Encounters with a negation rationale

3. Clinical Negation
["Procedure, Performed"] P
	without ["Contraindication": "Against This Particular Procedure"]
	without ["PatientPreference": "Not Performing This Procedure"]

["Encounter, Performed": "Inpatient"] E where E.negationRationale in "Patient Refused"
