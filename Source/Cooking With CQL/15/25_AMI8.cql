/*
Comments throughout, numbered in the order they should be considered.
*/

library PrimaryPCIReceivedWithin90MinutesofHospitalArrival version '0.0.000'

using QDM version '5.0.2'

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'

codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1' 

valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836' 

valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837' 

valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591' 

valueset "Cardiopulmonary arrest": 'urn:oid:2.16.840.1.113883.3.666.5.748' 

valueset "Electrocardiogram (ECG)": 'urn:oid:2.16.840.1.113883.3.666.5.735' 

valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292' 

valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307' 

valueset "Fibrinolytic Therapy": 'urn:oid:2.16.840.1.113883.3.666.5.736' 

valueset "Aortic balloon pump insertion": 'urn:oid:2.16.840.1.113883.3.666.5.1151' 

valueset "Endotracheal Intubation": 'urn:oid:2.16.840.1.113762.1.4.1045.69' 

valueset "PCI": 'urn:oid:2.16.840.1.113762.1.4.1045.67' 

valueset "Ventricular Assist Device placement": 'urn:oid:2.16.840.1.113883.3.666.5.3015' 

valueset "Ambulatory surgical center": 'urn:oid:2.16.840.1.113883.3.666.5.687' 

valueset "Transfer From Emergency Department (ED) Locations": 'urn:oid:2.16.840.1.113883.3.666.5.3006' 

valueset "Transfer From Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.3013' 

valueset "Transfer From Outpatient": 'urn:oid:2.16.840.1.113883.3.67.1.101.950' 

valueset "STEMI Exclusions": 'urn:oid:2.16.840.1.113762.1.4.1045.36' 

valueset "Acute Myocardial Infarction (AMI)": 'urn:oid:2.16.840.1.113883.3.666.5.3011' 

valueset "Acute or Evolving MI": 'urn:oid:2.16.840.1.113883.3.666.5.3022' 

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'

code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity": ["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer": ["Patient Characteristic Payer": "Payer"]

define "SDE Race": ["Patient Characteristic Race": "Race"]

