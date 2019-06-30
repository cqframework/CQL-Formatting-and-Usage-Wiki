library Example.Timing version '0.1.000'

using QDM version '5.5'

context Patient

//****
// CMS90 – example
// Assessment, Performed: Followup Heart Failure FSA

define "Assessed Initial and Followup PROMIS29":
  "Initial Encounter" Encounter
  	with "PROMIS29 Total Assessment Scores" InitialPROMIS29
  		such that InitialPROMIS29.authorDatetime 14 days or less on or before Encounter.relevantPeriod
  	with "PROMIS29 Total Assessment Scores" FollowupPROMIS29
  		such that FollowupPROMIS29.authorDatetime 30 days or more after day of end of Encounter.relevantPeriod
  			and FollowupPROMIS29.authorDatetime 180 days or less after day of end of Encounter.relevantPeriod

// Consider:	QDM 5.5 allows use of RelevantDatetime for Assessment, Performed 

//****
// CMS147v8
// Communication, From Patient to Provider: Influenza Immunization declined – author dateTime is appropriate
define "Patient Declined Influenza Vaccination":
  ["Communication: From Patient To Provider": "Influenza Vaccination Declined"] CommunicateFluVaccinationDeclined
	  where CommunicateFluVaccinationDeclined.authorDatetime during "Influenza Season Including August and September of the Prior Year"

// Consider: QDM 5.5 uses Communication, Performed with sent and received times. The subject, however, references that the vaccination was declined – if Immunization, NOT Administered were used, the author dateTime would be appropriate. For Communication, Performed, however the sent/received represents the time of the communication. 

define "Patient Reported Previous Receipt of Influenza Vaccine":
  ["Communication: From Patient To Provider": "Previous Receipt of Influenza Vaccine"] CommunicatePreviousReceiptFluVaccine
	  where CommunicatePreviousReceiptFluVaccine.authorDatetime during "Influenza Season Including August and September of the Prior Year"

// Consider: QDM 5.5 uses Communication, Performed with sent and received times. They may be more appropriate for indicating when the communication occurred Vs when the communication was documented/recorded.

// Influenza vaccine administered

