library CAP

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon called FC
include FHIRShared called FS

include CURBConcepts called Cx
include CURBElements called Ce

context Patient

define "Confusion":
  (FS.MostRecent(Ce."Confusion")) F
    return {
      label: 'Confusion',
      value: FHIRHelpers.ToBoolean(F.value),
      score: FS.ToScore(F.value is true)
    }

define "Blood urea nitrogen":
  (FS.MostRecent(Ce."Blood urea nitrogen")) F
    return {
      label: 'Blood urea nitrogen',
      value: FHIRHelpers.ToQuantity(F.value),
      score: FS.ToScore(F.value > 19 'mg/dL')
    }

define "Respiratory rate":
  (FS.MostRecent(Ce."Respiratory rate")) F
    return {
      label: 'Respiratory rate',
      value: FHIRHelpers.ToQuantity(F.value),
      score: FS.ToScore(F.value >= 30 '/min')
    }

define "Blood pressure":
  (FS.MostRecent(Ce."Blood pressure")) F
    return {
      label: 'Blood pressure',
      value: { systolic: FHIRHelpers.ToQuantity(F.systolic()), diastolic: FHIRHelpers.ToQuantity(F.diastolic()) },
      score: FS.ToScore(F.systolic() < 90 'mm[Hg]' or F.diastolic() <= 60 'mm[Hg]')
    }

define "Age":
  (AgeInYearsAt(FS.AsOf)) F
    return {
      label: 'Age',
      value: F,
      score: FS.ToScore(F >= 65)
    }

define "CAP Severity Factors": {
  "Confusion",
  "Blood urea nitrogen",
  "Respiratory rate",
  "Blood pressure",
  "Age"
}

define "CAP Severity Score":
  Sum(
    "CAP Severity Factors" F
      return all F.score
  )

define "Inclusion Criteria":
  exists Ce."Community Acquired Pneumonia"

define "CAP Severity Recommendation":
  case
    when "Has CURB65 Elements" then "CURB65 Severity Recommendation"
    when "Has CRB65 Elements" then "CRB65 Severity Recommendation"
    else 'Confusion, respiratory rate, blood pressure and age are required, and blood urea nitrogen is recommended as input to determining CAP severity'
  end

define "Has CRB65 Elements":
  exists Ce."Confusion"
    and exists Ce."Respiratory rate"
    and exists Ce."Blood pressure"
    and Patient.birthDate is not null

define "Has CURB65 Elements":
  "Has CRB65 Elements"
    and exists Ce."Blood urea nitrogen"

define "CURB65 Severity Recommendation":
  case
    when "CAP Severity Score" in { 0, 1 } then 'Low risk; consider home treatment'
    when "CAP Severity Score" = 2 then 'Short inpatient hospitalization or closely supervised outpatient treatment'
    when "CAP Severity Score" in { 3, 4, 5 } then 'Severe pneumonia; hospitalize and consider admitting to intensive care'
    else 'Insufficient data to determine a recommendation'
  end

define "CURB65 Severity Mortality Rate":
  case "CAP Severity Score"
    when 0 then '7/1,223 (0.6%)'
    when 1 then '31/1,142 (2.7%)'
    when 2 then '69/1,019 (6.8%)'
    when 3 then '79/563 (14.0%)'
    when 4 then '44/158 (27.8%)'
    when 5 then '44/158 (27.8%)'
    else null
  end

define "CRB65 Severity Recommendation":
  case
    when "CAP Severity Score" = 0 then 'Very low risk of death; usually does not require hospitalization'
    when "CAP Severity Score" in { 1, 2 } then 'Increased risk of deah; consider hospitalization'
    when "CAP Severity Score" in { 3, 4 } then 'High risk of death; urgent hospitalization'
    else 'Insufficient data to determine a recommendation'
  end

define "CRB65 Severity Mortality Rate":
  case "CAP Severity Score"
    when 0 then '2/212 (0.9%)'
    when 1 then '18/344 (5.2%)'
    when 2 then '30/251 (12.0%)'
    when 3 then '39/125 (31.2%)'
    else null
  end

define "Summary":
  if "Inclusion Criteria" then
    "CAP Severity Recommendation"
  else
    'Patient does not have an active diagnosis of Community Acquired Pneumonia (CAP)'

define "Detail":
  case
    when "Has CURB65 Elements" then "CURB65 Severity Score Detail"
    when "Has CRB65 Elements" then "CRB65 Severity Score Detail"
    else 'CURB-65 = Confusion, Urea nitrogen, Respiratory rate, Blood pressure, 65 years of age and older.
CRB-65 = Confusion, Respiratory rate, Blood pressure, 65 years of age and older.

*—Data are weighted averages from validation studies.1-2
†—Recommendations are consistent with British Thoracic Society guidelines.3 Clinical judgment may overrule the guideline recommendation.
‡—A CRB-65 score can be calculated by omitting the blood urea nitrogen value, which gives it a point range from 0 to 4. This score is useful when blood tests are not readily available.'
  end

define "CURB65 Severity Score Detail":
  'CURB65 Severity Score:' + ToString("CAP Severity Score")
    + 'Deaths/total (%): ' + "CURB65 Severity Mortality Rate"
    + Combine(
        "CAP Severity Factors" C
          return C.label + ': ' + ToString(C.value),
        '; '
      )

define "CRB65 Severity Score Detail":
  'CRB65 Severity Score:' + ToString("CAP Severity Score")
    + 'Deaths/total (%): ' + "CRB65 Severity Mortality Rate"
    + Combine(
        "CAP Severity Factors" C
          return C.label + ': ' + ToString(C.value),
        '; '
      )
