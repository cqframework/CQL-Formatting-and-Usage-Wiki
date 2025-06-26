This topic discusses calculation of the National Hospital Saftey Network (NHSN) Catheter-Associated Urinary Tract Infection measures to illustrate how these measures can be represented in FHIR- and CQL-based measures.

This discussion is based on the Urinary Tract Infection module available from NHSN here: https://www.cdc.gov/nhsn/pdfs/pscmanual/7psccauticurrent.pdf

To begin, we describe the CAUTI measures available in NHSN:

1. CAUTI Standardized Infection Ratio (SIR):

Number of Observed CAUTIs / Number of Predicted CAUTIs

2. CAUTI Rates: 

(Number of CAUTIs per location / Number of Urinary Catheter Days per location) * 1000

3. Urinary Catheter Standardized Utilization Ratio (SUR)

Number of Observed Catheter Days / Number of Predicted Catheter Days

4. Device Utilization Ratio (DUR):

Number of Catheter Days for a location / Number of Patient Days for a location

There are two measures in this set that can be calculated solely based on data from the location, the CAUTI Rates, and DUR. The other two measures require the use of baseline data to determine a predicted denominator.

We will consider the CAUTI Rates measure to demonstrate calculation approach for the first type, and then the CAUTI SIR to demonstrate calculation for the second type (predicted denominator).

## CAUTI Rates

This measure is a rate, representing the CAUTI Rate per 1000 urinary catheter days:

```
(Number of CAUTIs per location / Number of Urinary Catheter Days per location) * 1000
```

We will set this up as a _patient-based_ _ratio_ of _continuous variables_:

* **Initial Population:** Patients with an encounter during the measurement period
* **Denominator:** Patients with an encounter during which an indwelling urinary catheter was in use
* **Numerator:** Patients with an encounter during the measurement period
* **Denominator Observation:** Count(Urinary Catheter Days)
* **Numerator Observation:** Count(CAUTIs)

Note that validation of electronic denominator data collection requires validation of counts per day to within 5% of manual collection. This can be accomplished with a supplemental data element that outputs urinary catheter counts per day.

> Number of patients with an indwelling urinary catheter device on a given day, calculated at the same time each day.

First we establish "catheter usage intervals" as the intervals, in days, during which a catheter was inserted:

```cql
define "Catheter Inserted Procedure":
  [Procedure: "Catheter Inserted"] P
    where P.status = 'completed'

define "Catheter Removed Procedure":
  [Procedure: "Catheter Removed"] P
    where P.status = 'completed'

define "Catheter Usage":
  "Catheter Inserted Procedure" I
    let catheterRemoved: 
      First(
        "Catheter Removed Procedure" R
          where R.performed.toInterval() starts after I.performed.toInterval()
          sort by start of performed.toInterval()
      )
    return Interval[
      start of day of I.performed.toInterval(), 
      start of day of catheterRemoved.performed.toInterval()
    ]
```

We then use that to calculate the number of catheter days (i.e. days on which a catheter was in use) during the measurement period:

```cql
define "Catheter Usage During Measurement Period":
  collapse (
    "Catheter Usage" Usage
        where Usage overlaps "Measurement Period"
        return Interval[
            Max(start of Usage, start of "Measurement Period"),
            Min(end of Usage, end of "Measurement Period")
        ]
  )

define function "Denominator Observation"():
  Sum(
    "Catheter Usage During Measurement Period" Usage
      return all duration in days of Usage
  )
```

Note the use of `collapse` to ensure that usage intervals that meet or overlap are collapsed into single intervals, to avoid counting each day more than once.

> Number of CAUTIs

> Positive urine culture with no more than two species of organism, at least one of which is a bacterium of >= 10^5 CFU/ml. All elements of the UTI criterion must occur during the Infection Window Period

