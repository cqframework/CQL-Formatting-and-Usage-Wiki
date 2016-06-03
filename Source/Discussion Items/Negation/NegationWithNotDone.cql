/*
  Union of:
    * "Medication, Order not done: Medical Reason" for "Antithrombotic ingredient specific"
    * "Medication, Administered not done: Medical Reason" for "Antithrombotic Therapy"
    * "Medication, Order not done: Patient Refusal" for "Antithrombotic Therapy"
    * "Medication, Administered not done: Patient Refusal" for "Antithrombotic Therapy"
*/

define codesystem "QDM Data Types": 'X.Y.Z' version '5.0'
define code "Medication, Order": 'Medication, Order' from "QDM Data Types"
define code "Encounter, Performed": 'Encounter, Performed' from "QDM Data Types"

"Encounter, Performed" {
  code: Code,
  startDateTime: DateTime,
  ...
}

"Not Done" {
  code: Code - "QDM Data Types" { 'Encounter, Performed', 'Medication, Order', ... }
  actionCode: Code, - code of the action being negated
  negationRationale: Code
}

// Current
define "Antithrombotic Not Done":
  (["Medication, Order": "Antithrombotic ingredient specific"]
    union ["Medication, Order": "Antithrombotic Therapy"]) MedicationOrder
    where MedicationOrder.negationRationale in "Medical Reason"
      or MedicationOrder.negationRationale in "Patient Refusal"

// Proposed
define "Antithrombotic Not Done":
  ["Not Done": "Medication, Order"] NotDone
    where (NotDone.actionCode in "Antithrombotic ingredient specific" or NotDone.actionCode in "Antithrombotic Therapy")
      and NotDone.negationRationale in "Medical Reason"

/*
  Union of:
    * "Medication, Discharge not done: Patient Refusal" for "Statin ingredient specific"
    * "Medication, Discharge not done: Medical Reason" for "Statin ingredeient specific"
*/

// Current
define "Statin At Discharge Not Done":
  ["Medication, Discharge": "Statin ingredient specific"] Medication
    where Medication.negationRationale in "Patient Refusal"
      or Medication.negationRationale in "Medical Reason"

// Proposed
define "Statin At Discharge Not Done":
  ["Not Done": "Medication, Discharge"] NotDone
    where NotDone.actionCode in "Statin ingredient specific"
      and (
        NotDone.negationRationale in "Patient Refusal"
          or NotDone.negationRationale in "Medical Reason"
      )

/*
  Union of:
    * "Device, Applied not done: Medical Reason" for "Intermittent pneumatic compression devices (IPC)"
    * "Device, Applied not done: Medical Reason" for "Venous foot pumps (VFP)"
    * "Device, Applied not done: Medical Reason" for "Graduated compression stockings (GCS)"
    * "Device, Order not done: Medical Reason" for "Intermittent pneumatic compression devices (IPC)"
    * "Device, Order not done: Medical Reason" for "Venous foot pumps (VFP)"
    * "Device, Order not done: Medical Reason" for "Graduated compression stockings (GCS)"
*/

// Current
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

// Proposed
define "No Device VTE Prophylaxis Medical Reason":
    (["Not Done": "Intermittent pneumatic compression devices (IPC)"]
      union ["Not Done": "Venous foot pumps (VFP)"]
      union ["Not Done": "Graduated compression stockings (GCS)"]
      union ["Not Done": "Intermittent pneumatic compression devices (IPC)"]
      union ["Not Done": "Venous foot pumps (VFP)"]
      union ["Not Done": "Graduated compression stockings (GCS)"]
    ) NotDone
      where NotDone.actionType in { 'Device, Applied', 'Device, Order' }
        and NotDone.negationRationale in "Medical Reason"

define "No Device VTE Prophylaxis Medical Reason":
    (["Not Done": "Device, Applied"]
      union ["Not Done": "Device, Order"]
    ) NotDone
      where (NotDone.actionCode in "Intermittent pneumatic compression devices (IPC)"
          or NotDone.actionCode in ...)
        and NotDone.negationRationale in "Medical Reason"
