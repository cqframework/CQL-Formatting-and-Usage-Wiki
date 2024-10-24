/*
From CMS832-v2-1-000-QM-5-6.cql
https://ecqi.healthit.gov/sites/default/files/ecqm/measures/CMS832v2-v2.html
*/
library HospitalHarmAcuteKidneyInjury

using QDM version '5.6'

include MATGlobalCommonFunctionsQDM version '8.0.000' called Global

codesystem "AdministrativeGender": 'urn:oid:2.16.840.1.113883.5.1'
codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'

valueset "Body temperature": 'urn:oid:2.16.840.1.113762.1.4.1045.152'
valueset "Creatinine Mass Per Volume": 'urn:oid:2.16.840.1.113762.1.4.1248.21'
valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "High Risk Diagnosis for AKI": 'urn:oid:2.16.840.1.113762.1.4.1248.12'
valueset "High Risk Procedures for AKI": 'urn:oid:2.16.840.1.113762.1.4.1248.19'
valueset "Hospital Based Dialysis Services": 'urn:oid:2.16.840.1.113762.1.4.1248.199'
valueset "Obstetrical or Pregnancy Related Conditions": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.263'
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Payer Type": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Present on Admission or Clinically Undetermined": 'urn:oid:2.16.840.1.113762.1.4.1147.197'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'

code "Female": 'F' from "AdministrativeGender" display 'Female'
code "Heart rate": '8867-4' from "LOINC" display 'Heart rate'
code "Male": 'M' from "AdministrativeGender" display 'Male'
code "Respiratory rate": '9279-1' from "LOINC" display 'Respiratory rate'
code "Systolic blood pressure": '8480-6' from "LOINC" display 'Systolic blood pressure'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  "Initial Population"

define "Denominator Exclusion":
  "Encounter with 0.3 mg dL or More Increase in Creatinine within First 48 Hours"
    union "Encounter with Index eGFR Less Than 60 within First 48 Hours"
    union "Encounter with Less Than 2 Creatinine Results within First 48 Hours"
    union "Encounter with Kidney Dialysis Started 48 Hours or Less After Arrival without High Creatinine"
    union "Encounter with High Risk Diagnosis for AKI"
    union "Encounter with High Risk Procedures for AKI"

define "Encounter with 1.5 Times Serum Creatinine Increase":
  from
    "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] HighCreatinineTest,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] LowCreatinineTest
    let LowCreatinineTestTime: Global."EarliestOf" ( LowCreatinineTest.relevantDatetime, LowCreatinineTest.relevantPeriod ),
    HighCreatinineTestTime: Global."EarliestOf" ( HighCreatinineTest.relevantDatetime, HighCreatinineTest.relevantPeriod ),
    HospitalWithObservation: Global."HospitalizationWithObservation" ( QualifyingEncounter )
    where ( HighCreatinineTest.result.value > "Serum Creatinine Normal" )
      and HighCreatinineTest.result.value = "HighestSerumCreatinine"(QualifyingEncounter)
      and LowCreatinineTest.result.value = "LowestSerumCreatinine"(QualifyingEncounter)
      and "1.5IncreaseInCreatinine"(QualifyingEncounter) >= LowCreatinineTest.result.value
      and LowCreatinineTestTime 7 days or less before HighCreatinineTestTime
      and LowCreatinineTestTime during HospitalWithObservation
      and HighCreatinineTestTime during Interval[start of HospitalWithObservation + 48 hours, start of HospitalWithObservation + 30 days]
      and HighCreatinineTestTime during HospitalWithObservation
    return QualifyingEncounter

