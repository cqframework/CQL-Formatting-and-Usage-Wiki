## CQLIT-424

https://oncprojectracking.healthit.gov/support/projects/CQLIT/issues/CQLIT-424

CQLIT-424 CMS1218 Hospital Harm - Postoperative Respiratory Failure, Occurrence Issue with Numerator QDM AIR

Numerator 1: Intubation that occurs outside of a procedural area and within 30 days after the end of the First OR procedure of the encounter.
Issue: Intubations during a procedure (General Anesthesia or Anesthesia Requiring Monitored Care) should not ‘count’ towards the numerator, but in certain scenarios they do.


Summary: relates to Encounter with Procedure retrieve, exclude Anesthetics during O2 to MechVent Interval, use of id not member of excluded anesthesia 
Description: Numerator 1 is: Intubation that occurs outside of a procedural area and within 30 days after the end of the First OR procedure of the encounter.
Issue: Intubations during a procedure (General Anesthesia or Anesthesia Requiring Monitored Care) should not ‘count’ towards the numerator, but in certain scenarios they do.
If during an encounter a procedure occurs where there is no intubation, and then another procedure occurs where there is an Intubation that is performed during that procedure, it is meeting the Numerator because it is evaluating the intubation against that first procedure (where the intubation did not occur, hence meets numerator). The fact that the intubation occurred during the second procedure doesn’t seem to be considered, and we are requesting assistance with identifying and rectifying the issue in the logic. Attached is a screenshot from Bonnie showing such a case, where the Intubation occurred during the second procedure (during the 'Anesthesia Requiring Monitored Care' relevant period). Numerator 1 is met, but should fail. 
https://oncprojectracking.healthit.gov/support/projects/CQLIT/issues/CQLIT-424



```cql
define "Numerator":
  "Encounter with Intubation Outside of Procedural Area within 30 Days of End of First OR Procedure"
    union "Mia EncComb"
    union "Encounter with Extubation Outside of Procedural Area within 30 Days of End of First OR Procedure More Than 48 Hours After End of Anesthesia and not Preceded by Non Invasive Oxygen Therapy"
    union "Encounter with Mechanical Ventilation within 30 Days of End of First OR Procedure and Between 48 and 72 Hours After End of OR Procedure and not Preceded by Non Invasive Oxygen Therapy or Anesthesia"

define "Encounter with Intubation Outside of Procedural Area within 30 Days of End of First OR Procedure":
  from
    "Elective Inpatient Encounter with OR Procedure without Preceding ED Visit and without Obstetrical Condition" EncounterWithSurgery,
    ["Procedure, Performed": "Intubation"] EndotrachealTubeIn
    let IntubationTime: Global."NormalizeInterval" ( EndotrachealTubeIn.relevantDatetime, EndotrachealTubeIn.relevantPeriod ),
    FirstProcedureTime: Global."NormalizeInterval" ( "FirstProcedure"(EncounterWithSurgery).relevantDatetime, "FirstProcedure"(EncounterWithSurgery).relevantPeriod ),
    GATime: Global."NormalizeInterval" ( "LatestGeneralAnesthesiaOrMAC"(EndotrachealTubeIn).relevantDatetime, "LatestGeneralAnesthesiaOrMAC"(EndotrachealTubeIn).relevantPeriod ),
    HospitalizationPeriod: "AIR.HospitalizationWithObservationAndOutpatientSurgeryService"(EncounterWithSurgery)
    where IntubationTime starts 30 days or less after end of FirstProcedureTime
      and IntubationTime starts during HospitalizationPeriod
      and IntubationTime starts after end of GATime
      and not exists ( EncounterWithSurgery.facilityLocations EncounterLocation
          where EncounterLocation.code in "Procedural Hospital Locations"
            and IntubationTime starts during EncounterLocation.locationPeriod
      )
    return EncounterWithSurgery

define function "FirstProcedure"(Encounter "Encounter, Performed"):
  First(["Procedure, Performed": "General and Neuraxial Anesthesia"] FirstORProcedure
      where Global."NormalizeInterval"(FirstORProcedure.relevantDatetime, FirstORProcedure.relevantPeriod) starts during "AIR.HospitalizationWithObservationAndOutpatientSurgeryService"(Encounter)
      sort by start of Global."NormalizeInterval"(relevantDatetime, relevantPeriod)
  )

```

Test Case:

* Encounter, Performed: Elective Hospitalizations - 4/10/2023 - 4/14/2023
* Procedure, Performed: General or Neruaxial Anesthesia - 4/11/2023 - 4/11/2023
* Procedure, Performed: Intubation - 4/12/2023
* Procedure, Performed: Anesthesia Requiring Monitored Care - 4/12/2023 - 4/12/2023

Confirming measure intent and understanding of the issue:
Is the issue that the Intubation Procedure reference is not restricted to Intubation Procedures that occurred outside of a procedure with expected intubation?

Consider establishing that restriction explicitly in the definition of an Intubation:

```cql
define "Intubation Outside of Procedural Area":
  ["Procedure, Performed": "Intubation"] EndotrachealTubeIn
    without ["Procedure, Performed": "Procedures with Expected Intubation"] ExpectedIntubationProcedure
      such that Global."NormalizeInterval"(EndotrachealTubeIn.relevantDatetime, EndotrchealTubeIn.relevantPeriod) starts during Global."NormalizeInterval"(ExpectedIntubationProcedure.relevantDatetime, EpxectedIntubationProcedure.relevantPeriod)
```

Then that definition can be used whenever you need to identify an "unexpected intubation":

```cql
define "Encounter with Intubation Outside of Procedural Area within 30 Days of End of First OR Procedure":
  from
    "Elective Inpatient Encounter with OR Procedure without Preceding ED Visit and without Obstetrical Condition" EncounterWithSurgery,
    "Intubation Outside of Procedural Area" EndotrachealTubeIn
    let IntubationTime: Global."NormalizeInterval" ( EndotrachealTubeIn.relevantDatetime, EndotrachealTubeIn.relevantPeriod ),
    FirstProcedureTime: Global."NormalizeInterval" ( "FirstProcedure"(EncounterWithSurgery).relevantDatetime, "FirstProcedure"(EncounterWithSurgery).relevantPeriod ),
    GATime: Global."NormalizeInterval" ( "LatestGeneralAnesthesiaOrMAC"(EndotrachealTubeIn).relevantDatetime, "LatestGeneralAnesthesiaOrMAC"(EndotrachealTubeIn).relevantPeriod ),
    HospitalizationPeriod: "AIR.HospitalizationWithObservationAndOutpatientSurgeryService"(EncounterWithSurgery)
    where IntubationTime starts 30 days or less after end of FirstProcedureTime
      and IntubationTime starts during HospitalizationPeriod
      and IntubationTime starts after end of GATime
      and not exists ( EncounterWithSurgery.facilityLocations EncounterLocation
          where EncounterLocation.code in "Procedural Hospital Locations"
            and IntubationTime starts during EncounterLocation.locationPeriod
      )
    return EncounterWithSurgery
```

