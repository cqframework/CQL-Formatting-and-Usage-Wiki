// Two unilateral mastectomies 14 or more days apart

define "Unilateral Mastectomies":
  ["Procedure": code in "Unilateral Mastectomy"]

define "Unilateral Mastectomy Pairs":
  from
    "Unilateral Mastectomies" P1,
    "Unilateral Mastectomies" P2
  where days between P1.performedDateTime and P2.performedDateTime >= 14

define "Unique Unilateral Mastectomy Pairs":
  "Unilateral Mastectomy Pairs" P
    without "Unilateral Mastectomy Pairs" D
      such that (P.P1.id = D.P1.id and P.P1.performedDateTime < D.P2.performedDateTime)
        or P.P1.id = D.P2.id

// Equivalent formulation using First...
define "Unilateral Mastectomy Pairs":
  "Unilateral Mastectomies" P1
    return {
      P1: P1,
      P2: First(
            "Unilateral Mastectomies" P2
              where days between P1.performedDateTime and P2.performedDateTime >= 14
              sort by performedDateTime
          )
    }

define "Unique Unilateral Mastectomy Pairs":
  "Unilateral Mastectomy Pairs" P
    without "Unilateral Mastectomy Pairs" D
      such that D.P1.id = P.P2.id
