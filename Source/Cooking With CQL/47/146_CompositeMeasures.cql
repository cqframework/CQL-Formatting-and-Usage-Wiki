library CompositeMeasures

include THATKACommon

/*
Problem Statement:
We have 2 separate proportion measures:
* V2_Risk-standardized Major Bleeding Rate
    Following Elective Primary Total Hip Arthroplasty (THA)
    and/or Total Knee Arthroplasty (TKA) Electronic Clinical Quality Measure (eCQM)
* V2_Risk-standardized Venous Thromboembolism (VTE) Rate
    Following Elective Primary Total Hip Arthroplasty (THA)
    and/or Total Knee Arthroplasty (TKA) Electronic Clinical Quality Measure (eCQM)

Can we develop a composite measure that combines these 2 measures to produce a
single performance rate? What would be the best approach to achieve this goal?

Composite Measure Support in the CQL-based HQMF IG is described for two
general approaches:

1. Individual-Based: Scoring methods that operate at the individual level
  by combining members of component populations and then calculating the
  measure score using standard measure scoring techniques on the combined
  populations.

2. Component-Based: Scoring methods that operate at the population level
  by combining the summary scores of component measures.

From an implementation perspective, systems that can calculate component measures
can readily calculate individual-based composites by simply combining criteria
from the component measures.

However, component-based calculation would require aggregation and calculation
on the results of component calculations and would require more extensive modification
to existing systems to support. For this reason, eCQMs only make use of the
individual-based calculation methods for defining composite measures.

Composite Scoring methods described in CQL-based HQMF IG:

All-or-nothing
Opportunity-based
Patient-level linear combination
Component-level weighted combination

Patient-level linear combination is a special case of the more general "linear combination" category described in the blueprint.
Specifically, the "linear combination" in the blueprint allows for simple and weighted average, and can be performed at the
individual level, or the component level. Current tooling only supports specifying individual level composite measures, so
the capability is described as "patient-level linear combination" to make clear that it is not applying at the component level.
*/


/*
Question:
Will the following approach produce the same result:

Can just develop just one measure (this is not composite measure) that has the following components:
Initial population: Patient >= 18 and had THA/TKA surgery
Denominator Exclusions: combine denominator exclusion criteria from the 2 measures above
Denominator: Initial population – Denominator Exclusions
Numerator 1: include numerator criteria for VTE
Numerator 2: include numerator criteria for Bleeding

Then calculate a single performance rate using one of the following formulas:

1) linear combination:
Performance Rate = (Numerator 1 + Numerator 2) / (Denominator – Denominator Exclusions)

2) Any-Or-None
Performance Rate = (Numerator 1 + Numerator 2 - number with both) / (Denominator – Denominator Exclusions)

We also plan to present the individual rates:

Performance Rate VTE = Numerator 1 / (Denominator – Denominator Exclusions)
Performance Rate Bleeding = Numerator 2 / (Denominator – Denominator Exclusions)
*/

/*
Answer:
For option 1) linear combination:
This can be expressed as a composite measure within the MAT by selecting patient-level linear combination
as your composite scoring method. The way this will calculate is as a continuous variable measure
where:
* The initial population is made up of the combined initial population of all component measures
* The measure population is made up of the combined denominators of all component measures
* The measure population exclusion is made up of the combined denominator exclusions of all component measures
* The measure observation is then the number of numerators in which that member appears

For option 2) Any-or-None:
This can't be expressed as a composite (in the existing tooling) because the IG only provides for All-or-none,
Any-or-none would need to be added.

To make this more clear, let's define a non-composite measure, following the
approach being proposed (i.e. defining a measure with multiple performance rates)
*/

/*
For the purpose of this example, I've defined a common library THATKACommon, and
combined the measure logic from both measures in that library.
The initial population and denominator are the same for both measures, so I've left
them defined as is in the common library. In this library, we'll set up multiple
performance rates, one for Bleeding Rate, one for VTE Rate, and then one for
each of the different types of "composites" we want to produce.
*/

/*
First, the Bleeding Rate, we'll call it Numerator 1:
*/

define "Initial Population 1":
  THATKACommon."Initial Population"

define "Denominator 1":
  THATKACommon."Denominator"

define "Denominator Exclusions 1":
  THATKACommon."Common Denominator Exclusions"
    or THATKACommon."Bleeding Rate Denominator Exclusions"

define "Numerator 1":
  THATKACommon."Bleeding Rate Numerator"

/*
Next, the VTE Rate, we'll call it Numerator 2:
*/

define "Initial Population 2":
  THATKACommon."Initial Population"

