library Test111 version '0.0.011'

using QDM version '5.0.2'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1' 

valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836' 

valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837' 

valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591' 

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292' 

valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307' 

valueset "Hospital Settings": 'urn:oid:2.16.840.1.113762.1.4.1111.126' 

valueset "Decision to Admit to Hospital Inpatient": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.295' 

valueset "Psychiatric/Mental Health Patient": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.299' 

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity": ["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer": ["Patient Characteristic Payer": "Payer"]

define "SDE Race": ["Patient Characteristic Race": "Race"]

define "SDE Sex": ["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Inpatient Encounter": ["Encounter, Performed": "Encounter Inpatient"]Encounter
    where Encounter.lengthOfStay <=120 days
      and Encounter.relevantPeriod ends during "Measurement Period"

define "ED Visit": ["Encounter, Performed": "Emergency Department Visit"] ED
with ["Encounter, Order": "Decision to Admit to Hospital Inpatient"] Order
such that Order.authorDatetime during ED.relevantPeriod

define "Initial Population": "Inpatient Encounter" Encounter
with "ED Visit" ED
such that ED.relevantPeriod ends 1 hour or less before start of Encounter.relevantPeriod

define "Measure Population": "Initial Population"

define "Measure Population Exclusions": "Inpatient Encounter" Encounter
with "ED Visit" ED
such that ED.relevantPeriod ends 1 hour or less before start of Encounter.relevantPeriod
and ED.admissionSource in "Hospital Settings"

define "Stratum1": "Inpatient Encounter" Encounter
    where not (Encounter.principalDiagnosis in "Psychiatric/Mental Health Patient")

define "Stratum2": "Inpatient Encounter" Encounter
    where Encounter.principalDiagnosis in "Psychiatric/Mental Health Patient"

define function "Admit Decision"("Encounter" "Encounter, Performed" ): Last(
 ["Encounter, Order": "Decision to Admit to Hospital Inpatient"] O
      where O.authorDatetime during "Related ED Visit"(Encounter).relevantPeriod
      sort by authorDatetime
  )

// QUESTION: Doesn't the use of Last in the "Admit Decision" and "Related ED Visit"
// functions used in the "Measure Observation" section mean that only one observation
// will be reported for a patient, not one observation per encounter as intended in the measure?

// ANSWER: No, because the "Measure Observation" function is called for each
// member of the "Measure Population", which in this case is inpatient encounters
// with an immediately prior emergency department visit. The use of "Last"
// within these functions will return the most recent encounter related to the
// encounter in the measure population.
define function "Measure Observation"("Encounter" "Encounter, Performed" ): 
  minutes between "Admit Decision"(Encounter).authorDatetime 
    and end of "Related ED Visit"(Encounter).locationPeriod

define function "Related ED Visit"("Encounter" "Encounter, Performed" ): Last(
    ["Encounter, Performed": "Emergency Department Visit"] ED
      where ED.relevantPeriod ends 1 hour or less before start of Encounter.relevantPeriod
      sort by start of relevantPeriod
  )

