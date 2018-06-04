library CommonErrorMessages

using QDM version '5.3'

// Sort Clauses

define LabResults: ["Laboratory Test, Performed"] L
  where L.result > 10 'mg'
  sort by L.result

// >> Translation Error: [null[5:11, 5:11]Could not resolve identifier L in the current library.

// This is because the qualifier has no meaning in the sort since the sort is applied
// to the result of the query

define LabResults: ["Laboratory Test, Performed"] L
  where L.result > 10 'mg'
  sort by result

//>> Translation Error: [null[3:20, 5:16]Call to operator Less(choice<System.Integer,System.Decimal,System.Code,System.Quantity,QDM.Ratio>,choice<System.Integer,System.Decimal,System.Code,System.Quantity,QDM.Ratio>) is ambiguous with: 
//  - Less(System.Decimal,System.Decimal)
//  - Less(System.Integer,System.Integer)
//  - Less(System.Quantity,System.Quantity)
//]

define HighestLabResultGreaterThan10: 
  Last(["Laboratory Test, Performed"] L
    where L.result > 10 'mg'
    sort by result as Quantity)
  

