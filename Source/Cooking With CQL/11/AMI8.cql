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

define "Inpatient Encounters": ["Encounter, Performed": "Encounter Inpatient"] Encounter
    where Encounter.lengthOfStay <= 120 days
      		and Encounter.relevantPeriod ends during "Measurement Period"

define "Emergency Department Encounter": ["Encounter, Performed": "Emergency Department Visit"] Emergency
    with "Inpatient Encounters" Inpatient
    such that Emergency.relevantPeriod ends 1 hours or less before start of Inpatient.relevantPeriod

define "No Emergency Department Encounter": 
  not exists (
    ["Encounter, Not Performed": "Emergency Department Visit"] NoED
      with "Inpatient Encounters" Encounter
        such that NoED.relevantPeriod ends 1 hours or less before Encounter.relevantPeriod
  )

define "Encounter Principal Diagnosis of AMI": ["Encounter, Performed": "Encounter Inpatient"] Encounter
where Encounter.principalDiagnosis in "Acute Myocardial Infarction (AMI)"

define "Enc Dx Intersect": "Inpatient Encounters" intersect
"Encounter Principal Diagnosis of AMI"

define "Denominator Exclusions": from "Another Hospital Health Care Facility" Encounter,
 "Inpatient Encounters" Inpatient,
 "Emergency Department Encounter" Emergency
    where 
    ((Encounter.relevantPeriod starts 1 day or less before start of Emergency.relevantPeriod)
    and (Encounter.relevantPeriod starts 1 day or less before start of Inpatient.relevantPeriod))
    or
    (Encounter.relevantPeriod starts 1 day or less before start of Inpatient.relevantPeriod and Emergency is null)

define "Fibrinolytic": ["Medication, Administered": "Fibrinolytic Therapy"] Fibrinolytic

define "Denominator": "AMI Encounter"Encounter
let
  ECG: Coalesce(
   Last("Electrocardiogram Diagnostic" ECG
where ECG.relevantPeriod starts 1 hour or less before Hospitalization(Encounter)
sort by start of ECG.relevantPeriod),

First("Electrocardiogram Diagnostic" ECG
 where ECG.relevantPeriod starts during Hospitalization(Encounter)
sort by start of ECG.relevantPeriod)),

  PCI: First("PCI Procedure" PCI
where PCI.relevantPeriod starts after start of Hospitalization(Encounter)
sort by start of PCI.relevantPeriod),

  FT: First("Fibrinolytic Therapy" FT
where FT.relevantPeriod starts after start of Hospitalization(Encounter)
sort by start of FT.relevantPeriod)

define "Percutaneous Coronary": ["Procedure, Performed": "PCI"] PCI
with "Inpatient Encounters" IP
such that PCI.relevantPeriod starts 90 minutes or less after start of IP.relevantPeriod

define "Numerator": "PCI and not ED" union
"PCI ED IP"

define "Denominator Exceptions": exists ("Procedure Excep ED")
 or exists ("Procedure Except IP")

define "Another Hospital Health Care Facility": distinct (["Encounter, Performed": "Ambulatory surgical center"] ASC
where ASC.admissionSource in "Ambulatory surgical center"

or exists ["Encounter, Performed": "Transfer From Outpatient"] Outpatient
where Outpatient.admissionSource in "Transfer From Outpatient"

or exists ["Encounter, Performed": "Transfer From Emergency Department (ED) Locations"] ED
 where ED.admissionSource in "Transfer From Emergency Department (ED) Locations"
 
 or exists  ["Encounter, Performed": "Transfer From Inpatient"] Inpatient
 where Inpatient.admissionSource in "Transfer From Inpatient")

define "Age At Encounter": ["Encounter, Performed": "Encounter Inpatient"] Encounter
     where AgeInYearsAt(start of Encounter.relevantPeriod) >= 18

define "Most Recent ECG": {Last (["Diagnostic Study, Performed": "Electrocardiogram (ECG)"] RecentECG
with "Emergency Department Encounter" ED
such that RecentECG.relevantPeriod starts 1 hour or less before start of ED.relevantPeriod
sort by start of RecentECG.relevantPeriod)}

define "First ECG ED": {First (["Diagnostic Study, Performed": "Electrocardiogram (ECG)"] FirstECG
with "Emergency Department Encounter" ED
such that FirstECG.relevantPeriod starts 1 hour or less before start of ED.relevantPeriod
sort by start of FirstECG.relevantPeriod)}

define "First ECG Inpatient": {First (["Diagnostic Study, Performed": "Electrocardiogram (ECG)"] FirstECG
with "Inpatient Encounters" IP
such that FirstECG.relevantPeriod starts 1 hour or less before start of IP.relevantPeriod
sort by start of FirstECG.relevantPeriod)}

define "PCI Inpatient": First (["Procedure, Performed": "PCI"] PCI
with  "Emergency Department Encounter" Encounter 
such that PCI.incisionDatetime 1440 minutes or less after start of  Encounter.relevantPeriod
    sort by start of PCI.relevantPeriod)

