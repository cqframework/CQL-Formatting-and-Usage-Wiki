library GeometricMeanOfEncounterLength

using FHIR version '3.0.0'

context Patient

define "Product of Encounter Length":
  Statistics.GeometricMean(
    [Encounter] E
      return all days betweeen E.period."start" and E.period."end"
  )
  
