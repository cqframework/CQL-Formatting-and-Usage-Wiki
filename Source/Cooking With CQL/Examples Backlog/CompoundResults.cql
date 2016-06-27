/*
  The general problem is the attempt to access components of results like Diagnostic Studies,
  Laboratory Panels, and Assessments. These structures all have a parent-child aspect that
  cannot be represented accurately with current QDM.

  The current solution has been to focus on the individual elements, but this doesn't give a
  way to calculate when the basis is the report itself (i.e. there's no way to express that
  the components are part of a particular parent element).

  There are several potential solutions:

  A) Introduce a parentId attribute into the QDM to allow reference to parent elements.
  B) Introduce a new data type (Result?) that can be related to the parent tests, but has component results.
  C) Introduce a list-valued attribute within the test types that allows multiple results to be represented.

  For illustration, this example will use the Lipid Panel and LDL Result

*/

// A) Introduce a parentId attribute into the QDM type to allow reference to parent elements.

define "Lipid Panel":
  ["Laboratory Test, Performed": "Lipid Panel"]

define "LDL Result":
  ["Laboratory Test, Performed": "LDL Result"]

define "Lipid Panels with LDL Results":
  "Lipid Panel" Panel
    with "LDL Result" Result
      such that Result.performedDateTime = Panel.performedDateTime // could also use parentId = Id, but QDM doesn't have Id attributes at this point...

// B) Introduce a new data type (Result?) that can be related to the parent tests, but has component results.

define "Lipid Panel":
  ["Laboratory Test, Performed": "Lipid Panel"]

define "LDL Result":
  ["Laboratory Test, Result": "LDL Result"]

define "Lipid Panels with LDL Results":
  "Lipid Panel" Panel
    with "LDL Result" Result
      such that Result.performedDateTime = Panel.performedDateTime

// C) Introduce a new list-valued attribute within the test types

define "Lipid Panel":
  ["Laboratory Test, Performed": "Lipid Panel"]

define "LDL Result":
  "Lipid Panel".components Component
    where Component.code in "LDL Result"
