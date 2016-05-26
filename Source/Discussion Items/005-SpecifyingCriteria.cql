/*
Initial Population =
    AND: Age >= 5 year(s) at: "Measurement Period"
    AND: Age < 64 year(s) at: "Measurement Period"
    AND: "Diagnosis, Active: Persistent Asthma" overlaps "Measurement Period"
    AND: Union of:
        "Encounter, Performed: Office Visit"
        "Encounter, Performed: Face-to-Face Interaction"
        "Encounter, Performed: Preventive Care - Established Office Visit, 0 to 17"
        "Encounter, Performed: Preventive Care Services - Established Office Visit, 18 and Up"
        "Encounter, Performed: Preventive Care Services-Initial Office Visit, 18 and Up"
        "Encounter, Performed: Preventive Care- Initial Office Visit, 0 to 17"
        "Encounter, Performed: Home Healthcare Services"
        during "Measurement Period"
*/

define "In Demographic":
  AgeInYearsAt(start of "Measurement Period") >= 5
    and AgeInYearsAt(start of "Measurement Period") < 65

define "Has Asthma Diagnosis":
  exists (
    ["Diagnosis": "Persistent Asthma"] Diagnosis
      where Interval[Diagnosis.onsetDatetime, Diagnosis.abatementDatetime] overlaps "Measurement Period"
  )

define "Has Valid Encounters":
  exists (
    (["Encounter, Performed": "Office Visit"]
      union ["Encounter, Performed": "Face-to-Face Interaction"]
      union ["Encounter, Performed": "Preventive Care - Established Office Visit, 0 to 17"]
      union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
      union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
      union ["Encounter, Performed": "Preventive Care- Initial Office Visit, 0 to 17"]
      union ["Encounter, Performed": "Home Healthcare Services"]
    ) E where Interval[E.admissionDateTime, E.dischargeDateTime] during "Measurement Period"
  )

define "In Initial Population":
  "In Demographic"
    and "Has Asthma Diagnosis"
    and "Has Valid Encounters"
