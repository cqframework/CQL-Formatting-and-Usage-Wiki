["Encounter, Performed": "Encounter Inpatient" ] Encounter
    where "Encounter.dischargeDisposition" in "Patient Expired"
      and (
        not "Newborn Hearing Screening Left"
          or not "Newborn Hearing Screening Right"
      )

// behavior of with/without is additive
["Encounter, Performed": "Encounter Inpatient" ] Encounter
  without "Newborn Hearing Screening Left" Left such that Left.relevantPeriod during Encounter.relevantPeriod
  without "Newborn Hearing Screening Right" Right such that Right.relevantPeriod during Encounter.relevantPeriod
  where Encounter.dischargeDisposition in "Patient Expired"

define "Encounters Without Left":
  ["Encounter, Performed": "Encounter Inpatient" ] Encounter
    without "Newborn Hearing Screening Left" Left such that Left.relevantPeriod during Encounter.relevantPeriod

define "Encounters Without Right":
["Encounter, Performed": "Encounter Inpatient" ] Encounter
  without "Newborn Hearing Screening Right" Right such that Right.relevantPeriod during Encounter.relevantPeriod

define "Encounters Without Screening":
  "Encounters Without Left" union "Encounters Without Right"

// Multiple withs with the same such that
  ["Encounter, Performed": "Encounter Inpatient"] Encounter
    with ["Medication, Administered": "Aspirin"] Medication such that Encounter.relevantPeriod includes Medication.relevantPeriod
    with ["Medication, Administered": "Antithrombotics"] Medication such that Encounter.relevantPeriod includes Medication.relevantPeriod
    with ["Medication, Administered": "Medication"] Medication such that Encounter.relevantPeriod includes Medication.relevantPeriod
    with ["Medication, Administered": "Medication2"] Medication such that Encounter.relevantPeriod includes Medication.relevantPeriod


define "Medications":
  distinct (
    ["Medication, Administered": "Aspirin"]
      union ["Medication, Administered": "Antithrombotics"]
      union ["Medication, Administered": "Medication"]
      union ["Medication, Administered": "Medication2"]
  )

["Encounter, Performed": "Encounter Inpatient"] Encounter
  with "Medications" Medication such that Encounter.relevantPeriod includes Medication.relevantPeriod
