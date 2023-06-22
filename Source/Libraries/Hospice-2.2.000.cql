library Hospice version '2.2.000'

/*
Update to 5.6 to get class attribute
*/
using QDM version '5.6'

/*
Include global common for encounter classes
*/
include MATGlobalCommonFunctions version '6.2.000' called Global

codesystem "SNOMEDCT": 'urn:oid:2.16.840.1.113883.6.96'

valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Hospice care ambulatory": 'urn:oid:2.16.840.1.113762.1.4.1108.15'

code "Discharge to healthcare facility for hospice care (procedure)": '428371000124100' from "SNOMEDCT" display 'Discharge to healthcare facility for hospice care (procedure)'
code "Discharge to home for hospice care (procedure)": '428361000124107' from "SNOMEDCT" display 'Discharge to home for hospice care (procedure)'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Has Hospice":
  exists ( ["Encounter, Performed": "Encounter Inpatient"] DischargeHospice
      where ( DischargeHospice.dischargeDisposition ~ "Discharge to home for hospice care (procedure)"
          or DischargeHospice.dischargeDisposition ~ "Discharge to healthcare facility for hospice care (procedure)"
      )
        and DischargeHospice.relevantPeriod ends during "Measurement Period"
  )
    or exists ( ["Intervention, Order": "Hospice care ambulatory"] HospiceOrder
        where HospiceOrder.authorDatetime during "Measurement Period"
    )
    or exists ( ["Intervention, Performed": "Hospice care ambulatory"] HospicePerformed
        where HospicePerformed.relevantPeriod overlaps "Measurement Period"
    )

define "Has Hospice (1)":
  exists ( ["Encounter, Performed": class in Global."Inpatient Encounter Class"] DischargeHospice
      where ( DischargeHospice.dischargeDisposition ~ "Discharge to home for hospice care (procedure)"
          or DischargeHospice.dischargeDisposition ~ "Discharge to healthcare facility for hospice care (procedure)"
      )
        and DischargeHospice.relevantPeriod ends during "Measurement Period"
  )
    or exists ( ["Intervention, Order": "Hospice care ambulatory"] HospiceOrder
        where HospiceOrder.authorDatetime during "Measurement Period"
    )
    or exists ( ["Intervention, Performed": "Hospice care ambulatory"] HospicePerformed
        where HospicePerformed.relevantPeriod overlaps "Measurement Period"
    )