define "Encounter with 2 Times Serum Creatinine Increase":
  from
    "Encounter with 1.5 Times Serum Creatinine Increase" EncounterWithHighCreatinine,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] HighCreatinineTest,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] LowCreatinineTest
    let LowCreatinineTestTime: Global."EarliestOf" ( LowCreatinineTest.relevantDatetime, LowCreatinineTest.relevantPeriod ),
    HighCreatinineTestTime: Global."EarliestOf" ( HighCreatinineTest.relevantDatetime, HighCreatinineTest.relevantPeriod ),
    HospitalWithObservation: Global."HospitalizationWithObservation" ( EncounterWithHighCreatinine )
    where ( HighCreatinineTest.result.value > "Serum Creatinine Normal" )
      and HighCreatinineTest.result.value = "HighestSerumCreatinine"(EncounterWithHighCreatinine)
      and LowCreatinineTest.result.value = "LowestSerumCreatinine"(EncounterWithHighCreatinine)
      and "2.0IncreaseInCreatinine"(EncounterWithHighCreatinine) >= LowCreatinineTest.result.value
      and LowCreatinineTestTime before HighCreatinineTestTime
      and LowCreatinineTestTime during HospitalWithObservation
      and HighCreatinineTestTime during Interval[start of HospitalWithObservation + 48 hours, start of HospitalWithObservation + 30 days]
      and HighCreatinineTestTime during HospitalWithObservation
    return EncounterWithHighCreatinine

define "Encounter with High Risk Diagnosis for AKI":
  "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter
    where exists ( QualifyingEncounter.diagnoses HighRiskforAKI
        where HighRiskforAKI.code in "High Risk Diagnosis for AKI"
          and HighRiskforAKI.presentOnAdmissionIndicator in "Present on Admission or Clinically Undetermined"
    )
      and QualifyingEncounter.relevantPeriod during Global."HospitalizationWithObservation" ( QualifyingEncounter )

define "Encounter with High Risk Procedures for AKI":
  "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter
    with ["Procedure, Performed": "High Risk Procedures for AKI"] HighRiskProcedures
      such that Global."NormalizeInterval" ( HighRiskProcedures.relevantDatetime, HighRiskProcedures.relevantPeriod ) starts during Global."HospitalizationWithObservation" ( QualifyingEncounter )

define "Encounter with Index eGFR Less Than 60 within First 48 Hours":
  "Male Encounter with eGFR Less Than 60"
    union "Female Encounter with eGFR Less Than 60"

define "Encounter with Kidney Dialysis Started 48 Hours or Less After Arrival":
  from
    ["Procedure, Performed": "Hospital Based Dialysis Services"] Dialysis,
    "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter
    where Global."NormalizeInterval" ( Dialysis.relevantDatetime, Dialysis.relevantPeriod ) starts during Interval[start of Global."HospitalizationWithObservation" ( QualifyingEncounter ), start of Global."HospitalizationWithObservation" ( QualifyingEncounter ) + 48 hours]
      and Global."NormalizeInterval" ( Dialysis.relevantDatetime, Dialysis.relevantPeriod ) starts during Global."HospitalizationWithObservation" ( QualifyingEncounter )
    return QualifyingEncounter

define "Encounter with Kidney Dialysis Started 48 Hours or Less After Arrival without High Creatinine":
  "Encounter with Kidney Dialysis Started 48 Hours or Less After Arrival" EncounterWithKidneyDialysis48HoursOrAfter
    where not ( exists ( "Encounter with 2 Times Serum Creatinine Increase" EncounterWithHighCreatinine
          where ( EncounterWithHighCreatinine.relevantPeriod includes EncounterWithKidneyDialysis48HoursOrAfter.relevantPeriod )
      )
    )

define "Encounter with Kidney Dialysis Started More Than 48 Hours After Arrival":
  from
    ["Procedure, Performed": "Hospital Based Dialysis Services"] Dialysis,
    "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter
    where Global."NormalizeInterval" ( Dialysis.relevantDatetime, Dialysis.relevantPeriod ) starts during Interval[start of Global."HospitalizationWithObservation" ( QualifyingEncounter ) + 48 hours, end of Global."HospitalizationWithObservation" ( QualifyingEncounter )]
      and Global."NormalizeInterval" ( Dialysis.relevantDatetime, Dialysis.relevantPeriod ) starts during Global."HospitalizationWithObservation" ( QualifyingEncounter )
    return QualifyingEncounter

