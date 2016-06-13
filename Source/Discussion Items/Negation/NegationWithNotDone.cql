/*
To specify a QDM Data Element requires four pieces of information:

// Category - Medication, Encounter, etc.
// Data Type - Performed, Recommended, etc.
// Value Set - Inpatient, Antithrombotic, etc.
// Negated - Whether the element is being positively or negatively asserted

By default, QDM currently assumes a positive assertion.
Negative assertions are indicated within the data element by a "Not Done" qualifier
*/

/*
  * "Medication, Administered not done: Medical Reason" for "Antithrombotic Therapy"
*/

// Proposed 0 - Negation Rationale Filtering
// Assumes the unqualified retrieval will return both positive and negative assertions
// Relies on subsequent filtering by negationRationale
// Inconsistent with current QDM
// Infeasible to ensure filtering has occurred with tooling
define "Antithrombotic Not Administered":
  ["Medication, Administered": "Antithrombotic ingredient specific"] Medication
    where Medication.negationRationale in "Medical Reason"

// Proposed 1 - Single negation type
define "Antithrombotic Not Administered":
  ["Not Done": "Medication, Administered"] NotDone
    where NotDone.actionCode in "Antithrombotic ingredient specific"
      and NotDone.negationRationale in "Medical Reason"

// Proposed 2 - Negation type per data type
define "Antithrombotic Not Administered":
  ["Not Administered": "Medication"] NotAdministered
    where NotAdministered.medicationCode in "Antithrombotic ingredient specific"
      and NotAdministered.negationRationale in "Medical Reason"

// Proposed 3 - Negation type per category/data type
define "Antithrombotic Not Administered":
  ["Medication, Not Administered": "Antithrombotic ingredient specific"] MedicationNotAdministered
    where MedicationNotAdministered.negationRationale in "Medical Reason"

/*
  Union of:
    * "Medication, Order not done: Medical Reason" for "Antithrombotic ingredient specific"
    * "Medication, Administered not done: Medical Reason" for "Antithrombotic Therapy"
    * "Medication, Order not done: Patient Refusal" for "Antithrombotic Therapy"
    * "Medication, Administered not done: Patient Refusal" for "Antithrombotic Therapy"
*/

// Proposed 0 - Negation Rationale Filtering
  // Assumes the unqualified retrieval will return both positive and negative assertions
  // Relies on subsequent filtering by negationRationale
  // Inconsistent with current QDM
define "Antithrombotic Not Done":
  (["Medication, Order": "Antithrombotic ingredient specific"]
    union ["Medication, Order": "Antithrombotic Therapy"]) MedicationOrder
    where MedicationOrder.negationRationale in "Medical Reason"
      or MedicationOrder.negationRationale in "Patient Refusal"

// Proposed 1 - Single negation type
define "Antithrombotic Not Done":
  ["Not Done": "Medication, Order"] NotDone
    where (NotDone.actionCode in "Antithrombotic ingredient specific" or NotDone.actionCode in "Antithrombotic Therapy")
      and (NotDone.negationRationale in "Medical Reason" or NotDone.negationRationale in "Patient Refusal")

// Requires a QDM Data Types code system with values for each possible QDM Data Type
define codesystem "QDM Data Types": 'X.Y.Z' version '5.0'
define code "Medication, Order": 'Medication, Order' from "QDM Data Types"
define code "Encounter, Performed": 'Encounter, Performed' from "QDM Data Types"
...

// Requires a Not Done QDM Data Type with attributes describing the data element being negated
define class "Not Done" {
  code: Code, // "QDM Data Types" { 'Encounter, Performed', 'Medication, Order', ... }
  actionCode: Code, // code of the action being negated
  negationRationale: Code
}

// Proposed 2 - Negation type per data type (not per category/datatype combination)
define "Antithrombotic Not Done":
  ["Not Ordered": "Medication"] M
    where (M.actionCode in "Antithrombotic Therapy" or M.actionCode in "Antithrombotic ingredient specific")
      and (M.negationRationale in "Medical Reason" or M.negationRationale in "Patient Refusal")

// Requires a QDM Categories code system with values for each possible QDM category
define codesystem "QDM Categories": 'X.Y.Z' version '5.0'
define code "Medication": 'Medication' from "QDM Categories"
define code "Encounter": 'Encounter' from "QDM Categories"
...

