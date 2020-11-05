library QDMTimings

using QDM version '5.5'

context Patient

/*
Background:

With the introduction of "relevantDatetime" elements to several data types in the
QDM 5.5 release, measure authors and measure implementers have a choice of representation
for the "relevant" timing of these data types. From the authoring perspective, measure
developers can choose to use the most appropriate element for a given data type, and
from the implementer's perspective, systems can use either representation, whichever is
available within their systems.

This flexibility results in a challenge when the choice from the authoring and/or
system perspective has the potential to vary within a data type based on usage. The 2021
AU measures were reviewed for examples of variation in usage from the authoring perspective,
resulting in the following general guidance on the usage of QDM timing elements.

Guidance:

The following QDM data types have both a relevantDatetime and relevantPeriod:

Assessment, Performed
Device, Applied
Diagnostic Study, Performed
Intervention, Performed
Laboratory Test, Performed
Medication, Active
Medication, Administered
Medication, Dispensed
Physical Exam, Performed
Procedure, Performed
Substance, Administered

For each of these types, since there are use cases for both relevantDatetime and
relevantPeriod, the recommended approach is to use a "normalizing" function to
access the timing elements:
*/

define function "NormalizeInterval"(pointInTime DateTime, period Interval<DateTime>):
  if pointInTime is not null then Interval[pointInTime, pointInTime]
    else if period is not null then period
    else null as Interval<DateTime>

/*
This function can then be used for any of the types defining both "relevant" representations, as
illustrated in the following examples:
*/

/*
Procedures
*/

/*
1.	CMS66 “Total Knee Arthroplasty Procedure”
*/

["Procedure, Performed": "Primary TKA Procedure"] TKAProcedure
  where Global."NormalizeInterval"(TKAProcedure.relevantDatetime, TKAProcedure.relevantPeriod)
    starts 12 months or less before start of "Measurement Period"

/*
2.	CMS129 “First Prostate Cancer Treatment During Measurement Period”
*/

First(["Procedure, Performed": "Prostate Cancer Treatment"] ProstateCancerTreatment
    where Global."NormalizeInterval"(ProstateCancerTreatment.relevantDatetime, ProstateCancerTreatment.relevantPeriod)
      during "Measurement Period"
    sort by start of relevantPeriod
)

/*
Comment:
-	Case 1 “Primary TKA Procedure” uses value set 2.16.840.1.113883.3.464.1003.198.12.1007, including  one CPT and nine SNOMED procedure codes.
-	Case 2 “Prostate Cancer Treatment” uses value set 2.16.840.1.113883.3.526.3.398, including CPT and SNOMED procedure codes.
While these are all surgical procedures that require an interval of time from initiation to completion (i.e., incision to closure), the SNOMED-related codes reference procedures that should be retrievable from the clinical software. However, the start and stop times may exist only in the anesthesia record and not in the EHR or other clinical software. The reference to the procedure in the EHR or other clinical software may indicate a point in time rather than a period (interval).  Moreover, the surgical treatment reference in the ambulatory record for this clinician measure will likely be as part of the surgical history and, at best provide a date but not a time or a period. Additionally, the CPT codes are basically physician billing codes referencing the procedure performed by the physician but with at best a reference to a day and they are extremely unlikely to be represented by a period. Therefore, for this clinician (ambulatory) measure, relevantPeriod seems excessive.  If present at all, a relevant dateTime will be available.  Since there may be a possibility of detailed procedure timing in a shared enterprise EHR used for inpatient and ambulatory care, relevantPeriod may be available. Therefore, a Normalized Interval is the most appropriate solution for these use cases.
*/

/*
Immunizations
*/

/*
1.	CMS127 “Numerator
*/

exists ( ["Immunization, Administered": "Pneumococcal Vaccine"] PneumococcalVaccine
    where PneumococcalVaccine.relevantDatetime on or before
    end of "Measurement Period"
)
  or exists ( ["Procedure, Performed": "Pneumococcal Vaccine Administered"] PneumococcalVaccineGiven
      where PneumococcalVaccineGiven.relevantDatetime on or before
      end of "Measurement Period"
  )

/*
2.	CMS117 “DTaP Immunizations or Procedures”
*/

( ( ["Immunization, Administered": "DTaP Vaccine"]
    union ["Procedure, Performed": "DTaP Vaccine Administered"] ) DTaPVaccination
    where DTaPVaccination.relevantDatetime during Interval[Patient.birthDatetime + 42 days, Patient.birthDatetime + 2 years]
)