define "Encounter with Kidney Dialysis Started More Than 48 Hours After Arrival without High Creatinine":
  "Encounter with Kidney Dialysis Started More Than 48 Hours After Arrival" EncounterWithDialysisAfter48Hours
    where not ( exists ( "Encounter with 2 Times Serum Creatinine Increase" EncounterWithHighCreatinine
          where ( EncounterWithHighCreatinine.relevantPeriod includes EncounterWithDialysisAfter48Hours.relevantPeriod )
      )
    )

define "Female Encounter with eGFR Less Than 60":
  "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter
    where "FemaleeGFR"(QualifyingEncounter) is not null
      and "FemaleeGFR"(QualifyingEncounter) as Decimal < 60

define "Increase of 0.3 or More Using First Creatinine within First 48 Hours":
  from
    "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] IndexCreatinineLabResult,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] SubsequentCreatinineLabResult
    let IndexCreatinineLabResultTime: Global."EarliestOf" ( IndexCreatinineLabResult.relevantDatetime, IndexCreatinineLabResult.relevantPeriod ),
    SubsequentCreatinineLabResultTime: Global."EarliestOf" ( SubsequentCreatinineLabResult.relevantDatetime, SubsequentCreatinineLabResult.relevantPeriod ),
    HospitalWithObservation: Global."HospitalizationWithObservation" ( QualifyingEncounter )
    where ( SubsequentCreatinineLabResult.result.value ) - ( IndexCreatinineLabResult.result.value ) > 0.299
      and IndexCreatinineLabResult.result.value = "EarliestSerumCreatinine"(QualifyingEncounter)
      and IndexCreatinineLabResultTime during Interval[SubsequentCreatinineLabResultTime - 48 hours, SubsequentCreatinineLabResultTime]
      and IndexCreatinineLabResultTime during HospitalWithObservation
      and SubsequentCreatinineLabResultTime during Interval[start of HospitalWithObservation, start of HospitalWithObservation + 48 hours]
      and SubsequentCreatinineLabResultTime during HospitalWithObservation
      and IndexCreatinineLabResultTime during Interval[start of HospitalWithObservation, start of HospitalWithObservation + 48 hours]
      and SubsequentCreatinineLabResultTime during Interval[start of HospitalWithObservation, start of HospitalWithObservation + 48 hours]
      and IndexCreatinineLabResult.id != SubsequentCreatinineLabResult.id
    return QualifyingEncounter

define "Increase of 0.3 or More Using Lowest Creatinine within 24 Hours":
  from
    "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] IndexCreatinineLabResult,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] SubsequentCreatinineLabResult
    let IndexCreatinineLabResultTime: Global."EarliestOf" ( IndexCreatinineLabResult.relevantDatetime, IndexCreatinineLabResult.relevantPeriod ),
    SubsequentCreatinineLabResultTime: Global."EarliestOf" ( SubsequentCreatinineLabResult.relevantDatetime, SubsequentCreatinineLabResult.relevantPeriod ),
    HospitalWithObservation: Global."HospitalizationWithObservation" ( QualifyingEncounter )
    where ( SubsequentCreatinineLabResult.result.value ) - ( IndexCreatinineLabResult.result.value ) > 0.299
      and IndexCreatinineLabResult.result.value = "LowestSerumCreatinine"(QualifyingEncounter)
      and IndexCreatinineLabResultTime during Interval[SubsequentCreatinineLabResultTime - 48 hours, SubsequentCreatinineLabResultTime]
      and IndexCreatinineLabResultTime during HospitalWithObservation
      and IndexCreatinineLabResultTime during Interval[start of HospitalWithObservation, start of HospitalWithObservation + 24 hours]
      and SubsequentCreatinineLabResultTime during HospitalWithObservation
      and SubsequentCreatinineLabResultTime during Interval[start of HospitalWithObservation, start of HospitalWithObservation + 48 hours]
      and IndexCreatinineLabResult.id != SubsequentCreatinineLabResult.id
    return QualifyingEncounter

define "Initial Population":
  "Encounter with Creatinine and without Obstetrical Conditions"

define "Male Encounter with eGFR Less Than 60":
  "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter
    where "MaleeGFR"(QualifyingEncounter) is not null
      and "MaleeGFR"(QualifyingEncounter) as Decimal < 60

