This topic discusses some issues and proposed updates to logic for CMS832 version 2.1.000 using QDM 5.6.

* https://ecqi.healthit.gov/sites/default/files/ecqm/measures/CMS832v2-v2.html

## Measure Description

The measure assesses the number of inpatient hospitalizations for patients age 18 and older who have an acute kidney injury (stage 2 or greater) that occurred during the encounter. Acute kidney injury (AKI) stage 2 or greater is defined as a substantial increase in serum creatinine value, or by the initiation of kidney dialysis (continuous renal replacement therapy (CRRT), hemodialysis or peritoneal dialysis).

## Numerator

Inpatient hospitalizations for patients who develop AKI (stage 2 or greater) during the encounter, as evidenced by:

A subsequent increase in serum creatinine value at least 2 times higher than the lowest serum creatinine value, and the increased value is greater than the highest sex-specific normal value for serum creatinine.

Or:

Kidney dialysis (CRRT, hemodialysis or peritoneal dialysis) initiated more than 48 hours after the start of the encounter. Evidence of a 2 times increase in serum creatinine is not required.

## Identifying Acute Kidney Injury

The numerator harm, AKI (stage 2 or greater), is defined as a substantial increase in serum creatinine value during the encounter, as evidenced by a subsequent increase in value at least 2 times higher than the lowest serum creatinine value, and the increased value is greater than the highest sex-specific normal value for serum creatinine. The following steps are performed to determine if this criterion for AKI is met:
* To identify AKI, evaluate if any serum creatinine value obtained between 48 hours after the start of the encounter and either 30 days after the start of the encounter or discharge, whichever is sooner, is at least 1.5 times higher than the lowest value obtained within the prior 7 days. If yes, then:
* Evaluate if the increased serum creatinine is greater than the highest sex-specific normal value for serum creatinine. If yes, then:
* To stage AKI, evaluate if any serum creatinine value obtained between 48 hours after the start of the encounter and either 30 days after the start of the encounter or discharge, whichever is sooner, is at least 2 times higher than the lowest prior value (at any prior time) during that encounter. If yes, then:
* Evaluate if the increased serum creatinine value is greater than the highest sex-specific normal value for serum creatinine. If yes, then a harm (AKI stage 2 or greater) has been identified.

### Identifying Serum Creatinine Increase

The first step in the above process is identifying the 1.5 times serum creatinine increase:

```cql
define "Encounter with 1.5 Times Serum Creatinine Increase":
  from
    "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] HighCreatinineTest,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] LowCreatinineTest
    let LowCreatinineTestTime: Global."EarliestOf" ( LowCreatinineTest.relevantDatetime, LowCreatinineTest.relevantPeriod ),
    HighCreatinineTestTime: Global."EarliestOf" ( HighCreatinineTest.relevantDatetime, HighCreatinineTest.relevantPeriod ),
    HospitalWithObservation: Global."HospitalizationWithObservation" ( QualifyingEncounter )
    where ( HighCreatinineTest.result.value > "Serum Creatinine Normal" )
      and HighCreatinineTest.result.value = "HighestSerumCreatinine"(QualifyingEncounter)
      and LowCreatinineTest.result.value = "LowestSerumCreatinine"(QualifyingEncounter)
      and "1.5IncreaseInCreatinine"(QualifyingEncounter) >= LowCreatinineTest.result.value
      and LowCreatinineTestTime 7 days or less before HighCreatinineTestTime
      and LowCreatinineTestTime during HospitalWithObservation
      and HighCreatinineTestTime during Interval[start of HospitalWithObservation + 48 hours, start of HospitalWithObservation + 30 days]
      and HighCreatinineTestTime during HospitalWithObservation
    return QualifyingEncounter
```

This logic makes use of the `HighestSerumCreatinine` and `LowestSerumCreatinine` functions:

