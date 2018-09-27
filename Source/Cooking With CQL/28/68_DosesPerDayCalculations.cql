library DosesPerDayCalculations

/*
Issue: Different systems will provide different data for medications, we will
review alternative approaches to calculating doses per day with QDM medication statements.
*/

/*
Source data from Medications in QDM:

*/

/*
Medication, Active
  dosage - quantity to be taken at a single administration
  supply - number of doses supplied
  frequency - how frequently the medication is administered
  relevantPeriod - covers when the medication is first known to be used to when the medication is discontinued

Medication, Administered
  dosage - quantity to be taken at a single administration
  supply - number of doses supplied
  frequency - how frequently the medication was administered
  relevantPeriod - when a single medication administration event starts to the end of the administration

Medication, Discharge
  dosage - quantity to be taken at a single administration
  frequency - how frequently the medication should be administered
  supply - number of doses supplied per refill
  refills - number of refills allowed by the prescription
  authorDatetime - when the discharge medication list was authored

Medication, Dispensed
  dosage - quantity to be taken at a single administration
  supply - number of doses supplied per refill
  frequency - how frequently the medication is administered
  refills - number of refills allowed by the prescription
  relevantPeriod - covers when the administration of the medication is expected to start and end

Medication, Order
  dosage - quantity to be taken at a single administration
  supply - number of doses supplied per refill
  frequency - how frequently the medication should be administered
  refills - number of refills allowed by the prescription
  relevantPeriod - covers when the administration of the medication is expected to start and end

*/

/*
For reference, the dosesPerDay calculation used with "QDM Medication, Order":
*/

define function "DosesPerDay"(frequency Code):
	/*Calculates the cumulative dose per day for each prescription*/
	case
		when frequency ~ "Once daily (qualifier value)" then 1.0
		when frequency ~ "Twice a day (qualifier value)" then 2.0
		when frequency ~ "Three times daily (qualifier value)" then 3.0
		when frequency ~ "Four times daily (qualifier value)" then 4.0
		when frequency ~ "Every twenty four hours (qualifier value)" then 1.0
		when frequency ~ "Every twelve hours (qualifier value)" then 2.0
		when frequency ~ "Every thirty six hours (qualifier value)" then 0.67
		when frequency ~ "Every eight hours (qualifier value)" then 3.0
		when frequency ~ "Every four hours (qualifier value)" then 4.0
		when frequency ~ "Every six hours (qualifier value)" then 4.0
		when frequency ~ "Every seventy two hours (qualifier value)" then 0.34
		when frequency ~ "Every forty eight hours (qualifier value)" then 0.5 
		else null 
	end
  
/*
Example usage:
*/

define "Example QDM Doses Per Day":
  ["Medication, Order": "Opioid Medications"] O
    return {
        dosesPerDay = "DosesPerDay"(O.frequency)
      }

/*
NOTE: This calculation assumes "scheduled dosing" or "around-the-clock dosing", it does not consider
cases where PRN or as needed is part of the medication prescription.
*/

/*
This calculation method is using frequency directly to determine the number of doses per day
In QDM, we only have one frequency (not a range), so there's guidance to be given to the 
provider system to specify what to present

An alternative calculation method is to use the duration of the relevant period 
and the days supply to determine the number of doses per day:
*/

define "Example Doses Per Day With Supply":
  ["Medication, Order": "Opioid Medications"] O
    return {
      dosesPerDay: 
        O.supply * (1 + Coalesce(O.refills, 0)) /
          duration in days of O.relevantPeriod
    }
    


/*
For reference, the dosesPerDay calculation used with FHIR 
MedicationRequest resources in the CDC Opioid Guidance 
decision support:
*/

/*
MedicationRequest
  dosageInstruction
    timing
      repeat - repeat frequency - frequencyMax times per period
        frequency - number of times per period (lower bound)
        frequencyMax - number of times per period (upper bound, if specified)
        period - duration of the period (e.g. per day, per hour, per week, etc., represented as a UCUM duration quantity)
      code - coded frequency (e.g. BID, TID, QID, etc.)
    asNeeded
    dose - amount of medication per dose, expressed as a range or quantity (e.g. 1 {tab}, 400 mg, etc.)
*/

/*
  Calculates daily frequency given frequency within a period
*/

define function ToDaily(frequency Integer, period System.Quantity):
  case period.unit
    when 'h' then frequency * (24.0 / period.value)
    when 'min' then frequency * (24.0 / period.value) * 60
    when 's' then frequency * (24.0 / period.value) * 60 * 60
    when 'd' then frequency * (24.0 / period.value) / 24
    when 'wk' then frequency * (24.0 / period.value) / (24 * 7)
    when 'mo' then frequency * (24.0 / period.value) / (24 * 30) // assuming 30 days in month
    when 'a' then frequency * (24.0 / period.value) / (24 * 365) // assuming 365 days in year
    else null
  end

/*
This calculation method is using frequency directly to determine the number of doses per day
In the FHIR version, we take the maximum frequency, so we're calculating a maximum expected dosage
*/

define "Example Doses Per Day":
  [MedicationRequest: "Opioid Medications"] M
    let
      // NOTE: Assuming a single dosage instruction element
      dosageInstruction: O.dosageInstruction[0],
      repeat: dosageInstruction.timing.repeat,
      frequency: Coalesce(repeat.frequencyMax.value, repeat.frequency.value),
      period: System.Quantity { value: repeat.period.value, unit: repeat.periodUnit.value }
    return {
      dosesPerDay: Coalesce(OMTKLogic.ToDaily(frequency, period), 1.0)
    }


