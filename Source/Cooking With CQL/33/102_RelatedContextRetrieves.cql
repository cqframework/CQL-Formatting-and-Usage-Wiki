library RelatedContextRetrieves

using QDM version '5.5' // coming soon...

context Patient

/*
One of the questions on the CQL 1.4 Ballot has to do with Related Context Retrieves.
Consider the example of a "mother-infant" measure that requires data from both a mother
and the infant. If we think about the measure as written from the infants perspective,
then we need some way to be able to access the data from the mother's record.

The following proposal in the ballot provides a possible way to do this.

Note that since this is a ballot question, it's very possible that the end result may 
be different than this. We're reviewing it here to encourage you to provide feedback
on the proposal from both the authoring and the implementation perspectives.
*/

code "Mother Relationship": 'Mother' from "SNOMED"

/*
From the perspective of the infant, the "Mother" is a "Related Person" (new entity in QDM 5.5)
So we can define a "Mother" expression that lets us talk about who the mother is:
*/
define "Mother": singleton from (["Related Person": "Mother Relationship"])

// Would need more guidance on what codes to use, so QDM and FHIR profiles would 
// need to help in identifying what the terminologies are

/*
However, data coming back from a Retrieve in CQL is always limited to the current 
context, which is the infant's record. So even though we know who the mother is,
we still can't get to the data from her record. So what we need now is a way to say 
"Retrieve data from the Mother's record", rather than the current patient.

Note the use of the "Mother" -> syntax in the retrieve below:
*/

/*
How can we guarantee this exam is related to the encounter we're interested in?
*/
define "Estimated Due Date":
  Last(
    ["Mother" -> "Physical Exam, Performed": "Estimated Due Date"] Exam
      where Exam.relevantPeriod ends one year on or before Birth
      sort by start of relevantPeriod
  ).result as DateTime
  
/*
This would allow us to use the "Mother" expression as the "context" for just this retrieve.
So the above definition is saying "Return the most recent physical exam performed for estimated
due date from the mother's record"
*/

/*
We would then be able to use that retrieve, containing the mother's most recent estimated due date result to
perform a calculation in the infant measure, in this case, gestational age at birth:
*/

define "Gestational Age in Days at Birth":
  (280 - (duration in days between "Estimated Due Date" and "Birth Date")) div 7
  
