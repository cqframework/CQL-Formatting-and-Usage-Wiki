////////////////////////////////////////////////////////////////////////////////
// NCQA Measures using list promotion of boolean-valued expressions: 4

/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\NCQA\_CQL\IETv137-0.0.002.cql
Translation completed with messages:
Warning:[96:12, 96:31] Boolean-valued expression was promoted to a list.
ELM output written to: C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\NCQA\_CQL\IETv137-0.0.002.xml
*/

// EncounterTreatment is a yes/no result, so the use of exists is incorrect:
define "Numerator 2": "Numerator 1"
and exists "EncounterTreatment"

// Naming this something that indicates it returns a yes/no would potentially help:
// Something like "Has Encounter Treatments"
define "Has Encounter Treatments": 
  Count((["Encounter, Performed": "Alcohol and Drug Dependence Treatment"]
    union ["Encounter, Performed": "Psych Visit - Psychotherapy"]) ENT
    with ("DrugDependenceTreatment") DDT
    such that ENT.relevantPeriod starts 30 days or less after start of DDT.relevantPeriod) >=2

// Then the appearance of an exists would be an immediate flag because it wouldn't read well:
define "Numerator 2":
  "Numerator 1"
    and exists "Has Encounter Treatments"

// So the correct expression is:
define "Numerator 2":
  "Numerator 1"
    and "Has Encounter Treatments"
    
/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\NCQA\_CQL\Test165-0.0.002.cql
Translation completed with messages:
Warning:[103:59, 103:78] Boolean-valued expression was promoted to a list.
ELM output written to: C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\NCQA\_CQL\Test165-0.0.002.xml
*/

// Hospice Exclusions is actually a yes/no, so again, the exists is incorrect
define "Denominator Exclusions": exists HospiceExclusions."Hospice Exclusions" or 
exists "Exclusion Diagnoses" or
(exists "Exclusions Procedures"
or exists "Exclusion Encounter")

// And again, naming it something like "Has Hospice Exclusions" would make that clear:
define "Denominator Exclusions":
  HospiceExclusions."Has Hospice Exclusions"
    or exists "Exclusion Diagnoses"
    or exists "Exclusions Procedures"
    or exists "Exclusion Encounter"

/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\NCQA\_CQL\MDS82-0.0.002.cql
Translation completed with messages:
Warning:[47:11, 47:26] Boolean-valued expression was promoted to a list.
Warning:[48:12, 48:23] Boolean-valued expression was promoted to a list.
ELM output written to: C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\NCQA\_CQL\MDS82-0.0.002.xml
*/

// Here, the use of InDemographic1 is okay, but InDemographic2 and Encounters are both yes/no
define "Initial Population": exists "InDemographic1"
or exists "InDemographic2"
and exists "Encounters"

define "InDemographic1": ["Patient Characteristic Birthdate": "Birthdate"] PCB
    where PCB.birthDatetime occurs 5 months or less before start of "Measurement Period"

define "InDemographic2": exists(["Patient Characteristic Birthdate"] PB
                where PB.birthDatetime after start of "Measurement Period"
                                and PB.birthDatetime 6 months or more before end of "Measurement Period")

define "Encounters": exists((["Encounter, Performed": "Face-to-Face Interaction"]
      union ["Encounter, Performed": "Office Visit"]
      union ["Encounter, Performed": "BH Medical or psychiatric consultation"]) Ent
         where AgeInMonthsAt(Ent.authorDatetime)<= 6)

/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\NCQA\_CQL\CDC122-0.0.004.cql
Translation completed with messages:
Warning:[69:28, 69:56] Boolean-valued expression was promoted to a list.
Warning:[73:47, 74:73] Boolean-valued expression was promoted to a list.
Warning:[70:19, 70:50] Boolean-valued expression was promoted to a list.
ELM output written to: C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\NCQA\_CQL\CDC122-0.0.004.xml
*/

define "Recent Lab Test with Result": Last(["Laboratory Test, Performed": "HbA1c Laboratory Test"] Test
    where Test.relevantPeriod during "Measurement Period"
        and Test.result is not null).result > 9 '%'

