/*
* [CQLIT-165](https://oncprojectracking.healthit.gov/support/browse/CQLIT-165) - Multiple Encounters
*/

/*
This new measure assesses for substance use disorder encounters that include alcohol 
and drug dependence treatment in the initial population. The "New SUD Encounter" identification
 period occurs prior to the measurement period and is defined as 6 months before the 
 measurement period starts (July 1 of the year prior to the measurement period) to 
 6 months before it ends (June 30 of the year of the measurement period) and 
 cannot have have had another SUD encounter within 60 days prior. 
 
However, SUD Encounters are expected (continued treatment) after the New SUD Encounter 
and multiple episodes (New SUD with QOL to Another SUD Encounter with follow up QOL) may 
occur within the ID and Measurement Periods. See attached an attempt to visualize 
the measure. We need the logic to capture the New SUD Encounter that does not have 
another SUD encounter within the 60 days prior but has another SUD encounter within 3-6 months 
following the New SUD encounter and how to capture 2 episodes.
*/

define "SUD Encounters":
	"SUD Treatment Encounters"
		union "SUD Psych Encounters with Principal Diagnosis"

define "New SUD Encounter":
  "SUD Encounters" S
    without "SUD Encounters" S2 such that S2.relevantPeriod ends 60 days or less before start of S.relevantPeriod
    where S.relevantPeriod starts during "Identification Period"
    
define "Follow Up QOL Assessment":
	from
		"SUD Encounter During Identification Period with Patient Age at Start" NewSUDEncounter,
		"QOL Assessment" BaselineAssessment,
		"QOL Assessment" FollowupAssessment
		where (BaselineAssessment.authorDatetime 14 days or less before or on start of NewSUDEncounter.relevantPeriod
      or BaselineAssessment.authorDatetime during NewSUDEncounter.relevantPeriod)
      and FollowupAssessment.authorDatetime 3 months or more after start of NewSUDEncounter.relevantPeriod
			and FollowupAssessment.authorDatetime 6 months or less after start of NewSUDEncounter.relevantPeriod
      and exists ("SUD Encounter" SUDEncounter where SUDEncounter.relevantPeriod starts 60 days or less before or on FollowupAssessment.authorDatetime)
      and BaselineAssessment.code ~ FollowupAssessment.code
    return FollowupAssessment