```cql
define function "LowestSerumCreatinine"(QualifyingEncounter "Encounter, Performed"):
  First("SerumCreatinineSequenceByQuantity"(QualifyingEncounter)).result.value

define function "HighestSerumCreatinine"(QualifyingEncounter "Encounter, Performed"):
  Last("SerumCreatinineSequenceByQuantity"(QualifyingEncounter)).result.value

define function "SerumCreatinineSequenceByQuantity"(Encounter "Encounter, Performed"):
  ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] CreatinineTestByQuantity
    where Global."EarliestOf" ( CreatinineTestByQuantity.relevantDatetime, CreatinineTestByQuantity.relevantPeriod ) during Global."HospitalizationWithObservation" ( Encounter )
      and CreatinineTestByQuantity.result.value is not null
    sort by result.value
```

These functions return, for a given encounter, the highest or lowest serum creatinine value recorded during the encounter.

Next, the `1.5IncreaseInCreatinine` function is used to determine whether there is a 1.5 times increase between the lowest and highest values:

```cql
define function "1.5IncreaseInCreatinine"(QualifyingEncounter "Encounter, Performed"):
  "HighestSerumCreatinine"(QualifyingEncounter) / 1.5
```

Returning to the first step of the process, we are looking for:

> To identify AKI, evaluate if any serum creatinine value obtained between 48 hours after the start of the encounter and either 30 days after the start of the encounter or discharge, whichever is sooner, is at least 1.5 times higher than the lowest value obtained within the prior 7 days

Looking at the where clause in "Encounter With 1.5 Times Serum Creatinine Increase":

```cql
where ( HighCreatinineTest.result.value > "Serum Creatinine Normal" )
      and HighCreatinineTest.result.value = "HighestSerumCreatinine"(QualifyingEncounter)
      and LowCreatinineTest.result.value = "LowestSerumCreatinine"(QualifyingEncounter)
      and "1.5IncreaseInCreatinine"(QualifyingEncounter) >= LowCreatinineTest.result.value
      and LowCreatinineTestTime 7 days or less before HighCreatinineTestTime
      and LowCreatinineTestTime during HospitalWithObservation
      and HighCreatinineTestTime during Interval[start of HospitalWithObservation + 48 hours, start of HospitalWithObservation + 30 days]
      and HighCreatinineTestTime during HospitalWithObservation
```

This logic will:
* Limit the `HighCreatinineTest` values to those over the `Serum Creatinine Normal`
* Limit the `HighCreatinineTest` values to those that are equal to the `HighestSerumCreatinine` for the encounter
* Limit the `LowCreatinineTest` values to those that are eqaul to the `LowestSerumCreatinine` for the encounter
* Limit the `LowCreatiningTest` values to those that are 7 days or less before the `HighestCreatinineTest` values
* Limit the test values considered to those during the hospitalization, and the creatinine observation time as defined by the measure

This is representing the first two steps, and the last two steps are then to look for a 2 times increase:

```cql
define "Encounter with 2 Times Serum Creatinine Increase":
  from
    "Encounter with 1.5 Times Serum Creatinine Increase" EncounterWithHighCreatinine,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] HighCreatinineTest,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] LowCreatinineTest
    let LowCreatinineTestTime: Global."EarliestOf" ( LowCreatinineTest.relevantDatetime, LowCreatinineTest.relevantPeriod ),
    HighCreatinineTestTime: Global."EarliestOf" ( HighCreatinineTest.relevantDatetime, HighCreatinineTest.relevantPeriod ),
    HospitalWithObservation: Global."HospitalizationWithObservation" ( EncounterWithHighCreatinine )
    where ( HighCreatinineTest.result.value > "Serum Creatinine Normal" )
      and HighCreatinineTest.result.value = "HighestSerumCreatinine"(EncounterWithHighCreatinine)
      and LowCreatinineTest.result.value = "LowestSerumCreatinine"(EncounterWithHighCreatinine)
      and "2.0IncreaseInCreatinine"(EncounterWithHighCreatinine) >= LowCreatinineTest.result.value
      and LowCreatinineTestTime before HighCreatinineTestTime
      and LowCreatinineTestTime during HospitalWithObservation
      and HighCreatinineTestTime during Interval[start of HospitalWithObservation + 48 hours, start of HospitalWithObservation + 30 days]
      and HighCreatinineTestTime during HospitalWithObservation
    return EncounterWithHighCreatinine
```