define "Numerator": exists "Recent Lab Test with Result"
        or exists "Recent Lab Test with No Result"
        or "Lab Test Not Done"

define "Recent Lab Test with No Result": Last((["Laboratory Test, Performed": "HbA1c Laboratory Test"] Test
    where Test.relevantPeriod during "Measurement Period").result is null)

define "Lab Test Not Done": not exists ["Laboratory Test, Performed": "HbA1c Laboratory Test"] LTP
    where LTP.relevantPeriod during "Measurement Period"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// NCQA Measures using list promotion: 8

/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\NCQA\_CQL\IETv137-0.0.002.cql
Translation failed due to errors:
Error:[86:5, 86:41] Could not resolve call to operator Exists with signature (QDM.Diagnosis).
Error:[88:23, 88:42] Could not validate reference to expression Initial Population because its definition contains errors.
Error:[96:5, 96:31] Could not resolve call to operator Exists with signature (System.Boolean).
*/


define "InDemographic": AgeInYearsAt(start of "Measurement Period") >= 13

define "FirstAlcoholDrugDependenceDx": First (["Diagnosis": "Alcohol and Drug Dependence"] DADD
    with ("FirstAlcoholEncounters") ENT
    such that DADD.prevalencePeriod starts 319 days or less after start of "Measurement Period"
)

// This is a valid use of list promotion, and enables the author to write this:
define "Initial Population": 
  "InDemographic"
    and exists "FirstAlcoholDrugDependenceDx"
    
// Rather than this:
define "Initial Population":
  "InDemographic"
    and "FirstAlcoholDrugDependenceDx" is not null
    
/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\NCQA\_CQL\TestCMS146-5.1.008.cql
Translation failed due to errors:
Error:[64:39, 64:46] Could not resolve call to operator Contains with signature (QDM.PositiveEncounterPerformed,QDM.PositiveEncounterPerformed).
Error:[87:51, 87:58] Could not resolve call to operator Contains with signature (QDM.Diagnosis,QDM.Diagnosis).
*/

define "Numerator": 
  exists(
    from
      "Streptococcus Lab Test" StrepLabTest,
      ["Encounter, Performed": "Ambulatory/ED Visit"] Encounter,
      "Diagnosis Related Encounters" DiagnosticEncounter
    where start of StrepLabTest.relevantPeriod 3 days or less before end of Encounter.relevantPeriod
      or start of StrepLabTest.relevantPeriod 3 days or less after end of Encounter.relevantPeriod
      and DiagnosticEncounter.Visit includes Encounter // This "includes" does not work as expected, it's promoting to set inclusion, which is not what's intended
      // This should read "DiagnosticEncounter.Visit.relevantPeriod includes Encounter.relevantPeriod"
  )

define "Diagnosis Related Encounters": 
  from
    (["Encounter, Performed": "Ambulatory/ED Visit"] Encounter
      with ["Medication, Order": "Antibiotic Medications for Pharyngitis"] Antibiotic
        such that Encounter.relevantPeriod starts 3 days or less before Antibiotic.authorDatetime
          or Encounter.relevantPeriod starts same as Antibiotic.authorDatetime
        where Encounter.relevantPeriod during "Measurement Period") Visit,
    "Pharyngitis or Tonsillitis" AcutePharyngitisTonsillitis
  where Visit.relevantPeriod overlaps AcutePharyngitisTonsillitis.prevalencePeriod

/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\NCQA\_CQL\CCS124-0.0.002.cql
Translation failed due to errors:
Error:[82:40, 82:54] Could not resolve call to operator In with signature (interval<System.DateTime>,interval<System.DateTime>).
Error:[75:11, 75:44] Could not validate reference to expression Pap Test With HPV Within 5 Years because its definition contains errors.
*/

// Another example of promotion not working as expected
define "Pap Test With HPV Within 5 Years": "Pap Test with Results" Test
    with "HPV Test With Results" HPVTest
      such that HPVTest.relevantPeriod within 1 day of Test.relevantPeriod // "within" as a clause expects times, not periods
      // but with list promotion enabled, this promotes to a membership test of the interval within a list of the interval (because within translates as an "in")
    where (AgeInYearsAt(start of Test.relevantPeriod) >= 30)
      and Test.relevantPeriod 5 years or less before end of "Measurement Period"

