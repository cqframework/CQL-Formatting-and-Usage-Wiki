/*
Diagnostic Imaging Study, Ultrasound, MRI, or CT, with a result of >50% diameter reduction in peripheral artery

  Assuming the existence of a value set that specifies the method and body site (peripheral arteries)

  Pseudo-QDM:
  "Diagnostic Study, Performed: US of peripheral arteries (Assessment: % diameter reduction (result < 50%)"
*/

codesystem "SNOMED-CT": 'urn:oid:2.16.840.1.113883.6.96'

valueset "Ultrasound of peripheral arteries": 'urn:oid:1.2.3.4.5'

code "% diameter reduction": '397442008' from "SNOMED-CT"

define "Study Indicating Stenosis":
  ["Diagnostic Study, Performed": "Ultrasound"] Study
    where exists (
      Study.components component
        where component.code = "% diameter reduction"
          and component.bodySite in "Peripheral Artery BodySite Value Set"
          and component.result > 50 '%'
    )
