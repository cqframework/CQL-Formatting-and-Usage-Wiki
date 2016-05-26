library 01_ScreeningForAlcoholMisuse

using QDM

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population":
  "In Demographic" and exists ("Valid Encounter During Measurement Period")

define "Denominator":
  true

define "Numerator":
  exists ("Screening For Alcohol Misuse")
