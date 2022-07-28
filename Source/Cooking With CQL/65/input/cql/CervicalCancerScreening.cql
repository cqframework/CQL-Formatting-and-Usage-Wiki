/*
Quality Measurement

Based on
[CMS124 - Cervical Cancer Screening](https://ecqi.healthit.gov/sites/default/files/ecqm/measures/CMS124v9.html)

## Description
Percentage of women 21-64 years of age who were screened for cervical cancer using either of the following criteria:
*  Women age 21-64 who had cervical cytology performed within the last 3 years
*  Women age 30-64 who had cervical human papillomavirus (HPV) testing performed within the last 5 years

## Initial Population
Women 23-64 years of age with a visit during the measurement period

## Denominator
Equals Initial Population

## Denominator Exclusions
Women who had a hysterectomy with no residual cervix or a congenital absence of cervix.
Exclude patients whose hospice care overlaps the measurement period.

## Numerator
Women with one or more screenings for cervical cancer. Appropriate screenings are defined by any one of the following criteria:
*  Cervical cytology performed during the measurement period or the two years prior to the measurement period for women who are at least 21 years old at the time of the test
*  Cervical human papillomavirus (HPV) testing performed during the measurement period or the four years prior to the measurement period for women who are 30 years or older at the time of the test

NOTE: This example is for instructional purposes only and is dervied from work in progress.
It should in no way be considered a final specification or recommendation for guidance.
The example is derived from work in progress by the Centers for Medicare and Medicaid Services,
see the original project repository for more information: https://github.com/cqframework/ecqm-content-r4
*/
library CervicalCancerScreening

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include FHIRCommon version '4.0.1' called FC

codesystem "SNOMEDCT:2017-09": 'http://snomed.info/sct/731000124108' version 'http://snomed.info/sct/731000124108/version/201709'

valueset "Hysterectomy with No Residual Cervix": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1014'
valueset "Pap Test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1017'
valueset "HPV Test": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.110.12.1059'

code "Congenital absence of cervix (disorder)": '37687000' from "SNOMEDCT:2017-09" display 'Congenital absence of cervix (disorder)'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2019-01-01T00:00:00.0, @2020-01-01T00:00:00.0)

context Patient

/*
Build expressions for the
* Initial Population
* Denominator
* Denominator Exclusion
* Numerator

HINT: Express the intermediates first:
* Cervical Cytology Within 3 Years
* HPV Test Within 5 Years For Women Age 30 and Older
*/

define "Absence of Cervix":
  ([Procedure: "Hysterectomy with No Residual Cervix"] NoCervixProcedure
    where FC.ToInterval(NoCervixProcedure.performed) ends on or before end of "Measurement Period"
      and NoCervixProcedure.status = 'completed'
  )
    union [Condition : "Congenital absence of cervix (disorder)"] NoCervixBirth
  		where FC.ToInterval(NoCervixBirth.onset) starts on or before end of "Measurement Period"

define "Cervical Cytology Within 3 Years":
	[Observation: "Pap Test"] CervicalCytology
		where CervicalCytology.value is not null
			and CervicalCytology.status in { 'final', 'amended', 'corrected', 'preliminary' }
		  and FC.ToInterval(CervicalCytology.effective) ends 3 years or less on or before end of "Measurement Period"

define "HPV Test Within 5 Years for Women Age 30 and Older":
	[Observation: "HPV Test"] HPVTest
    where HPVTest.value is not null
      and HPVTest.status in { 'final', 'amended', 'corrected', 'preliminary' }
      and AgeInYearsAt(start of FC.ToInterval(HPVTest.effective)) >= 30
      and FC.ToInterval(HPVTest.effective) ends 5 years or less on or before end of "Measurement Period"

define "Initial Population":
	Patient.gender = 'female'
		and AgeInYearsAt(start of "Measurement Period") in Interval[23, 64]

define "Denominator":
	"Initial Population"

define "Denominator Exclusion":
		exists "Absence of Cervix"

define "Numerator":
	exists "Cervical Cytology Within 3 Years"
		or exists "HPV Test Within 5 Years for Women Age 30 and Older"

