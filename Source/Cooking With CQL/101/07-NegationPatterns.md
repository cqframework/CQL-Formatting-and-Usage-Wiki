## Negation Patterns

The EC measures CMS 135, 138, 144, 347 and EH measure CMS72 contain a denominator exclusion based on the action, or inaction, of not ordering one of many eligible medications to treat a condition for a medical reason or a patient refusal.

### Pros and Cons of these patterns?

**Vendor reports that this is the preferred method--**

CMS 153 Chlamydia Screening

```cql
define "Denominator Exclusions":
  Hospice."Has Hospice Services"
    or ( 
      ( "Has Pregnancy Test Exclusion" )
        and not ( "Has Assessments Identifying Sexual Activity" )
        and not ( "Has Diagnoses Identifying Sexual Activity" )
        and not ( "Has Active Contraceptive Medications" )
        and not ( "Has Ordered Contraceptive Medications" )
        and not ( "Has Laboratory Tests Identifying Sexual Activity But Not Pregnancy" )
        and not ( "Has Diagnostic Studies Identifying Sexual Activity" )
        and not ( "Has Procedures Identifying Sexual Activity" )
    )
```

**Instead of this**

CMS 144

```cql
define "Has Medical or Patient Reason for Not Ordering Beta Blocker for LVSD":
  exists (
    ["MedicationNotRequested": medication in "Beta Blocker Therapy for LVSD"] NoBetaBlockerOrdered
      with AHA."Heart Failure Outpatient Encounter with History of Moderate or Severe LVSD" ModerateOrSevereLVSDHFOutpatientEncounter
        such that NoBetaBlockerOrdered.authoredOn during day of ModerateOrSevereLVSDHFOutpatientEncounter.period
      where ( NoBetaBlockerOrdered.reasonCode in "Medical Reason" or NoBetaBlockerOrdered.reasonCode in "Patient Reason" )
  )  
```

This is effectively suggesting that the measure only look for absence of evidence, not evidence of absence

It seems unlikely that this type of general guidance could be provided, artifact intent is going to drive what patterns are used to identify when something didn't happen, and specifically what bar needs to be hit to count as evidence that something didn't happen for an acceptable reason. Approach we've taken thus far is to provide guidance around what patterns can be used for negation, and allowing authors to select the appropriate pattern for their use case.

