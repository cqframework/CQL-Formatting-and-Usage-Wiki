library BloodPressureAverage

using QDM version '5.3'

parameter "Measurement Period" Interval<DateTime>

/*
Current blood pressure criteria in CMS22 takes the most recent encounter with
a blood pressure reading, and then the most recent reading from that encounter.

New guidelines determine a reference reading as the average of all blood pressure
readings taken during the most recent encounter.
*/

/* identify qualifying encounters */
define "Qualifying Encounters During Measurement Period":
  ["Encounter, Performed": "BP Screening Encounter Codes"] QualifyingEncounter
    where QualifyingEncounter.relevantPeriod during "Measurement Period"

/* identify most recent encounter with bp results */
define "Most Recent Encounter With Blood Pressure Screening Results":
  Last("Qualifying Encounters During Measurement Period" QualifyingEncounter
    with ["Physical Exam, Performed": "Diastolic blood pressure"] DiastolicBP
      such that DiastolicBP.relevantPeriod starts during QualifyingEncounter.relevantPeriod
        and DiastolicBP.result is not null
    with ["Physical Exam, Performed": "Systolic blood pressure"] SystolicBP
      such that SystolicBP.relevantPeriod starts during QualifyingEncounter.relevantPeriod
        and SystolicBP.result is not null
    sort by start of relevantPeriod
  )

/* pull list of all systolic results from that most recent encounter (will do the same for diastolic) */
define "All Systolic Readings During Most Recent Blood Pressure Screening":
  ["Physical Exam, Performed": "Systolic blood pressure"] SystolicBP
    with "Most Recent Encounter With Blood Pressure Screening Results" LastBPEncounter
      such that SystolicBP.relevantPeriod during LastBPEncounter.relevantPeriod
        and SystolicBP.result is not null
    return SystolicBP.result

/* 
Since the result attribute is a "choice" type, the result type of the "All Systolic Readings..."
expression is List<Choice<Integer, Decimal, Code, Quantity, Ratio>>
*/

define "Average Systolic Reading During Most Recent Blood Pressure Screening":
  Avg("All Systolic Readings During Most Recent Blood Pressure Screening")
  
/*
And since the Avg operator is defined for both Decimal and Quantity, the use of
Avg here is ambiguous (because we could mean Avg the decimals, or Avg the quantities).
*/

/*
In this case, we intend to average the quantities, since blood pressure readings should
be reported using a Quantity with units 'mm[Hg]'. Looking back at the "Most Recent Encounter..."
definition, note the use of "is not null". This indicates that we are only interested in
blood pressure readings that have a result, but we can tighten this to say, we are
only interested in blood pressure readings that have a "Quantity" result using the "is" operator:
*/

define "Most Recent Encounter With Blood Pressure Screening Results":
  Last("Qualifying Encounters During Measurement Period" QualifyingEncounter
    with ["Physical Exam, Performed": "Diastolic blood pressure"] DiastolicBP
      such that DiastolicBP.relevantPeriod starts during QualifyingEncounter.relevantPeriod
        and DiastolicBP.result is "Quantity"
    with ["Physical Exam, Performed": "Systolic blood pressure"] SystolicBP
      such that SystolicBP.relevantPeriod starts during QualifyingEncounter.relevantPeriod
        and SystolicBP.result is "Quantity"
    sort by start of relevantPeriod
  )

/*
We could also restrict even further to say, readings that have a 'mm[Hg]' quantity:
*/

define "Most Recent Encounter With Blood Pressure Screening Results":
  Last("Qualifying Encounters During Measurement Period" QualifyingEncounter
    with ["Physical Exam, Performed": "Diastolic blood pressure"] DiastolicBP
      such that DiastolicBP.relevantPeriod starts during QualifyingEncounter.relevantPeriod
        and DiastolicBP.result is "Quantity"
        and DiastolicBP.result.unit = 'mm[Hg]'
    with ["Physical Exam, Performed": "Systolic blood pressure"] SystolicBP
      such that SystolicBP.relevantPeriod starts during QualifyingEncounter.relevantPeriod
        and SystolicBP.result is "Quantity"
        and SystolicBP.result.unit = 'mm[Hg]'
    sort by start of relevantPeriod
  )

/*
Next, in the "All Systolic Readings..." definition, we indicate that we are only
dealing with results as quantities using the "as" operator:
*/

define "All Systolic Readings During Most Recent Blood Pressure Screening":
  ["Physical Exam, Performed": "Systolic blood pressure"] SystolicBP
    with "Most Recent Encounter With Blood Pressure Screening Results" LastBPEncounter
      such that SystolicBP.relevantPeriod during LastBPEncounter.relevantPeriod
        and SystolicBP.result is "Quantity"
        and SystolicBP.result.unit = 'mm[Hg]'
    return SystolicBP.result as Quantity
    
/*
Now, when we use the Avg operator to calculate the Average blood pressure for the
encounter, it's clear we are Averaging quantities:
*/

define "Average Systolic Reading During Most Recent Blood Pressure Screening":
  Avg("All Systolic Readings During Most Recent Blood Pressure Screening")
  
