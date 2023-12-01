## PC-07 Numerator Reporting

### Situation

* All diagnoses that qualify a patient for the PC07 numerator are found in 17 extensional value sets rolled up into one grouping value set (OID: 2.16.840.1.113762.1.4.1029.255). 
* Similarly, 5 procedures that qualify a patient are found in 5 extensional value sets. 
* Only the grouping value set is referenced in the logic. 
* Therefore, once production data is received, there is no flag as to which numerator codes triggered the patient to land in the numerator.  
* Yale/CORE has requested that we add logic to identify the patients within the numerator(s) at the extensional value set level.  
* We believe the simplest approach to accomplish this goal is to add a definition for each extensional value set to be reported as a supplemental data element or ??? 
* We are seeking input on this approach and ideas on other approaches from the expert community.

### Background: Numerator

* Definition: Inpatient hospitalizations for patients with severe obstetric complications (not present on admission that occur during the current delivery encounter) including the following: 
    * Severe maternal morbidity diagnoses 
    * Severe maternal morbidity procedures 
    * Discharge disposition of expired
* Two numerator populations are defined for this measure:
    * All Severe Obstetric Complications (SOC)
    * SOC excluding encounters where transfusion was the only SOC

* Severe maternal morbidity diagnoses
    * valueset "Severe Maternal Morbidity Diagnoses" (2.16.840.1.113762.1.4.1029.255)
    * Grouping value set consisting of 17 extensional value sets
        * Acute Heart Failure 
        * Acute Myocardial Infarction
        * Acute Renal Failure
        * etc.

* Severe maternal morbidity procedures 
    * valueset "Blood Transfusion" (2.16.840.1.113762.1.4.1029.213)
    * valueset "Severe Maternal Morbidity Procedures" (2.16.840.1.113762.1.4.1029.256)
    * Grouping value set consisting of 4 extensional value sets
        * Conversion of Cardiac Rhythm
        * Hysterectomy 
        * Tracheostomy
        * Ventilation

### Background: Numerator Exclusion

* Definition: Inpatient hospitalizations with blood transfusion or hysterectomy with a diagnosis of placenta percreta or placenta increta and no additional severe obstetrical complications.
* No need to apply numerator exclusion to the numerator since additional severe obstetrical complication will exist.
    * Exception:  Will be needed for transfusion and hysterectomy definitions.

### Assessment

* Simple solution: Add definitions for each extensional value set and package as a supplemental data element
* As there are 17 dx and 5 procedure SMM valuesets, this approach will result in 22 additional definitions.

```cql
define "Numerator Acute Heart Failure":
    "Numerator 1 Delivery Encounters with Severe Obstetric Complications" Numerator1
       "POAIsNoOrUTD"(Numerator1).code in "Acute Heart Failure"
```

### Recommendations

* Seeking input from the expert community for the most efficient approach to achieve the desired results

Solution under consideration:

```cql

valueset "Severe Maternal Morbidity Diagnosis": 'urn:oid:2.16.840.1.113762.1.4.1029.255'

/* extensional value sets grouped under "Severe Maternal Morbidity Diagnosis" */
valueset "Acute Heart Failure": '...'
valueset "Acute Myocardial Infarction": '...'
valueset "Acute Renal Failure": '...'
...

valueset "Severe Maternal Morbidity Procedures": 'urn:oid:2.16.840.113762.1.4.1029.256'

/* extensional value sets grouped under "Several Maternal Morbidity Procedures" */
valueset "Conversion of Cardiac Rhythm": '...'
valueset "Hysterectomy": '...'
valueset "Tracheostomy": '...'
valueset "Ventilation": '...'

...
define "Delivery Encounters":
    ["Encounter, Performed": "..."]

define "Delivery Encounters with Severe Obstetric Complications":
    "Delivery Encounters" Encounter
      let complications: "POAIsNoOrUTD"(Encounter)
      where exists complications
      return {
        id: Encounter.id,
        code: Encounter.code,
        ...
        diagnoses: complications
      }

/* Additional breakdown per grouped/extensional value set */
define "Delivery Encounters with Acute Heart Failure":
  "Delivery Encounters with Severe Obstetric Complications" Encounter
    where "EncounterCondition"(Encounter).code in "Acute Heart Failure"

define "Delivery Encounters with Severe Maternal Morbidity Procedures":
  "Delivery Encounters" Encounter
    with ["Procedure, Performed": "Severe Maternal Morbidity Procedures"] Procedure
      such that Global.NormalizeInterval(Procedure) starts during Global.NormalizeInterval(Encounter)

/* Additional breakdown per group/extensional value set */
define "Delivery Encounters with Conversion of Cardiac Rhythm":
  "Delivery Encounters" Encounter
    where "EncounterProcedure"(Encounter).code in "Conversion of Cardiac Rhythm"
```

