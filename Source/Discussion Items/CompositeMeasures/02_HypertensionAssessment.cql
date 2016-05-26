library 02_HypertensionAssessment

using QDM

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population":
  "In Demographic" and exists ("Valid Encounter During Measurement Period")

define "Denominator":
  true

define "Numerator":
  exists ("Hypertension Assessment")