define "Numerator":
  "Encounter with 2 Times Serum Creatinine Increase"
    union "Encounter with Kidney Dialysis Started More Than 48 Hours After Arrival without High Creatinine"

define "Risk Variable All Encounter Diagnoses with POA Indication":
  "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter
    return Tuple {
      encounterId: QualifyingEncounter.id,
      diagnosiscode: QualifyingEncounter.diagnoses.code,
      POA: QualifyingEncounter.diagnoses.presentOnAdmissionIndicator
    }

define "Risk Variable Estimated Glomerular Filtration Rate for Females":
  "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter
    return Tuple {
      encounterId: QualifyingEncounter.id,
      eGFR: "FemaleeGFR"(QualifyingEncounter)
    }

define "Risk Variable Estimated Glomerular Filtration Rate for Males":
  "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter
    return Tuple {
      encounterId: QualifyingEncounter.id,
      eGFR: "MaleeGFR"(QualifyingEncounter)
    }

define "Risk Variable First Heart Rate in Encounter":
  "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter
    return Tuple {
      encounterId: QualifyingEncounter.id,
      firstHeartRate: "FirstHeartRate"(QualifyingEncounter)
    }

define "Risk Variable First Respiratory Rate in Encounter":
  "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter
    return Tuple {
      encounterId: QualifyingEncounter.id,
      firstRespiratoryRate: "FirstRespiratoryRate"(QualifyingEncounter)
    }

define "Risk Variable First Systolic Blood Pressure in Encounter":
  "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter
    return Tuple {
      encounterId: QualifyingEncounter.id,
      firstSystolicBP: "FirstSystolicBloodPressure"(QualifyingEncounter)
    }

define "Risk Variable First Temperature in Encounter":
  "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter
    return Tuple {
      encounterId: QualifyingEncounter.id,
      firstTemperature: "FirstBodyTemperature"(QualifyingEncounter)
    }

define "SDE Ethnicity":
  ["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer":
  ["Patient Characteristic Payer": "Payer Type"]

define "SDE Race":
  ["Patient Characteristic Race": "Race"]

define "SDE Sex":
  ["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Encounter with Less Than 2 Creatinine Results within First 48 Hours":
  "Encounter with Creatinine and without Obstetrical Conditions" QualifyingEncounter
    where ( Count("CreatinineLabTestwithResultwithinFirst48Hours"(QualifyingEncounter)) < 2 )

define "Encounter with Creatinine and without Obstetrical Conditions":
  "Inpatient Encounter with Creatinine" EncounterWithCreatinine
    where not exists ( EncounterWithCreatinine.diagnoses EncounterDiagnoses
        where EncounterDiagnoses.code in "Obstetrical or Pregnancy Related Conditions"
    )

define "Encounter with 0.3 mg dL or More Increase in Creatinine within First 48 Hours":
  if exists "Increase of 0.3 or More Using Lowest Creatinine within 24 Hours" then "Increase of 0.3 or More Using Lowest Creatinine within 24 Hours" 
    else "Increase of 0.3 or More Using First Creatinine within First 48 Hours"

define "Serum Creatinine Normal":
  if exists ( ["Patient Characteristic Sex": "Female"] ) then 1.02 
    else 1.18

define "Encounter with Age 18 and Length of Stay 48 Hours or More and Male or Female Sex":
  ["Encounter, Performed": "Encounter Inpatient"] InpatientEncounter
    where InpatientEncounter.relevantPeriod ends during day of "Measurement Period"
      and AgeInYearsAt(date from start of InpatientEncounter.relevantPeriod) >= 18
      and duration in hours of Global."HospitalizationWithObservation" ( InpatientEncounter ) >= 48
      and exists ( ( ["Patient Characteristic Sex": "Female"] )
          union ( ["Patient Characteristic Sex": "Male"] )
      )

define "Inpatient Encounter with Creatinine":
  from
    "Encounter with Age 18 and Length of Stay 48 Hours or More and Male or Female Sex" Encounter48Hours,
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] CreatinineTest
    let HospitalizationPeriod: Global."HospitalizationWithObservation" ( Encounter48Hours ),
    CreatinineTestTime: Global."EarliestOf" ( CreatinineTest.relevantDatetime, CreatinineTest.relevantPeriod )
    where CreatinineTest.result is not null
      and CreatinineTestTime during Interval[start of HospitalizationPeriod + 48 hours, end of HospitalizationPeriod]
    return Encounter48Hours

define function "SerumCreatinineSequenceByQuantity"(Encounter "Encounter, Performed"):
  ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] CreatinineTestByQuantity
    where Global."EarliestOf" ( CreatinineTestByQuantity.relevantDatetime, CreatinineTestByQuantity.relevantPeriod ) during Global."HospitalizationWithObservation" ( Encounter )
      and CreatinineTestByQuantity.result.value is not null
    sort by result.value

