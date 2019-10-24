library Hospice version '1.0.000'

using QDM version '5.3'

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'
codesystem "SNOMEDCT:2017-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2017-03'
codesystem "SNOMEDCT:2017-09": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2017-09'

valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Hospice care ambulatory": 'urn:oid:2.16.840.1.113762.1.4.1108.15'

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'
code "Discharge to healthcare facility for hospice care (procedure)": '428371000124100' from "SNOMEDCT:2017-09" display 'Discharge to healthcare facility for hospice care (procedure)'
code "Discharge to home for hospice care (procedure)": '428361000124107' from "SNOMEDCT:2017-09" display 'Discharge to home for hospice care (procedure)'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Has Hospice":
	exists ( ["Encounter, Performed": "Encounter Inpatient"] DischargeHospice
			where ( DischargeHospice.dischargeDisposition as Code ~ "Discharge to home for hospice care (procedure)"
					or DischargeHospice.dischargeDisposition as Code ~ "Discharge to healthcare facility for hospice care (procedure)"
			)
				and DischargeHospice.relevantPeriod ends during "Measurement Period"
	)
		or exists ( ["Intervention, Order": "Hospice care ambulatory"] HospiceOrder
				where HospiceOrder.authorDatetime during "Measurement Period"
		)
		or exists ( ["Intervention, Performed": "Hospice care ambulatory"] HospicePerformed
				where HospicePerformed.relevantPeriod overlaps "Measurement Period"
		)
