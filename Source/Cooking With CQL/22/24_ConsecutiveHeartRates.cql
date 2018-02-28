library Test145 version '6.0.0'

using QDM version '5.0.2'

/*
Coronary Artery Disease (CAD): Beta Blocker Therapy Prior Myocardial Infarction (MI) 
or Left Ventricular Systolic Dysfunction (LVEF < 40%)

Patient-based Proportion Measure
*/

valueset "Heart Rate": 'X.Y.Z'

/*
Specifically:

AND: Most Recent: "Occurrence B of Physical Exam, Performed: Heart Rate" 
  starts before start of "Occurrence A of Physical Exam, Performed: Heart Rate" 
AND: "Occurrence A of Physical Exam, Performed: Heart Rate (result < 50 bpm)" 
  during Occurrence A of $CADEncounters145 
AND: "Occurrence B of Physical Exam, Performed: Heart Rate (result < 50 bpm)" 
  during Occurrence A of $CADEncounters145  
*/

define "Consecutive Heart Rates Below 50 bpm":
  from
    ["Physical Exam, Performed": "Heart Rate"] Exam,
    CADEncounters145 Encounter
  let
    PriorExam: Last(["Physical Exam, Performed": "Heart Rate"] X 
      where X.relevantPeriod during Encounter.relevantPeriod
        and X.relevantPeriod starts before start of Exam.relevantPeriod
      sort by start of relevantPeriod)
  where Exam.relevantPeriod during Encounter.relevantPeriod
    and Exam.result < 50 'bpm'
    and PriorExam.result < 50 'bpm'
    
//PE { 1, 88 }, { 2, 90 }, { 3, 74 } { 4, 45 } { 5, 46 } // True
//PE { 1, 88 }, { 2, 36 }, { 3, 74 } { 4, 80 } { 5, 46 } // False


// NOTE: For illustration purposes only
define CADEncounters145:
  ["Encounter, Performed"]