library OpioidCQM_STU3 version '0.1.0'

using FHIR version '3.0.0'

include OMTKLogic version '0.1.0' called OMTKLogic

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
  Opioid Management Quality Measure
  All patients with an MME > 90 mg during the measurement period
  The measure uses dispense data
*/

define Prescriptions:
  [MedicationDispense] O
    let
      // NOTE: Assuming medication is specified as a CodeableConcept with a single RxNorm code
      rxNormCode: ToCode(O.medicationCodeableConcept.coding[0]),
      medicationName: OMTKLogic.GetMedicationName(rxNormCode),
      // NOTE: Assuming a single dosage instruction element
      dosageInstruction: O.dosageInstruction[0],
      repeat: dosageInstruction.timing.repeat,
      frequency: Coalesce(repeat.frequencyMax, repeat.frequency),
      period: System.Quantity { value: repeat.period, unit: repeat.periodUnit },
      periodDescription:
        ToString(repeat.period) +
          Coalesce(
            '-' + ToString(repeat.periodMax),
            ''
          ) + repeat.periodUnit,
      doseDescription: 
        Coalesce(
          // There should be a conversion from FHIR.SimpleQuantity to System.Quantity
          ToString(ToQuantity(dosageInstruction.doseQuantity)),
          ToString(ToQuantity(dosageInstruction.doseRange.low))
            + '-' + ToString(ToQuantity(dosageInstruction.doseRange.high))
            + dosageInstruction.doseRange.high.unit.value
        ),
      frequencyDescription:
        ToString(dosageInstruction.timing.repeat.frequency.value) +
          Coalesce(
            '-' + ToString(dosageInstruction.timing.repeat.frequencyMax.value),
            ''
          ),
      effectivePeriod: Interval[O.whenHandedOver.value, O.whenHandedOver.value + O.daysSupply.value]
    where O.status.value = 'completed'
      and effectivePeriod overlaps "Measurement Period"
      //and O.whenHandedOver during "Measurement Period"
    return {
      rxNormCode: rxNormCode,
      effectivePeriod: Interval[Max({ start of effectivePeriod, start of "Measurement Period" }), 
        Min({ end of effectivePeriod, end of "Measurement Period" })],
      whenHandedOver: O.whenHandedOver,
      daysSupply: O.daysSupply,
      // NOTE: Assuming asNeeded is expressed as a boolean
      isPRN: dosageInstruction.asNeededBoolean.value,
      prescription:
        if dosageInstruction.text is not null then
          medicationName + ' ' + dosageInstruction.text.value
        else
          // TODO: Shouldn't need the .value here on asNeededBoolean
          medicationName + ' ' + doseDescription + ' q' + frequencyDescription + (if dosageInstruction.asNeededBoolean.value then ' PRN' else ''),
      // TODO: Shouldn't need the ToQuantity here...
      dose: ToQuantity(Coalesce(dosageInstruction.doseQuantity, dosageInstruction.doseRange.high)),
      dosesPerDay: Coalesce(OMTKLogic.ToDaily(frequency, period), 1.0)
    }
    
define OpioidMedications:
  ["Medication, Order": "Opioid Medications"] M

// Prescriptions during the measurement period together with the MME for that prescription
define PrescriptionsWithMME:
  Prescriptions P
    let mme: SingletonFrom(OMTKLogic.CalculateMMEs({ { rxNormCode: P.rxNormCode, doseQuantity: P.dose, dosesPerDay: P.dosesPerDay } }))
    return {
      rxNormCode: P.rxNormCode,
      whenHandedOver: P.whenHandedOver,
      daysSupply: P.daysSupply,
      effectivePeriod: P.effectivePeriod,
      isPRN: P.isPRN,
      prescription: P.prescription,
      dailyDose: mme.dailyDoseDescription,
      conversionFactor: mme.conversionFactor,
      mme: mme.mme
    }
    
// A very simple approach would be to compute the average mme for each RxNormCode and then
// return the sum of the average mmes. This wouldn't always be accurate (it would produce
// false positives), but it wouldn't miss any true positives.

define PrescriptionRanges:
  PrescriptionsWithMME P
    return {
      rxNormCode: P.rxNormCode,
      firstPrescription: First(PrescriptionsWithMME F1 sort by whenHandedOver),
      lastPrescrpition: Last(PrescriptionsWithMME L1 sort by whenHandedOver)
    }
    
define AverageEquivalents:
  PrescriptionRanges R
    return {
      rxNormCode: R.rxNormCode,
      effectivePeriod: Interval[R.firstPrescription.whenHandedOver, R.lastPrescription.whenHandedOver + R.lastPrescription.daysSupply],
      averageMme: firstPrescription.mme + lastPrescription.mme / 2
    }

// A more accurate, but calculation-intensive approach would be to calculate the
// mme for every prescription for every day, sum the values by day, and then
// collapse the days back to the covering intervals.

// This approach would give you a much more accurate result, but it is based on the 
// assumption that the prescription period (and dosing during it) is
// accurate.

define PrescriptionPeriods:
  PrescriptionsWithMME P
    return {
      rxNormCode: P.rxNormCode,
      periods: collapse ( PrescriptionsWithMME R where R.rxNormCode = P.rxNormCode return R.effectivePeriod ),
      mme: P.mme
    }

// { rxNormCode, periods, mme }

define PrescriptionDays:
  PrescriptionPeriods R
    return {
      rxNormCode:
      days: flatten (R.periods I return DaysInInterval(I)) // DaysInInterval returns a list of Dates in the interval
      mme: R.mme
    }

// { rxNormCode, days, mme }
  
define MMEDays:
  flatten (
    PrescriptionDays R
      return all R.days D return { rxNormCode: R.rxNormCode, day: D, mme: R.mme }
  )
  
// { rxNormCode, day, mme }

define MMESum:
  MMEDays D
    return { day: D.day, totalMME: Sum(MMEDays X where X.day = D.day return X.mme) }
    
// { day, mme }

define MMEPeriods:
  MMESum S
    return { periods: collapse (MMESum X where X.mme = S.mme return Interval[day, day]), mme: S.mme  }
    
// { periods, mme }

define MMEIntervals:
  flatten (
    MMEPeriods S
      return all S.periods P return { period: P,  mme: S.mme }
  )

// Potentially confusing syntax...
define MMESum:
  MMEDays D
    group by { D.day } return { totalMME: Sum(D.mme) }
    
define MMEIntervals:
  PrescriptionsWithMME P
    using { P.periods }
    group by { P.periods } add { totalMME: Sum(D.mme) }

// For consistency would need to introduce the using clause to enable temporal queries for all operators
// Would be a significant burden on the engine and implementations
// For not a lot of gain
  
// Returns the total MME for each period covered by any of the given prescriptions  
define function GetMMEIntervals(prescriptions Tuple { rxNormCode Code, periods List<Interval<DateTime>>, mme Quantity }):
    
// { period, mme }

// NOTE: These functions have been moved here from the FHIRHelpers STU3 library to boost performance
define function ToCode(coding FHIR.Coding):
    System.Code {
      code: coding.code.value,
      system: coding.system.value,
      version: coding.version.value,
      display: coding.display.value
    }

define function ToQuantity(quantity FHIR.Quantity):
    System.Quantity { value: quantity.value.value, unit: quantity.unit.value }

