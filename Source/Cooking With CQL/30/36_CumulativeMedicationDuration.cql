library CumulativeMedicationDuration

using QDM version '5.0.2'

codesystem "EventTiming": 'urn:oid:2.16.840.1.113883.4.642.1.69' // http://hl7.org/fhir/event-timing

code "HS": 'HS' from "EventTiming" // event occurs [offset] before the hour of sleep (or trying to)
code "WAKE": 'WAKE' from "EventTiming" // event occurs [offset] after waking
code "C": 'C' from "EventTiming" //	event occurs at a meal (from the Latin cibus)
code "CM": 'CM' from "EventTiming" //	event occurs at breakfast (from the Latin cibus matutinus)
code "CD": 'CD' from "EventTiming" //	event occurs at lunch (from the Latin cibus diurnus)
code "CV": 'CV' from "EventTiming" //	event occurs at dinner (from the Latin ante cibus vespertinus)
code "AC": 'AC' from "EventTiming" //	event occurs [offset] before a meal (from the Latin ante cibus)
code "ACM": 'ACM' from "EventTiming" //	event occurs [offset] before breakfast (from the Latin ante cibus matutinus)
code "ACD": 'ACD' from "EventTiming" //	event occurs [offset] before lunch (from the Latin ante cibus diurnus)
code "ACV": 'ACV' from "EventTiming" //	event occurs [offset] before dinner (from the Latin ante cibus vespertinus)
code "PC": 'PC' from "EventTiming" //	event occurs [offset] after a meal (from the Latin post cibus)
code "PCM": 'PCM' from "EventTiming" //	event occurs [offset] after breakfast (from the Latin post cibus matutinus)
code "PCD": 'PCD' from "EventTiming" //	event occurs [offset] after lunch (from the Latin post cibus diurnus)
code "PCV": 'PCV' from "EventTiming" //	event occurs [offset] after dinner (from the Latin post cibus vespertinus)

context Patient

/*
 Goal is to get to number of days
 Two broad approaches to the calculation:
  1) Based on supply and frequency, calculate the number of expected days the medication will cover/has covered
  2) Based on relevant period, determine a covered interval and calculate the length of that interval in days
*/

/*
  For the first approach, we need to get from frequency to a frequency/day
  So we define ToDaily
*/

define function ToDaily(Frequency Quantity):
  case Frequency.unit
    when 'h' then (24.0 / Frequency.value)
    when 'min' then (24.0 / Frequency.value) * 60
    when 's' then (24.0 / Frequency.value) * 60 * 60
    when 'd' then (24.0 / Frequency.value) / 24
    when 'wk' then (24.0 / Frequency.value) / (24 * 7)
    when 'mo' then (24.0 / Frequency.value) / (24 * 30) // assuming 30 days in month
    when 'a' then (24.0 / Frequency.value) / (24 * 365) // assuming 365 days in year
    else null
  end

define function ToDaily(Frequency Code):
  case Frequency
    when "C" then 3
    // etc.
    else null
  end

define function ToDaily(Frequency Choice<Quantity, Code>):
  case
    when Frequency is Quantity then ToDaily(Frequency as Quantity)
    else ToDaily(Frequency as Code)
  end

// Calculate cumulative medication duration for a medication order:
  // refills
  // dosage
  // supply
  // frequency
define function CMD(Order "Medication, Order"):
  Order.supply / ToDaily(Order.frequency) * Order.refills
  
// Calculate cumulative medication duration for a medication active:
  // relevantPeriod
  // dosage
  // supply
  // frequency
define function CMD(Medication "Medication, Active"):
  Medication.supply / ToDaily(Medication.frequency)

// Calculate cumulative medication duration for a medication administered:
  // relevantPeriod?
  // dosage
  // supply
  // frequency
define function CMD(Medication "Medication, Administered"):
  Medication.supply / ToDaily(Medication.frequency)
  
// Calculate cumulative medication duration for a medication dispensed:
  // refills
  // dosage
  // supply
  // frequency
define function CMD(Medication "Medication, Dispensed"):
  Medication.supply / ToDaily(Medication.frequency) * Medication.refills
  
// Calculate cumulative medication duration for a medication discharge:
  // refills
  // dosage
  // supply
  // frequency  
define function CMD(Medication "Medication, Discharge"):
  Medication.supply / ToDaily(Medication.frequency) * Medication.refills
  
/*
  For the second approach, assuming we have a relevant period for each data element,
  the cumulative medication duration is just a sum of the number of days in each
  interval in the result of a collapse:
*/
define function CumulativeDuration(Intervals List<Interval<DateTime>>):
  Sum((collapse Intervals) X return all difference in days between start of X and end of X)

define function CMD(Medications List<"Medication, Administered">):
  CumulativeDuration(Medications M return M.relevantPeriod)

  