/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\NCQA\_CQL\AntidepressantMedicationManagement-0.0.003.cql
Translation failed due to errors:
Error:[63:16, 64:25] Could not resolve call to operator First with signature (System.DateTime).
Error:[56:39, 56:44] Could not validate reference to expression IPSD because its definition contains errors.
Error:[58:39, 58:44] Could not validate reference to expression IPSD because its definition contains errors.
Error:[61:95, 61:114] Could not validate reference to expression IPSD plus 231 days because its definition contains errors.
Error:[67:94, 67:113] Could not validate reference to expression IPSD plus 114 days because its definition contains errors.
*/

// This case is harmless, because it just promoted the result of a First so it could call First again,
// but it is redundant, the First in the definition of IPSD is unnecessary.
define "IPSD": First(("Medication Dispensed 270 days before or 90 days after Start of Measurement Period") MD
return MD.authorDatetime)

// "IPSD" could be simplified to just an element access:
define "IPSD": "Medication Dispensed 270 days before or 90 days after Start of Measurement Period".authorDatetime

define "Medication Dispensed 270 days before or 90 days after Start of Measurement Period": 
  First(["Medication, Dispensed": "Antidepressant Medication"] DepMedDisp
    where DepMedDisp.authorDatetime 270 days or less before start of "Measurement Period"
      or DepMedDisp.authorDatetime 90 days or less after start of "Measurement Period"
      or DepMedDisp.authorDatetime same as start of "Measurement Period" sort by authorDatetime
  )

/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\NCQA\_CQL\HIV52-0.0.003.cql
Translation failed due to errors:
Error:[96:5, 96:28] Could not resolve call to operator Exists with signature (QDM.Diagnosis).
Error:[103:24, 103:44] Could not validate reference to expression Initial Population3 because its definition contains errors.
*/

// This is also a valid use of list promotion, just enabling the author to write the following:
define "Initial Population3": "InDemographic3"
and exists "First Diagnosis"
and exists "Followup HIV Visit"

// Rather than:
define "Initial Population3":
  "InDemographic3" // yes/no
    and "First Diagnosis" is not null // singleton
    and exists "Followup HIV Visit" // list<Encounter>

////////////////////////////////////////////////////////////////////////////////
// PCPI Measures using list promotion of boolean-valued expressions: 5

/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\PCPI\_CQL\TestCMS135-0.0.003.cql
Translation completed with messages:
Warning:[121:17, 121:36] Boolean-valued expression was promoted to a list.
ELM output written to: C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\PCPI\_CQL\TestCMS135-0.0.003.xml
*/

// exists "Two or More Visits" is incorrect, "Two or More Visits" is already a yes/no
define "Initial Population": AgeInYearsAt(start of "Measurement Period") >= 18
    and (exists "Two or More Visits" or exists "Inpatient Discharge")
    and exists "Heart Failure Diagnosis"

// So the correct expression is:
define "Initial Population": AgeInYearsAt(start of "Measurement Period") >= 18
    and ("Two or More Visits" or exists "Inpatient Discharge")
    and exists "Heart Failure Diagnosis"

/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\PCPI\_CQL\TestCMS149-0.0.006.cql
Translation completed with messages:
Warning:[108:13, 108:45] Boolean-valued expression was promoted to a list.
ELM output written to: C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\PCPI\_CQL\TestCMS149-0.0.006.xml
*/

// No need for the exists here, the result of Count("Provider Encounters" >= 2) is already a yes/no
define "Initial Population": exists "Dementia and Mental Degenerations Diagnosis"
and exists (Count("Provider Encounters") >= 2)

// So the correct expression is:
define "Initial Population": exists "Dementia and Mental Degenerations Diagnosis"
  and Count("Provider Encounters") >= 2

