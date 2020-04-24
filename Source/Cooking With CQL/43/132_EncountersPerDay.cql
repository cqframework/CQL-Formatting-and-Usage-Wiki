library EncountersPerDay

/*
Question about capturing encounters per day.
Credit to Peter Muir for the response, thank you!
*/

using QDM version '5.5'

valueset "Face to Face Interaction - No ED": 'urn:oid:2.16.840.1.113762.1.4.1080.2'
valueset "Office Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Outpatient Consultation": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1008'
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services - Other": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1030'
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1023'

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
I have a question about how to best express logic needed for a quality measure
that only should return one encounter per day for a given patient. I would like
the expression to return one encounter ID per day (no preference is given to
which encounter ID); the measure is running in the Patient context.

Currently, I have implemented it like this:
*/

define "Deduplicated Ambulatory Numerator":
  "Ambulatory Numerator" N1
    with "Ambulatory Numerator" N2
      such that ( ( IndexOf("Ambulatory Numerator", N2) + 1 = IndexOf("Ambulatory Numerator", N1) )
        and not ( end of N1.relevantPeriod = end of N2.relevantPeriod ) )
          or IndexOf("Ambulatory Numerator", N1) = 1

/*
In the example, “ED Numerator” is a list of ED encounters (assume it’s a list of encounter IDs)
that meet the measure criteria sorted in ascending order by the end of the period attribute.

Is my solution a good way to go about this? Does this come up often in quality
measures running over data sets that aggregate across multiple data sources?
Is there a better way to return one encounter per day?

If I were writing in SQL I would do:

Select max( N1.EncounterId ) EncounterId,
           End of N1.period EncounterDate
  From “ED Numerator” N1
  Group by end of N1.period
*/

/*
In CQL, as in SQL, there are many pathways to a solution that depend upon the
constraint filters applied to target data elements to meet the measure intent.
For simplicity, this will focus on the Quality Data Model.
I have provided examples of different use cases to emphasize different approaches.

In the snippets, "Measure Assessment Period" represents the target time period
definition or time interval (day in your case).
*/

define "Measure Assessment Period": Interval[@2020-04-01, @2020-04-01]

// Use case 0 – did an office visit occur during a specific period of time for a given patient? (true/false):
define "Qualifying Encounters":
    exists ( ["Encounter, Performed": "Face to Face Interaction - No ED"]
      union ["Encounter, Performed": "Office Visit"]
      union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
      union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
      union ["Encounter, Performed": "Outpatient Consultation"]
      union ["Encounter, Performed": "Preventive Care Services - Other"] ) ValidEncounter
        where ValidEncounter.relevantPeriod during "Measure Assessment Period"

/*
Note that this looks for typical "Office Visit" types to eliminate ambulatory encounters
such as imaging visits, laboratory visits, physiotherapy, etc.; however, it will
miss pediatric visits, tele-medicine and other ambulatory encounters.
It is possible to add other "Encounter, Performed" visit types by adding other
visit types on by creating or using a broader VSAC value set.
*/

// Use case 1 - return just the last office visit that ended during the target time period for a given patient:
define "Qualifying Encounters - 2":
    Last (
      ["Encounter, Performed": "Office Visit"] ValidEncounter
        where ValidEncounter.relevantPeriod during "Measure Assessment Period"
        sort by end of relevantPeriod
    )

/*
Note that it is conceivable that an encounter on day 1 but not closed until day 2
could be masked by another encounter on day 2 that was closed on day 2.
*/

// Use case 2 - return one encounter per day for a given patient (ambulatory) at a specific location:
/*
It is possible for a patient to see Provider A and Provider B at another location
but on the same EHR network.  In your and the above example, only the last one
would be captured.  It is possible to constrain by Encounter.location if so required.
(In a similar fashion, encounters could be constrained by diagnosis, procedure, etc.)
*/

// Use case 3 - return one encounter per day for a given patient over a target period of time such as number of encounter days over a 90 day time period:

define "Ambulatory Numerator Days":
  "Ambulatory Numerator" N
    return date from start of N.relevantPeriod

define OneEncounterPerDay:
  "Ambulatory Numerator Days" D
    return Last(
      "Ambulatory Numerator" N
        where N.relevantPeriod starts same day as D
        sort by end of relevantPeriod
    )

// Use case 4 - return number of encounters on a day over a target period of time

define "Measurement Period Days":
  expand { "Measurement Period" } per day

define "Number Of Encounters Per Day":
  "Measurement Period Days" D
    return {
      encounterDay: point from D,
      numberOfEncounters: Count(
        "Ambulatory Numerator" N
          where N.relevantPeriod starts same day as point from D
    )}

/* Supplemental definition to support translation */
define "Ambulatory Numerator": ["Encounter, Performed"]
