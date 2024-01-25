## CQLIT-421

https://oncprojectracking.healthit.gov/support/projects/CQLIT/issues/CQLIT-421

CQLIT-421 CMS866 Guidance in correcting the statement "Encounter with First Systolic Blood Pressure"  FHIR/QICore MADiE Lantana
Logic in the statement "Encounter with First Systolic Blood Pressure" does not seem to be written correctly as we are unable to capture the first systolic reading with the logic. Please advise. 

Initial logic:

```cql
define "Encounter with First Systolic Blood Pressure":
    "Inpatient Encounters" EncounterInpatient
    let FirstSystolicBP: 
        First(["observation-bp"]  SystolicBP
            where SystolicBP.effective.earliest() during Interval[start of EncounterInpatient.period - 1440 minutes, start of EncounterInpatient.period + 120 minutes] 
                and SystolicBP.status in {'final', 'amended', 'corrected'}
                and SystolicBP.value is not null
            sort by effective.earliest() 
        )
    return {
        EncounterId: EncounterInpatient.id,
        FirstSystolicResult: FirstSystolicBP.component ComponentSystolic where ComponentSystolic.code ~ "Systolic blood pressure" return ComponentSystolic.value as Quantity,
        Timing: FirstSystolicBP.effective.earliest()
    }
```

Note that because the profile for bp defines slices for the blood pressure components, we can access those directly:

https://hl7.org/fhir/R4/bp.html


Corrected statement:

```cql
define "Encounter with First Systolic Blood Pressure":
    "Inpatient Encounters" EncounterInpatient
    let FirstSystolicBP: 
        First(["observation-bp"] SystolicBP
            where SystolicBP.effective.earliest() during Interval[start of EncounterInpatient.period - 1440 minutes, start of EncounterInpatient.period + 120 minutes] 
                and SystolicBP.status in {'final', 'amended', 'corrected'}
                and SystolicBP.value is not null
            sort by effective.earliest() 
        )
    return {
        EncounterId: EncounterInpatient.id,
        FirstSystolicResult: FirstSystolicBP.SystolicBP.value as Quantity,
        Timing: FirstSystolicBP.effective.earliest()
    }
```