/*
Comment:
Use case 1:
•	"Pneumococcal Vaccine” (2.16.840.1.113883.3.464.1003.110.12.1027) includes 4 CVX codes representing vaccine product.
•	"Pneumococcal Vaccine Administered" (2.16.840.1.113883.3.464.1003.110.12.1034) includes 2 SNOMED and 1 CPT code indicating the procedure to administer the specific vaccine.
Use case 2:
•	"DTaP Vaccine" (2.16.840.1.113883.3.464.1003.196.12.1214) includes 6 CVX codes representing vaccine product
•	"DTaP Vaccine Administered" (2.16.840.1.113883.3.464.1003.110.12.1022) includes 20 SNOMED and 3 CPT codes indicating the procedure to administer the specific vaccine,

All vaccines are administered at a single point in time except for oral Typhoid vaccine which is patient self-administered as three oral doses several days apart but is clinically recorded as a single point in time. Therefore, the vaccination (“Immunization, Administered”) and the procedure to vaccinate (“Procedure, Performed”) can always be expected to have a single time element, i.e., relevant dateTime.
*/

/*
Intervention, Performed
*/

/*
1.	CMS134 “Renal Interventions”
*/

["Intervention, Performed": "Other Services Related to Dialysis"]
  union ["Intervention, Performed": "Dialysis Education"]

"Nephropathy Screenings"
  ( "Renal Procedures"
  union "Renal Interventions"
  union "End Stage Renal Disease Encounter"
  union "Protein Urea Lab Test" ) ScreeningNephropathy
  where Global."NormalizeInterval"(ScreeningNephropathy.relevantDatetime, ScreeningNephropathy.relevantPeriod)
    during "Measurement Period"

/*
2.	Hospice Library “Hospice.Has Hospice”
*/

exists ( ["Encounter, Performed": "Encounter Inpatient"] DischargeHospice
    where ( DischargeHospice.dischargeDisposition ~ "Discharge to home for hospice care (procedure)"
        or DischargeHospice.dischargeDisposition ~ "Discharge to healthcare facility for hospice care (procedure)"
    )
      and DischargeHospice.relevantPeriod ends during "Measurement Period"
)
  or exists ( ["Intervention, Order": "Hospice care ambulatory"] HospiceOrder
      where HospiceOrder.authorDatetime during "Measurement Period"
  )
  or exists ( ["Intervention, Performed": "Hospice care ambulatory"] HospicePerformed
      where Global."NormalizeInterval"(HospicePerformed.relevantDatetime, HospicePerformed.relevantPeriod)
        overlaps "Measurement Period"
  )

/*
3. CMS104: Encounter with Comfort Measures during Hospitalization
*/

define "Encounter with Comfort Measures during Hospitalization":
  "Ischemic Stroke Encounter" IschemicStrokeEncounter
    with "Intervention Comfort Measures" ComfortMeasure
      such that Coalesce(start of Global."NormalizeInterval"(ComfortMeasure.relevantDatetime, ComfortMeasure.relevantPeriod),
        ComfortMeasure.authorDatetime)
        during Global."HospitalizationWithObservation" ( IschemicStrokeEncounter )

/*
Comment:
-	“Nephropathy Screenings”: Protein Urea Lab Test – [“Laboratory Test, Performed”: "Urine Protein Tests"] (2.16.840.1.113883.3.464.1003.109.12.1024) – 70 LOINC codes – mix of timed urine collections, text strip, unspecified collection.
-	“End Stage Renal Disease Encounter” – [“Encounter, Performed”: "ESRD Monthly Outpatient Services"] (2.16.840.1.113883.3.464.1003.109.12.1014) – 25 CPT codes
-	“Renal Interventions” – [“Intervention, Performed”: "Other Services Related to Dialysis"](2.16.840.1.113883.3.464.1003.109.12.1015) UNION [“Intervention, Performed”: "Dialysis Education"] (2.16.840.1.113883.3.464.1003.109.12.1016) – 4 SNOMED codes
-	“Hospice Care Ambulatory” (2.16.840.1.113762.1.4.1108.15) – 2 SNOMED codes (regime/therapy and procedure)

All of these items likely have variation in documentation in EHR and other software. The urine tests include in one value set spot urines (test strip) and 24 hour or other time collections. Since the method for documentation may include points in time for some and periods for others, NormalizeInterval seems most appropriate. The same applies for the other renal interventions – education, other services, etc. since documentation may be a single point in time or a period. Similarly, hospice care includes 2 SNOMED codes that could be documented in an ambulatory record as points in time (perhaps even day without specific time) as individual visits.  None of these elements lend themselves to consistent use of relevant dateTime or relevantPeriod.  Therefore, Normalized Interval seems appropriate for all.
*/

