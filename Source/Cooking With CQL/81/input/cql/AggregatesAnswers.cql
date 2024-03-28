library AggregatesAnswers

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

context Patient

/*
1. How many observations does this patient have?
*/

define NumberOfObservations: Count([Observation])

/*
2. How many observations have an encounter?
*/

define NumberOfObservationsWithEncounters: Count(
  [Observation] O
    where O.encounter is not null
  )

/*
3. How many different kinds of observations does this patient have?
*/

define NumberOfKindsOfObservations: Count(
  [Observation] O
    return O.code
  )

/*
4. How many of each kind of observation does this patient have?
*/

define NumberOfObservationsPerCode:
  [Observation] O
    return {
      code: O.code,
      numberOfObservations: Count([Observation] InnerO where InnerO.code ~ O.code)
    }

/*
5. Which kinds of observations have more than one observation?
*/

define ObservationCodesWithMultipleObservations:
  (
    [Observation] O
      return {
        code: O.code,
        numberOfObservations: Count([Observation] InnerO where InnerO.code ~ O.code)
      }
  ) ObservationsPerCode
    where ObservationsPerCode.numberOfObservations > 1

define Question5Alternate:
  NumberOfObservationsPerCode O
    where O.numberOfObservations > 1

/*
6. How many kinds of observations have more than one observation?
*/

define NumberOfObservationCodesWithMultipleObservations: Count(
    (
      [Observation] O
        return {
          code: O.code,
          numberOfObservations: Count([Observation] InnerO where InnerO.code ~ O.code)
        }
    ) NumberOfObservationsPerCode
      where NumberOfObservationsPerCode.numberOfObservations > 1
  )

define Question6Alternate:
  Count(ObservationCodesWithMultipleObservations)

/*
7. For each kind of observation with more than one observation, what is the date and result of the most recent observation?
*/

define MostRecentDateAndResultPerObservationCodeWithMultipleObservations:
  ObservationCodesWithMultipleObservations ObsCodes
    let MostRecentObservation:
      First(
        [Observation] O
          where O.code ~ ObsCodes.code
          sort by FHIRHelpers.ToDateTime(effective as dateTime) desc
      )
    return {
      code: ObsCodes.code,
      effective: MostRecentObservation.effective,
      value: MostRecentObservation.value
    }