define function "LowestSerumCreatinine"(QualifyingEncounter "Encounter, Performed"):
  First("SerumCreatinineSequenceByQuantity"(QualifyingEncounter)).result.value

define function "IndexCreatinine"(QualifyingEncounter "Encounter, Performed"):
  Coalesce("LowestSerumCreatinineIn24Hours"(QualifyingEncounter), "FirstSerumCreatinineIn48Hours"(QualifyingEncounter))

define function "HighestSerumCreatinine"(QualifyingEncounter "Encounter, Performed"):
  Last("SerumCreatinineSequenceByQuantity"(QualifyingEncounter)).result.value

define function "FirstRespiratoryRate"(QualifyingEncounter "Encounter, Performed"):
  First(["Physical Exam, Performed": "Respiratory rate"] FirstRespiration
      where Global."EarliestOf"(FirstRespiration.relevantDatetime, FirstRespiration.relevantPeriod) during Global."HospitalizationWithObservation"(QualifyingEncounter)
        and FirstRespiration.result is not null
      sort by Global."EarliestOf"(relevantDatetime, relevantPeriod)
  ).result as Decimal

define function "FirstSystolicBloodPressure"(QualifyingEncounter "Encounter, Performed"):
  First(["Physical Exam, Performed": "Systolic blood pressure"] FirstSystolic
      where Global."EarliestOf"(FirstSystolic.relevantDatetime, FirstSystolic.relevantPeriod) during Global."HospitalizationWithObservation"(QualifyingEncounter)
        and FirstSystolic.result is not null
      sort by Global."EarliestOf"(relevantDatetime, relevantPeriod)
  ).result as Decimal

define function "FirstBodyTemperature"(QualifyingEncounter "Encounter, Performed"):
  First(["Physical Exam, Performed": "Body temperature"] FirstTemperature
      where Global."EarliestOf"(FirstTemperature.relevantDatetime, FirstTemperature.relevantPeriod) during Global."HospitalizationWithObservation"(QualifyingEncounter)
        and FirstTemperature.result is not null
      sort by Global."EarliestOf"(relevantDatetime, relevantPeriod)
  ).result as Decimal

define function "FirstHeartRate"(QualifyingEncounter "Encounter, Performed"):
  First(["Physical Exam, Performed": "Heart rate"] FirstHeartBeats
      where Global."EarliestOf"(FirstHeartBeats.relevantDatetime, FirstHeartBeats.relevantPeriod) during Global."HospitalizationWithObservation"(QualifyingEncounter)
        and FirstHeartBeats.result is not null
      sort by Global."EarliestOf"(relevantDatetime, relevantPeriod)
  ).result as Decimal

define function "EarliestSerumCreatinine"(QualifyingEncounter "Encounter, Performed"):
  First("SerumCreatinineSequencebyTime"(QualifyingEncounter)).result.value

define function "CreatinineLabTestwithResultwithinFirst48Hours"(QualifyingEncounter "Encounter, Performed"):
  from
    ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] CreatinineTest
    where CreatinineTest.result is not null
      and Global."EarliestOf" ( CreatinineTest.relevantDatetime, CreatinineTest.relevantPeriod ) during Interval[start of Global."HospitalizationWithObservation" ( QualifyingEncounter ), start of Global."HospitalizationWithObservation" ( QualifyingEncounter ) + 48 hours]
      and Global."EarliestOf" ( CreatinineTest.relevantDatetime, CreatinineTest.relevantPeriod ) during Global."HospitalizationWithObservation" ( QualifyingEncounter )
    return CreatinineTest

