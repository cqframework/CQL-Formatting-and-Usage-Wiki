library AllergyToEggsRevisited

using QDM version '5.3'

valueset "Allergy to Eggs": 'urn:oid:2.16.840.1.113883.3.526.3.1253'

//parameter "Measurement Period" Interval<DateTime>

context Patient

define "Diagnosis of Allergy to Egg":
	["Diagnosis": "Allergy to Eggs"] Dx
		where Dx.prevalencePeriod overlaps "Measurement Period"
			and not ( Dx.prevalencePeriod starts 90 days or more after start of "Measurement Period" )
			and not ( Dx.prevalencePeriod ends 89 days or less after start of "Measurement Period" )

define "Diagnosis of Allergy to Egg (using overlaps)":
  ["Diagnosis": "Allergy to Eggs"] Dx
    where Dx.prevalencePeriod overlaps Date(year from "Measurement Period", 3, 31) //start of "Measurement Period" + 89 days
    
define "Measurement Period": Interval[@2017-01-01, @2018-01-01)

define "Flu Season": Interval[start of "Measurement Period", start of "Measurement Period" + 90 days)

define "Allergy Test Data": {
  { id: 'Allergy Starts Before, Continues Past', period: Interval[@2012-01-01, null] },
  { id: 'Allergy Starts Before, Ends Before', period: Interval[@2012-01-01, @2016-01-01] },
  { id: 'Allergy Starts Before, Ends During', period: Interval[@2012-01-01, @2017-02-21] },
  { id: 'Allergy Starts During, Continues Past', period: Interval[@2017-02-01, null] },
  { id: 'Allergy Starts During, Ends During', period: Interval[@2017-02-01, @2017-02-23] },
  { id: 'Allergy Starts During, Ends After', period: Interval[@2017-02-01, @2017-06-01] },
  { id: 'Allergy Starts After', period: Interval[@2017-04-01, null] },
  { id: 'Allergy Starts After, Ends After', period: Interval[@2017-04-01, @2017-08-01] }
}

define "Test":
  "Allergy Test Data" A
    where A.period overlaps after "Flu Season"

define "Test Starts Before, Continues Past": "Allergy Period Starts Before, Continues Past" overlaps after "Flu Season"
define "Test Starts Before, Ends Before": "Allergy Period Starts Before, Ends Before" overlaps after "Flu Season"




