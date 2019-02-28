library DeterminingCoverage

/*
This examples demonstrates the use of the QDM Participation type to determine coverage
The examples here are based on coverage and participation content developed by NCQA
Many thanks for the contribution!
*/

using QDM version '5.3'

valueset "Commercial": 'urn:oid:2.16.840.1.113762.1.4.1165.46'
valueset "Medicaid": 'urn:oid:2.16.840.1.113762.1.4.1165.45'
valueset "Medicare": 'urn:oid:2.16.840.1.113762.1.4.1165.44'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Medicaid Product":
	'medicaid'

define "Commercial Product":
	'commercial'

define "Medicare Product":
	'medicare'

/*
  Report in the product line based on which product they are enrolled in at a given date
	(generally the end of the measurement period) but continuous enrollment calculations
	should consider all participation periods, regardless of product
	
	Input parameters:
    ProductLine: One of 'medicaid', 'commercial', or 'medicare' (use the defined expressions above)
		Index Date: Generally measurement period, but could be tied to an event
		Participation Period: Generally one year, two years, or twenty seven months, but could be based on an event
		Allowed Gap Days: Generally 45 days, but could be 0
*/
define function "Is Enrolled"(ProductLine String, IndexDate DateTime, ParticipationPeriod Interval<DateTime>, AllowedGapDays Integer):
	case
		// If this is not running for a specific product line, ignore enrollment considerations
		when ProductLine is null then true
		else
			// Is the patient enrolled in the given product line on the given index date?
			"Is Enrolled On Date"(ProductLine, IndexDate)
			// Is the patient continuously enrolled in every year of the participation period
			  and AllTrue(
						("Enrollment Periods"(ParticipationPeriod)) EnrollmentPeriod
							return "Is Continuously Enrolled In Period"(EnrollmentPeriod, if duration in months of EnrollmentPeriod >= 6 then AllowedGapDays else 0)
					)
	end

/*	
	Example 1 - One year continuously enrolled
		"Is Enrolled"(ProductLine, end of "Measurement Period", "Measurement Period", 45)
*/

/*		
	Example 2 - Two years continuously enrolled
	  "Is Enrolled"(ProductLine, end of "Measurement Period", Interval[start of "Measurement Period" - 1 year, end of "Measurement Period"], 45)
*/

/*		
	Example 3 - Twenty seven months continuously enrolled
		"Is Enrolled"(ProductLine, end of "Measurement Period", Interval[start of "Measurement Period" - 2 years - 3 months, end of "Measurement Period"], 45)
*/

/*		
	Example 4 - Continuously enrolled surrounding an index event such as a heart attack
		"Is Enrolled"(ProductLine, "Date of Heart Attack", Interval["Date of Heart Attack", "Date of Heart Attack" + 18 months], 45)
*/

/*		
	Example 5 - Continuously enrolled with no gaps during the 9 months prior to a birth and for the following year, allowing for a gap
	  "Is Enrolled"(ProductLine, "Date Of Delivery", Interval["Date Of Delivery" - 9 months, "Date Of Delivery"], 0)
		  and "Is Enrolled"(ProductLine, "Date Of Delivery", Interval["Date Of Delivery", "Date Of Delivery" + 1 year], 45)
*/


/*
Returns true if there is a participation record for the given product line that
includes the given index date
*/
define function "Is Enrolled On Date"(ProductLine String, IndexDate DateTime):
  exists (
		(
			case ProductLine
			  when "Commercial Product" then ["Participation": "Commercial"]
				when "Medicare Product" then ["Participation": "Medicare"]
				when "Medicaid Product" then ["Participation": "Medicaid"]
				else null
			end
		) P
			where IndexDate during P.participationPeriod
	)

/*
Returns enrollment periods of up to a year ending at the end of the participation period.
Note that this will not return more than 3 years (would need the expand from 1.3 to support more generally)

For example, given the following participation period:

        10/1/16 1/1/17       1/1/18      12/31/18
            [---||------------||------------]

The function will return the following enrollment periods:

            [---][------------][------------]
						
In values:
Participation Period: Interval[@2016-10-01, @2018-12-31]
Enrollment Periods: { Interval[@2016-10-01, @2016-12-31], Interval[@2017-01-01, @2017-12-31] Interval[@2018-01-01, @2018-12-31] }
*/
define function "Enrollment Periods"(ParticipationPeriod Interval<DateTime>):
  ( { 3 years, 2 years, 1 year } ) Year
	  where end of ParticipationPeriod - (Year - 1 year) after start of ParticipationPeriod
	  return 
		  Interval[
		    Max({ successor of (end of ParticipationPeriod - Year), start of ParticipationPeriod }), 
				end of ParticipationPeriod - (Year - 1 year)
			]

/*
Returns all Commercial, Medicaid, and Medicare participation for the patient
*/
define "Participation":
  ["Participation": "Commercial"]
	  union ["Participation": "Medicaid"]
		union ["Participation": "Medicare"]

/*
Returns the periods during which the patient had coverage during the given participation period	
*/
define function "Participation In Period"(ParticipationPeriod Interval<DateTime>):
	collapse (
		Participation P
			let I: P.participationPeriod intersect ParticipationPeriod
			where P.participationPeriod overlaps ParticipationPeriod
			return all Interval[ToDate(start of I), predecessor of (ToDate(end of I) + 1 day)]
	)

/*
Returns the number of gap days in the given coverage periods, allowing only one gap.
If there is more than one gap, returns the maximum Integer
*/
define function "Gap Days In Period"(ParticipationPeriod Interval<DateTime>, Periods List<Interval<DateTime>>):
		case Count(Periods)
			when 1 then
			  if Periods[0] starts day of ParticipationPeriod then
				  difference in days between end of Periods[0] and end of ParticipationPeriod
			  else if Periods[0] ends day of ParticipationPeriod then
				  difference in days between start of ParticipationPeriod and start of Periods[0]
			  else 
				  maximum Integer
			when 2 then
			  if Periods[0] starts day of ParticipationPeriod and Periods[1] ends day of ParticipationPeriod then
				  difference in days between end of Periods[0] and start of Periods[1]
			  else
				  maximum Integer
			else
			  maximum Integer
		end

define function "Is Continuously Enrolled In Period"(EnrollmentPeriod Interval<DateTime>, AllowedGapDays Integer):
	"Gap Days In Period"(EnrollmentPeriod, "Participation In Period"(EnrollmentPeriod)) <= AllowedGapDays

