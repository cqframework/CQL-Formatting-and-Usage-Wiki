library BeforeAndAfterAssessments

/*
How can we have two events around a single procedure?
For example, how can we reference two instances of an assessment
 one before a procedure and one after a procedure?
 This is just a general question. Since, we can't iterate through
 the lists of Assessments or list of procedures.
*/

using QDM version '5.4'

valueset "Some Procedure Value Set": 'TBD'
valueset "Some Assessment Value Set": 'TBD'

define "Assessments Before and After":
  ["Procedure, Performed": "Some Procedure Value Set"] P
    with ["Assessment, Performed": "Some Assessment Value Set"] A1
      such that A1.authorDatetime before start of P.relevantPeriod 
    with ["Assessment, Performed": "Some Assessment Value Set"] A2
      such that A2.authorDatetime after end of P.relevantPeriod
