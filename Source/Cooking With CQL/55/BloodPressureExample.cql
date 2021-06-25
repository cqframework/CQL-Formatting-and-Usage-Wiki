library BloodPressureExample

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

include MATGlobalCommonFunctionsFHIR4 called Common

code "Birth date": '21112-8' from Common."LOINC" display 'Birth date'
code "Blood pressure": '85354-9' from Common."LOINC" display 'blood pressure'
code "Diastolic blood pressure": '8462-4' from Common."LOINC" display 'Diastolic blood pressure'
code "Systolic blood pressure": '8480-6' from Common."LOINC" display 'Systolic blood pressure'

parameter "Measurement Period" Interval<DateTime> default Interval[@2019-01-01T00:00:00.0, @2020-01-01T00:00:00.0)

context Patient

define "Qualifying Diastolic Blood Pressure Reading":
	["Observation": "Blood pressure"] BloodPressure
	  where BloodPressure.status in {'final', 'amended'}
      and Common."Normalize Interval"(BloodPressure.effective) during "Measurement Period"
      and exists (
        BloodPressure.component DiastolicBP
          where FHIRHelpers.ToConcept(DiastolicBP.code) ~ "Diastolic blood pressure"
            and DiastolicBP.value.code = 'mm[Hg]'
      )

define "Lowest Diastolic Reading on Most Recent Blood Pressure Day":
	First(
    "Qualifying Diastolic Blood Pressure Reading" DBPReading
		  where Common.Earliest(DBPReading.effective) same day as "Most Recent Blood Pressure Day"
      return singleton from (
        DBPReading.component C
          where C.code ~ "Diastolic blood pressure"
          return C.value as FHIR.Quantity
      )
			sort ascending
	)

define "Has Diastolic Blood Pressure Less Than 90":
	"Lowest Diastolic Reading on Most Recent Blood Pressure Day" < 90 'mm[Hg]'


/***** Supporting Definitions *********/

define "Qualifying Systolic Blood Pressure Reading":
	["Observation": "Blood pressure"] BloodPressure
	  where BloodPressure.status in {'final', 'amended'}
      and Common."Normalize Interval"(BloodPressure.effective) during "Measurement Period"
      and exists (
        BloodPressure.component SystolicBP
          where FHIRHelpers.ToConcept(SystolicBP.code) ~ "Systolic blood pressure"
            and SystolicBP.value.code = 'mm[Hg]'
      )

define "Blood Pressure Days":
	( ( "Qualifying Diastolic Blood Pressure Reading" DBPExam
				return date from Common.Earliest(DBPExam.effective)
		)
			intersect ( "Qualifying Systolic Blood Pressure Reading" SBPExam
					return date from Common.Earliest(SBPExam.effective)
			)
	)

define "Most Recent Blood Pressure Day":
	Max("Blood Pressure Days")