This logic is similar, with the exception that it is looking for a 2 times increase, and it does not limit the low value to only those within 7 days of the highest value.

### Scenario 1

The first issue is with identification of the first stage:

> To identify AKI, evaluate if any serum creatinine value obtained between 48 hours after the start of the encounter and either 30 days after the start of the encounter or discharge, whichever is sooner, is at least 1.5 times higher than the lowest value obtained **within the prior 7 days**

The logic is currently considering `LowestSerumCreatinine` for the entire encounter, rather than only those within the prior 7 days. If the lowest value is outside the 7 days prior, it will be incorrectly excluded, resulting the 1.5 times increase being missed.

### Scenario 2

The second issue is also with the identification of the first stage:

> To identify AKI, evaluate if **any** serum creatinine value obtained between 48 hours after the start of the encounter and either 30 days after the start of the encounter or discharge, whichever is sooner, is at least 1.5 times higher than the lowest value obtained within the prior 7 days

In the case that the highest value does not represent a 1.5 times increase, but there is a second highest value that does, the measure logic will only consider the first instance, resulting in the next highest increase being missed.

### Scenario 3

The third issue, similar to the second, is with the identification of the second stage. Consider the stage 2 logic:

```cql
define "Encounter with 2 Times Serum Creatinine Increase":
  from
    "Encounter with 1.5 Times Serum Creatinine Increase" EncounterWithHighCreatinine,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] HighCreatinineTest,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] LowCreatinineTest
    let LowCreatinineTestTime: Global."EarliestOf" ( LowCreatinineTest.relevantDatetime, LowCreatinineTest.relevantPeriod ),
    HighCreatinineTestTime: Global."EarliestOf" ( HighCreatinineTest.relevantDatetime, HighCreatinineTest.relevantPeriod ),
    HospitalWithObservation: Global."HospitalizationWithObservation" ( EncounterWithHighCreatinine )
    where ( HighCreatinineTest.result.value > "Serum Creatinine Normal" )
      and HighCreatinineTest.result.value = "HighestSerumCreatinine"(EncounterWithHighCreatinine)
      and LowCreatinineTest.result.value = "LowestSerumCreatinine"(EncounterWithHighCreatinine)
      and "2.0IncreaseInCreatinine"(EncounterWithHighCreatinine) >= LowCreatinineTest.result.value
      and LowCreatinineTestTime before HighCreatinineTestTime
      and LowCreatinineTestTime during HospitalWithObservation
      and HighCreatinineTestTime during Interval[start of HospitalWithObservation + 48 hours, start of HospitalWithObservation + 30 days]
      and HighCreatinineTestTime during HospitalWithObservation
    return EncounterWithHighCreatinine
```

The second stage definition is:

> To stage AKI, evaluate if any serum creatinine value obtained between 48 hours after the start of the encounter and either 30 days after the start of the encounter or discharge, whichever is sooner, is at least 2 times higher than the lowest prior value **(at any prior time)** during that encounter.

Because the highest and lowest test values are identified across the encounter, the possibility exists for a lower value after the highest to prevent the consideration of a 2 times lower value prior to the highest test.

### Proposed Updates

```cql
define "Encounter With 1.5 Times Serum Creatinine Increase":
  from
    "Encounter With Creatinine And Without Obstetrical Complications" QualifyingEncounter
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] CreatinineTest
    let LowestCreatinineTestWithin7DaysPrior: "LowestSerumCreatinineWithin7DaysPrior"(QualifyingEncounter, CreatinineTest)
    where LowestCreatinineTestWithin7DaysPrior * 1.5 >= CreatinineTest.result.value
      and CreatinineTest.result.value > "Serum Creatinine Normal"
      ...
    return QualifyingEncounter

define function "LowestSerumCreatinineWithin7DaysPrior"(QualifyingEncounter "Encounter, Performed", CreatinineTest "Laboratory Test, Performed"):
  First(
    ("SerumCreatinineSequenceByQuantity"(QualifyingEncounter)) Test
      where Global."EarliestOf"(Test.relevantDatetime, Test.relevantPeriod) 7 days or less before Global."EarliestOf"(CreatinineTest.relevantDatetime, CreatinineTest.relevantPeriod)
  ).result.value
```