define "Medical Patient or System Reason for Not Performing Influenza Vaccination":
  ["Procedure, Not Performed": "Influenza Vaccination"] NoFluVaccination
  	where NoFluVaccination.authorDatetime during "Influenza Season Including August and September of the Prior Year"
  		and ( NoFluVaccination.negationRationale in "Medical Reason"
  				or NoFluVaccination.negationRationale in "Patient Reason"
  				or NoFluVaccination.negationRationale in "System Reason"

// Consider – author dateTime appropriate for negation rationale

define "Influenza Immunization Administered":
  ["Immunization, Administered": "Influenza Vaccine"] AdministeredFluVaccine
	  where AdministeredFluVaccine.authorDatetime during "Influenza Season Including August and September of the Prior Year"

// Consider – QDM 5.5 allows Relevant dateTime for actual administration time 

//****
// CMS142v7
// Communication, From Provider to Provider: Level of Severity of Retinopathy Findings; and Macular Edema Findings Absent; and Macular Edema Findings Absent – all use author dateTime

define "Communicate Level of Severity of Retinopathy Findings":
  ["Communication: From Provider To Provider": "Level of Severity of Retinopathy Findings"] CommunicationLevelOfSeverity
	  with "Diabetic Retinopathy Encounter" EncounterDiabeticRetinopathy
		  such that CommunicationLevelOfSeverity.authorDatetime after start of EncounterDiabeticRetinopathy.relevantPeriod

// Consider: QDM 5.5 uses Communication, Performed with sent and received times. They may be more appropriate for indicating when the communication occurred Vs when the communication was documented/recorded.

//****
// CMS50v7
// uses Intervention, Performed Relevant Period but sorts by author dateTime to determine FIRST

define "Referring Provider Communicated Consultant Report to Close Referral Loop":
  ["Communication: From Provider To Provider": "Consultant Report"] ConsultantReportCommunicated
  	with "First Referral During Measurement Period" FirstReferral
  		such that FirstReferral.id in ConsultantReportCommunicated.relatedTo
  			and ConsultantReportCommunicated.authorDatetime after start of FirstReferral.relevantPeriod

// Consider – QDM 5.4 and 5.5 allow sent and received times – previously only allowed author dateTime

//****
// CMS52v7
// Laboratory Test, Performed CD4 Count uses author dateTime instead of Relevant Period

define "Denominator Exceptions":
  exists ( ( ["Laboratory Test, Performed": "CD4+ Count"] FirstCD4Count
  			with ["Laboratory Test, Performed": "CD4+ Count"] SecondCD4Count
  				such that SecondCD4Count.authorDatetime occurs 3 months or less after day of FirstCD4Count.authorDatetime
  					and SecondCD4Count.result >= 500 '/mm3'
  	)
  		union ( ["Laboratory Test, Performed": "CD4+ Percentage"] FirstCD4Percent
  				with ["Laboratory Test, Performed": "CD4+ Percentage"] SecondCD4Percent
  					such that SecondCD4Percent.authorDatetime occurs 3 months or less after FirstCD4Percent.authorDatetime
  						and SecondCD4Percent.result >= 15 '%'
  		)
  )

// Consider – Consider use of FirstCD4Count.resultDatetime and Second CD4Count.resultDatetime

//****
// CMS136v8
// uses author time rather than relevant period to determine FIRST

define "First ADHD Medication Dispensed":
  First(["Medication, Dispensed": "ADHD Medications"] FirstADHDMedication
  		where FirstADHDMedication.authorDatetime 60 days or less after start "Measurement Period"
  			or FirstADHDMedication.authorDatetime 90 days or less on or before start "Measurement Period"
  		sort by authorDatetime
  )

// Consider – most likely discomfort with Relevant Period for a point in time – QDM 5.5 allows Relevant dateTime.  

//****
// CMS69v7 
// BMI ratio recorded (author time) rather than performance time

// Uses Relevant Period for the physical exam but sorts by authorDatetime – likely because Relevant dateTime not available as with QDM 5.5

define "Has High BMI with Follow Up":
  Last(["Physical Exam, Performed": "Body mass index (BMI) [Ratio]"] LastBMI
  		with "High BMI Follow Up Encounters" HighBMIEncounter
  			such that LastBMI.relevantPeriod starts 12 months or less on or before end of HighBMIEncounter.relevantPeriod
  		sort by authorDatetime
  ).result >= 25 'kg/m2'

define "Has Low BMI with Follow Up":
  Last(["Physical Exam, Performed": "Body mass index (BMI) [Ratio]"] LastBMI
  		with "Low BMI Follow Up Encounters" LowBMIEncounter
  			such that LastBMI.relevantPeriod starts 12 months or less on or before end of LowBMIEncounter.relevantPeriod
  		sort by authorDatetime
  ).result < 18.5 'kg/m2'

//****
// CMS165v7
//Does sort by start of relevant period
define "Has Diastolic Blood Pressure Less Than 90":
  Last("Diastolic Blood Pressure Exam" LastDiastolicBP
  		with "Most Recent Visit With Blood Pressure" HypertensionNumeratorEncounter
  			such that LastDiastolicBP.relevantPeriod during HypertensionNumeratorEncounter.relevantPeriod
  		sort by start of relevantPeriod
  ).result < 90 'mm[Hg]'

define "Has Systolic Blood Pressure Less Than 140":
  Last("Systolic Blood Pressure Exam" LastSystolicBP
  		with "Most Recent Visit With Blood Pressure" HypertensionNumeratorEncounter
  			such that LastSystolicBP.relevantPeriod during HypertensionNumeratorEncounter.relevantPeriod
  		sort by start of relevantPeriod
  ).result < 140 'mm[Hg]'
