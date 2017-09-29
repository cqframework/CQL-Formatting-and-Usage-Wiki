library LocationPeriod

using QDM version '5.3'

valueset "Inpatient Encounter": '1.2.3'
valueset "ED": '4.5.6'
valueset "ICU": '7.8.9'

//define "Measure Observation":
//  duration in minutes of "Related ED Visit"(Encounter). locationPeriod

// Arrival time: earliest start of a location period for any facility location
// Departure time: latest end of a location period for any facility location
define function "Arrival And Departure Time"(Encounter "Encounter, Performed"):
  Interval
  [
    First(Encounter.facilityLocations Location 
      return start of Location.locationPeriod sort ascending),
    Last(Encounter.facilityLocations Location 
      return end of Location.locationPeriod sort ascending)
  ]
  
//define "Measure Observation":
//    duration in minutes of "Arrival And Departure Time"("Related ED Visit"(Encounter))
    
// Location-specific period
define "Encounters with ICU over 2 days":
  ["Encounter, Performed": "Inpatient Encounter"] Encounter
    where exists (Encounter.facilityLocations Location
      where Location.code in "ICU"
        and duration in days of Location.locationPeriod >= 2
    )

    
