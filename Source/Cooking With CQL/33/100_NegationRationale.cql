library NegationRationale

/*
Two common patterns for negation used in quality measurement:

1. Absence of evidence for a particular event
2. Documentation of a reason for an event not occurring, together with a reason
*/

/*
Start with the basic pattern for "evidence for an event", specifically: 
Evidence that "Antithrombotic Therapy" (defined by a medication-specific value set) was administered:
*/

define "Antithrombotic Administered":
  ["Medication, Administered": "Antithrombotic Therapy"] 

/*
Then in CQL, for the "absence of evidence" pattern, specifically:
No evidence that "Antithrombotic Therapy"
*/

define "No Antithrombotic Administered":
   not exists (
    ["Medication, Administered": "Antithrombotic Therapy"]
) 

/*
Note carefully this is _not_ using the "Not Administered" data type:
*/

/*
And finally, for a full negation rationale:
Evidence that "Antithrombotic Therapy" medication administration did not occur 
for an acceptable medical reason as defined by a value set referenced by the 
eCQM (i.e. negation rationale):
*/

define "Antithrombotic Not Administered":
  ["Medication, Not Administered": "Antithrombotic Therapy"] NotAdministered
    where NotAdministered.negationRationale in "Medical Reason"

/*
Note about implementation:
When looking for negation rationale, it's almost always the case that the system will
document negation rationale by saying "I didn't do any of these things", rather than 
"I didn't do one of the specific items in this list". In this case, for example, the 
practitioner won't choose a specific antithrombotic medication they didn't administer,
they will simply say, "I didn't administer any antithrombotic and here's why"

In these cases, systems will not report a specific "code", but rather the physical  
representation of the QDM data element will specify the value set OID to indicate
that none of these things were done. In QRDA, this manifests as a "valueset" attribute
on the "code" element. One of the ballot questions on the CQL 1.4 ballot is specifically
about including a "valuesetPath" in the "Retrieve" representation to allow for this type
of behavior in the implementation, but without needing to surface that in the CQL.
*/
