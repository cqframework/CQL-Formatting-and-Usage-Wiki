library EqualityEquivalenceAndNulls


//define Test1: null as Code ~ Concept { codes: { null as Code } }
//define Test2: null as Code ~ Concept { codes: { } }

//define "Code1": Code { system: 'http://loinc.org', code: '8480-6', display: 'Systolic blood pressure' }
//define "Concept1": Concept { codes: { Code1 }, display: 'Concepts' }
//define "Concept2": Concept { codes: { null }, display: 'More Concepts' }
//define "EquivalentIsTrue": Code1 ~ Code1
//define "EquivalentIsAlsoTrue": Concept2 ~ Concept2
//define "EquivalentIsFalse": Concept1 ~ Concept2

define Test3: null as List<Any> = { }
define Test4: { null as Integer } = { null }
define Test5: null as List<Integer> ~ { }

define Test6: null as Integer in { 1, 2, 3, null }

define Test7: { 'a', 'b', null } contains null
