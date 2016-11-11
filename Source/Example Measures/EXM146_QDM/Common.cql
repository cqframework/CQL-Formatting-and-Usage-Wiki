library Common version '1'

/*
This example is a work in progress and should not be considered a final specification
or recommendation for guidance. This example will help guide and direct the process
of finding conventions and usage patterns that meet the needs of the various stakeholders
in the measure development community.
*/

using QDM version '5.0.2'

context Patient

define function "Includes Or Starts During"(P "Diagnosis", E "Encounter, Performed"):
  P.prevalencePeriod includes E.relevantPeriod
    or P.prevalencePeriod starts during E.relevantPeriod
