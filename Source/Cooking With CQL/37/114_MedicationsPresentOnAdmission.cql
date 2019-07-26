library MedicationsPresentOnAdmission

/*
What is the best way to specify in CQL that a medication was present on admission
for an inpatient encounter. There have been conversations recently about a
"presentOnAdmissionIndicator" for diagnoses in QDM 5.5, but not something equivalent
for medications.

There are some examples of possible workarounds (e.g. medication active before the start of
an encounter), but it's not clear whether this approach will work.

We understand, of course, that having a way to specify this in CQL is not the same as 
assuring that the medication list is up to date, or that it would clearly delineate 
between medications that were truly "present on admission" and those initiated in 
the hospital, but we are looking for the clearest way to use logic to express our intent.  
*/

using QDM version '5.4'

context Patient

/*
QDM does not specifically have an "Admission Medication" like "MedicationDischarge", this
concept would be represented with Medication, Active where the medication relevant period
contains the encounter start date.
*/

define "Medications Active at Admission":
  ["Medication, Active"] M
	  with ["Encounter, Performed"] E
		  such that M.relevantPeriod contains start of E.relevantPeriod

/*
This is typically documented as part of the admissions record,
but if there is no documentation in the admissions record, this may be from the most recent known
medication list from an ambulatory setting. Either way, the Medication, Active must have a relevant
period that includes the start date of the encounter.

Note also that this is only addressing the simplest case of an inpatient admission. It may need to
be expanded to account for an immediately preceding emergency department visit, depending on
measure intent.

Also note that the QDM model specifies relevant period start for a Medication, Active as the
time when the patient is first known to have been taking the medication. Whether this is captured
by the EHRs is a question for investigation.
*/