This updated logic considers for each encounter, for each creatinine test, what is the lowest creatinine test value within 7 days prior, and then considers whether that represents a 1.5 times increase.

This update addresses the first two scenarios above because for each test, it only considers the test results in the immediately preceding 7 days, and it considers this for each test result, so it will catch the increase, even if there are higher creatinine values that don't have an increase of 1.5 times.

The proposal for the third scenario is similar:

```cql
define "Encounter With 2 Times Serum Creatinine Increase":
  from 
    "Encounter With 1.5 Times Serum Creatinine Increase" EncounterWithHighCreatinine
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] CreatinineTest
    let LowestCreatinineTestPrior: "LowestSerumCreatininePrior"(EncounterWithHighCreatinine, CreatinineTest)
    where LowestCreatinineTestPrior * 2.0 >= CreatinineTest.result.value
      and CreatinineTest.result.value > "Serum Creatinine Normal"
      ...
    return EncounterWithHighCreatinine

define function "LowestSerumCreatininePrior"(QualifyingEncounter "Encounter, Performed", CreatinineTest "Laboratory Test, Performed"):
  First(
    ("SerumCreatinineSequenceByQuantity"(QualifyingEncounter)) Test
      where Global."EarliestOf"(Test.relevantDatetime, Test.relevantPeriod) before Global."EarliestOf"(CreatinineTest.relevantDatetime, CreatinineTest.relevantPeriod)
  ).result.value
```

This proposal addresses the third scenario by ensuring only test values prior to the current test are considered when determining whether there is a 2.0 times increase.

Note that these proposals also mean that the "1.5IncreaseInCreatinine" and "2.0IncreaseInCreatinine" functions are no longer required.

As well, the proposals simplify the logic because they only need to bring in the creatinine test source once, rather than twice as the previous logic did.

### Other Considerations

As a final note, consider the additional restrictions on the test results:

```cql
    and LowCreatinineTestTime during HospitalWithObservation
    and HighCreatinineTestTime during Interval[start of HospitalWithObservation + 48 hours, start of HospitalWithObservation + 30 days]
    and HighCreatinineTestTime during HospitalWithObservation
```

These restrictions are based on the HospitalWithObservation definition:

```cql
    HospitalWithObservation: Global."HospitalizationWithObservation" ( EncounterWithHighCreatinine )
```

Which in turn relies on the "HospitalizationWithObservation":

```cql
define function "HospitalizationWithObservation"(Encounter "Encounter, Performed" ):
  Encounter Visit
  	let ObsVisit: Last(["Encounter, Performed": "Observation Services"] LastObs
  			where LastObs.relevantPeriod ends 1 hour or less on or before start of Visit.relevantPeriod
  			sort by 
  			end of relevantPeriod
  	),
  	VisitStart: Coalesce(start of ObsVisit.relevantPeriod, start of Visit.relevantPeriod),
  	EDVisit: Last(["Encounter, Performed": "Emergency Department Visit"] LastED
  			where LastED.relevantPeriod ends 1 hour or less on or before VisitStart
  			sort by 
  			end of relevantPeriod
  	)
  	return Interval[Coalesce(start of EDVisit.relevantPeriod, VisitStart), end of Visit.relevantPeriod]
```

This is consistent with the measure intent of considering test values during any immediately prior emergency department visit or observation services encounter.

However, since the `SerumCreatinineSequenceByQuantity` function is already restricting test results to that range:

```cql
define function "SerumCreatinineSequenceByQuantity"(Encounter "Encounter, Performed"):
  ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] CreatinineTestByQuantity
    where Global."EarliestOf" ( CreatinineTestByQuantity.relevantDatetime, CreatinineTestByQuantity.relevantPeriod ) during Global."HospitalizationWithObservation" ( Encounter )
      and CreatinineTestByQuantity.result.value is not null
    sort by result.value
```