// Requires a Negation type in QDM per data type (Performed, Order, Administered, etc)
define class "Not Ordered" {
  code: Code, // "QDM Categories" { 'Medication', 'Encounter', ... }
  actionCode: Code, // code of the action being negated
  negationRationale: Code
}

// Proposed 3 - Negation type per category/datatype combination
define "Antithrombotic Not Done":
  (["Medication, Not Ordered": "Antithrombotic Therapy"]
    union ["Medication, Not Ordered": "Antithrombotic ingredient specific"]) M
    where (M.negationRationale in "Medical Reason" or M.negationRationale in "Patient Refusal")

define class "Medication, Not Ordered" {
  code: Code, // code of the medication being negated (e.g. "Antithrombotic")
  negationRationale: Code
}

/*
  Union of:
    * "Medication, Discharge not done: Patient Refusal" for "Statin ingredient specific"
    * "Medication, Discharge not done: Medical Reason" for "Statin ingredeient specific"
*/

// Proposed 0
define "Statin At Discharge Not Done":
  ["Medication, Discharge": "Statin ingredient specific"] Medication
    where Medication.negationRationale in "Patient Refusal"
      or Medication.negationRationale in "Medical Reason"

// Proposed 1
define "Statin At Discharge Not Done":
  ["Not Done": "Medication, Discharge"] NotDone
    where NotDone.actionCode in "Statin ingredient specific"
      and (
        NotDone.negationRationale in "Patient Refusal"
          or NotDone.negationRationale in "Medical Reason"
      )

// Proposed 3
define "Statin At Discharge Not Done":
  ["Medication, Not At Discharge": "Statin ingredient specific"] NotAtDischarge
    where NotAtDischarge.negationRationale in "Patient Refusal"
      or NotAtDischarge.negationRationale in "Medical Reason"

/*
  Union of:
    * "Device, Applied not done: Medical Reason" for "Intermittent pneumatic compression devices (IPC)"
    * "Device, Applied not done: Medical Reason" for "Venous foot pumps (VFP)"
    * "Device, Applied not done: Medical Reason" for "Graduated compression stockings (GCS)"
    * "Device, Order not done: Medical Reason" for "Intermittent pneumatic compression devices (IPC)"
    * "Device, Order not done: Medical Reason" for "Venous foot pumps (VFP)"
    * "Device, Order not done: Medical Reason" for "Graduated compression stockings (GCS)"
*/

// Proposed 0
define "No Device VTE Prophylaxis Medical Reason":
  exists (
    (["Device, Applied": "Intermittent pneumatic compression devices (IPC)"]
      union ["Device, Applied": "Venous foot pumps (VFP)"]
      union ["Device, Applied": "Graduated compression stockings (GCS)"]
    ) DeviceApplied
      where DeviceApplied.negationRationale in "Medical Reason"
  ) or exists (
    (["Device, Order": "Intermittent pneumatic compression devices (IPC)"]
        union ["Device, Order": "Venous foot pumps (VFP)"]
        union ["Device, Order": "Graduated compression stockings (GCS)"]
    ) DeviceOrdered
      where DeviceOrdered.negationRationale in "Medical Reason"
  )

// Proposed 1
define "No Device VTE Prophylaxis Medical Reason":
    (["Not Done": "Device, Applied"]
      union ["Not Done": "Device, Order"]
    ) NotDone
      where (NotDone.actionCode in "Intermittent pneumatic compression devices (IPC)"
          or NotDone.actionCode in "Venous foot pumps (VFP)"
          or NotDone.actionCode in "Graduated compression stockings (GCS)")
        and NotDone.negationRationale in "Medical Reason"

// Proposed 3
define "No Device VTE Prophylaxis Medical Reason":
  exists (
    (["Device, Not Applied": "Intermittend pneumatic compression devices (IPC)"]
      union ["Device, Not Applied": "Venous foot pumps (VFP)"]
      union ["Device, Not Applied": "Graduated compression stockings (GCS)"]
    ) NotApplied
      where NotApplied.negationRationale in "Medical Reason"
  ) or exists (
    (["Device, NotOrdered": "Intermittent pneumatic compression devices (IPC)"]
      union ["Device, Not Ordered": "Venous foot pumps (VFP)"]
      union ["Device, Not Ordered": "Graduated compression stockings (GCS)"]
    ) NotOrdered
      where NotOrdered.negationRationale in "Medical Reason"
  )
