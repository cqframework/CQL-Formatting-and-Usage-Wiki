library GroupBy

using FHIR version '4.0.1'

context Patient

define ObservationCountsByCategory:
  [Observation] O
    return {
      category: O.category,
      numberOfObservations: Count([Observation] InnerO where InnerO.category ~ O.category)
    }
