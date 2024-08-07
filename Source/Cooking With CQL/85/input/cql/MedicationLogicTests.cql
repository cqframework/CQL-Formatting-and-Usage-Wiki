library MedicationLogicTests

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

include MedicationLogic called ML

context Patient

/*
# Example 1:
MedicationRequest 2 tabs 3x/day   #180/2
* dosage = 2
* frequency = 3x /day (i.e., repeats / period = day)
* supply = 180
* daysSupplied = 30 days
* refills = 2

derived daysSupplied = [supply (180) / ((dosage (2) x frequency (3))] = 30
daysSuppliedWithRefills = [supply (180) x (1 + refills (2)) / ((dosage (2) x frequency (3))] = 30 x 3 = 90 days
daily dose = 6 tabs
*/

/*
## Example 1a - boundsPeriod specified

## Example 1b - expectedSupplyDuration specified

## Example 1c - Calculated from dosing information
*/

/*
# Example 2:
MedicationDispense 2 tabs 3x/day #180/2*
* dosage = 2
* frequency = 3x /day (i.e., repeats / period = day)
* supply = 180
* daysSupplied = 30 days
* refills = n/a

derived daysSupplied = [supply (180) / ((dosage (2) x frequency (3))] = 30
daily dose = 6 tabs
*/

/*
## Example 2a - daysSupply Specified

## Example 2b - Calculated from dosing information
*/

/*
# Example 3:
MedicationRequest ½ tab 2x/day #30/2
* dosage = 1/2
* frequency = 2x /day (i.e., repeats / period = day)
* supply = 30
* daysSupplied = 30
* refills = 2

derived daysSupplied = [supply (30) / ((dosage (1/2) x frequency (2))] = 30
daysSuppliedWithRefills = [supply (30) x (1 + refills (2)) / ((dosage (1/2) x frequency (2) = 30 x 3 = 90 days
daily dose = 1 tab
*/

/*
## Example 3a - boundsPeriod specified

## Example 3b - expectedSupplyDuration specified

## Example 3c - Calculated from dosing information
*/

/*4
# Example 4:
MedicationDispense ½ tab 2x/day #30/2*
* dosage = 1/2
* frequency = 2x /day (i.e., repeats / period = day)
* supply = 30
* daysSupplied = 30
* refills = n/a

derived daysSupplied = [supply (30) / ((dosage (1/2) x frequency (2))] = 30
daily dose = 1 tab
*/

/*
## Example 4a - daysSupply Specified

## Example 4b - Calculated from dosing information
*/

/*
# Example 5:
MedicationRequest 5 ml 3x/day  #150 ml/0
* dosage = 5 ml
* frequency = 3x /day (i.e., repeats / period = day)
* supply = 150 ml
* daysSupplied = 10
* refills = 0

derived daysSupplied = [supply (150 ml) / ((dosage (5 ml) x frequency (3)) = 10 days
daysSuppliedWithRefills = [supply (150 ml) x (1 + refills (0)) / ((dosage (5 ml) x frequency (3)) = 10 days
daily dose = 15 ml
*/

/*
# Example 6:
MedicationDispense 5 ml 3x/day  #150 ml/0*
* dosage = 5 ml
* frequency = 3x /day (i.e., repeats / period = day)
* supply = 150 ml
* daysSupplied = 10
* refills = n/a

daily dose = 15 ml

CMD calculated for “Medication, Dispensed” does not use the number of refills; rather, the days covered by each dispensing event must be retrieved and added.
*/

define Prescriptions: [MedicationRequest]
define Dispenses: [MedicationDispense]

define PrescriptionDailyDoses:
  Prescriptions P
    return P.dailyDose()

define PrescriptionPeriods:
  Prescriptions P
    return P.medicationRequestPeriod()

define DispenseDailyDoses:
  Dispenses D
    return D.dailyDose()

define DispensePeriods:
  Dispenses D
    return D.medicationDispensePeriod()

define CumulativeDuration:
  (PrescriptionPeriods union DispensePeriods).cumulativeDuration()
