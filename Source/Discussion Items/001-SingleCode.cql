codesystem "SNOMED-CT": '2.16.840.1.113883.6.96' version '2016A'
// NOTE: The definition name here _MUST_ be the same as the display for the code or we are potentially in violation of legal agreements on the use of code system IP.
code "Breastfeeding intention": '123456789' system "SNOMED-CT" display 'Breastfeeding intention'

define "Breastfeeding Intention":
  ["Risk Assessment, Performed": "Breastfeeding intention"] RiskAssessment
    where RiskAssessment.negationRationale is null

// The HQMF would need the OID
// This is what the QDM Data Element would look like in the HTML
"Risk Assessment, Performed: Breastfeeding intention" using "Breastfeeding intention SNOMED-CT version 2016A Code (123456789)"
