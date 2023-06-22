library EXM9_BPS version '4.0.1'

codesystem "SNOMED-CT": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:March%202016'
codesystem "LOINC": 'http://loinc.org'

valueset "Feeding Intention-Breast": 'urn:oid:2.16.840.1.113762.1.4.1045.29' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }
valueset "Galactosemia": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.35' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }
valueset "Single Live Birth": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.25)' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }
valueset "Single Live Born Newborn Born in Hospital": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.26' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }
valueset "Estimated Gestational Age at Birth": 'urn:oid:2.16.840.1.113762.1.4.1045.47' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }
valueset "Parenteral Nutrition": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.38' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }
valueset "Breast Milk": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.30' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }
valueset "Dietary Intake Other than Breast Milk": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.27' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }
valueset "Neonatal Intensive Care Unit (NICU)": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.75' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }
valueset "Patient Expired": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.309' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }
valueset "Discharge To Acute Care Facility": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.87' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }

valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1' version 'urn:hl7:version:2016-04-01' codesystems { "SNOMED-CT" }

code "Normative No": '123456789' from "SNOMED-CT" display 'No'
