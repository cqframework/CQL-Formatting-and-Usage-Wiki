library PrenatalImmunizationStatus version '0.0.000'

/*
This example is taken from the NCQA Prenatal Immunization Status measure
It illustrates calculation of gestational age from assessments and diagnoses,
as well as the use of a function to calculate conception date
*/

using QDM version '5.3'

codesystem "SNOMEDCT": 'urn:oid:2.16.840.1.113883.6.96'

valueset "Deliveries": 'urn:oid:2.16.840.1.113883.3.464.1004.1072'
valueset "Adult Influenza Vaccine": 'urn:oid:2.16.840.1.113883.3.464.1004.1475'
valueset "37 Gestational Weeks": 'urn:oid:2.16.840.1.113883.3.464.1003.1880'
valueset "38 Gestational Weeks": 'urn:oid:2.16.840.1.113883.3.464.1003.1881'
valueset "39 Gestational Weeks": 'urn:oid:2.16.840.1.113883.3.464.1003.1882'
valueset "40 Gestational Weeks": 'urn:oid:2.16.840.1.113883.3.464.1003.1883'
valueset "41 Gestational Weeks": 'urn:oid:2.16.840.1.113883.3.464.1003.1884'
valueset "42 Gestational Weeks": 'urn:oid:2.16.840.1.113883.3.464.1003.1885'
valueset "43 Gestational Weeks": 'urn:oid:2.16.840.1.113883.3.464.1003.1886'

code "Length of gestation at birth (observable entity)": '412726003' from "SNOMEDCT" display 'Length of gestation at birth (observable entity)'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Delivery":
	["Procedure, Performed": "Deliveries"] DeliveryProcedure
		where DeliveryProcedure.relevantPeriod ends during "Measurement Period"

define "Gestational Age Assessment":
	["Assessment, Performed": "Length of gestation at birth (observable entity)"]

define "Gestational Age Diagnosis":
	(["Diagnosis": "37 Gestational Weeks"] D
	    return { id: D.id, code: D.code, authorDatetime: end of D.prevalencePeriod, result: 37 weeks }
  )
	   union
	   (["Diagnosis": "38 Gestational Weeks"] D
	       return { id: D.id, code: D.code, authorDatetime: end of D.prevalencePeriod, result: 38 weeks }
	   )
	   union
	   (["Diagnosis": "39 Gestational Weeks"] D
	       return { id: D.id, code: D.code, authorDatetime: end of D.prevalencePeriod, result: 39 weeks }
	   )
	   union
	   (["Diagnosis": "40 Gestational Weeks"] D
	       return { id: D.id, code: D.code, authorDatetime: end of D.prevalencePeriod, result: 40 weeks }
	   )
	   union
	   (["Diagnosis": "41 Gestational Weeks"] D
	       return { id: D.id, code: D.code, authorDatetime: end of D.prevalencePeriod, result: 41 weeks }
	   )
	   union
	   (["Diagnosis": "42 Gestational Weeks"] D
	       return { id: D.id, code: D.code, authorDatetime: end of D.prevalencePeriod, result: 42 weeks }
	   )
	   union
	   (["Diagnosis": "43 Gestational Weeks"] D
	       return { id: D.id, code: D.code, authorDatetime: end of D.prevalencePeriod, result: 43 weeks }
	   )

define "All Gestational Age Assessment":
	"Gestational Age Assessment"
	    union "Gestational Age Diagnosis"

define function "Conception Date"(Delivery "Procedure, Performed", GestationalAge "Assessment, Performed" ):
	end of Delivery.relevantPeriod - GestationalAge.result

// NOTE: This definition is simplified as the details are irrelevant to the example
define "Influenza Immunization Administered":
	["Immunization, Administered": "Adult Influenza Vaccine"]

define "Immunization Post Conception":
	"Delivery" DeliveryProcedure
	  with "Influenza Immunization Administered" I 
      such that I.authorDatetime after 
        "Conception Date"(
          DeliveryProcedure,
  	      Last("All Gestational Age Assessment" GestationalAge
            where GestationalAge.authorDatetime within 24 hours of end of DeliveryProcedure.relevantPeriod 
            sort by authorDatetime
        )
	    )

