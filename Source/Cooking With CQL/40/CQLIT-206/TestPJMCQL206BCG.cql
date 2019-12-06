library TestPJMCQL206BCG version '0.0.011'

/*Testing only
based on:
IntravesicalBacillusCalmetteGuerinfornonmuscleinvasivebladdercancer version '0.1.008'
Recommend caution re length of library name since can afffect zip files.
Comments added within test script near associated definition.*/

using QDM version '5.5'

codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'
codesystem "SNOMEDCT": 'urn:oid:2.16.840.1.113883.6.96'
codesystem "ICD10CM": 'urn:oid:2.16.840.1.113883.6.90'

valueset "Active Tuberculosis for Urology Care": 'urn:oid:2.16.840.1.113762.1.4.1151.56'
valueset "BCG Bacillus Calmette Guerin for Urology Care": 'urn:oid:2.16.840.1.113762.1.4.1151.52'
valueset "Bladder Cancer for Urology Care": 'urn:oid:2.16.840.1.113762.1.4.1151.45'
valueset "Bladder Cancer Staging Tis for Urology Care": 'urn:oid:2.16.840.1.113762.1.4.1151.58'
valueset "Cystectomy for Urology Care": 'urn:oid:2.16.840.1.113762.1.4.1151.55'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "HIV": 'urn:oid:2.16.840.1.113883.3.464.1003.120.12.1003'
valueset "Immunocompromised Conditions": 'urn:oid:2.16.840.1.113883.3.666.5.1940'
valueset "Immunosuppressive Drugs for Urology Care": 'urn:oid:2.16.840.1.113762.1.4.1151.32'
valueset "Mixed histology urothelial cell carcinoma for Urology Care": 'urn:oid:2.16.840.1.113762.1.4.1151.39'
valueset "Office Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Unavailability of Bacillus Calmette Guerin for urology care": 'urn:oid:2.16.840.1.113762.1.4.1151.44'

