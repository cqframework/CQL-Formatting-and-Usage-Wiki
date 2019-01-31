/*
Continuing on the Blood Pressure example, the guidance futher indicates that the
blood pressure readings should not come from inpatient or emergency visits.

For blood pressure results, we're pulling them with "Physical Exam, Performed" in
the "Systolic Blood Pressure" and "Diastolic Blood Pressure" value sets:
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

/*
To exclude any readings that happened during an inpatient or emergency department visit,
we can use a without:
*/

define "Systolic Blood Pressure Exam":
  ["Physical Exam, Performed": "Systolic blood pressure"] SystolicBP
    without (
      ["Encounter, Performed": Inpatient]
        union ["Encounter, Performed": "Emergency"]
    ) Encounter
      such that SystolicBP.authorDatetime during Encounter.relevantPeriod
    where SystolicBP.result is not null
      and SystolicBP.result is Quantity
      and SystolicBP.result.unit = 'mm[Hg]'
      and SystolicBP.authorDatetime during "Measurement Period"
      
