library WellnessComposite

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

/*
Explore what it means to compute a composite measure with mixed population bases:

* All-or-none
* Opportunity scoring (weighted by denominator, that is, that each measured
entity would have unique set of weights based on their eligible population for
each measure; higher weight for measure with more denominator components)
* Patient-level unweighted
* Component-level linear unweighted
*/

/* Component Summaries:

Breast Cancer Screening - patient-based proportion
Colorectal Cancer Screening - patient-based proportion
High Blood Pressure Screening - encounter-based proportion
Pneumococcal Vaccination - patient-based proportion
Tobacco Screening - patient-based proportion

Initial Populations:
BCS: female, 51-74, with Qualifying Encounters
CCS: 50-75, with Qualifying Encounters
HBP: >= 18, Encounters in Encounter to Screen for Blood Pressure
PVS: >= 65, with Qualifying Encounters or Nursing/Long-term Facility encounters
TSC: >= 18 with Qualifying Encounters or Other/Counseling encounters or 2 or more Office visits

Denominators:
BCS: Initial Population
CCS: Initial Population
HBP: Initial Population
PVS: Initial Population
TSC: Initial Population

Denominator Exclusions:
BCS: Hospice or Mastectomy or AIFLTC
CCS: Hospice or Cancer or Colectomy or AIFLTC
HBP: Hypertension Diagnosis
PVS: Hospice
TSC: None

Denominator Exceptions:
BCS: None
CCS: None
HBP: Medical or Patient Reason
PVS: None
TSC: Medical Reason or Limited Life Expectancy

Numerators:
BCS: Mammography
CCS: Colonoscopy or FOBT or Flex Sig or FIT DNA or CT Colonography
HBP: Normal BP or High BP with Followup
PVS: Pneumococcal Vaccine
TSC: Screened for Tobacco Use

*/

/*
# All-or-nothing scoring

Interpretation: For each Eligible Clinician, the percentage of patients who received
all preventive services for which they were eligible

The challenge with mixed basis is that for an encounter-based measure,
each encounter is where the "all-or-nothing" determination is made, which
means that for the patient-based measures, a patient in the numerator would
have to be considered satisfied for all the encounters introduced by the encounter-based
components.

To effectively apply this, we would need to construct the pool of all encounters,
so each patient-based component would need a way to establish the "set of eligible
encounters". The composite initial population is then the union of all the encounters
from all the components, and then for each component, we remove from that composite
initial population, the set of encounters that are in the denominator and not the
numerator.

denominator implies numerator => not numerator or denominator

IP except (denominator except numerator)

initial population implies (denominator and numerator)

composite initial population except (denominator except numerator)

*/

context Patient

define "BCS Qualifying Encounters":
  AdultOutpatientEncounters."Qualifying Encounters"

define "CCS Qualifying Encounters":
  AdultOutpatientEncounters."Qualifying Encounters"

define "PVS Qualifying Encounters":
  PVS."Qualifying Encounters"

define "TSC Qualifying Encounters":
  TSC."Office-based Visit During Measurement Period"
    union TSC."Preventive Visit During Measurement Period"

define "Initial Population":
  ("BCS Qualifying Encounters" E where BCS."Initial Population")
    union ("CCS Qualifying Encounters" E where CCS."Initial Population")
    union HBP."Initial Population"
    union ("PVS Qualifying Encounters" E where PVS."Initial Population")
    union ("TSC Qualifying Encounters" E where TSC."Initial Population")

define "Denominator":
  ("BCS Qualifying Encounters" E where BCS."Denominator")
    union ("CCS Qualifying Encounters" E where CCS."Denominator")
    union HBP."Denominator"
    union ("PVS Qualifying Encounters" E where PVS."Denominator")
    union ("TSC Qualifying Encounters" E where TSC."Denominator")

define "Denominator Exclusion":
  ("BCS Qualifying Encounters" E where BCS."Denominator Exclusion")
    union ("CCS Qualifying Encounters" E where CCS."Denominator Exclusion")
    union HBP."Denominator Exclusion"
    union ("PVS Qualifying Encounters" E where PVS."Denominator Exclusion")
    union ("TSC Qualifying Encounters" E where TSC."Denominator Exclusion")

define "Denominator Exception":
  ("BCS Qualifying Encounters" E where BCS."Denominator Exception")
    union ("CCS Qualifying Encounters" E where CCS."Denominator Exception")
    union HBP."Denominator Exception"
    union ("PVS Qualifying Encounters" E where PVS."Denominator Exception")
    union ("TSC Qualifying Encounters" E where TSC."Denominator Exception")

define "BCS Numerator Membership": // Repeat for each component
  BCS."Denominator Membership" implies BCS."Numerator Membership"

define "Numerator":
  ("Initial Population" IP
      where BCS."Denominator Membership" implies BCS."Numerator Membership"
        and CCS."Denominator Membership" implies CCS."Numerator Membership"
        and PVS."Denominator Membership" implies PVS."Numerator Membership"
        and TSC."Denominator Membership" implies TSC."Numerator Membership"
  )
    except (HBP."Denominator" except HBP."Numerator")

/*
An alternative for all-or-nothing would be to "demote" the encounter-based to a
patient-based and, since it's all-or-nothing, effectively say that the encounter-based
measure gives credit for each patient where each encounter in the denominator is
also in the numerator.
*/

define "HBP Initial Population":
  exists HBP."Initial Population"

define "HBP Denominator":
  exists HBP."Denominator"

define "HBP Numerator":
  Count(HBP."Denominator") = Count(HBP."Numerator")

/*
# Opportunity scoring

Opportunity scoring considers the appearance of a patient in a denominator of a
component measure as an opportunity to provide a service, and the appearance of
that patient in the numerator of each component as the fulfillment of that opportunity.
This means that each component measure is considered a “case” in the composite population.
The denominator is then the set of cases in which patients appeared in the denominator
for the component measures, and so on for each population criteria. This allows the
composite to then be calculated as a standard proportion measure where the basis
for the population criteria is membership in the population for each component

Same notion as above, except the numerator would combine with "or" instead of "and"

And the same option exists for "promoting" the patient-based measures to encounters
or "demoting" the encounter-based measure to patient-level
*/

/*
# Patient-level unweighted

For each Eligible Clinician (EC), the percentage of completed preventive services,
which gives EC partial numerator credit for meeting the criteria for some but not
all components of the measure.

This one can be approached straightforwardly, because it's already being calculated as a count.
For patient-based, that "count" is 0 or 1, where for encounter-based, it would just
be the count of encounters for that patient.
*/

/*
# Component-level linear unweighted

For each Eligible Clinician (EC), percentage of patients who received preventive
services, which gives EC partial numerator credit for meeting the criteria for
some but not all components of the measure. _Example:_ On average, each preventive
service was provided to X% of patients.

This approach already allows for a mixture of bases, so no changes are necessary
*/