/*
Assessments, Referrals
*/

/*
1.	CMS149 “Assessment of Cognition Using Standardized Tools or Alternate Methods”
*/

( ["Assessment, Performed": "Standardized Tools for Assessment of Cognition"]
  union ["Intervention, Performed": "Cognitive Assessment"] ) CognitiveAssessment
  with "Dementia Encounter" EncounterDementia
    such that start of "NormalizeInterval"(CognitiveAssessment.relevantDatetime, CognitiveAssessment.relevantPeriod)
      12 months or less on or before day of end of EncounterDementia.relevantPeriod
  where CognitiveAssessment.result is not null

/*
2.	CMS50 “First Referral During Measurement Period
*/

First(
  (
    (["Intervention, Performed": "Referral"] ReferralPerformed
      where Global."NormalizeInterval"(ReferralPerformed.relevantDatetime, ReferralPerformed.relevantPeriod)
        during "Measurement Period"
    )
      union (
        ["Intervention, Order": "Referral"] ReferralOrder
          where ReferralOrder.authorDatetime during "Measurement Period"
          return "Intervention, Performed" { id: ReferralOrder.id, relevantDatetime: ReferralOrder.authorDatetime }
      )
  ) ReferralInterventions
    sort by start of Global."NormalizeInterval"(relevantDatetime, relevantPeriod)
)

/*
1.	CMS2
*/

“Follow Up For Positive Adult Depression Screening”
["Medication, Order": "Adult Depression Medications"]
  union ["Intervention, Order": "Referral for Adult Depression"]
  union ["Intervention, Performed": "Follow Up for Adult Depression"]

“Most Recent Adult Depression Screening Positive and Follow up Provided”
from
  "Most Recent Adult Depression Screening" LastAdultScreen,
  "Follow Up for Positive Adult Depression Screening" FollowUpPositiveAdultScreen,
  "Qualifying Encounter During Measurement Period" QualifyingEncounter
  where LastAdultScreen.relevantDatetime 14 days or less on or before day of start of QualifyingEncounter.relevantPeriod
    and LastAdultScreen.result in "Positive Depression Screening"
    and ( FollowUpPositiveAdultScreen.authorDatetime same day as
      end of QualifyingEncounter.relevantPeriod
        or FollowUpPositiveAdultScreen.relevantDatetime same day as
        end of QualifyingEncounter.relevantPeriod
    )

/*
Comment:
-	"Standardized Tools for Assessment of Cognition (2.16.840.1.113883.3.526.3.1006)" – 8 LOINC concepts indicating scores from evaluation tools
-	"Cognitive Assessment" (2.16.840.1.113883.3.526.3.1332) – 2 SNOMED procedure codes:
-	113014001 Assessment and interpretation of higher cerebral function, cognitive testing (procedure)
-	4719001 Psychological cognitive testing and assessment (procedure)
-	"Referral" (2.16.840.1.113883.3.464.1003.101.12.1046) – 209 SNOMED procedure concepts
-	"Follow Up for Adult Depression" (2.16.840.1.113883.3.526.3.1568) – 39 SNOMED regime/therapy or procedure concepts
-	"Follow Up for Adolescent Depression" (2.16.840.1.113883.3.526.3.1569) – 39 SNOMED regime/therapy or procedure concepts
Many of these concepts reference point in time actions from the standpoint of documentation (use of an evaluation tool or creating a referral). While administration of the evaluation tool or the workflow to process the referral requires a time interval, it would not be recorded as such. Others, such as the interventions to assess cognitive status or to follow up for adult or adolescent depressions, do require time to complete; for example, psychological cognitive testing is a specific set of interview and evaluation tool processes that clearly takes time to complete. However, it is not clear that such assessment would be recorded as anything other than a specific date or, in some cases a dateTime. Therefore, relevant dateTime is likely appropriate. However, especially for the SNOMED “cognitive assessment” and “follow up…” interventions, a measure developer should carefully assess real-world documentation and data availability to determine the best approach to address timing.
*/

/*
Diagnostic Study, Performed
Normalized Interval should be considered:
*/

/*
1.	CMS129 “Bone Scan Study Performed”
*/

["Diagnostic Study, Performed": "Bone Scan"] BoneScan
  with "Prostate Cancer Diagnosis" ActiveProstateCancer
    such that Global."NormalizeInterval"(BoneScan.relevantDatetime, BoneScan.relevantPeriod)
      starts after start of ActiveProstateCancer.prevalencePeriod

