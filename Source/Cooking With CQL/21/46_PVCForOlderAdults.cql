library PVCForOlderAdults version '0.0.016'

using QDM version '5.3'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Anaphylactic Reaction to Pneumococcal Conjugate Vaccine": 'urn:oid:2.16.840.1.113883.3.464.1003.199.12.1027'
valueset "Bone Marrow Transplant": 'urn:oid:2.16.840.1.113883.3.464.1004.1325'
valueset "Cerebrospinal Fluid Leaks": 'urn:oid:2.16.840.1.113883.3.464.1004.1448'
valueset "Chemotherapy": 'urn:oid:2.16.840.1.113883.3.464.1003.108.12.1040'
valueset "Cochlear Implants": 'urn:oid:2.16.840.1.113883.3.464.1004.1447'
valueset "Disorders of the Immune System": 'urn:oid:2.16.840.1.113883.3.464.1003.120.12.1001'
valueset "Functional or Aplastic Anemia": 'urn:oid:2.16.840.1.113883.3.464.1004.1449'
valueset "Pneumococcal 13 Valent Vaccine Administered": 'urn:oid:2.16.840.1.113883.3.464.1004.1439'
valueset "Pneumococcal 23 Valent Vaccine Administration": 'urn:oid:2.16.840.1.113883.3.464.1004.1440'
valueset "Hospice care ambulatory": 'urn:oid:2.16.840.1.113762.1.4.1108.15'
valueset "Anaphylactic Reaction Due To Vaccination": 'urn:oid:2.16.840.1.113883.3.464.1004.1024'

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

define "Initial Population":
	AgeInYearsAt(start of "Measurement Period")>= 65

define "Denominator":
	"Initial Population"

define "Pneumoccal 13 Valent Vaccine":
	["Immunization, Administered": "Pneumococcal 13 Valent Vaccine Administered"]

define "Pneumoccal 23 Valent Vaccine":
	["Immunization, Administered": "Pneumococcal 23 Valent Vaccine Administration"]

define "Stratifier 1":
	AgeInYearsAt(start of "Measurement Period")in Interval[65, 74]

define "Stratifier 2":
	AgeInYearsAt(start of "Measurement Period")in Interval[75, 84]

define "Stratifier 3":
	AgeInYearsAt(start of "Measurement Period")>= 85

define "Aplastic or Functional Anemia":
	["Diagnosis": "Functional or Aplastic Anemia"] A
		where A.prevalencePeriod overlaps "Measurement Period"

define "CSF":
	["Diagnosis": "Cerebrospinal Fluid Leaks"] F
		where F.prevalencePeriod overlaps "Measurement Period"

define "Cochlear Implant":
	["Procedure, Performed": "Cochlear Implants"] C
		where C.relevantPeriod overlaps "Measurement Period"

define "Exclusions":
	exists ( ["Procedure, Performed": "Chemotherapy"] C
			where C.relevantPeriod overlaps "Measurement Period"
	)
		or exists ( ["Procedure, Performed": "Bone Marrow Transplant"] B
				where B.relevantPeriod overlaps "Measurement Period"
		)
		or exists ( ["Diagnosis": "Anaphylactic Reaction to Pneumococcal Conjugate Vaccine"] C
				where C.prevalencePeriod overlaps "Measurement Period"
		)
		or exists ( ["Diagnosis": "Anaphylactic Reaction Due To Vaccination"] D
				where D.prevalencePeriod overlaps "Measurement Period"
		)
		or exists ( ["Intervention, Performed": "Hospice care ambulatory"] E
				where E.relevantPeriod overlaps "Measurement Period"
		)

define "Immunocompromising Conditions":
	exists ( "Cochlear Implant"
			union "Aplastic or Functional Anemia"
			union "Immune Disorders"
			union "CSF"
	)

/* The numerator should only be satisfied for this measure if the patient
 is NOT immunocompromised and received both pneumococcal vaccinations after age 60  
 OR is immunocompromised and received both pneumococcal vaccinations age 2.
*/

define "Numerator":
	( not "Immunocompromising Conditions"
			and exists "Pneumococcal vaccines after age 60"
	)
		or ( "Immunocompromising Conditions"
				and "Pneumococcal vaccines after age 2"
		)

define "Pneumococcal vaccines after age 60":
	"Pneumoccal 13 and 23 12 months apart" A
		where AgeInYearsAt(A.authorDatetime)>= 60

define "Pneumoccal 13 and 23 12 months apart":
	"Pneumoccal 13 Valent Vaccine" A
		with "Pneumoccal 23 Valent Vaccine" B
			such that months between A.authorDatetime and B.authorDatetime >= 12
				or months between B.authorDatetime and A.authorDatetime >= 12

define "Pneumococcal vaccines after age 2":
	exists ( "Pneumoccal 12 and 23 8 weeks apart" A
			where AgeInYearsAt(A.authorDatetime)>= 2
	)

define "Pneumoccal 12 and 23 8 weeks apart":
	"Pneumoccal 13 Valent Vaccine" A
		with "Pneumoccal 23 Valent Vaccine" B
			such that weeks between A.authorDatetime and B.authorDatetime >= 8
				or weeks between B.authorDatetime and A.authorDatetime >= 8

/*
The problem with this formulation is that we are only checking the age of the
first administration in each case, and since the timing of the related vaccinations
only checks that they are at least 8 weeks or 12 months apart, having a single
vaccination at age, say, 3, and a second vaccination at age, say, 61, would
satisfy the criteria.

What we need to do is ensure that both vaccinations satisfy the age requirement:
*/

define "Pneumoccal 13 Valent Vaccine After Age 2":
  "Pneumoccal 13 Valent Vaccine" A
	  where AgeInYearsAt(A.authorDatetime) >= 2
		
define "Pneumoccal 23 Valent Vaccine After Age 2":
  "Pneumoccal 23 Valent Vaccine" A
	  where AgeInYearsAt(A.authorDatetime) >= 2

define "Pneumoccal 13 Valent Vaccine After Age 60":
  "Pneumoccal 13 Valent Vaccine" A
	  where AgeInYearsAt(A.authorDatetime) >= 60
		
define "Pneumoccal 23 Valent Vaccine After Age 60":
  "Pneumoccal 23 Valent Vaccine" A
	  where AgeInYearsAt(A.authorDatetime) >= 60

/*
We can then use these definitions to write the 8 weeks and 12 months expressions
*/
define "Pneumococcal 13 and 23 12 months apart after age 60":
	"Pneumoccal 13 Valent Vaccine After Age 60" A
		with "Pneumoccal 23 Valent Vaccine After Age 60" B
			such that months between A.authorDatetime and B.authorDatetime >= 12
				or months between B.authorDatetime and A.authorDatetime >= 12

define "Pneumococcal 13 and 23 8 weeks apart after age 2":
	"Pneumoccal 13 Valent Vaccine After Age 2" A
		with "Pneumoccal 23 Valent Vaccine After Age 2" B
			such that weeks between A.authorDatetime and B.authorDatetime >= 8
				or weeks between B.authorDatetime and A.authorDatetime >= 8

/*
And then use these in the expression of the numerator:
*/

define "Numerator (updated)":
	( not "Immunocompromising Conditions"
			and exists "Pneumococcal 13 and 23 12 months apart after age 60"
	)
		or ( "Immunocompromising Conditions"
				and exists "Pneumococcal 13 and 23 8 weeks apart after age 2"
		)

define "Immune Disorders":
	["Diagnosis": "Disorders of the Immune System"] D
		where D.prevalencePeriod overlaps "Measurement Period"
