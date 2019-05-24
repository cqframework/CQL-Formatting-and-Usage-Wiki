library MultiSourceQueries_Redux

// From CMS144v7: Heart Failure (HF): Beta-Blocker Therapy for Left Ventricular Systolic Dysfunction (LVSD):

define "Consecutive Heart Rates Less Than 50 Inpatient":
	from
		["Physical Exam, Performed": "Heart rate"] HeartRate,
		"Heart Failure Inpatient Encounter with Moderate or Severe LVSD" ModerateOrSevereLVSDHFInpatientEncounter
		let PriorHeartRate: Last(["Physical Exam, Performed": "Heart rate"] MostRecentPriorHeartRate
				where MostRecentPriorHeartRate.relevantPeriod during ModerateOrSevereLVSDHFInpatientEncounter.relevantPeriod
					and MostRecentPriorHeartRate.relevantPeriod starts before start of HeartRate.relevantPeriod
				sort by start of relevantPeriod
		)
		where HeartRate.relevantPeriod during ModerateOrSevereLVSDHFInpatientEncounter.relevantPeriod
			and HeartRate.result < 50 '{Beats}/min'
			and PriorHeartRate.result < 50 '{Beats}/min'

// Result Type:
{
  { HeartRate: { ... }, ModerateOrSevereLVSDHFInpatientEncounter: { ... } }      
  { HeartRate: { ... }, ModerateOrSevereLVSDHFInpatientEncounter: { ... } }      
  { HeartRate: { ... }, ModerateOrSevereLVSDHFInpatientEncounter: { ... } }      
  { HeartRate: { ... }, ModerateOrSevereLVSDHFInpatientEncounter: { ... } }      
  { HeartRate: { ... }, ModerateOrSevereLVSDHFInpatientEncounter: { ... } }      
}

// If this is being used in a denominator exception
define "Denominator Exception":
  "Consecutive Heart Rates Less Than 50 Inpatient" CH
    return CH.ModerateOrSevereLVSDHFInpatientEncounter
//  exists ( "Consecutive Heart Rates Less Than 50 Inpatient" )

// Typically if the result is used elsewhere, a return would be included:
define "Consecutive Heart Rates Less Than 50 Inpatient":
	from
		["Physical Exam, Performed": "Heart rate"] HeartRate,
		"Heart Failure Inpatient Encounter with Moderate or Severe LVSD" ModerateOrSevereLVSDHFInpatientEncounter
		let PriorHeartRate: Last(["Physical Exam, Performed": "Heart rate"] MostRecentPriorHeartRate
				where MostRecentPriorHeartRate.relevantPeriod during ModerateOrSevereLVSDHFInpatientEncounter.relevantPeriod
					and MostRecentPriorHeartRate.relevantPeriod starts before start of HeartRate.relevantPeriod
				sort by start of relevantPeriod
		)
		where HeartRate.relevantPeriod during ModerateOrSevereLVSDHFInpatientEncounter.relevantPeriod
			and HeartRate.result < 50 '{Beats}/min'
			and PriorHeartRate.result < 50 '{Beats}/min'
    return HeartRate
    
{
  { id: 123, code: Code { code: 'ABC', },  method: '', ... },
  { id: 124, code: Code { code: 'ABC', },  method: '', ... }
}

// From CMS156v7: Use of High-risk Medications in the Elderly

define "Medication List":
	( from
			["Medication, Order": "List of Single RxNorm Code Concepts for High Risk Drugs for the Elderly"] MedicationOrder1,
			["Medication, Order": "List of Single RxNorm Code Concepts for High Risk Drugs for the Elderly"] MedicationOrder2
			where MedicationOrder1.authorDatetime during "Measurement Period"
				and MedicationOrder2.authorDatetime during "Measurement Period"
				and MedicationOrder1.authorDatetime 1 day or more after MedicationOrder2.authorDatetime
				and MedicationOrder1.code ~ MedicationOrder2.code
			return MedicationOrder1
	)

// From CMS157v7: Oncology: Medical and Radiation - Pain Intensity Quantified  

define "Face to Face Encounter with Ongoing Chemotherapy":
	from
		["Encounter, Performed": "Office Visit"] FaceToFaceEncounter,
		["Procedure, Performed": "Chemotherapy Administration"] ChemoBeforeEncounter,
		["Procedure, Performed": "Chemotherapy Administration"] ChemoAfterEncounter,
		["Diagnosis": "Cancer"] Cancer
		where ChemoBeforeEncounter.relevantPeriod starts 30 days or less on or before day of end of FaceToFaceEncounter.relevantPeriod
			and ChemoAfterEncounter.relevantPeriod starts 30 days or less on or after day of end of FaceToFaceEncounter.relevantPeriod
			and ChemoBeforeEncounter !~ ChemoAfterEncounter
			and Cancer.prevalencePeriod overlaps FaceToFaceEncounter.relevantPeriod
			and FaceToFaceEncounter.relevantPeriod during "Measurement Period"
		return FaceToFaceEncounter
    