define "PCI ED": First (["Procedure, Performed": "PCI"] PCI
with  "Emergency Department Encounter" Encounter 
    such that PCI.incisionDatetime  1440 minutes or less after start of Encounter.relevantPeriod
  sort by start of PCI.relevantPeriod)

define "Initial Population": "AMI Encounter"

define "Procedure Exceptions": distinct (
  ( ["Procedure, Performed": "Endotracheal Intubation"]
union ["Procedure, Performed": "Aortic balloon pump insertion"]
union ["Procedure, Performed": "Ventricular Assist Device placement"]))

define "ED & unions": exists ("Emergency Department Encounter") and exists ("Most Recent ECG") and exists ("First ECG ED"))

define "Not ED & unions": 
  "No Emergency Department Encounter"  
    and exists ("Most Recent ECG") or exists ("First ECG Inpatient")

define "ECG Acute result": ["Diagnostic Study, Performed": "Electrocardiogram (ECG)"] ECG
where (ECG.result as Code) in "Acute or Evolving MI" and ECG.result is not null

define "ECG Not STEMI": ["Diagnostic Study, Performed": "Electrocardiogram (ECG)"] ECG
  where not ((ECG.result as Code) in "STEMI Exclusions") and ECG.code is not null

define "PCI Med ED": from ["Procedure, Performed":"PCI"] PCI,
["Medication, Administered": "Fibrinolytic Therapy"] Fib,
["Encounter, Performed":"Emergency Department Visit"] ED
where PCI.relevantPeriod starts after start of Fib.relevantPeriod
and Fib.relevantPeriod starts after start of ED.relevantPeriod

define "PCI Med IP": from ["Procedure, Performed":"PCI"] PCI,
["Medication, Administered": "Fibrinolytic Therapy"] Fib,
"Inpatient Encounters" IP
where PCI.relevantPeriod starts after start of Fib.relevantPeriod
and Fib.relevantPeriod during IP.relevantPeriod

define "First PCI not ED not PCI Med": 
  exists ("PCI Inpatient") 
    and "No Emergency Department Encounter"
    and not exists ("PCI Med IP")

define "ED and First PCI and not PCI Med": "Emergency Department Encounter" union "PCI ED" not intersect  "PCI Med ED"

define "PCI ED IP": "Percutaneous Coronary" PCI
with "Emergency Department Encounter" ED
such that PCI.relevantPeriod starts 90 minutes or less after start of ED.relevantPeriod

define "Diagnosis Exception": ["Diagnosis": "Cardiopulmonary arrest"]

define "Reason For No PCI": "Diagnosis for no PCI"
or exists "Procedure Reason for No PCI"

define "Procedure Excep ED": "Procedure Exceptions" Procedure
with "Emergency Department Encounter" Encounter
 such that Procedure.relevantPeriod starts 90 minutes or less after start of Encounter.relevantPeriod

define "Procedure Except IP": "Procedure Exceptions" Procedure
with "Inpatient Encounters" Encounter
 such that( Procedure.relevantPeriod starts 90 minutes or less after start of Encounter.relevantPeriod)
 /*"No Emergency Department Encounter"*/

define "Diagnosis for no PCI": ["Diagnosis": "Cardiopulmonary arrest"]

define "Procedure Reason for No PCI": distinct (
["Procedure, Performed": "Endotracheal Intubation"]
union ["Procedure, Performed": "Aortic balloon pump insertion"]
union ["Procedure, Performed": "Ventricular Assist Device placement"])

define "AMI Encounter": ["Encounter, Performed": "Encounter Inpatient"] Encounter
    where AgeInYearsAt(start of Encounter.relevantPeriod) >= 18
      and Encounter.principalDiagnosis in "Acute Myocardial Infarction (AMI)"

define "Electrocardiogram Diagnostic": ["Diagnostic Study, Performed": "Electrocardiogram (ECG)"] Diagnostic

define "PCI Procedure": ["Procedure, Performed": "PCI"] Procedure

define "Nonelective Inpatient Encounters with Comfort Measures": Nonelective Inpatient" inp 
with ["Encounter, Performed": "Emergency Department Visit"] ed 
with "Comfort Measures" comf 
 such that ed.relevantPeriod ends 1 hour or less before start of inp.relevantPeriod 
and comf.relevantPeriod starts during ed.relevantPeriod

define function "Hospitalization"("Encounter" "Encounter, Performed" ): (singleton from (
    ["Encounter, Performed": "Emergency Department Visit"] EDVisit
      where EDVisit.relevantPeriod ends 1 hour or less before start of Encounter.relevantPeriod
  )) X
    return if X is null then Encounter.relevantPeriod
      else Interval[start of X.relevantPeriod, end of Encounter.relevantPeriod]

define "PCI and not ED": 
  exists ("Percutaneous Coronary") 
    and "No Emergency Department Encounter"

