//
// https://oncprojectracking.healthit.gov/support/browse/CQM-3414

/*
Guidance says:  If there are multiple blood pressure readings on the same day, 
use the lowest systolic and the lowest diastolic reading as the most recent blood 
pressure reading. But the logic is using the most recent:
*/

define "Diastolic Blood Pressure Exam":
	["Physical Exam, Performed": "Diastolic blood pressure"] DiastolicBP
		where DiastolicBP.result is not null
			and DiastolicBP.authorDatetime during "Measurement Period"

define "Has Diastolic Blood Pressure Less Than 90":
	Last("Diastolic Blood Pressure Exam" LastDiastolicBP
			with "Most Recent Visit With Blood Pressure" HypertensionNumeratorEncounter
				such that LastDiastolicBP.relevantPeriod during HypertensionNumeratorEncounter.relevantPeriod
			sort by start of relevantPeriod
	).result < 90 'mm[Hg]'

/*
Note that this measure is changing this year to focus on whether the readings 
are on the same "day", rather than using the "visit" as the grouper for the readings,
so this restatement will focus on the readings on the same day

For this measure, we are just looking for the most recent blood pressure, where the
day has both systolic and diastolic readings.
*/

define "Diastolic Blood Pressure Exam":
	["Physical Exam, Performed": "Diastolic blood pressure"] DiastolicBP
		where DiastolicBP.result is not null
      and DiastolicBP.result is Quantity
      and DiastolicBP.result.unit = 'mm[Hg]'
			and DiastolicBP.authorDatetime during "Measurement Period"

define "Systolic Blood Pressure Exam":
	["Physical Exam, Performed": "Systolic blood pressure"] SystolicBP
		where SystolicBP.result is not null
      and SystolicBP.result is Quantity
      and SystolicBP.result.unit = 'mm[Hg]'
			and SystolicBP.authorDatetime during "Measurement Period"

define "Blood Pressure Days":
  ("Diastolic Blood Pressure Exam" D return date from D.authorDatetime)
    intersect ("Systolic Blood Pressure Exam" S return date from S.authorDatetime)
    
define "Most Recent Blood Pressure Day":
  Last("Blood Pressure Days" D
    order by authorDatetime
  )

define "Lowest Diastolic on Most Recent Blood Pressure Day":
  First("Diastolic Blood Pressure Exam" D
    where D.authorDatetime same day as "Most Recent Blood Pressure Day"
    order by result as Quantity
  )
  
define "Lowest Systolic on Most Recent Blood Pressure Day":
  First("Systolic Blood Pressure Exam" S
    where S.authorDatetime same day as "Most Recent Blood Pressure Day"
    order by result as Quantity
  )

  
    
