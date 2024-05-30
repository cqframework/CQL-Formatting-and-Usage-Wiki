library Q45_exercise_2 version '0.0.1'
using FHIR version '4.0.1'
include FHIRHelpers version '4.0.1' called FHIRHelpers
codesystem "ActCode": 'http://terminology.hl7.org/CodeSystem/v3-ActCode'
codesystem "LOINC": 'http://loinc.org'
code "Body Weight": '29463-7' from "LOINC" display 'Body weight'
code "Ambulatory Encounter": 'AMB' from "ActCode" display 'Ambulatory Encounter'

context Patient

define AllObservations:
  // GET Observation?patient={Context.patient}
  [Observation]

define "Weight Observations":
  // GET Observation?patient={Context.patient}&code=http://loinc.org|29463-7
  // code ~ "Body Weight"
  [Observation: "Body Weight"]

// Added `.value` to the `sort by effective`
define "Last body weight observation":
   // GET Observation/$lastn?max=1&patient={Context.patient}&code=http://loinc.org|29463-7&status=final,amended,corrected
   // sort acsending, return Last
   Last([Observation: "Body Weight"] O
         where O.status in { 'final', 'amended', 'corrected' }
         sort by effective.value ascending)

define "Last known body weigth":
    //return value (Quantity type) rather than full resource
    FHIRHelpers.ToQuantity("Last body weight observation".value)

// Updated `60000 'g'` to `60 'kg'`
define "Last known body weigth exceeds 60 kg":
    //return value (Quantity type) rather than full resource
    // note that the type cast is not necessary
    "Last body weight observation".value > 60 'kg'