Question: Would it be reasonable for this information to be provided as supplemental data? For example:

Consider use of the `case` expression:
https://cql.hl7.org/03-developersguide.html#conditional-expressions

```cql

Delivery Encounters with Severe Obstetric Complications Diagnosis or Procedure (Excluding Blood Transfusion)
"Delivery Encounters At Greater than or Equal to 20 Weeks Gestation" TwentyWeeksPlusEncounter
  where exists ( TwentyWeeksPlusEncounter.diagnoses EncounterDiagnoses
      where EncounterDiagnoses.code in "Severe Maternal Morbidity Diagnoses"
        and EncounterDiagnoses.presentOnAdmissionIndicator in "Present on Admission = No or Unable To Determine"
  )
    or exists ( ["Procedure, Performed": "Severe Maternal Morbidity Procedures"] EncounterProcedures
        where Global."NormalizeInterval" ( EncounterProcedures.relevantDatetime, EncounterProcedures.relevantPeriod ) starts during day of PCMaternal."HospitalizationWithEDOBTriageObservation" ( TwentyWeeksPlusEncounter )
    )

define function POAIsNoOrUTD(Encounter "Encounter, Performed")
    Encounter.diagnoses EncounterDiagnoses
        where EncounterDiagnoses.presentOnAdmissionIndicator in "Present on Admission is No or Unable To Determine"
        return EncounterDiagnoses.code

define "Delivery Encounter Complication":
  "Delivery Encounters with Severe Obstetric Complications" Encounter
    let complication: "POAIsNoOrUTD"(Encounter)
    return {
        id: Encounter.id,
        code: Encounter.code,
        complications: 
          complication C
            return {
                code: C,
                category:
                    case 
                        when complication.code in "Acute Heart Failure" then 'Acute Heart Failure'
                        when complication.code in "Acute Myocardial Infarction" then 'Acute Myocardial Infarction'
                        when complication.code in "Acute Renal Failure" then 'Acute Renal Failure'
                        ...
                        else null
                    end
            }
    }

{ 
    id: '123', 
    code: '99201', 
    complications: { 
        { code: 'XXX123', category: 'Acute Heart Failure' }, 
        { code: 'XXX124', category: 'Acute Heart Failure' }, 
        { code: 'XXX125', category: 'Acute Heart Failure' }, 
        { code: 'XXX123', category: 'Acute Renal Failure' } 
    } 
},
{ 
    id: '124', 
    code: '99201', 
    complications: { 
        { code: 'SNOMEDFORHF', category: 'Acute Heart Failure' }, 
        { code: 'SNOMEDFORRF', category: 'Acute Renal Failure' } 
    } 
},
...

define "Delivery Encounter Procedure":
  "Delivery Encounters with Severe Maternal Morbidity Procedures" Encounter
    let procedure: "EncounterProcedure"(Encounter)
    return {
        id: Encounter.id,
        code: Encounter.code,
        procedureCode: procedure.code,
        procedureCategory:
          case
            when procedure.code in "Conversion of Cardiac Rhythm" then 'Conversion of Cardiac Rhythm'
            when procedure.code in "Hysterectomy" then 'Hysterectomy'
            when procedure.code in "Tracheostomy" then 'Tracheostomy'
            when procedure.code in "Ventilation" then 'Ventilation'
            else null
          end
    }
```