define "Denominator 2":
  THATKACommon."Denominator"

define "Denominator Exclusions 2":
  THATKACommon."Common Denominator Exclusions"
    or THATKACommon."VTE Rate Denominator Exclusions"

define "Numerator 2":
  THATKACommon."VTE Rate Numerator"

/*
Any-or-none:
*/

define "Initial Population 3":
  THATKACommon."Initial Population"

define "Denominator 3":
  THATKACommon."Denominator"

define "Denominator Exclusions 3":
  THATKACommon."Common Denominator Exclusions"
    or THATKACommon."Bleeding Rate Denominator Exclusions"
    or THATKACommon."VTE Rate Denominator Exclusions"

define "Numerator 3":
  THATKACommon."Bleeding Rate Numerator"
    or THATKACommon."VTE Rate Numerator"

/*
Patient-level linear combination
To get to a patient-level linear combination, we have two potential approaches:

1. Switch the _basis_ of the measure
2. Use a continuous variable scoring method

For the basis, if we use patient-based, we only get one count per patient, no
matter how many events occurred. So if we want to count both the major bleed
and a VTE towards the rate, we need to switch the _basis_ to the event.

If we want to continue to consider this a proportion measure, then when we switch
the basis, we need to make sure we consider everything we want to count in the
numerator as part of the denominator. Given that there are multiple ways that
we are looking for an event, that becomes pretty involved to express the denominator
in that way, so we could either switch to a ratio measure, or to a continuous-variable
measure.

If we switch to a continuous variable measure, we can keep the denominator as
"Patients wtih elective THA/TKA Surgery", and use the measure observation to count
the number of events for each patient.
*/

define "Initial Population 4":
  THATKACommon."Initial Population"

define "Measure Population 4":
  THATKACommon."Denominator"

/*
For the measure population exclusions, we only want to exclude
characteristics that are common to both events. Otherwise, we might exclude
an event for a VTE exclusion, and end up missing it when it should have counted
for a Bleeding event.
*/
define "Measure Population Exclusion 4":
  THATKACommon."Common Denominator Exclusions"

/*
With the measure population established, we can define the measure observation
that combines them. To do this, we'll define a ToScore function that converts
the boolean-valued determination of an event to a score
*/
define function ToScore(Value Boolean):
  if Value then 1 else 0 end

/*
This expression is just a raw number of events
*/
define "Measure Observation 4":
  ToScore(THATKACommon."VTE Numerator" and not THATKACommon."VTE Rate Denominator Exclusions")
    + ToScore(THATKACommon."Bleeding Numerator" and not THATKACommon."Bleeding Rate Denominator Exclusions")

/*
If we use the Sum aggregation method for the continuous variable,
that means the performance rate is simply the number of events that occurred
*/

/*
We can also set it up as a rate, by incorporating event-specific exclusions:
*/

define "Measure Denominator Score 5":
  ToScore(THATKACommon."Denominator" and not THATKACommon."VTE Rate Denominator Exclusions")
    + ToScore(THATKACommon."Denominator" and not THATKACommon."Bleeding Rate Denominator Exclusions")

define "Measure Numerator Score 5":
  ToScore(THATKACommon."VTE Numerator" and not THATKACommon."VTE Rate Denominator Exclusions")
    + ToScore(THATKACommon."Bleeding Numerator" and not THATKACommon."Bleeding Rate Denominator Exclusions")

define "Measure Observation 5":
  "Measure Numerator Score 5" / "Measure Denominator Score 5"

/*
We then use the Average aggregation method to determine the overall rate for the population
*/

/*
So this is a patient-based linear combination, which we can then weight by introducing
the weighting factor as a component of the measure observation calculation:
*/

define "VTE Weight": 5
define "Bleeding Weight": 1

define "Measure Denominator Score 6":
  (ToScore(THATKACommon."Denominator" and not THATKACommon."VTE Rate Denominator Exclusions") * "VTE Weight")
    + (ToScore(THATKACommon."Denominator" and not THATKACommon."Bleeding Rate Denominator Exclusions") * "Bleeding Weight")

define "Measure Numerator Score 6":
  (ToScore(THATKACommon."VTE Numerator" and not THATKACommon."VTE Rate Denominator Exclusions") * "VTE Weight")
    + (ToScore(THATKACommon."Bleeding Numerator" and not THATKACommon."Bleeding Rate Denominator Exclusions") * "Bleeding Weight")

define "Measure Observation 6":
  "Measure Numerator Score 6" / "Measure Denominator Score 6"

/*
And again, we use the Average aggregation method to combine the measure observations.
This represents a weighted patient-based linear combination
*/
