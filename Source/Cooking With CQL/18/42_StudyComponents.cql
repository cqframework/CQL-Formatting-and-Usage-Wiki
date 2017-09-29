library StudyComponents

using QDM version '5.3'

valueset "Macular Exam": '1.1' // { ME001: Macular Exam }
valueset "Retinopathy Severity Finding": '2.1' // { F001: Retinopathy Severity }
valueset "Level of Severity of Retinopathy Findings": '3.1' // { Mild: Mild Retinopathy, Moderate: Moderate Retinopathy, Severe: Severe Retinopathy }
valueset "Macular Edema Finding": '2.2' // { F002: Macular Edema Finding }
valueset "Macular Edema Findings Absent": '3.2' // { Absent: No macular edema findings }
valueset "Macular Edema Findings Present": '3.3' // { Present: Macular edema findings present }

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Appropriate Macular Exam":
  ["Diagnostic Study, Performed": "Macular Exam"] Study
    where exists ( Study.components component1
      where component1.code in "Macular Exam"
        and component1.result in "Level of Severity of Retinopathy Findings"
    )
      and exists ( Study.components component2
        where component2.code in "Macular Exam"
          and ( component2.result in "Macular Edema Findings Absent"
            or component2.result in "Macular Edema Findings Present"
          )
      )

define "Retinopathy Findings":
  ["Diagnostic Study, Performed": "Macular Exam"] Study
    where Study.result in "Level of Severity of Retinopathy Findings"
   
define "Macular Edema Findings":
  ["Diagnostic Study, Performed": "Macular Exam"] Study
    where Study.result in "Macular Edema Findings Absent"
      or Study.result in "Macular Edema Findings Present"