define function "FirstSerumCreatinineIn48Hours"(QualifyingEncounter "Encounter, Performed"):
  First(["Laboratory Test, Performed": "Creatinine Mass Per Volume"] FirstCreatinineTest
      where Global."EarliestOf"(FirstCreatinineTest.relevantDatetime, FirstCreatinineTest.relevantPeriod) during Interval[start of Global."HospitalizationWithObservation"(QualifyingEncounter), start of Global."HospitalizationWithObservation"(QualifyingEncounter) + 48 hours]
        and Global."EarliestOf"(FirstCreatinineTest.relevantDatetime, FirstCreatinineTest.relevantPeriod) during Global."HospitalizationWithObservation"(QualifyingEncounter)
        and FirstCreatinineTest.result is not null
        and "LowestSerumCreatinineIn24Hours"(QualifyingEncounter) is null
      sort by Global."EarliestOf"(relevantDatetime, relevantPeriod)
  ).result as Quantity

define function "LowestSerumCreatinineIn24Hours"(QualifyingEncounter "Encounter, Performed"):
  Min(["Laboratory Test, Performed": "Creatinine Mass Per Volume"] LowCreatinine
      where Global."EarliestOf"(LowCreatinine.relevantDatetime, LowCreatinine.relevantPeriod) during Interval[start of Global."HospitalizationWithObservation"(QualifyingEncounter), start of Global."HospitalizationWithObservation"(QualifyingEncounter) + 24 hours]
        and Global."EarliestOf"(LowCreatinine.relevantDatetime, LowCreatinine.relevantPeriod) during Global."HospitalizationWithObservation"(QualifyingEncounter)
        and LowCreatinine.result is not null
      return LowCreatinine.result as Quantity
  )

define function "1.5IncreaseInCreatinine"(QualifyingEncounter "Encounter, Performed"):
  "HighestSerumCreatinine"(QualifyingEncounter) / 1.5

define function "2.0IncreaseInCreatinine"(QualifyingEncounter "Encounter, Performed"):
  "HighestSerumCreatinine"(QualifyingEncounter) / 2

define function "SerumCreatinineSequencebyTime"(QualifyingEncounter "Encounter, Performed"):
  ["Laboratory Test, Performed": "Creatinine Mass Per Volume"] CreatinineTestByTime
    where Global."EarliestOf" ( CreatinineTestByTime.relevantDatetime, CreatinineTestByTime.relevantPeriod ) during Global."HospitalizationWithObservation" ( QualifyingEncounter )
      and CreatinineTestByTime.result.value is not null
    sort by Global."EarliestOf" ( relevantDatetime, relevantPeriod )

define function "MaleeGFR"(QualifyingEncounter "Encounter, Performed"):
  if exists ( ["Patient Characteristic Sex": "Male"] ) then ( 142 * Min({("IndexCreatinine"(QualifyingEncounter).value / 0.9), 1 }) ^ ( - 0.302 ) * Max({("IndexCreatinine"(QualifyingEncounter).value / 0.9), 1 }) ^ ( - 1.200 ) * 0.9938 ^ ( AgeInYearsAt(start of Global."HospitalizationWithObservation"(QualifyingEncounter)) ) ) 
    else null

define function "FemaleeGFR"(QualifyingEncounter "Encounter, Performed"):
  if exists ( ["Patient Characteristic Sex": "Female"] ) then ( 142 * Min({("IndexCreatinine"(QualifyingEncounter).value / 0.7), 1 }) ^ ( - 0.241 ) * Max({("IndexCreatinine"(QualifyingEncounter).value / 0.7), 1 }) ^ ( - 1.200 ) * 0.9938 ^ ( AgeInYearsAt(start of Global."HospitalizationWithObservation"(QualifyingEncounter)) ) * 1.012 ) 
    else null
