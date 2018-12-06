library PositiveScreens

/*
Snippet from ASF: Unhealthy Alcohol Use Screening and Followup
*/

define "Positive Screen":
	( ["Assessment, Performed": "Total score [AUDIT-C]"] AuditC
			where ( "Patient is Male" and AuditC.result >= 4 )
				or ( "Patient is Female" and AuditC.result >= 3 )
					and AuditC.authorDatetime during "Screening Period" 
	)
		union ( ["Assessment, Performed": "Total score [AUDIT]"] Audit
				where Audit.result >= 8
					and Audit.authorDatetime during "Screening Period"
		)
		union ( ( ["Assessment, Performed": "How often have you had five or more drinks in one day during the past year [Reported]"] FiveDrinks
				where "Patient is Male"
					and FiveDrinks.result >= 1 ) FiveDrinks
				where FiveDrinks.authorDatetime during "Screening Period"
		)
		union ( ( ["Assessment, Performed": "How often have you had four or more drinks in one day during the past year [Reported]"] FourDrinks
				where ( "Patient is Female"
						or "Patient is 65 or Over"
				)
					and FourDrinks.result >= 1 ) FourDrinks
				where FourDrinks.authorDatetime during "Screening Period"
		) 

// Looking specifically at the first snippet:

	( ["Assessment, Performed": "Total score [AUDIT-C]"] AuditC
			where ( "Patient is Male" and AuditC.result >= 4 )
				or ( "Patient is Female" and AuditC.result >= 3 )
					and AuditC.authorDatetime during "Screening Period" 
	)
  
// Note order of operations here, this will be evaluated as 
  (male or (female and documented during screening))
// rather than the expected 
  (male or female) and documented during screening
  
// Looking specifically at this snippet:
		union 
    ( 
      ( ["Assessment, Performed": "How often have you had five or more drinks in one day during the past year [Reported]"] FiveDrinks
				where "Patient is Male"
					and FiveDrinks.result >= 1 
      ) FiveDrinks
				where FiveDrinks.authorDatetime during "Screening Period"
		)

// Note that there are two queries here:
  // The inner query on the assessment that is testing Patient is Male and FiveDrinks.result >= 1
  // An outer query that tests that the result of the inner query for the authorDatetime during Screening Period
  
// Because there is nothing added by the inner query, the two queries can be collapsed into 1:
    ( 
      ["Assessment, Performed": "How often have you had five or more drinks in one day during the past year [Reported]"] FiveDrinks
				where "Patient is Male"
					and FiveDrinks.result >= 1 
          and FiveDrinks.authorDatetime during "Screening Period"
		)

// However, looking at the expression overall, notice that each input to the union includes the same criteria
  authorDatetime during "Screening Period"
  
// So the expression could be simplified by moving that criteria to be tested after the union:

define "Positive Screens":
	( ["Assessment, Performed": "Total score [AUDIT-C]"] AuditC
			where ( "Patient is Male" and AuditC.result >= 4 )
				or ( "Patient is Female" and AuditC.result >= 3 )
	)
		union ( ["Assessment, Performed": "Total score [AUDIT]"] Audit
			where Audit.result >= 8
		)
		union ( ["Assessment, Performed": "How often have you had five or more drinks in one day during the past year [Reported]"] FiveDrinks
			where "Patient is Male"
				and FiveDrinks.result >= 1
		)
		union ( ["Assessment, Performed": "How often have you had four or more drinks in one day during the past year [Reported]"] FourDrinks
			where ( "Patient is Female" or "Patient is 65 or Over" )
					and FourDrinks.result >= 1
		) 

define "Positive Screens During Screening Period":
  "Positive Screens" S
    where S.authorDatetime during "Screening Period"
  