library FHIRShared

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

include FHIRCommon called FC

parameter AsOf DateTime default Now()

context Patient

define function Earliest(observations List<Observation>):
  First(
    observations O
      sort by issued
  )

define fluent function earliest(observations List<Observation>):
  First(
    observations O
      sort by issued
  )

define function Latest(observations List<Observation>):
  Last(
    observations O
      sort by issued
  )

define fluent function latest(observations List<Observation>):
  Last(
    observations O
      sort by issued
  )

define function MostRecent(observations List<Observation>):
  Last(
    observations O
      where O.issued on or before AsOf
      sort by issued
  )

define fluent function mostRecent(observations List<Observation>):
  Last(
    observations O
      where O.issued on or before AsOf
      sort by issued
  )

define function Lowest(observations List<Observation>):
  First(
    observations O
      sort by (value as FHIR.Quantity)
  )

define fluent function lowest(observations List<Observation>):
  First(
    observations O
      sort by (value as FHIR.Quantity)
  )

define function Highest(observations List<Observation>):
  Last(
    observations O
      sort by (value as FHIR.Quantity)
  )

define fluent function highest(observations List<Observation>):
  Last(
    observations O
      sort by (value as FHIR.Quantity)
  )

define function ToScore(value Boolean):
  case
    when value is true then 1
    when value is false then 0
    else null
  end

define fluent function toScore(value Boolean):
  case
    when value is true then 1
    when value is false then 0
    else null
  end

define function ToDisplay(value Boolean, displayString String):
  if value is true then
    displayString
  else
    null

define fluent function toDisplay(value Boolean, displayString String):
  if value is true then
    displayString
  else
    null
