library CQLv151ChangesAppliedWorking

include CQLv151ChangesApplied called C

// https://jira.hl7.org/browse/
// Related commits: https://github.com/HL7/cql/search?q=27509&type=commits

/*
=== Normative Changes

==== Non-substantive

==== Errata

=== Trial-Use Changes

==== Compatible, Substantive

==== Non-substantive

==== Errata
*/

define "Ballot Categories": C.Changes C return C."Ballot Category"

define "Change List":
  C.Changes C
    return {
      "Issue Type": C."Issue Type",
      "Issue key": C."Issue key",
      "Summary": C."Summary",
      "Ballot Category": C."Ballot Category",
      "Change Description": C."Change Description",
      "Change Category": C."Change Category",
      "Change Impact": C."Change Impact",
      "Commit": C."Commit",
      "Entry": '* https://jira.hl7.org/browse/' + C."Issue key" + '[J#' + C."Issue key" + ']: '
        + C."Change Description"
        + ' https://github.com/HL7/cql/search?q=' + C."Commit" + '&type=commits[View changes]'
    }
    sort by "Issue key"

define "Normative":
  Combine(
    "Change List" C
      where C."Ballot Category" = 'Normative'
      return C."Entry",
    '\r\n'
  )

define "Informative":
  Combine(
    "Change List" C
      where C."Ballot Category" = 'Informative'
      return C."Entry",
    '\r\n'
  )

define "Trial Use":
  Combine(
    "Change List" C
      where C."Ballot Category" = 'Trial Use'
      return C."Entry",
    '\r\n'
  )

define "Errata":
  Combine(
    "Change List" C
      where C."Ballot Category" = 'Errata'
      return C."Entry",
    '\r\n'
  )