the additional restrictions `and LowCreatinineTestTime during HospitalWithObservation` and `and HighCreatinineTestTime during HospitalWithObservation` are redundant and could be removed.

This would result in the following proposed updated definitions for the measure:

```cql
define "Encounter With 1.5 Times Serum Creatinine Increase":
  from
      "Encounter With Creatinine And Without Obstetrical Complications" QualifyingEncounter
      ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] CreatinineTest
    let 
      LowestCreatinineTestWithin7DaysPrior: "LowestSerumCreatinineWithin7DaysPrior"(QualifyingEncounter, CreatinineTest),
      CreatinineTestTime: Global."EarliestOf" ( CreatinineTest.relevantDatetime, CreatinineTest.relevantPeriod ),
      HospitalWithObservation: Global."HospitalizationWithObservation" ( EncounterWithHighCreatinine )
    where LowestCreatinineTestWithin7DaysPrior * 1.5 >= CreatinineTest.result.value
      and CreatinineTest.result.value > "Serum Creatinine Normal"
      and CreatinineTestTime during Interval[start of HospitalWithObservation + 48 hours, start of HospitalWithObservation + 30 days]
    return QualifyingEncounter

define function "LowestSerumCreatinineWithin7DaysPrior"(QualifyingEncounter "Encounter, Performed", CreatinineTest "Laboratory Test, Performed"):
  First(
    ("SerumCreatinineSequenceByQuantity"(QualifyingEncounter)) Test
      where Global."EarliestOf"(Test.relevantDatetime, Test.relevantPeriod) 7 days or less before Global."EarliestOf"(CreatinineTest.relevantDatetime, CreatinineTest.relevantPeriod)
  ).result.value

define "Encounter With 2 Times Serum Creatinine Increase":
  from 
      "Encounter With 1.5 Times Serum Creatinine Increase" EncounterWithHighCreatinine
      ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] CreatinineTest
    let 
      LowestCreatinineTestPrior: "LowestSerumCreatininePrior"(EncounterWithHighCreatinine, CreatinineTest)
      CreatinineTestTime: Global."EarliestOf" ( CreatinineTest.relevantDatetime, CreatinineTest.relevantPeriod ),
      HospitalWithObservation: Global."HospitalizationWithObservation" ( EncounterWithHighCreatinine )
    where LowestCreatinineTestPrior * 2.0 >= CreatinineTest.result.value
      and CreatinineTest.result.value > "Serum Creatinine Normal"
      and CreatinineTestTime during Interval[start of HospitalWithObservation + 48 hours, start of HospitalWithObservation + 30 days]
    return EncounterWithHighCreatinine

define function "LowestSerumCreatininePrior"(QualifyingEncounter "Encounter, Performed", CreatinineTest "Laboratory Test, Performed"):
  First(
    ("SerumCreatinineSequenceByQuantity"(QualifyingEncounter)) Test
      where Global."EarliestOf"(Test.relevantDatetime, Test.relevantPeriod) before Global."EarliestOf"(CreatinineTest.relevantDatetime, CreatinineTest.relevantPeriod)
  ).result.value
```


define function "LowestSerumCreatinineWithin7DaysPrior"(QualifyingEncounter "Encounter, Performed", CreatinineTest "Laboratory Test, Performed"):
  First(
    ("SerumCreatinineSequenceByQuantity"(QualifyingEncounter)) Test
      where Global."EarliestOf"(Test.relevantDatetime, Test.relevantPeriod) 7 days or less before Global."EarliestOf"(CreatinineTest.relevantDatetime, CreatinineTest.relevantPeriod)
  ).result.value

define Test:
  ["Encounter, Performed": "Relevant Encounters"] QualifyingEncounter
    let Lowest: "LowestSerumCreatinineWithin7DaysPrior"(
        QualifyingEncounter, 
        First(
            ["Laboratory Test, Performed": "Relevant Tests"] Test
              where Test.result is not null
                and Test.result.value > 10
        ))