/*
1.	CMS143 “Cup to Disc Ratio Performed with Result”
*/

["Diagnostic Study, Performed": "Cup to Disc Ratio"] CupToDiscExamPerformed
  with "Primary Open Angle Glaucoma Encounter" EncounterWithPOAG
    such that Global."Nomralize Interval"(CupToDiscExamPerformed.relevantDatetime, CupToDiscExamPerformed.relevantDatetime)
      during EncounterWithPOAG.relevantPeriod
  where CupToDiscExamPerformed.result is not null

/*
2.	CMS645 “Has Baseline DEXA Scan Two Years Prior to the Start of or Less than Three Months After the Start of ADT”
*/

define "First Androgen Deprivation Therapy":
  First(["Medication, Active": "Androgen deprivation therapy for Urology Care"] InitialADTTherapy
     with "Prostate Cancer Diagnosis" ProstateCancer
       such that Global."NormalizeInterval"(InitialADTTherapy.relevantDatetime, InitialADTTherapy.relevantPeriod) starts on or before
       end ProstateCancer.prevalencePeriod
     with ["Procedure, Order": "Injection of leuprolide acetate for twelve month period (regime/therapy)"] TwelveMonthADTTherapy
       such that TwelveMonthADTTherapy.authorDatetime during Global."NormalizeInterval"(InitialADTTherapy.relevantDatetime, InitialADTTherapy.relevantPeriod)
     where Global."NormalizeInterval"(InitialADTTherapy.relevantDatetime, InitialADTTherapy.relevantPeriod) overlaps "Measurement Period"
     sort by start of Global."NormalizeInterval"(relevantDatetime, relevantPeriod)
  )

define "Has Baseline DEXA Scan Two Years Prior to the Start of or Less than Three Months After the Start of ADT":
  exists ( ( ["Diagnostic Study, Order": "DEXA Dual Energy Xray Absorptiometry, Bone Density for Urology Care"] DEXAOrdered
        with "First Androgen Deprivation Therapy" FirstADT
          such that DEXAOrdered.authorDatetime 3 months or less after start Global."NormalizeInterval"(FirstADT.relevantDatetime, FirstADT.relevantPeriod)
            or DEXAOrdered.authorDatetime 2 years or less before start Global."NormalizeInterval"(FirstADT.relevantDatetime, FirstADT.relevantPeriod)
    )
      union ( ["Diagnostic Study, Performed": "DEXA Dual Energy Xray Absorptiometry, Bone Density for Urology Care"] DEXAPerformed
          with "First Androgen Deprivation Therapy" FirstADT
            such that Global."NormalizeInterval"(DEXAPerformed.relevantDatetime, DEXAPerformed.relevantPeriod)
              3 months or less after start Global."NormalizeInterval"(FirstADT.relevantDatetime, FirstADT.relevantPeriod)
              or Global."NormalizeInterval"(DEXAPerformed.relevantDatetime, DEXAPerformed.relevantPeriod)
                2 years or less before start Global."NormalizeInterval"(FirstADT.relevantDatetime, FirstADT.relevantPeriod)
      )
  )

/*
Comment:
-	"Bone Scan" (2.16.840.1.113883.3.526.3.320) – 26 LOINC concepts (observable entities)
-	"Cup to Disc Ratio" (2.16.840.1.113883.3.526.3.1333) – 2 LOINC concepts (observable entities)
-	"DEXA Dual Energy Xray Absorptiometry, Bone Density for Urology Care" (2.16.840.1.113762.1.4.1151.38) – 2 LOINC concepts (observable entities)
All of these imaging studies take time to complete. Two of them, Bone Scan and DEXA study occur in the Imaging Department; the other, Cup to Disc Ratio, occurs in an ophthalmologist’s office or outpatient ophthalmology suite of a facility.  While each takes time, the imaging software may capture the start and stop times of the studies (i.e., relevantPeriod), the recording of the procedures in the Radiology Information System (RIS), Ophthalmology Information System, or, subsequent reference to the studies in the EHR are likely only to record a date and, possibly, a dateTime. Most likely, these “Diagnostic Study, Performed” data elements will be available only as dates or points in time. The measure developer should carefully assess real-world documentation and data availability to determine the best approach to address timing.  A Normalized Interval will allow retrieval of the information regardless of how the information is documented in the software used but timing may only be able to reference a date in many settings.
*/

/*
Medication, Order
*/

/*
1.	CMS137 “Treatment Initiated With Medication Order”
*/

