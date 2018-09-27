library HospitalHarmHyperglycemiainHospitalizedPatients version '0.0.051'

/*
This example is taken from the following JIRA ticket:
https://oncprojectracking.healthit.gov/support/browse/CQLIT-126
*/

using QDM version '5.3'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Glucose Lab Test": 'urn:oid:2.16.840.1.113762.1.4.1045.134' version 'urn:hl7:version:20180706'
valueset "Diabetes": 'urn:oid:2.16.840.1.113883.3.464.1003.103.12.1001' version 'urn:hl7:version:20180706'
valueset "Antidiabetics": 'urn:oid:2.16.840.1.113883.3.1260.1.1978'
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307' version 'urn:hl7:version:eCQM%20Update%202018-05-04'
valueset "Emergency Department Visit": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292' version 'urn:hl7:version:eCQM%20Update%202018-05-04'
valueset "Observation Services": 'urn:oid:2.16.840.1.113762.1.4.1111.143' version 'urn:hl7:version:eCQM%20Update%202018-05-04'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity":
	["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer":
	["Patient Characteristic Payer": "Payer"]

define "SDE Race":
	["Patient Characteristic Race": "Race"]

define "SDE Sex":
	["Patient Characteristic Sex": "ONC Administrative Sex"]

// BTR 2018-09-14: This is the same expression as the initial population, consider reusing the initial population?
define "Eligible Denominator Encounters":
	( ["Encounter, Performed": "Encounter Inpatient"]
		union ["Encounter, Performed": "Emergency Department Visit"]
		union ["Encounter, Performed": "Observation Services"] ) ValidEncounter
		where ValidEncounter.relevantPeriod during "Measurement Period"
			and AgeInYearsAt(start of "Measurement Period")>= 18
      
define "Eligible Initial Population Encounters":
	( ["Encounter, Performed": "Encounter Inpatient"]
		union ["Encounter, Performed": "Emergency Department Visit"]
		union ["Encounter, Performed": "Observation Services"] ) ValidEncounter
		where ValidEncounter.relevantPeriod during "Measurement Period"
			and AgeInYearsAt(start of "Measurement Period")>= 18

define "Existing Diabetes Diagnosis":
	"Eligible Initial Population Encounters" ValidEncounter
		with ["Diagnosis": "Diabetes"] DiabetesDiagnosis
			such that DiabetesDiagnosis.prevalencePeriod starts before 
			end of ValidEncounter.relevantPeriod

define "Initial Elevated Blood Glucose Lab":
	"Eligible Initial Population Encounters" ValidEncounter
		with ["Laboratory Test, Performed": "Glucose Lab Test"] ElevatedBloodGlucoseLab
			such that ElevatedBloodGlucoseLab.resultDatetime during ValidEncounter.relevantPeriod
				and ElevatedBloodGlucoseLab.result > 200 'mg/dL'

define "Overlapping Antidiabetic Medication":
	"Eligible Initial Population Encounters" ValidEncounter
		with ["Medication, Administered": "Antidiabetics"] AntiDiabeticMedication
			such that AntiDiabeticMedication.relevantPeriod overlaps ValidEncounter.relevantPeriod

define function "Blood Glucose Measured"(Qualifying_Encounter "Encounter, Performed", Day Integer):
	["Laboratory Test, Performed": "Glucose Lab Test"] BloodGlucoseLab
		where BloodGlucoseLab.resultDatetime during "Encounter Day"(Qualifying_Encounter, Day)

define function "Blood Glucose Not Measured Exception"(Qualifying_Encounter "Encounter, Performed", Day Integer):
	from
		["Laboratory Test, Performed": "Glucose Lab Test"] BloodGlucoseLab1,
		["Laboratory Test, Performed": "Glucose Lab Test"] BloodGlucoseLab2
		where ( BloodGlucoseLab1.resultDatetime during "Encounter Day"(Qualifying_Encounter, Day - 1)
				and BloodGlucoseLab1.result < 200 'mg/dL'
		)
			and ( BloodGlucoseLab2.resultDatetime during "Encounter Day"(Qualifying_Encounter, Day - 2)
					and BloodGlucoseLab2.result < 200 'mg/dL'
			)
		return BloodGlucoseLab1
	
	/* does it matter what we return? */
// BTR 2018-09-14 ->  No, but this is potentially performing a lot of unnecessary computation
// The reason is that what's happening here is we're asking for the cartesian product of all blood glucose labs
// and then filtering to those on Day - 1 and those on Day - 2.  I think the intent would be more clearly
// communicated by something like:
define function "Non-Elevated Blood Glucose"(QualifyingEncounter "Encounter, Performed", Day Integer):
  ["Laboratory Test, Performed": "Glucose Lab Test"] BloodGlucoseLab
    where BloodGlucoseLab.resultDatetime during "Encounter Day"(QualifyingEncounter, Day)
      and BloodGlucoseLab.result < 200 'mg/dL'
      
define function "Has Blood Glucose Not Measured Exception"(Qualifying_Encounter "Encounter, Performed" Day Integer):
  exists "Non-Elevated Blood Glucose"(QualifyingEncounter, Day - 1)
    and exists "Non-Elevated Blood Glucose"(QualifyingEncounter, Day - 2)
  
define function "Extreme Blood Glucose"(Qualifying_Encounter "Encounter, Performed", Day Integer):
	["Laboratory Test, Performed": "Glucose Lab Test"] ExtremeBloodGlucoseLab
		where ExtremeBloodGlucoseLab.result > 300 'mg/dL'
			and ExtremeBloodGlucoseLab.resultDatetime during "Encounter Day"(Qualifying_Encounter, Day)

// BTR 2018-09-14 -> We shouldn't need to switch to population context, is this intentional?
context Population

define "Initial Population Qualifying Encounters":
	"Eligible Initial Population Encounters"
		intersect ( "Existing Diabetes Diagnosis"
				union "Overlapping Antidiabetic Medication"
				union "Initial Elevated Blood Glucose Lab"
		)

define "Denominator Length in Days":
	"Denominator Qualifying Encounters" QualifyingEncounters
		return "Denominator Observations"(QualifyingEncounters)

define "Initial Population Length in Days":
	"Initial Population Qualifying Encounters" QualifyingEncounters
		return "Initial Population Observations"(QualifyingEncounters)

define "Numerator Hyperglycemic or Not Measured Days":
	"Denominator Qualifying Encounters" QualifyingEncounters
		return "Numerator Observations"(QualifyingEncounters)

// BTR 2018-09-14 -> This is the same criteria as Initial Population Qualifying Encounters, consider reusing?
define "Denominator Qualifying Encounters":
	"Eligible Denominator Encounters"
		intersect ( "Existing Diabetes Diagnosis"
				union "Overlapping Antidiabetic Medication"
				union "Initial Elevated Blood Glucose Lab"
		)

define function "Denominator Observations"(Qualifying_Encounter "Encounter, Performed"):
	Min({(days between(start of Qualifying_Encounter.relevantPeriod + 24 hours)and(
				end of Qualifying_Encounter.relevantPeriod
			)
		), 9 }
	)

// BTR 2018-09-14 -> I thought the intent was to have encounter length in days be the lesser of 10 and the length of the encounter in days?
// The use of Min in this function is effectively not doing anything because the Min is only given one value.
define function "Initial Population Observations"(Qualifying_Encounter "Encounter, Performed"):
	Min({(days between(start of Qualifying_Encounter.relevantPeriod + 24 hours)and(
				end of Qualifying_Encounter.relevantPeriod
			)
		)}
	)

define function "Encounter Length in Days (up to a max of 10)"(QualifyingEncounter "Encounter, Performed"):
  Min(
    {
      days between start of QualifyingEncounter.relevantPeriod and end of QualifyingEncounter.relevantPeriod,
      10
    }
  )

// BTR 2018-09-14 -> 
  // The guidance indicates this includes emergency department and observation status, 
  // should this be using the Hospitalization function?
// BTR 2018-09-14 ->
  // It's not clear what the - 1 hour is doing in this function?
define function "Encounter Day"(Qualifying_Encounter "Encounter, Performed", Day Integer):
	Interval[start of Qualifying_Encounter.relevantPeriod + ( 24 hours * ( Day - 1 ) ), start of Qualifying_Encounter.relevantPeriod + ( ( 24 hours * Day ) - 1 hour )]

define function "Extreme Blood Glucose or Not Measured Day"(Qualifying_Encounter "Encounter, Performed", Day Integer):
	if exists ( "Extreme Blood Glucose"(Qualifying_Encounter, Day))
		or ( not exists ( "Blood Glucose Measured"(Qualifying_Encounter, Day))
        // BTR 2018-09-14 -> Shouldn't this be a "not exists"? Basically, it's okay if they didn't measure on a given day so long as the previous two consecutive days were not elevated?
				and exists ( "Blood Glucose Not Measured Exception"(Qualifying_Encounter, Day))
		) then 1 
		else 0

define function "Numerator Observations"(Qualifying_Encounter "Encounter, Performed"):
	"Extreme Blood Glucose or Not Measured Day"(Qualifying_Encounter, 2)+ 
  "Extreme Blood Glucose or Not Measured Day"(Qualifying_Encounter, 3)+ 
  "Extreme Blood Glucose or Not Measured Day"(Qualifying_Encounter, 4)+ 
  "Extreme Blood Glucose or Not Measured Day"(Qualifying_Encounter, 5)+ 
  "Extreme Blood Glucose or Not Measured Day"(Qualifying_Encounter, 6)+ 
  "Extreme Blood Glucose or Not Measured Day"(Qualifying_Encounter, 7)+ 
  "Extreme Blood Glucose or Not Measured Day"(Qualifying_Encounter, 8)+ 
  "Extreme Blood Glucose or Not Measured Day"(Qualifying_Encounter, 9)+ 
  "Extreme Blood Glucose or Not Measured Day"(Qualifying_Encounter, 10)

// BTR 2018-09-14 -> Not sure if this clearer or not, but consider:
define function "Numerator Days"(QualifyingEncounter "Encounter, Performed"):
  Sum(
    ({ 2, 3, 4, 5, 6, 7, 8, 9, 10 }) Day
      where "Encounter Day"(QualifyingEncounter, Day) during QualifyingEncounter.relevantPeriod // This limits to only those days from 2 through 10 that are actually present for this Encounter
      return "Extreme Blood Glucose or Not Measured Day"(QualifyingEncounter, Day)
  )
  
// BTR 2018-09-14
// Once you have these changes, I was thinking a ratio measure with
// Initial Population - Qualifying Encounters
// Denominator - Qualifying Encounters
// Numerator - Qualifying Encounters
// Denominator Observations - Denominator Days
// Numerator Observations - Numerator Days
// Aggregate Method - Sum

// This should set up a ratio measure where the denominator is the length in days 
// (with a max of 10) of each encounter, across all patients, and the numerator is
// the number of days with extreme blood glucose or blood glucose not measured
// (with a max of 10) of each encounter, across all patients.

