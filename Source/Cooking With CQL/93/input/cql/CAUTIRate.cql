library CAUTIRate

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '2.0.0'

valueset "Catheter Inserted": 'TBD'
valueset "Catheter Removed": 'TBD'
valueset "Urine Culture": 'TBD'
valueset "Bacterium Presence": 'TBD'

parameter "Measurement Period" Interval<DateTime> default Interval[@2025-01-01, @2025-12-31]

context Patient

define "Encounter During Measurement Period":
  [Encounter] E
    where E.period during "Measurement Period"

define "Initial Population":
  exists ("Encounter During Measurement Period")

define "Denominator":
  "Initial Population"

define "Numerator"
  "Initial Population"

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

define "Catheter-Associated UTI":
  "UTI" U
    where exists (
        "Catheter Usage" Usage
          where start of Usage before U.dateOfEvent
            and end of Usage on or after U.dateOfEvent - 1 day
            and duration in days of Usage > 2
    )

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

define "Numerator Observation":
  Count("Catheter-Associated UTI")
