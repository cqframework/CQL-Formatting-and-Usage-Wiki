/*
  The general problem is the attempt to access components of results like Diagnostic Studies,
  Laboratory Panels, and Assessments. These structures all have a parent-child aspect that
  cannot be represented accurately with current QDM.

  The current solution has been to focus on the individual elements, but this doesn't give a
  way to calculate when the basis is the report itself (i.e. there's no way to express that
  the components are part of a particular parent element).

  A potential solution enabled by CQL is to introduce a list-valued attribute:

  Laboratory Test, Performed {
    code, // This is then the panel code
    relevantPeriod,
    result,
    components: {
      code, // individual results, this is the code
      result // this is the individual result
    }
  }

  For illustration, this example will use the Lipid Panel and LDL Result such as the following pseudo-QDM:

    "Laboratory Test, Performed: Lipid Panel (result: LDL, result: <130mg/dL)"

*/

define "Lipid Panel":
  ["Laboratory Test, Performed": "Lipid Panel Value Set"]

define "LDL Result":
  "Lipid Panel" Panel
    return singleton from (
      Panel.components Component
        where Component.code in "LDL Result"
          and Component.result < 130 'mg/dL'
    )

define "Macular Exam With Expected Results":
  ["Diagnostic Study, Performed": "Macular Exam"] Exam
    where exists (
      Exam.component Component
        where Component.code = "Severity of Retinopathy"
          and Component.result is not null
    )
    and exists (
      Exam.component Component
        where Component.code = "Macular Edema"
          and (
            Component.result in "Macular Edema Presence"
              or Component.result in "Macular Edema Absence"
          )
    )
