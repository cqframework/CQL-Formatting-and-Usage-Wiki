library 04_ScreeningForColorectalCancer

using QDM

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population":
  "In Demographic" and exists ("Valid Encounter During Measurement Period")

define "Denominator":
  true

define "Numerator":
  exists ("Screening For Colorectal Cancer")
