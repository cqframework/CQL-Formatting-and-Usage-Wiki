library MedianTimefromEDArrivaltoEDDepartureforDischargedEDPatients version '7.2.004'

 

using QDM version '5.3'

 

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'

codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

codesystem "SNOMEDCT:2017-09": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2017-09'

codesystem "SNOMEDCT:2013-09": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2013-09'

 

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'

valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'

valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'

valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'

valueset "Discharge To Acute Care Facility": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.87'

valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'

valueset "Patient Expired": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.309'

valueset "Psychiatric/Mental Health Diagnosis": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.299'

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'

valueset "Observation Services": 'urn:oid:2.16.840.1.113762.1.4.1111.143'

 

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'

code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'

code "Patient deceased during stay (discharge status = dead) (finding)": '371828006' from "SNOMEDCT:2013-09" display 'Patient deceased during stay (discharge status = dead) (finding)'

 

parameter "Measurement Period" Interval<DateTime>

 

context Patient

 

define "SDE Ethnicity":

                ["Patient Characteristic Ethnicity": "Ethnicity"]

 

define "SDE Payer":

                ["Patient Characteristic Payer": "Payer"]

 

define "SDE Race":

                ["Patient Characteristic Race": "Race"]

 

define "SDE Sex":

                ["Patient Characteristic Sex": "ONC Administrative Sex"]

 

define "Emergency Department (ED) Visit":

                /*Emergency Department visit during the measurement period*/

                ["Encounter, Performed": "Emergency Department Visit"] EDVisit

                                where EDVisit.relevantPeriod during "Measurement Period"

 

define "Initial Population":

                "Emergency Department (ED) Visit"

 

define "Measure Population Exclusions":

                /*ED visits where patient expired or the patient was admitted inpatient within an hour of the ED visit*/

                ( "Emergency Department (ED) Visit" EDVisit

                                                where EDVisit.dischargeDisposition ~ "Patient deceased during stay (discharge status = dead) (finding)"

                )

                                union ( "Emergency Department (ED) Visit" EDVisit

                                                                with ["Encounter, Performed": "Encounter Inpatient"] Encounter

                                                                                such that EDVisit.relevantPeriod ends 1 hour or less before or on start of Encounter.relevantPeriod

                                )

 

define "Stratification 2":

                /*Patients who are discharged to an acute care facility as detailed in the value set*/

                "Emergency Department (ED) Visit" EDVisit

                                where EDVisit.dischargeDisposition in "Discharge To Acute Care Facility"

 

define "Stratification 1":

                /*Patients with a principal diagnosis that is in the "Psychiatric/Mental Health Diagnosis" value set*/

                "Emergency Department (ED) Visit" EDVisit

                                where EDVisit.principalDiagnosis in "Psychiatric/Mental Health Diagnosis"

 

define "Stratification 3":

                /*Patients without a principal diagnosis in the "Psychiatric/Mental Health Diagnosis" value set* and who are not discharged to an "Acute Care Facility as detailed in the value set*/

                "Emergency Department (ED) Visit" EDVisit

                                where not ( EDVisit.principalDiagnosis in "Psychiatric/Mental Health Diagnosis" )

                                                and not ( EDVisit.dischargeDisposition in "Discharge To Acute Care Facility" )

 

define "Measure Population":

                "Emergency Department (ED) Visit"

 

define function "Arrival And Departure Time"(Encounter "Encounter, Performed" ):

                /*Evaluates the interval from the first ED encounter time (arrival) to the last ED encounter time (departure)*/

                Interval[First(Encounter.facilityLocations Location

                                                return start of Location.locationPeriod

                                                sort ascending

                ), Last(Encounter.facilityLocations Location

                                                return end of Location.locationPeriod

                                                sort ascending

                )]

 

define function "Measure Observation"(Encounter "Encounter, Performed" ):

                /*Time from ED visit arrival to ED departure for patients not admitted to inpatient*/

                duration in minutes of "Arrival And Departure Time"(Encounter)

 

define function "Arrival Time"(Encounter "Encounter, Performed" ):

                First(Encounter.facilityLocations Location

                                                return start of Location.locationPeriod

                                                sort ascending

                )

 

define function "Observation Services Order"(Encounter "Encounter, Performed" ):

                /*Order to place patient in observation services*/

                Last(["Encounter, Order": "Observation Services"] ObservationOrder

                                                where ObservationOrder.authorDatetime during Encounter.relevantPeriod

                                                sort by authorDatetime

                )

 

define function "Departure Time"(Encounter "Encounter, Performed" ):

                Last(Encounter.facilityLocations Location

                return end of Location.locationPeriod

                sort ascending

 

define function "Arrival to Observation Order or Departure Time"(Encounter "Encounter, Performed" ):

                duration in minutes of Interval ["Arrival Time"(Encounter), Coalesce("Observation Services Order"(Encounter).authorDatetime, "Departure Time"(Encounter))]

 