```cql
define "Urine Culture With Bacterium":
  [Observation: "Urine Culture"] O
    where O.status = 'final'
      and exists (
        O.component C
          where C.code in "Bacterium Presence"
            and C.value >= 10000 'CFU/ml'
      )

define "UTI":
  "Urine Culture With Bacterium" U
    let 
      DOE: start of day of U.effective.toInterval(),
      IWP: Interval[DOE - 3 days, DOE + 3 days]
    where start of U.effective.toInterval() during "Measurement Period"
    return {
      urineCultureResult: U,
      dateOfEvent: DOE,
      infectionWindowPeriod: IWP
    }
```

> Indwelling urinary catheter that had been in place for > two days AND was either: 1. Still present for any portion of the calendar day on date of event OR 2. Removed day before date of event?

```cql
define "Catheter-Associated UTI":
  "UTI" U
    where exists (
        "Catheter Usage" Usage
          where start of Usage before U.dateOfEvent
            and end of Usage on or after U.dateOfEvent - 1 day
            and duration in days of Usage > 2
    )
```

> At least one of the following signs:

a. Any age patient: fever > 38.0 Cel, suprapubic tenderness or costovertebral angle pain with no other recognized cause, or urgency, dysuria, frequency when no catheter is in place

b. Patients <= 1 year: fever > 38 Cel, hypothermia 36 Cel, suprapubic tenderness, costovertebral pain, apnea, bradycardia, lethargy, or vomiting with no other recognized cause.

```cql
define "Symptomatic UTI":
  "UTI" U
    where exists ("Symptoms Not Attributable To Catheter" S 
      where S.prevalencePeriod() starts during U.infectionWindowPeriod
    )
      or exists (
        "Symptoms Attributable to Catheter" S
          where S.prevalencePeriod() starts during U.infectionWindowPeriod
            and not exists (
              "Catheter Usage" Usage
                where S.prevalencePeriod() starts during Usage
            )
      )

define "Symptoms Not Attributable To Catheter":
  "Fever Over 38"
    union "Suprapubic Tenderness"
    union "Costovertebral Angle Pain"
    union "Hypothermia Under 36 In Infants"
    union "Apnea In Infants"
    union "Bradycardia In Infants"
    union "Lethargy In Infants"
    union "Vomiting In Infants"
```

> Organism identified from blood specimen with at least one matching bacterium to bacterium in the urine at >= 10^5 CFU/ml, where the organism is identified by a culture or non-culture based microbiologic testing method performed for purposes of clinical diagnosis or treatment (e.g. not Active Surveillance Culture/Testing (ASC/AST))

```cql
define "Microbiologic Blood Test Result":
  [Observation: "Microbiologic Blood Tests"] T
    where T.status = 'final'
      and exists (
        O.component C
          where C.code in "Bacterium Presence"
            and C.value >= 10000 'CFU/ml'
      )

define "Bacteremic UTI":
  "UTI" U
    where exists (
      "Microbiologic Blood Test Result" B
        where B.effective.toInterval() during U.infectionWindowPeriod
          and exists (
            B.component.code intersect U.component.code
          )
    )
```

The numerator observation is then just the count of Catheter-Associated UTIs

```cql
define "Numerator Observation":
  Count("Catheter-Associated UTI")
```

## CAUTI Standardized Infection Ratio (SIR)

The Standardized Infection Ratio is a summary measure used to track Hospital Acquired Infections at a national, state, or local level over time. The SIR adjusts for factors that contribute to HAI risk.

The SIR compares the actual number of HAIs reported to the number that would be predicted, given the standard population (i.e. NHSN baseline), adjusting for risk factors.

The number of predicted infections is calculated using probabilities from negative binomial regression models constructed from 2015 NHSN data.

See the SIR guide: https://www.cdc.gov/nhsn/pdfs/ps-analysis-resources/nhsn-sir-guide.pdf

For CAUTI, the SIR is:

```
Observed (O) HAIs / Predicted (P) HAIs
```

CAUTI SIR is calculated with a negative binomial regression model:

```
log(l) = a + b1X1 + b2X2 + ... + biXi
```

