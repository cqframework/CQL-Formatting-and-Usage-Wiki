library ThreeConditions

using QICore version '4.1.1'

include FHIRHelpers version '4.3.000'
include QICoreCommon version '2.0.000'

valueset "Condition Codes": 'http://example.org/fhir/ValueSet/condition-codes'

context Patient

define "Indicator Conditions":
  [Condition: "Condition Codes"]

/*
I have a need to determine if there are 3 or more conditions (of a kind indicated by a value set) within a period of 2 months. 
The CQL below works, but it can probably be done in different ways as well. Any suggestions ?
*/

define "3 Or More Conditions Within 2 Months":
    exists (
        from "Indicator Conditions" C1, "Indicator Conditions" C2, "Indicator Conditions" C3
            let FirstOnset: C1.onset.toInterval(), SecondOnset: C2.onset.toInterval(), ThirdOnset: C3.onset.toInterval()
            where (SecondOnset starts after end FirstOnset) and (ThirdOnset starts after end SecondOnset)
                and (ThirdOnset starts 2 months or less after start FirstOnset)
    )

define "3 Or More Conditions Within 2 Months (alt)":
    exists (
        "Indicator Conditions" C
          where Count(
            "Indicator Conditions" C2
                where C2.onset.toInterval() starts on or before start of C.onset.toInterval() + 2 months
                  and C2.id != C.id
        ) >= 2
    )