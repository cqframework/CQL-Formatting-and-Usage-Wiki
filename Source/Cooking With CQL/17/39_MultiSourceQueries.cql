library MultiSourceQueries

// This example is based on issue BONNIE-344: https://oncprojectracking.healthit.gov/support/browse/BONNIE-344

using QDM version '5.0.2'

context Patient

// Initial definition of VTE Prophylaxis using a Multi-source query
define "VTEProphylaxis"
  from 
    "Initial Population" E,
    "Procedure of Anesthesia" P,
    "MedicationVTEProphylaxis" M,
    "DeviceVTEProphylaxis" D
  where M. relevantPeriod starts  1 day or less on or  after day of start of E.relevantPeriod
    or M. relevantPeriod starts 1 day or less on or  after day of end of P.relevantPeriod
    or D. relevantPeriod starts 1 day or less on or  after day of start of E.relevantPeriod
    or D. relevantPeriod starts 1 day or less on or  after day of end of P.relevantPeriod
  return E

// Intent of the logic is:
// Encounters in the initial population that have medication or device VTE prophylaxis
// 1 day or less after the start of the encounter, or the end of an anasthesia procedure during the encounter

// Interpretation of the logic is:
// Encounters in the initial population paired with encounters having anasthesia procedures,
// that have medication AND device VTE prohpylaxis, where the medication prophylaxis starts
// 1 day or less after the start of the encounter, or 1 day or less after the end of the encounter,
// or the device prophylaxis starts 1 day or less after the start of the encounter, or
// 1 day or less after the end of the encounter.

// There are two main issues. First, the Procedure of Anesthesia expression returns
// encounters that have a procedure of anesthesia, but because it is called "Procedure of
// Anesthesia", it seems like it should be procedures, and is used as such in the
// expression. The name of the expression should reflect that it's encounters, rather than
// procedures.

// The second issue is the use of a multi-source query. Multi-source queries start
// by computing the "cartesian product" of the sources, or all possible combinations.
// The problem is that if one of the sources is empty, the result is empty, because
// there are no elements in the empty source to create a combination with.

// What this means in this case is that if the encounter has a medication VTE prophylaxis,
// but no device VTE prophylaxis, then it will not pass the numerator.

// To get an expression of the intent, we need to split the query into different parts:
define "Encounters with Medication VTE Prophylaxis":
  "Initial Population" E
      with "MedicationVTEProphylaxis" M
        such that M.relevantPeriod starts 1 day or less on or after day of start of E.relevantPeriod
          and M.relevantPeriod starts on or after start of E.relevantPeriod
          
define "Encounters with Device VTE Prophylaxis":
  "Initial Population" E
      with "DeviceVTEProphylaxis" D
        such that D.relevantPeriod starts 1 day or less on or after day of start of E.relevantPeriod
          and D.relevantPeriod starts on or after start of E.relevantPeriod

// Note the use of multi-source queries for these parts, because we need to define
// the relationship of the VTE prophylaxis element to both the encounter
// and the anesthesia procedure.
define "Encounters with Anasthesia and Medication VTE Prophylaxis":
  from
    "Initial Population" E,
		["Procedure, Performed": "General or Neuraxial Anesthesia"] P,
    "MedicationVTEProphylaxis" M
	where P.relevantPeriod ends 1 day or less on or after day of start of E.relevantPeriod
		and P.relevantPeriod ends on or after start of E.relevantPeriod
    and M.relevantPeriod starts 1 day or less on or after day of end of P.relevantPeriod
    and M.relevantPeriod starts on or after end of P.relevantPeriod
      
define "Encounters with Anasthesia and Device VTE Prophylaxis":
  from
    "Initial Population" E,
		["Procedure, Performed": "General or Neuraxial Anesthesia"] P,
    "DeviceVTEProphylaxis" D
	where P.relevantPeriod ends 1 day or less on or after day of start of E.relevantPeriod
		and P.relevantPeriod ends on or after start of E.relevantPeriod
    and D.relevantPeriod starts 1 day or less on or after day of end of E.relevantPeriod
    and D.relevantPeriod starts on or after end of E.relevantPeriod

// Then the VTE Prophylaxis expression can be defined as a union of the four components:        
define "Encounters with VTE Prophylaxis":
  "Encounters with Medication VTE Prophylaxis"
    union "Encounters with Device VTE Prophylaxis"
    union "Encounters with Anesthesia and Medication VTE Prophylaxis"
    union "Encounters with Anasthesia and Device VTE Prophylaxis"