/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\PCPI\_CQL\TestCMS50-0.0.003.cql
Translation completed with messages:
Warning:[52:30, 52:49] Boolean-valued expression was promoted to a list.
ELM output written to: C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\PCPI\_CQL\TestCMS50-0.0.003.xml
*/

// The "exists" is incorrect here, "Initial Population" is already a yes/no
define "Denominator": exists "Initial Population"

// So the correct expression is:
define "Denominator": "Initial Population"

/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\PCPI\_CQL\TestCMS142-0.0.005.cql
Translation completed with messages:
Warning:[127:28, 127:70] Boolean-valued expression was promoted to a list.
ELM output written to: C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\PCPI\_CQL\TestCMS142-0.0.005.xml
*/

// The "exists" is incorrect here, "Communication of Diagnostic Study Results" is already a yes/no
define "Numerator": exists "Communication of Diagnostic Study Results"

define "Communication of Diagnostic Study Results": 
  exists "Communicate Level of Severity of Retinopathy Findings"
    and (exists "Communicate Macular Edema Absent"
      or exists "Communicate Macular Edema Present"
    )

// So the correct expression is:
define "Numerator": "Communication of Diagnostic Study Results"

/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\PCPI\_CQL\TestCMS144-0.0.002.cql
Translation completed with messages:
Warning:[118:17, 118:36] Boolean-valued expression was promoted to a list.
Warning:[212:11, 212:56] Boolean-valued expression was promoted to a list.
ELM output written to: C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\PCPI\_CQL\TestCMS144-0.0.002.xml
*/

// Same issue as 135

////////////////////////////////////////////////////////////////////////////////
// PCPI Measures using list promotion: 7

/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\PCPI\_CQL\TestCMS138-0.0.003.cql
Translation failed due to errors:
Error:[75:23, 75:73] Could not resolve call to operator Exists with signature (QDM.PositiveAssessmentPerformed).
Error:[89:9, 89:56] Could not resolve call to operator Exists with signature (QDM.PositiveAssessmentPerformed).
Error:[139:23, 139:73] Could not resolve call to operator Exists with signature (QDM.PositiveAssessmentPerformed).
*/

// This measure uses list promotion appropriately, allowing the author to write this:
define "Numerator 1": 
  exists "Screened and Identified as Tobacco NonUser"
    or exists "Screened and Identified as Tobacco User"
    
// Rather than this:
define "Numerator 1":
  "Screened and Identified as Tobacco NonUser" is not null
    or "Screened and Identifier as Tobacco User" is not null

define "Screened and Identified as Tobacco NonUser": Last (["Assessment, Performed": "Tobacco Use Screening"] Assess 
    let "Result" : (Assess.result as Code)
    where Assess.authorDatetime 24 months or less before end of "Measurement Period"
    and "Result" in "Tobacco Non-User"
    sort by authorDatetime)

define "Screened and Identified as Tobacco User": Last (["Assessment, Performed": "Tobacco Use Screening"] Assess 
    let "Result" : (Assess.result as Code)
    where Assess.authorDatetime 24 months or less before end of "Measurement Period"
    and "Result" in "Tobacco User"
    sort by authorDatetime)

/*
================================================================================
TRANSLATE C:\Users\Bryn\Documents\Src\SS\Docs\CQLTestingVendorEngagement\TestMeasures-2017-08-14\PCPI\_CQL\TestCMS129-0.0.005.cql
Translation failed due to errors:
Error:[92:5, 92:44] Could not resolve call to operator Exists with signature (QDM.PositiveProcedurePerformed).
*/

// This measure uses list promotion appropriately:
define "Denominator": "Initial Population"
and exists "First Prostate Cancer Treatment" // A single procedure
and exists "Most Recent Prostate Cancer Staging Tumor Size"
and exists "Most Recent PSA Test Result"
and exists "Most Recent Gleason Score Test Result"

// Without list promotion, the expression would be:
define "Denominator": "Initial Population"
and "First Prostate Cancer Treatment" is not null
and "Most Recent Prostate Cancer Staging Tumor Size" is not null
and "Most Recent PSA Test Result" is not null
and "Most Recent Gleason Score Test Result" is not null