* **a** = Intercept
* **bi** = Parameter Estimate
* **Xi** = Value of Risk Factor (Categorical values 1 if present, 0 if absent)
* **i** = Number of Predictors

The SIR is a facility-level calculation, but importantly, it's calculated in a way that can be summarized across facilities, with the contribution from each facility adjusted based on factors appropriate for the facility type. In FHIR measure terms, we want to re-use the CAUTI counting from the rate measure, but we want to introduce a location-based regression model calculation. To accomplish this, we set up the measure in the same way as the rate measure, as a _patient-based_ _ratio_ of _continuous-variables_. However, our denominator population will be location-based, whereas our numerator population will be patient-based:


* **Denominator Initial Population:** Locations with an encounter during the measurement period
* **Numerator Initial Population:** Patients with an encounter during the measurement period
* **Denominator:** Locations with an encounter during the measurement period
* **Numerator:** Patients with an encounter during the measurement period
* **Denominator Observation:** Predicted CAUTIs
* **Numerator Observation:** Count(CAUTIs)

The denominator function in this case is the "Predicted CAUTIs" calculation (i.e. the negative binomial regression model calculation).

This calculation makes use of various parameter estimates established by the NHSN baseline data, such as facility type, medical school affiliation, facility bed size, and facility type.

Note that because the regression model is based on facility type, the measure can be run across facilities, but the regression calculation must be performed for each facility and summarized.

Starting with the regression model calculation for a single facility, first we need the values of for parameter estimates of the regression model:

```cql
define "Acute Care Hospital Parameters": {
    { code: "Intercept", estimate: -10.2667, standardError: 0.1618, pValue: Quantity { value: 0.001, comparator: '<' } },
    { code: "Burn Critical Care", estimate: 3.3318, standardError: 0.1580, pValue: Quantity { value: 0.001, comparator: '<' } },
    ...
}
```

These are provided in the SIR calculation guide, and can be represented in CQL with a list of tuples, where each tuple has the parameter code, it's estimate, standard error, and p-value.

Next we need to construct the parameters appropriate for this location:

```cql
define "Location Parameters"(location Location):
  {
    "Intercept",
    location.type.toCDCLocationCode(),
    location.medicalSchoolAffiliation(),
    location.facilityBedSize(),
    location.facilityType()
  }
```

Note the use of several mapping functions here, these will need to be established based on how this information is represented in a FHIR Location resource, mapping information like facility type to CDC Location Codes, and so on. Note that a complete implementation here will likely involve extension information, and potentially additional calculations to determine aspects such as number of beds.

With this information, we can then look up the parameter estimates for each parameter appropriate to the facility, summarize them, and then multiply by "Patient Days":

```cql
define function "Denominator Observation"(location Location):
  Sum(
    from "Location Parameters"(location) P, "Acute Care Hospital Parameters" H
      where P ~ H.code
      return all H.estimate
  ) * "Patient Days"(location)
```

Patient days is calculated by:

```cql
define "Encounter During Measurement Period":
  [Encounter] E
    where E.period during "Measurement Period"

define function "Patient Days"(location Location):
  Sum(
    "Encounter During Measurement Period" E
      where E.location.references(location)
      return all duration in days of E.period
  )

define "Denominator Initial Population":
  [Location] L
    with "Encounter During Measurement Period" E
     such that E.location.references(L)

define "Denominator":
  "Denominator Initial Population"
```

And finally, we need to determine the number of observed events for the numerator observation:

```cql
define function "Numerator Observation"():
  Count(CAUTIRate."Catheter-Associated UTI")

define "Encounter During Measurement Period":
  [Encounter] E
    where E.period during "Measurement Period"

define "Numerator Initial Population":
  exists ("Encounter During Measurement Period")

define "Numerator":
  "Numerator Initial Population"
```

Note that we can reuse the logic from the CAUTIRate measure here to determine the number of Catheter-Associated UTI, we just need to adapt it to return the number of events for the location, so we use the set of Patients from the Encounters During the Measurement Period.