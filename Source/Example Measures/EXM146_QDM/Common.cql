library Common version '1'

/*
This example is a work in progress and should not be considered a final specification
or recommendation for guidance. This example will help guide and direct the process
of finding conventions and usage patterns that meet the needs of the various stakeholders
in the measure development community.
*/

using QDM

context Patient

define function includesOrStartsDuring(P "Diagnosis, Active", E "Encounter, Performed"):
  Interval[P."start datetime", P."stop datetime"] includes Interval[E."start datetime", E."stop datetime"]
    or P."start datetime" in Interval[E."start datetime", E."stop datetime"]