define "SDE Sex": ["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Emergency Department Encounter": ["Encounter, Performed": "Emergency Department Visit"] Emergency
    with "Inpatient Encounters" Inpatient
    such that Emergency.relevantPeriod ends 1 hours or less before start of Inpatient.relevantPeriod

define "No Emergency Department Encounter": not exists (
  ["Encounter, Not Performed": "Emergency Department Visit"] NoED
    with "Inpatient Encounters" Encounter
     such that NoED.relevantPeriod ends 1 hours or less before Encounter.relevantPeriod)

/*
NOTE: 6. The denominator exclusion here is just that we aren't coming from another hospital health care facility,
and we can use the same Hospitalization function to relate it to the inpatient encounters (rather than restating
the Emergency Department visit condition)
define "Denominator Exclusions": from "Another Hospital Health Care Facility" Encounter,
 "Inpatient Encounters" Inpatient,
 "Emergency Department Encounter" Emergency
    where 
    ((Encounter.relevantPeriod starts 1 day or less before start of Emergency.relevantPeriod)
    and (Encounter.relevantPeriod starts 1 day or less before start of Inpatient.relevantPeriod))
    or
    (Encounter.relevantPeriod starts 1 day or less before start of Inpatient.relevantPeriod and Emergency is null)
*/

define "Denominator Exclusions":
  "Inpatient Encounters" Encounter
    with "Another Hospital Health Care Facility" External
      such that External.relevantPeriod starts 1 day or less before start of Hospitalization(Encounter)

define "Fibrinolytic": ["Medication, Administered": "Fibrinolytic Therapy"] Fibrinolytic

/*
NOTE: 3. The reference to "Initial Population" here is the primary source for a new query, so it needs an alias,
and it needs to be Encounter because all the references to the Hospitalization function are expecting something
named Encounter.
*/

/*
NOTE: 4. The restriction criteria here doesn't reference ECG, so it's not clear why it's included at all.
If the change to the measure no longer references the ECG to determine STEMI exclusion, what is the new criteria
for the ECG, just that there has to be one?
*/
define "Denominator": 
  "Initial Population"
let
  ECG: Coalesce(
   Last("Electrocardiogram Diagnostic" ECG
    where ECG.relevantPeriod starts 1 hour or less before "Hospitalization"(Encounter)
sort by start of ECG.relevantPeriod
),
   First("Electrocardiogram Diagnostic" ECG
        where ECG.relevantPeriod starts during Hospitalization(Encounter)
    sort by start of ECG.relevantPeriod
)
),
  PCI: First("PCI Procedure" PCI
    where PCI.relevantPeriod starts after start of Hospitalization(Encounter)
    sort by start of PCI.relevantPeriod
    ),
  FT: First("Fibrinolytic Therapy" FT
    where FT.relevantPeriod starts after start of Hospitalization(Encounter)
    sort by start of FT.relevantPeriod
    )
where PCI.relevantPeriod starts 1440 minutes or less after Hospitalization(Encounter)
  and not (PCI.relevantPeriod starts after start of FT.relevantPeriod)

/*
NOTE: 5. The query here uses the alias name Inpatient, but the reference to Hospitalization is using Encounter,
so we just need to change Inpatient to Encounter as the alias.
*/
define "Numerator": "Inpatient Encounters" Inpatient
  with "PCI Procedure" PCI
    such that PCI.relevantPeriod starts 90 minutes or less after start of "Hospitalization"(Encounter)

/*
NOTE: 12. Episode-of-care measure
define "Denominator Exceptions": exists ("Exceptions ED")
 or exists ("Exceptions IP")
*/

define "Denominator Exceptions":
  distinct (
    "Procedure Exceptions"
      union "Diagnosis Exception"
  )

/*
NOTE: 8. The use of distinct here is setting up for a union, but then the query uses "or"s to connect
the other encounters. Instead of "or exists" use "union" to connect these queries

NOTE: 9. If we're looking for admissionSource, shouldn't these just be expressed as conditions on the inpatient encounter?
define "Another Hospital Health Care Facility": 
distinct (["Encounter, Performed": "Ambulatory surgical center"] ASC
where ASC.admissionSource in "Ambulatory surgical center"

or exists ["Encounter, Performed": "Transfer From Outpatient"] Outpatient
where Outpatient.admissionSource in "Transfer From Outpatient"

or exists ["Encounter, Performed": "Transfer From Emergency Department (ED) Locations"] ED
 where ED.admissionSource in "Transfer From Emergency Department (ED) Locations"
 
 or exists  ["Encounter, Performed": "Transfer From Inpatient"] Inpatient
 where Inpatient.admissionSource in "Transfer From Inpatient")
 */
 
define "Another Hospital Health Care Facility":
  "Inpatient Encounters" Encounter
    where Encounter.admissionSource in "Ambulatory surgical center"
      or Encounter.admissionSource in "Transfer From Outpatient"
      or Encounter.admissionSource in "Transfer From Emegency Department (ED) Locations"
      or Encounter.admissionSource in "Transfer From Inpatient"

/*
NOTE: 10. Because this is an episode-of-care measure, we need to define the exceptions in terms of
the encounters being considered for the case
define "Procedure Exceptions": distinct (
  ( ["Procedure, Performed": "Endotracheal Intubation"]
union ["Procedure, Performed": "Aortic balloon pump insertion"]
union ["Procedure, Performed": "Ventricular Assist Device placement"]))Procedure
where Procedure.relevantPeriod starts 90 minutes or less after start of "Hospitalization"(Encounter)
*/

define "Exception Procedures":
  distinct (
    ["Procedure, Performed": "Endotracheal Intubation"]
      union ["Procedure, Performed": "Aortic balloon pump insertion"]
      union ["Procedure, Performed": "Ventricular Assist Device placement"]
  )

define "Procedure Exceptions":
  "Inpatient Encounters" Encounter
    with "Exception Procedures" Procedure
      such that Procedure.relevantPeriod starts 90 minutes or less after start of Hospitalization(Encounter)

/*
NOTE: 11. Episode-of-care measure, so the encounter is the focus
define "Diagnosis Exception": 
["Diagnosis": "Cardiopulmonary arrest"] Arrest
  with "Inpatient Encounters" Encounter
    such that Arrest.prevalencePeriod starts 90 minutes or less after start of "Hospitalization"(Encounter)
*/
define "Diagnosis Exception":
  "Inpatient Encounters" Encounter
    with ["Diagnosis": "Cardiopulmonary arrest"] Arrest
      such that Arrest.prevalencePeriod starts 90 minutes or less after start of Hospitalization(Encounter)

/*
NOTE: 9. We don't need the distinction between ED and IP here because we're using the Hospitalization function
to relate the exception criteria to the encounter case
define "Exceptions ED": exists ("Procedure Exceptions") Procedure
 or exists ("Diagnosis Exception") Diagnosis

define "Exceptions IP": exists ("Procedure Exceptions") Procedure
or exists ("Diagnosis Exception") Diagnosis
  and exists ("No Emergency Department Encounter")
*/

define "AMI Encounter": ["Encounter, Performed": "Encounter Inpatient"] Encounter
    where AgeInYearsAt(start of Encounter.relevantPeriod) >= 18
      and Encounter.principalDiagnosis in "Acute or Evolving MI"

define "Electrocardiogram Diagnostic": ["Diagnostic Study, Performed": "Electrocardiogram (ECG)"] Diagnostic

define "PCI Procedure": ["Procedure, Performed": "PCI"] Procedure

define "Inpatient Encounters": ["Encounter, Performed": "Encounter Inpatient"] Encounter
    where Encounter.lengthOfStay <= 120 days
      		and Encounter.relevantPeriod ends during "Measurement Period"

/*
NOTE: 1. Starting here with the initial population, this is an episode-of-care measure, so all the criteria
need to return lists of encounters, right? More specifically, they need to return the inpatient encounter
under consideration for the case.
*/
//define "Initial Population": exists "AMI Encounter"
// and exists "Inpatient Encounters"
define "Initial Population":
  "Inpatient Encounters"
    intersect "AMI Encounter"
    
/*
NOTE: 2. An AMI Encounter is an Inpatient Encounter with a principal diagnosis of Acute or Evolving MI,
so why not define AMI Encounter in those terms?
define "AMI Encounter":
  "Inpatient Encounters" Encounter
    where AgeInYearsAt(start of Encounter.relevantPeriod) >= 18
      and Encounter.principalDiagnosis in "Acute or Evolving MI"
      
Then the Initial Population is just "AMI Encounter", right?
define "Initial Population":
  "AMI Encounter"
*/

define function "Hospitalization"("Encounter" "Encounter, Performed" ): (
singleton from (
    ["Encounter, Performed": "Emergency Department Visit"] EDVisit
      where EDVisit.relevantPeriod ends 1 hour or less before start of Encounter.relevantPeriod
  )
  ) X
    return if X is null then Encounter.relevantPeriod
      else Interval[start of X.relevantPeriod, end of Encounter.relevantPeriod]
