


// There is a subtle error here:

define "Ex1": ["Diagnosis": "Alcohol and Drug Dependence"] FAD
    with ("FirstAlcoholDrugDependenceDx") FADD
    such that FAD.prevalencePeriod start 60 days or less before start of FADD.prevalencePeriod

// Because it's not one of the expected keywords, the parser is interpreting that as a query alias, 
// which is basically a no-op, so it's really saying:

define "Ex1": ["Diagnosis": "Alcohol and Drug Dependence"] FAD
    with ("FirstAlcoholDrugDependenceDx") FADD
    such that FAD.prevalencePeriod 60 days or less before start of FADD.prevalencePeriod

// And when you use an interval in a before like that, it chooses the end of the interval to do the comparison.

// So, the fix is to just correct the keyword to "starts" instead of "start".

define "Ex1": ["Diagnosis": "Alcohol and Drug Dependence"] FAD
    with ("FirstAlcoholDrugDependenceDx") FADD
    such that FAD.prevalencePeriod starts 60 days or less before start of FADD.prevalencePeriod

/*
define "First ICU": First(["Encounter, Performed": "ICU Admission or Transfer"] ICU
    with "Initial Population" E
such that ICU.relevantPeriod during E.relevantPeriod
sort by start of relevantPeriod
)
*/

// We don't want the first ICU for any encounter during the measure period,
// we want the first encounter for each encounter, so we use a return...
define "First ICU": 
  "Initial Population" E
    return
      First(["Encounter, Performed": "ICU Admission or Transfer"] ICU
        where ICU.relevantPeriod during E.relevantPeriod
        sort by start of relevantPeriod
      )

