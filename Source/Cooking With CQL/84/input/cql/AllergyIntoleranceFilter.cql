library AllergyIntoleranceFilter

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

context Patient

/*
Question:

[AllergyIntolerance] A
   where A.category in { 'medication', 'food' }

I've tried using A.category.value, and type casting to System.String, all to no avail.
*/

/*
Answer:

This is an interesting case, it's a multi-cardinality code-valued element with a required binding. 
Since it is required, it gets represented in client frameworks as a string value, rather than a terminology-valued element. 

As such, it's safe to use string comparison, but since it's multi-cardinality, it needs the exists pattern to test each element:
*/
define "Medication Or Food Allergy Or Intolerance":
  [AllergyIntolerance] A
    where exists (
      A.category C where C in { 'food', 'medication' }
    )
