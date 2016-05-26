// Single code retrieve

codesystem "SNOMED-CT": '2.16.840.1.113883.6.96' version '2016A'

define "$Breastfeeding Intention":
    Code '123456789' from "SNOMED-CT" display 'Breastfeeding intention'

define "$Has Breastfeeding Assessment":
  ["Risk Assessment, Performed": "$Breastfeeding Intention"] R
    where R.negationRationale is null

////////////////////////////////////////////////////////
// CQL (D)STU Update Examples

// expand -> flatten
define "$Flatten": flatten { { 1, 2, 3 }, { 4, 5, 6 } }

// "flattens" the list to: { 1, 2, 3, 4, 5, 6 }

// string and identifier escaping
define "$Identifier with a """: 'String literal with a ''';

define "$Identifier with a \"": 'String literal with a \'';

// matches -> ~
define "$Matches": 100 matches 100.0

define "$Equivalent": 100 ~ 100.0

// 0-based Indexes
define "$Indexer Expression (1-based)": "$List Value"[1]

define "$Indexer Expression (0-based)": "$List Value"[0]

// define -> let
define "$Inpatient Encounters":
	["Encounter, Performed": "Inpatient"] E
	    define stayDuration = duration in days between E.admissionDateTime and E.dischargeDateTime
	    where stayDuration <= 120

define "$Inpatient Encounters":
	["Encounter, Performed": "Inpatient"] E
	    let stayDuration = duration in days between E.admissionDateTime and E.dischargeDateTime
	    where stayDuration <= 120

//////////////////////////////////////////////////////////////////////////////
// CQL 101 Examples

// Values



// Filter by Existence

define "$CD4+ Count With Results and Medications":
  ["Laboratory Test, Performed": "CD4+ Count"] LTP
    with ["Medication, Order": "Dapsone and pyrimethamine"] MODP
      such that MODP.signedDatetime occurs 3 months or less after LTP.stopDateTime
    with ["Medication, Order": "Leucovorin"] MOL
      such that MOL.signedDatetime occurs 3 months or less after LTP.stopDateTime
    where LTP.result is not null
