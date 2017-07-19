library LengthOfStay

// NOTE: This is a proposed resolution for BONNIE-301
// https://oncprojectracking.healthit.gov/support/browse/BONNIE-301

using QDM version '5.0.2'

// As we've been discussing, LengthOfStay is a "calculated" value and that 
// presents some challenges when used as an attribute in QDM. An alternative
// is to define a function to calculate the LengthOfStay
// of an encounter or hospitalization.

// The approaches we've been considering this far have used duration:
define function LengthOfStay(Stay Interval<DateTime>):
  duration in days of Stay

// But the intent of the "length of stay" is based on calendar days  
// So we can achieve this by changing the function to use a difference calculation:
define function LengthOfStay(Stay Interval<DateTime>):
  difference in days between start of Stay and end of Stay
  
// This can then be combined with the Hospitalization function to get consistent LengthOfStay treatment:
define "Encounter Less Than Two Days":
  "Encounter With Ischemic Stroke" E
    where LengthOfStay(Hospitalization(E)) < 2

  
