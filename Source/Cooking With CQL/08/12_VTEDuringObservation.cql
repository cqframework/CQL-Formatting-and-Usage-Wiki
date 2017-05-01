/*
  VTE-01

  https://oncprojectracking.healthit.gov/support/browse/CQM-1608

  VTE-01- VTE prophylaxis starts (TED hose placed) while the patient is in
  observation and is continued in the inpatient setting, so the patient does
  not meet the numerator. This ticket includes slide presentations that were
  used for CRP discussions, and provide more context around the issue.
*/

/*

  Patients who received VTE prophylaxis:
    the day of or the day after hospital admission
    the day of or the day after surgery end date for surgeries that end the day of or the day after hospital admission

  # VTE prophylaxis options
    OR: Union of:
      $MedicationVTEProphylaxis <= 1 day(s) starts after start of Occurrence A of $EncounterInpatient
      $MedicationVTEProphylaxis <= 1 day(s) starts after end of ("Procedure, Performed: General or Neuraxial Anesthesia" <= 1 day(s) ends after start of Occurrence A of $EncounterInpatient )
      $DeviceVTEProphylaxis <= 1 day(s) starts after start of Occurrence A of $EncounterInpatient
      $DeviceVTEProphylaxis <= 1 day(s) starts after end of ("Procedure, Performed: General or Neuraxial Anesthesia" <= 1 day(s) ends after start of Occurrence A of $EncounterInpatient )

  Hospital Arrival for an Episode-of-Care defined as:
    Earliest of:
      ED Visit start
      Observation start
      Inpatient admission

*/
