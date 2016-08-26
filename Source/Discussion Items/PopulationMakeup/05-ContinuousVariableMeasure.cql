library ContinuousVariableMeasure version '1'

using QDM

valueset "Inpatient": '2.16.840.1.113883.3.666.5.307'
valueset "Emergency Department Visit": '2.16.840.1.113883.3.117.1.7.1.293'

parameter "Measurement Period" Interval<DateTime>

/*
  For continuous variable measures, the measure observation is defined as a
  function that takes a single parameter of the type of elements returned by
  the population criteria.

  Each population criteria other than the measure observation must return the
  same type.

  The measure score is described in the population context section below.
*/

context Patient

define "Inpatient Encounters":
	["Encounter, Performed": "Inpatient"] Encounter
		where Encounter.lengthOfStay <= 120 days
			and Encounter.dischargeDatetime during "Measurement Period"

define "Emergency Department Encounters":
	["Encounter, Performed": "Emergency Department Visit"] EmergencyEncounter
		with "Inpatient Encounters" InpatientEncounter
			such that EmergencyEncounter.dischargeDatetime 1 hour or less before InpatientEncounter.admissionDatetime

define "Measure Population":
	"Emergency Department Encounters" Encounter
		where Encounter.admissionDatetime is not null
			and Encounter.dischargeDatetime is not null

define function "Median ED Time"(Encounter "Encounter, Performed")
	return minutes between Encounter.facilityLocationArrivalDatetime and Encounter.facilityLocationDepartureDatetime

// Measure score definition starts here
// NOTE: This is the formal description of the measure score calculation for
// this type of measure. It is the same for all measures of this type, and is
// provided here for reference. It is NOT expected that this calculation be
// included in each measure, with the exception that for continuous variable
// measures, the HQMF itself specifies the aggregation method (Avg in this case).

context Population

define "Measure Score":
  Avg(
    "Measure Population" PopulationMember
      return "Median ED Time"(PopulationMember)
  )
