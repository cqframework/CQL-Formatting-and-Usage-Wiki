library DayOrLess

// NOTE: This issue is a proposed resolution to BONNIE-311: https://oncprojectracking.healthit.gov/support/browse/BONNIE-311
// More generally, it is a proposed resolution for timing phrases and calculation expressions throughout the measures

using QDM version '5.0.2'

define "Encounter with Principal Diagnosis of Ischemic Stroke":
  ["Encounter, Performed"]
  
define "Intervention Comfort Measures":
  ["Intervention, Performed"]

// The issue is that the intent of the measure is to consider comfort measures that occurred within a calendar day, regardless of the time component.
// Using the phrase "1 day or less on or after start" uses duration calculations which take the time components into account.
// However, by adding the "day of" qualifier to the timing phrase, we can perform the comparisons at the day precision:

define "Comfort Measures in Encounter": 
  "Encounter with Principal Diagnosis of Ischemic Stroke" NonElectiveEncounter 
    with "Intervention Comfort Measures" ComfortMeasure 
      such that ComfortMeasure.authorDatetime 1 day or less on or after day of start of NonElectiveEncounter.relevantPeriod

  // The timing phrase in the above such that clause renders to the machine readable as:
    // ComfortMeasure.authorDatetime 
      // in (using day) Interval[start of NonElectiveEncounter.relevantPeriod, start of NonElectiveEncounter.relevantPeriod + 1 day]

  // which is defined to evaluate using comparisons at the specified level of precision against the interval boundaries
      
// So, as a specific example, if E is the encounter start time, and A is the intervention author time, we have:

define E1: @2012-10-10T06:16:00Z
define A1: @2012-10-11T11:59:00Z
define Test1: A1 same day or after E1 and A1 same day or before (E1 + 1 day)

// So this approach returns true, and allows us to express the desired intent but still using the timing phrases.

// And another example of a comfort measure occurring on the same day
define E2: @2012-10-10T06:16:00Z
define A2: @2012-10-10T11:59:00Z
define Test2: A2 same day or after E2 and A2 same day or before (E2 + 1 day)

// Note that because we're performing the comparisons at the day precision, a comfort measure
// that occurred _before_ the encounter would also pass. That's not likely to occur in 
// practice for this case, but it's something to keep in mind for this timing pattern.

// Note also the use of "on or after" in the timing phrase. When performing the comparison
// with time values, this is less likely to impact the result, because it's unlikely for
// a comfort measure to have _exactly_ the same time as the start of the encounter. But
// when the comparison is performed at the day precision, it becomes much more significant
// because without it, measures performed on the same day wouldn't count.