code "Birth date": '21112-8' from "LOINC" display 'Birth date'
code "Cancer staging (tumor staging)": '258232002' from "SNOMEDCT" display 'Cancer staging (tumor staging)'
code "Carcinoma in situ of bladder": 'D09.0' from "ICD10CM" display 'Carcinoma in situ of bladder'
code "Chemotherapy care (regime/therapy)": '385786002' from "SNOMEDCT" display 'Chemotherapy care (regime/therapy)'
code "Combined radiotherapy (procedure)": '169331000' from "SNOMEDCT" display 'Combined radiotherapy (procedure)'
code "Dead (finding)": '419099009' from "SNOMEDCT" display 'Dead (finding)'
code "High grade histologic differentiation (finding)": '399611001' from "SNOMEDCT" display 'High grade histologic differentiation (finding)'
code "T1: Tumor invades lamina propria or submucosa (finding)": '369909002' from "SNOMEDCT" display 'T1: Tumor invades lamina propria or submucosa (finding)'
code "Ta: Noninvasive papillary carcinoma (urinary tract) (finding)": '369949005' from "SNOMEDCT" display 'Ta: Noninvasive papillary carcinoma (urinary tract) (finding)'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "SDE Ethnicity":
  ["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer":
  ["Patient Characteristic Payer": "Payer"]

define "SDE Race":
  ["Patient Characteristic Race": "Race"]

define "SDE Sex":
  ["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Denominator Exclusion":
  exists "HIV Diagnosis"
    or exists "Immunocompromised Conditions Diagnosis"
    or exists "Immunosuppressive Drugs"
    or exists "Acute Tuberculosis Diagnosis"
    or exists "Mixed Histology Urothelial Cell Carcinoma"
    or exists "Cystectomy Done"
    or exists "Chemotherapy Exclusion"
    or exists "Radiation Done"

define "Numerator":
  "First BCG Administered" is not null

define "Radiation Done":
  ["Procedure, Performed": "Combined radiotherapy (procedure)"] Radiation
    with "First BCG Administered" FirstBCG
      such that Radiation.relevantPeriod starts 6 months or less before start of FirstBCG.relevantPeriod

define "Denominator":
  "Initial Population"

define "Denominator Exception":
  exists "BCG Not Available"

define "BCG Not Available":
  ( ["Medication, Not Administered": "BCG Bacillus Calmette Guerin for Urology Care"] BCGShortage
      where BCGShortage.negationRationale in "Unavailability of Bacillus Calmette Guerin for urology care"
  )

define "First BCG Administered":
  First(["Medication, Administered": "BCG Bacillus Calmette Guerin for Urology Care"] BCG
      with "Bladder Cancer Diagnosis" BladderCancer
        such that BCG.relevantPeriod starts 6 months or less after start BladderCancer.prevalencePeriod
          and BCG.relevantPeriod overlaps "Measurement Period"
      sort by start of relevantPeriod
  )

define "Immunosuppressive Drugs":
  ["Medication, Active": "Immunosuppressive Drugs for Urology Care"] ImmunosuppressiveRx
    where ImmunosuppressiveRx.relevantPeriod starts same day or before
    end "Measurement Period"

define "HIV Diagnosis":
  ["Diagnosis": "HIV"] HIV
    where HIV.prevalencePeriod starts same day or before
    end "Measurement Period"

define "Immunocompromised Conditions Diagnosis":
  ["Diagnosis": "Immunocompromised Conditions"] ImmunocompromisedDx
    where ImmunocompromisedDx.prevalencePeriod starts same day or before
    end "Measurement Period"

define "Acute Tuberculosis Diagnosis":
  ["Diagnosis": "Active Tuberculosis for Urology Care"] TB
    where TB.prevalencePeriod starts same day or before
    end "Measurement Period"

define "Mixed Histology Urothelial Cell Carcinoma":
  ["Diagnosis": "Mixed histology urothelial cell carcinoma for Urology Care"] MixedHisto
    where MixedHisto.prevalencePeriod starts same day or before
    end "Measurement Period"

define "Cystectomy Done":
  ["Procedure, Performed": "Cystectomy for Urology Care"] Cystectomy
    with "First BCG Administered" FirstBCG
      such that Cystectomy.relevantPeriod starts 6 months or less before start of FirstBCG.relevantPeriod

define "Chemotherapy Exclusion":
  ["Medication, Active": "Chemotherapy care (regime/therapy)"] Chemo
    with "First BCG Administered" FirstBCG
      such that Chemo.relevantPeriod starts 6 months or less before start of FirstBCG.relevantPeriod

  // original
  //define "Qualifying Encounter":
  //  First(["Encounter, Performed": "Office Visit"] Encounter
  //      where Encounter.relevantPeriod during "Measurement Period"
  //  )

  // definition "Qualifying Encounter" is accepted by MAT but not used since moved qualifying encounter expression into IPP
define "Qualifying Encounter":
  ["Encounter, Performed": "Office Visit"] Encounter
      where Encounter.relevantPeriod during "Measurement Period"

  // original IPP
  //define "Initial Population":
  //  "Bladder Cancer Diagnosis"
  //  and "Qualifying Encounter"
  //  and "Most Recent Bladder Cancer Staging Tumor Ta HG, Tis, T1"

  // population must be boolean (use exists for true/false with lists)
  // staging tumor expressions return true/false
  // Qualifying Encounter caused issue so moved expression into IPP

define "Initial Population":
  exists ( "Bladder Cancer Diagnosis" )
    and "Most Recent Bladder Cancer Staging Tumor Ta HG, Tis, T1"
    and exists "Qualifying Encounter"


  //define "Most Recent Bladder Cancer Staging Tumor Ta HG, Tis, T1":
  //  (Last BladderCancerStaging
  //  	where ( LastBladderCancerStaging.result ~ "T1: Tumor invades lamina propria or submucosa (finding)"
  //  			or LastBladderCancerStaging.result ~ "Ta: Noninvasive papillary carcinoma (urinary tract) (finding)"
  //  			or LastBladderCancerStaging.result ~ "Bladder Cancer staging Tis for Urology Care")

  //first two are codes, but last is oid valueset so need 'in operator'

define "Most Recent Bladder Cancer Staging Tumor Ta HG, Tis, T1":
  "Bladder Cancer Staging".result ~ "T1: Tumor invades lamina propria or submucosa (finding)"
    or "Bladder Cancer Staging".result ~ "Ta: Noninvasive papillary carcinoma (urinary tract) (finding)"
    or "Bladder Cancer Staging".result in ( "Bladder Cancer Staging Tis for Urology Care" )


  // original expression
  //define "Bladder Cancer Staging":
  //  ( Last(["Procedure, Performed": "Cancer staging (tumor staging)"] BladderCancerStaging
  //        with "First BCG Administered" BCGGiven
  //          such that BladderCancerStaging.relevantPeriod starts before start of BCGGiven.relevantPeriod
  //        sort by start of relevantPeriod
  //    )
  //  )

define "Bladder Cancer Staging":
  ( Last(["Procedure, Performed": "Cancer staging (tumor staging)"] BladderCancerStaging
        with "First BCG Administered" BCGGiven
          such that BladderCancerStaging.relevantPeriod starts before start of BCGGiven.relevantPeriod
        sort by start of relevantPeriod
    )
  )

  // original expression
  //define "Bladder Cancer Diagnosis":
  //  singleton from ( ["Diagnosis": "Bladder Cancer for Urology Care"] BladderCancer
  //      where BladderCancer.prevalencePeriod starts same day or before
  //      end "Measurement Period"
  //  )

  // should not need to use singleton for Dx, will use exists for IPP

define "Bladder Cancer Diagnosis":
  ["Diagnosis": "Bladder Cancer for Urology Care"] BladderCancer
    where BladderCancer.prevalencePeriod starts same day or before
    end "Measurement Period"