// From CMS169v7: Bipolar Disorder and Major Depression: Appraisal for alcohol or chemical substance use

define "Numerator":
	exists ( from
			["Procedure, Performed": "BH Assessment for Alcohol or Other Drugs"] SubstanceAbuseAssessment,
			"Qualifying Encounters" QualifiedEncounter,
			"Qualifying Treatments" QualifiedTreatment
			where SubstanceAbuseAssessment.relevantPeriod starts same or after start of QualifiedEncounter.relevantPeriod
				and SubstanceAbuseAssessment.relevantPeriod ends same or before QualifiedTreatment.authorDatetime
				and not exists ( "Qualifying Treatments" PriorQualifiedTreatment
						where PriorQualifiedTreatment.authorDatetime before QualifiedTreatment.authorDatetime
							and PriorQualifiedTreatment.authorDatetime same or after start of QualifiedEncounter.relevantPeriod
							and PriorQualifiedTreatment !~ QualifiedTreatment
				)
	)
  
// From CMS22v7: Preventive Care and Screening: Screening for High Blood Pressure and Follow-Up Documented

define "High Blood Pressure at Most Recent Screening Encounter":
	from
		"Most Recent Systolic Reading During Most Recent Blood Pressure Screening Encounter" LastSystolicBP,
		"Most Recent Diastolic Reading During Most Recent Blood Pressure Screening Encounter" LastDiastolicBP
		where ( LastSystolicBP.result >= 140 'mm[Hg]'
				or LastDiastolicBP.result >= 90 'mm[Hg]'
		)
    
// From CMS52v7: HIV/AIDS: Pneumocystis Jiroveci Pneumonia (PCP) Prophylaxis

define "CD4 Count Under 200 With Current PCP Treatment":
	from
		"CD4 Count Under 200" CD4CountUnder200,
		["Medication, Order": "Dapsone 100 MG / Pyrimethamine 12.5 MG Oral Tablet"] DapsoneOrder,
		["Medication, Order": "Leucovorin"] LeucovorinOrder
		where DapsoneOrder.authorDatetime occurs 3 months or less after end CD4CountUnder200.relevantPeriod
			and LeucovorinOrder.authorDatetime occurs 3 months or less after end CD4CountUnder200.relevantPeriod
			and DapsoneOrder.authorDatetime same day as LeucovorinOrder.authorDatetime
		return CD4CountUnder200
    

// From CMS108v7: Venous Thromboembolism Prophylaxis:

define "No VTE Prophylaxis Device Due to Medical Reason During ED Visit":
	from
		"Encounter With Age Range and Without VTE Diagnosis or Obstetrical Conditions" QualifyingEncounter,
		"ED Visit" EDVisit,
		"No VTE Prophylaxis Device Applied or Ordered" NoVTEDevice
		where EDVisit.relevantPeriod ends 1 hour or less on or before start of QualifyingEncounter.relevantPeriod
			and NoVTEDevice.negationRationale in "Medical Reason"
			and NoVTEDevice.authorDatetime during EDVisit.relevantPeriod
		return QualifyingEncounter

// CMS113v7: Elective Delivery

define "Medical Induction Medication Administered While Not In Labor":
	from
		"Delivery Encounter Near Term" DeliveryEncounter,
		"Medical Induction Medication" InductionMedication,
		"Is In Labor" Labor
		where Labor.authorDatetime during DeliveryEncounter.relevantPeriod
			and InductionMedication.relevantPeriod 24 hours or less before Labor.authorDatetime
		return DeliveryEncounter

// From CMS117v7: Childhood Immunization Status:

define "Four DTaP Vaccinations":
	from
		"DTaP Immunizations or Procedures" DTaPVaccination1,
		"DTaP Immunizations or Procedures" DTaPVaccination2,
		"DTaP Immunizations or Procedures" DTaPVaccination3,
		"DTaP Immunizations or Procedures" DTaPVaccination4
		where DTaPVaccination2.authorDatetime 1 day or more after day of DTaPVaccination1.authorDatetime
			and DTaPVaccination3.authorDatetime 1 day or more after day of DTaPVaccination2.authorDatetime
			and DTaPVaccination4.authorDatetime 1 day or more after day of DTaPVaccination3.authorDatetime
		return DTaPVaccination1
    
