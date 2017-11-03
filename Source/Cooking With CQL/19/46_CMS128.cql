library AMM128 version '0.0.011'

// This example is an excerpt of CMS128
// Only the relevant logic is included

using QDM version '5.3'

valueset "Antidepressant Medication": 'urn:oid:2.16.840.1.113883.3.464.1003.196.12.1213'
valueset "Major Depression": 'urn:oid:2.16.840.1.113883.3.464.1003.105.12.1007'

parameter "Measurement Period" Interval<DateTime>

context Patient

// Consider using an Interval expression here to make the range more clear
define "Medication Dispensed 270 days before or 90 days after Start of Measurement Period":
	First(["Medication, Dispensed": "Antidepressant Medication"] DepMedDisp
			//where DepMedDisp.authorDatetime 270 days or less before start of "Measurement Period"
				//or DepMedDisp.authorDatetime 90 days or less after start of "Measurement Period"
				//or DepMedDisp.authorDatetime same as start of "Measurement Period"
			where DepMedDisp.authorDatetime in Interval[start of "Measurement Period" - 270 days, start of "Measurement Period" + 90 days]
			sort by authorDatetime
  )

// Use a within to make the range more clear
define "Initial Major Depression Diagnosis":
	First(["Diagnosis": "Major Depression"] Dx
			with "Medication Dispensed 270 days before or 90 days after Start of Measurement Period" Med
				//such that Dx.prevalencePeriod starts 60 days or less before Med.authorDatetime
				//	or Dx.prevalencePeriod starts 60 days or less after Med.authorDatetime
				such that Dx.prevalencePeriod within 60 days of Med.authorDatetime
			sort by start of prevalencePeriod
	) is not null

