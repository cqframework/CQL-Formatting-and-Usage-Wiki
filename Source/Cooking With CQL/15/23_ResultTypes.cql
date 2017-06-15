// Formatting and Usage Guide:
// https://github.com/esacinc/CQL-Formatting-and-Usage-Wiki/wiki

// Specifically, the Measure Authoring Guide:
// https://github.com/esacinc/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Measures-in-CQL

// Other educational resources avaiable here:
// Slides and webinars
// http://ecqi.healthit.gov/cql/cql-educational-resources

// CQL is a query language, every expression returns a value
// Simplest expression just returns a single value:

define "Simple Expression": 4

// Every value has a type, and the validator uses this information to make sure
// the operations used in an expression are appropriate for the types of values:

define "Invalid Expression": 1 + 'John'

// The validator will say that it does not understand how to "add" strings and numbers

// CQL deals with different kinds of values:
// Simple values like strings, date/times, and numbers
// Structured values, like Encounters and MedicationAdministrations
// These structured values are defined by the data model, QDM
// Intervals, i.e. ranges of values from a lower bound to an upper bound
// Lists, i.e. lists of values of some type

// For patient-based measures, all the population criteria return a yes/no (Boolean)
define "Initial Population":
  AgeInYearsAt(start of "Measurement Period") >= 13

// For non-patient-based measures, all the population criteria return values of the "case"
// i.e. Encounters, Procedures, etc.

define "Inpatient Encounter":
  ["Encounter, Performed": "Encounter Inpatient"] E
    where E.lengthOfStay <= 120 days
      and E.relevantPeriod ends during "MeasurementPeriod"

// In general, because retrieves always return lists of values, most expressions 
// will be of this type, namely lists of values, Encounters in this case
// However, some operations take a list of values, and return one of those values:

define "Most Recent Adolescent Depression Screening":
  Last (
    ["Assessment, Performed": "Adolescent Depression Screening"] adoscreen 
      with "Depression Screening Encounter" Enc
       such that adoscreen.authorDatetime during Enc.relevantPeriod and adoscreen.result is not null
      sort by adoscreen.authorDatetime
  )

// This expression returns the most recent adolescent depression screening, but it returns
// a single Assessment, not a list of assessments.

// This means that when we try to use it in an operation that expects a list, the validator
// will say it doesn't understand how to perform the operation:

define "Most Recent Adolescent Depression Screening with Negative Result":
  exists (
    "Most Recent Adolescent Depression Screening" adoscreen
       where adoscreen.result as Code in "Negative Depression Screening"
  )

// This is because the "exists" operation expects a list of values, and we're giving it a single assessment
// To correct this, we can "convert" the single assessment to a list using curly braces:
define "Most Recent Adolescent Depression Screening with Negative Result":
  exists ( {
    "Most Recent Adolescent Depression Screening" adoscreen
      where adoscreen.result as Code in "Negative Depression Screening"
  })

// This syntax { ... } is a "list selector" and lets us construct lists of values as an expression
// In the simplest case, like we're using it here, it just takes a single value and returns a list
// with that value as the only element.
// But we can also use list selectors to construct arbitrary lists:

define "List Selector": { 1, 2, 3, 4, 5 }

// One of the features that will be available in an upcoming version of the MAT is
// validation of the result types of the population expressions based on the kind of
// measure being authored.
// The following topic has a discussion about what the expected types are for each population criteria:
// https://github.com/esacinc/CQL-Formatting-and-Usage-Wiki/wiki/Specifying-Population-Criteria




