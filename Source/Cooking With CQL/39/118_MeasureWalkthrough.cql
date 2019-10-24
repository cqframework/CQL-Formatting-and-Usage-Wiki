/*
Measure walkthrough of CMS130 in QDM
This example serves as a basic introduction to the elements of CQL as used in specifying eCQMs
See the supporting files in ColorectalCancerScreening-7.2.000.cql
For FHIR, see the supporting file in EXM130_FHIR3-7.2.000.cql
*/

/*
The following are excerpts showing side-by-side QDM to FHIR for this measure
*/

// Value Sets:

// QDM
valueset "Colonoscopy": 'urn:oid:2.16.840.1.113883.3.464.1003.108.12.1020'

// FHIR
valueset "Colonoscopy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1020'

// Flexible Sigmoidoscopy Performed

// QDM

define "Flexible Sigmoidoscopy Performed":
	["Procedure, Performed": "Flexible Sigmoidoscopy"] FlexibleSigmoidoscopy
		where FlexibleSigmoidoscopy.relevantPeriod ends 5 years or less on or before end of "Measurement Period"

// FHIR
define "Flexible Sigmoidoscopy Performed":
	[Procedure: "Flexible Sigmoidoscopy"] FlexibleSigmoidoscopy
		where FlexibleSigmoidoscopy.status = 'completed'
			and FlexibleSigmoidoscopy.performed ends 5 years or less on or before end of "Measurement Period"