( ( ["Medication, Order": "Opiate Antagonists"] ) TreatmentInitiatedWithMedication
    with ( "First Dependence Diagnosis During Measurement Period" ) FirstDiagnosed
      such that start of TreatmentInitiatedWithMedication.relevantPeriod
        14 days or less on or after day of start of FirstDiagnosed.prevalencePeriod
)

/*
2.	CMS249 “Has Independent Risk Factors Before Measurement Period
*/

exists ( ( ( ["Procedure, Performed": "Gastric Bypass Surgery"]
      union ["Medication, Active": "Aromatase Inhibitors"]
      union ["Medication, Order": "Aromatase Inhibitors"] ) GastricBypassOrAromataseInhibitor
      where Global."NormalizeInterval"(
        GastricBypassOrAromataseInhibitor.relevantDatetime,
        GastricBypassOrAromataseInhibitor.relevantPeriod
      )
        starts before start "Measurement Period"
  )
    union "Osteoporosis Fracture Probability Assessment"
)

/*
1.	CMS137 “Treatment with Single Medication Order During Measurement Period”
*/

["Medication, Order": "Opiate Antagonists"] MedicationOrderOpiate
  where MedicationOrderOpiate.authorDatetime during "Measurement Period"

/*
Comment:
-	Use case 1 (CMS137): The CQL definition, Treatment Initiation With Medication Order and the alias for ([“Medication, Order”: “Opiate Antagonists”]) TreatmentInitiatedWithMedication are too similar which causes confusion here. Note the order for opiate antagonists does not indicate that it is the initiating treatment until it is combined with the FirstDiagnosed condition as part of the CQL definition.
Note, the timing for the order in the expression assumes knowledge that the EHR frequently does not have. QDM’s “Medication, Order” relevantPeriod is intended to capture the time the patient is expected to start the medication and when the patient is expected to end use of the medication. The EHR does have the time the order was written (author dateTime) which represents a better timing to identify initiation of treatment within 14 days or less on or after day of start of FirstDiagnosed.prevalence period
Current expression
Treatment Initiation With Medication Order
( ( ["Medication, Order": "Opiate Antagonists"] ) TreatmentInitiatedWithMedication
    with ( "First Dependence Diagnosis During Measurement Period" ) FirstDiagnosed
      such that start of TreatmentInitiatedWithMedication.relevantPeriod 14 days or less on or after day of start of FirstDiagnosed.prevalencePeriod
)
Suggested expression (with modified alias
Treatment Initiation With Medication Order
( ( ["Medication, Order": "Opiate Antagonists"] ) TreatmentInitiatedWithMedicationMedicationOrderOpiate
    with ( "First Dependence Diagnosis During Measurement Period" ) FirstDiagnosed
      such that MedicationOrderOpiate.authorDatetime 14 days or less on or after day of start of FirstDiagnosed.prevalencePeriod
)
*** NOTE – Reused the alias for the same [“Medication, Order”: “Opiate Antagonists”] from the definition Treatment with Single Medication Order During Medication Period.  Using the same alias for the same data element throughout the CQL helps a lot with readability. Note, however, that the alias indicates an Opiate order when in fact it is an opioid antagonist order.

Use case 2 (CMS 249):
•	"Gastric Bypass Surgery" (2.16.840.1.113883.3.464.1003.198.12.1050) 16 CPT procedure codes, 61 SNOMED procedure codes – used with QDM datatype “Procedure, Performed”
•	"Aromatase Inhibitors" (2.16.840.1.113883.3.464.1003.196.12.1265) 3 RxNorm concepts (all oral agents) – used with QDM datatypes “Medication, Active” and “Medication, Order”
This is a mixed-use case. “Procedure, Performed” references activities that take time. The anesthesia records may capture the start and stop times as incision and closure times (i.e., relevantPeriod); however, the EHR, even if it is an enterprise system shared by inpatient and ambulatory practices will likely only record a date and, possibly, a dateTime. Most likely, this “Procedure, Performed” data element will be available only as dates or points in time. The “Medication, Active” may include a start time of a relevantPeriod but mostly likely the “Medication, Order” will have an author dateTime with subsequent status as active, but not a relevantPeriod. The measure developer should carefully assess real-world documentation and data availability to determine the best approach to address timing.  Especially for mixed cases such as this CQL definition, a Normalized Interval will allow less burdensome retrieval of the information regardless of how the elements are documented in the software used.

Use case 3 (CMS137): The expression appropriately uses author dateTime for QDM datatype “Medication, Order” (see use case 1 in this section).
*/
