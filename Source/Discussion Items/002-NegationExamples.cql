Current consensus approach:

// Returns _all_ encounters, "negated" or not
["Encounter, Performed": "Inpatient"]

// Returns encounters _without_ a negation rationale (meaning they have not been "negated")
["Encounter, Performed": "Inpatient"] Encounter
  where Encounter.negationRationale is null

// Returns encounters _with_ a negation rationale (meaning they have been "negated")
["Encounter, Performed": "Inpatient"] Encounter
  where Encounter.negationRationale is not null

// Returns encounters with a _specific_ negation rationale
["Encounter, Performed": "Inpatient"] Encounter
  where Encounter.negationRationale in "Medical Reason"

not exists ( ["Encounter, Performed": "Inpatient"] Encounter where Encounter.principalDiagnosis in "Diabetes" )

["Laboratory Test, Performed"] LaboratoryTest where LaboratoryTest.result is null

["Not Applied"]
["Not Dispensed"]
["Not Administered"]
["Not Ordered"]
["Not Performed"]
["Not Recommended"]
["Not Communicated"]
["Not Documented"]
  authorTime DateTime
  negationRationale Concept (just rationale?)

Templates for an HL7 RIM Act with a negation indicator
  and capable of representing an "authorTime" and a "negationRationale"
  for each "data type kind" { Performed, Recommended, Ordered, Administered, ... }


["Encounter, Performed": "Inpatient Encounter"]
  Encounter.negationRationale is null
["Procedure, Performed": "Heart Surgery"]

["Not Ordered": "Antithromobtic ingredient specific"] NotOrdered
  where NotOrdered.negationRationale in ("Medical Reason" union "Patient Refusal")


["Encounter"] E
 where E.status = 'completed'


["Not Performed"]

/*
  Union of:
    * "Medication, Order not done: Medical Reason" for "Antithrombotic ingredient specific"
    * "Medication, Administered not done: Medical Reason" for "Antithrombotic Therapy"
    * "Medication, Order not done: Patient Refusal" for "Antithrombotic Therapy"
    * "Medication, Administered not done: Patient Refusal" for "Antithrombotic Therapy"
*/

define "Antithrombotic Not Done":
  (["Medication, Order": "Antithrombotic ingredient specific"]
    union ["Medication, Order": "Antithrombotic Therapy"]) MedicationOrder
    where MedicationOrder.negationRationale in "Medical Reason"
      or MedicationOrder.negationRationale in "Patient Refusal"

define "Antithrombotic Not Done":
  (["Not Ordered": "Antithrombotic ingredient specific"]
    union ["Not Ordered": "Antithrombotic Therapy"]) O
      where O.negationRationale in "Medical Reason"
        or O.negationRationale in "Patient Refusal"

define "Antithrombotic Not Done":
  (["Not Done": "Antithrombotic ingredient specific"]
    ["Not Done": "Antithrombotic Therapy"]) NotDone
    where NotDone.actionType = 'Medication, Order'
      and NotDone.negationRationale in "Medical Reason"

/*
  Union of:
    * "Medication, Discharge not done: Patient Refusal" for "Statin ingredient specific"
    * "Medication, Discharge not done: Medical Reason" for "Statin ingredeient specific"
*/

define "Statin At Discharge Not Done":
  ["Medication, Discharge": "Statin ingredient specific"] Medication
    where Medication.negationRationale in "Patient Refusal"
      or Medication.negationRationale in "Medical Reason"

define "Statin At Discharge Not Done":
  ["Not Documented": "Statin ingredient specific"] NotDocumented
    where NotDocumented.negationRationale in "Patient Refusal"
      or NotDocumented.negationRationale in "Medical Reason"

/*
  Union of:
    * "Device, Applied not done: Medical Reason" for "Intermittent pneumatic compression devices (IPC)"
    * "Device, Applied not done: Medical Reason" for "Venous foot pumps (VFP)"
    * "Device, Applied not done: Medical Reason" for "Graduated compression stockings (GCS)"
    * "Device, Order not done: Medical Reason" for "Intermittent pneumatic compression devices (IPC)"
    * "Device, Order not done: Medical Reason" for "Venous foot pumps (VFP)"
    * "Device, Order not done: Medical Reason" for "Graduated compression stockings (GCS)"
*/

define "No Device VTE Prophylaxis Medical Reason":
  (["Device, Applied": "Intermittent pneumatic compression devices (IPC)"]
      union ["Device, Applied": "Venous foot pumps (VFP)"]
      union ["Device, Applied": "Graduated compression stockings (GCS)"]
      union ["Device, Order": "Intermittent pneumatic compression devices (IPC)"]
      union ["Device, Order": "Venous foot pumps (VFP)"]
      union ["Device, Order": "Graduated compression stockings (GCS)"]
    ) DA
      where DA.negationRationale in "Medical Reason"

define "No Device VTE Prophylaxis Medical Reason":
  (["Not Applied": "Intermittent pneumatic compression devices (IPC)"]
      union ["Not Applied": "Venous foot pumps (VFP)"]
      union ["Not Applied": "Graduated compression stockings (GCS)"]
      union ["Not Ordered": "Intermittent pneumatic compression devices (IPC)"]
      union ["Not Ordered": "Venous foot pumps (VFP)"]
      union ["Not Ordered": "Graduated compression stockings (GCS)"]
    ) DA
      where DA.negationRationale in "Medical Reason"
