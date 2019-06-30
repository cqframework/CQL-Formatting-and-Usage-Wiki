library PressureInjury

/*
This example comes from CMS826v0 - Hospital Harm - Pressure Injury
https://ecqi.healthit.gov/ecqm/measures/cms826v0

The current measure description is:

This measure assesses the proportion of inpatient encounters of patients 18 years
 of age or older at admission, who suffer the harm of developing a new stage 2, 
 stage 3, stage 4 pressure injury, deep tissue pressure injury, or unstageable 
 pressure injury. The measure defines a new pressure injury as not present on 
 arrival to the hospital or not documented within the first 24 hours after 
 hospital arrival. Only one harm (new qualifying pressure injury) is counted 
 per encounter.


This measure was written and tested prior to the availability of some key elements 
that are now available through QDM, so we want to enhance the specifications while 
retaining the intent. FYI: we may need to create a new VS to address anatomical 
location site if existing ones in VSAC are not appropriate for a pressure injury (TBD)
—note that current logic does not define this aspect and it is in header guidance only.

Needed for eCQM:

Numerator needs to capture 2 scenarios but rolled into a single count:

    PI stage 2+ or unstageable that was not documented as present on arrival (POA)
    PI stage 2+ or unstageable that was POA, but a new one (stage 2+ or unstageable) 
			is identified in a different anatomical location site and 24 hours after arrival

Thoughts:

    1. We probably should create a definition for "PI stage 2+ or unstageable" to 
		  simplify logic that needs to be added
		2. Using the Encounter Performed datatype and Diagnoses and POA components could work for aspects
    3. Anatomical location site is only available if Diagnosis datatype is used for QDM, 
		  but POA is only allowable for Encounter, Performed
		4. Would POA work? It appears that it might be required with admission orders (?), 
		  for the measure we want to know whether it was documented in 24hrs of arrival… 
			so perhaps not using the POA indicator?
		
Past QDM UG had the following modeling for using POA:

define "Encounter With Ischemic Stroke Diagnosis Present On Admission":
  ["Encounter, Performed": "Inpatient"] E
    where exists (E.diagnoses D where D.code in "Ischemic Stroke"
      and D.presentOnAdmissionIndicator ~ "Y")

It is not clear on whether the above would work or become more complicated since 
we need to add the aspect of anatomical location site
*/

/*
So the primary issue seems to be a need to relate a diagnosis that is indicated as present
on arrival with an active Diagnosis record, and be able to reliably ensure they are the
"same" diagnosis.
*/

