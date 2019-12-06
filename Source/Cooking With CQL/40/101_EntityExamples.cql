// So this is saying Inpatient encounters where the primary participant is an Organization
define "Qualifying Encounters":
  ["Encounter, Performed": "Inpatient"] Encounter
    where Encounter.participant is "Organization"

define "Eye Exam Order":
  ["Intervention, Order": "Diabetic Eye Exam"] ExamOrder
    where ExamOrder.requester is Practitioner
      // So the intent here is to say "the requester is part of this organization", right?
      // If so, we don't have a way to say this in QDM, this would require the ability to
      // link a Practitioner to an Organization
      and ExamOrder.requester.id in (Encounter.participant as Organization)
      // So assuming we had an "organizationId" attribute on the Practitioner, we could say:
      and ExamOrder.requester.organizationId = (Encounter.participant as Organization).id

define "Eye Exam Complete":
  ["Intervention, Performed": "Diabetic Eye Exam"] EyeExam
    where EyeExam.performer is Practitioner
      // Same here
      and EyeExam.performer.id in Encounter.participant.organization
      // This would become
      and EyeExam.performer.organizationId = (Encounter.participant as Organization).id
      and EyeExam.performer.specialty in "Ophthalmology"


// The issue with making the attributes 0..* is that it would complicate the CQL.
// Specifically, instead of being able to say:

define "Qualifying Encounters":
  ["Encounter, Performed": "Inpatient"] Encounter
    where Encounter.participant is "Organization"

// I would have to say:

define "Qualifying Encounters":
  ["Encounter, Performed": "Inpatient"] Encounter
    where exists (Encounter.participant P where P is "Organization")

// And without knowing that we need it, it seems like we shouldn't introduce that level of complexity
