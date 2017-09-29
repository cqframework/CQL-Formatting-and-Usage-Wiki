library Diagnoses

// https://oncprojectracking.healthit.gov/support/browse/CQLIT-65

using QDM version '5.3'

valueset "Encounter Inpatient": 'urn:oid:2.16.840.1.113883.3.666.5.307'
valueset "Single Live Birth": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.25'
valueset "Single Live Born Newborn Born in Hospital": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.26'
valueset "Gestational Diabetes": '1.2.3'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Inpatient-Encounter":
	["Encounter, Performed": "Encounter Inpatient"] Encounter
		where Encounter.lengthOfStay <= 120 days
			and Encounter.relevantPeriod ends during "Measurement Period"

define "Single-Live-Birth-Diagnosis":
	["Diagnosis": "Single Live Birth"]
			union ["Diagnosis": "Single Live Born Newborn Born in Hospital"]

/*
define "Single-Live-Birth-Encounter":
	distinct(("Inpatient-Encounter" Encounter
				where Encounter.diagnoses in "Single Live Birth"
					or Encounter.diagnoses in "Single Live Born Newborn Born in Hospital"
		)
			union("Inpatient-Encounter" Encounter
					with "Single-Live-Birth-Diagnosis" D
						such that D.prevalencePeriod starts during Encounter.relevantPeriod
			)
	)
*/

define "Single-Live-Birth-Encounter":
  ("Inpatient-Encounter" Encounter
    where exists (Encounter.diagnoses Diagnosis 
      where Diagnosis in "Single Live Birth"
        or Diagnosis in "Single Live Born Newborn Born in Hospital"
    )
  )
    union (
      "Inpatient-Encounter" Encounter
        with "Single-Live-Birth-Diagnosis" D
          such that D.prevalencePeriod starts during Encounter.relevantPeriod
    )

// Or Example:

define "Single Live Birth Encounter Or Gestational Diabetes":
  "Inpatient-Encounter" Encounter
    where exists (Encounter.diagnoses Diagnosis 
      where Diagnosis in "Single Live Birth"
        or Diagnosis in "Gestational Diabetes"
    )

// And Example

define "Single Live Birth Encounter And Gestational Diabetes":
  "Inpatient-Encounter" Encounter
    where exists (Encounter.diagnoses Diagnosis 
      where Diagnosis in "Single Live Birth"
    )
      and exists (Encounter.diagnoses Diagnosis
        where Diagnosis in "Gestational Diabetes"
      )

