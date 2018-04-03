// Specific Occurrences

/*
Specific occurrences in versions of Quality Data Model (QDM) prior to version 5 
allowed measure logic to associate criteria with a specific occurrence or single 
instance of a QDM Data Element. This functionality was necessary in QDM because 
logic could not be applied to the result of an expression. CQL, however, allows 
expressions to be built up from other expressions, so the ability to express 
different criteria that apply to the same instance of a QDM Data Element is a 
natural part of the language.
*/

/*
1. Simple Usage of Specific Occurrences
For example, consider the following snippet of QDM 4.3 logic:
*/

AND: "Occurrence A of Encounter, Performed: BH Outpatient encounter" >= 
  42 day(s) starts before start of "Measurement End Date"
AND: "Occurrence A of Encounter, Performed: BH Outpatient encounter"
  starts after start of "Measurement Start Date"
  
/*
Without the specific occurrencing, this criteria could potentially be satisfied 
by different encounters. The specific occurrence label ensures that the criteria 
is only satisfied if there is at least one encounter that satisfies both of the 
criteria.

In CQL, however, this is expressed by combining the criteria in a single where clause:
*/

define "Valid Encounters":
  ["Encounter, Performed": "BH Outpatient encounter"] E
    where E.relevantPeriod starts 42 days or less before end of "Measurement Period"
      and E.relevantPeriod starts after start of "Measurement Period"
      
/*
2. Multiple Specific Occurrences of the Same Event Type
Specific occurrencing could also be used to related different instances of the 
same type of data element:
*/

AND: "Occurrence A of Encounter, Performed: HIV Visit" during "Measurement Period"
AND: "Occurrence B of Encounter, Performed: HIV Visit" during "Measurement Period"
AND: "Occurrence B of Encounter, Performed: HIV Visit" >= 90 day(s)
  starts after end of "Occurrence A of Encounter, Performed: HIV Visit"
  
/*
In CQL, this would be accomplished with a query to relate different encounters:
*/

define "HIV Visits During Measurement Period":
  ["Encounter, Performed": "HIV Visit"] E
    where E.relevantPeriod during "Measurement Period"

define "HIV Followup Visits":
  "HIV Visits During Measurement Period" V1
    with "HIV Visits During Measurement Period" V2
      such that V1.relevantPeriod starts 90 days or more after end of V2.relevantPeriod

/*
Note the use of the definition HIV Visits During Measurement Period in the second 
query. Using that definition means that only encounters that satisfy the first 
criteria of being during the measurement period will be considered, and using 
the definition twice allows us to set up a relationship between different 
encounters in that same set.
*/

/*
3. Multiple Specific Occurrences of Different Event Types
Specific occurrencing could also be used to relate different types of QDM Data 
Elements:
*/

AND: "Occurrence A of Medication, Order: Dapsone and pyrimethamine" <=
  3 month(s) starts after end of "Occurrence A of Laboratory Test, Performed: CD4+ Count (result)"
AND: "Occurrence A of Medication, Order: Leucovorin" <=
  3 month(s) starts after end of "Occurrence A of Laboratory Test, Performed: CD4+ Count (result)"

/*
In CQL, again, this is expressed with a query:
*/

define "CD4+ Count With Results and Medications":
  ["Laboratory Test, Performed": "CD4+ Count"] LTP
    with ["Medication, Order": "Dapsone and pyrimethamine"] MODP
      such that MODP.authorDatetime occurs 3 months or less after end of LTP.relevantPeriod
    with ["Medication, Order": "Leucovorin"] MOL
      such that MOL.authorDatetime occurs 3 months or less after end of LTP.relevantPeriod
  where LTP.result is not null

/*
4. Specific Occurrences in OR Clauses and Negations
When a specific occurrence is used in criteria that are combined with an OR clause, 
it means that the criteria is satisfied is there an event in at least one of the 
branches of the OR:
*/

OR: Intersection of:
  Occurrence A of $EncounterInpatientNonElective
  "Encounter, Performed: Non-Elective Inpatient Encounter (principal diagnosis: Ischemic Stroke)"
OR: Intersection of:
  Occurrence A of $EncounterInpatientNonElective
  "Encounter, Performed: Non-Elective Inpatient Encounter (principal diagnosis: Hemorrhagic Stroke)"

/*
In this case, the specific occurrence is an encounter that has a principal 
diagnosis of either Ischemic Stroke or Hemorrhagic Stroke.

In CQL, this is expressed with an or in a where clause:
*/

define "Valid Encounter":
  "Encounter Inpatient Non Elective" E
    where E.principalDiagnosis in "Ischemic Stroke"
      or E.principalDiagnosis in "Hemorrhagic Stroke"

/*
When a specific occurrence appears in a negation clause (e.g. AND NOT), the 
criteria must evaluate to false for the specific occurrence, or the event must 
not exist:
*/

AND NOT: "Occurrence A of Procedure, Performed: PCI" starts after start of 
  ("Medication, Administered: Fibrinolytic Therapy" starts after start of 
    "Occurrence A of Encounter, Performed: Emergency Department Visit" ) 

/*
For the case where the event should not exist:
*/

define "No PCI":
  not exists (
    ["Procedure, Performed": "PCI"] P
      with (
        ["Medication, Administered": "Fibrinolytic Therapy"] M
          with "ED Visit" E such that M.relevantPeriod starts after start of E.relevantPeriod
      ) M such that P.relevantPeriod starts after start of M.relevantPeriod
  )
  
/*
And for the case that evaluates to false for the procedure:
*/

define "PCI Without Medication":
  ["Procedure, Performed": "PCI"] P
    without (
      ["Medication, Administered": "Fibrinolytic Therapy"] M
        with "ED Visit" E such that M.relevantPeriod starts after start of E.relevantPeriod
    ) M such that P.relevantPeriod starts after start of M.relevantPeriod

/*
5. Specific Occurrences Between Populations
When conditions are applied to specific occurrences in different populations, 
the conditions carry forward to the next population in the calculation order for 
the measure.

In CQL, this means that the expressions that define the conditions for the 
specific occurrence must be used in subsequent populations in order for the 
criteria to be applied. For example, consider this initial population:
*/

define "Initial Population":
  ["Encounter, Performed": "BH Outpatient encounter"] E
    where E.relevantPeriod starts 42 days or less before end of "Measurement Period"
      and E.relevantPeriod starts after start of "Measurement Period"
      
/*
If subsequent populations start with the direct reference to the QDM Element:
*/

define "Denominator":
  ["Encounter, Performed": "BH Outpatient encounter"] E
    with ["Medication, Order": "Anti-depressant medications"] M
      such that M.authorDatetime occurs after end of E.relevantPeriod
      
/*
Then they do not have the same criteria described for the specific occurrence. 
Instead, defining a separate expression and reusing it carries the criteria forward:
*/

define "Valid Encounters":
  ["Encounter, Performed": "BH Outpatient encounter"] E
    where E.relevantPeriod starts 42 days or less before end of "Measurement Period"
      and E.relevantPeriod starts after start of "Measurement Period"

define "Initial Population":
  "Valid Encounters"

define "Denominator":
  "Valid Encounters" E
    with ["Medication, Order": "Anti-depressant medications"] M
      such that M.authorDatetime occurs after end of E.relevantPeriod
      
/*
Of course, in this simple case the criteria would have carried forward because 
the denominator is defined to be a subset of the initial population, but the 
example illustrates how specific occurrence criteria can be "carried forward" 
through the use of named expressions.
*/
