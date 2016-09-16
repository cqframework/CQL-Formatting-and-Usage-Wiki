// Expressions
  // Combinations of values, operations, and functions, that return valueset

// Retrieve
  // Central construct for accessing clinical information
  // Result of a retrieve is always a list of clinical data
  // Retrieve describes the type of data
  // How much data is returned depends on context (patient vs population)

  ["Encounter, Performed": "Inpatient"]

//id       code    relevantPeriod                         admissionSource diagnosis dischargeStatus facilityLocation locationPeriod lengthOfStay negationRationale principalDiagnosis reason
//-------- ------- -------------------------------------- --------------- --------- --------------- ---------------- -------------- ------------ ----------------- ------------------ --------
//ENC-0001 4525004 [2015-02-05T13:30Z, 2015-02-08T10:45Z] <No Value>      57054005  434781000124105 <No Value>       <No Value>     2 'days'     <No Value>        <No Value>         57054005

// Where

  ["Encounter, Performed": "Inpatient"] Encounter
    where Encounter.relevantPeriod during "Measurement Period"

// With

  ["Encounter, Performed": "Inpatient"] Encounter
    with ["Laboratory Test, Performed": "Streptococcus Test"] LabTest
      such that LabTest.resultDateTime during Encounter.relevantPeriod

// Without

  ["Encounter, Performed": "Inpatient"] Encounter
    without ["Laboratory Test, Performed": "Streptococcus Test"] LabTest
      such that LabTest.resultDateTime during Encounter.relevantPeriod

// Return

  ["Encounter, Performed": "Inpatient"] Encounter
    return { relevantPeriod: Encounter.relevantPeriod }

// Sort

  ["Encounter, Performed": "Inpatient"] Encounter
    sort by start of relevantPeriod

// Naming Expressions

  define "Sorted Encounters":
    ["Encounter, Performed": "Inpatient"] Encounter
      sort by start of relevantPeriod

// Index

  First("Sorted Encounters")

  Last("Sorted Encounters")

  "Sorted Encounters"[0]

  "Sorted Encounters"[1]

// Numbers and Arithmetic

  // CQL Supports Integers (whole numbers) and Decimals
  // Integers are implicitly converted to Decimals
  // Comparison of decimals ignores precision
  // Arithmetic operators
  // CQL uses standard operator precedence
  // Use parentheses to force precedence
  // Divide (/) always returns a decimal, use div for integer division

  5
  5.0
  5 + 5.0     // 10.0
  5.0 = 5.00  // true

  // Arithmetic

  2 + 5 * 10    // 52
  (2 + 5) * 10  // 70
  10 / 2        // 5.0
  10 div 2      // 5
  10 mod 2      // 0

  // Rounding
  Round(5.5)      // 6
  Round(5.55, 1)  // 5.6
  Truncate(5.5)   // 5
  Truncate(-5.5)  // -5
  Floor(5.5)      // 5
  Floor(-5.5)     // -6
  Ceiling(5.5)    // 6
  Ceiling(-5.5)   // -5

  // Exponents
  5 ^ 2                   // 25
  25 ^ 0.5                // 5
  Log(25, 5)              // 2
  Log(5, 25)              // 0.5
  Ln(10)                  // 2.30258209288405
  Exp(2.30258509288405)   // 10

// Quantities

  // Quantity type is a Decimal with a UCUM unit
  // Quantity operators
  // Implementations are required to respect units, but not necessarily
  // required to support conversions between them.
  // Arithmetic and comparison operators are defined for quantities.
  // Arithmetic operators in particular must return quantities with appropriate units,
  // but not necessarily converted units

  25 'mg'
  100 'cm2'
  1 'm' = 100 'cm'   // true
  10 'cm' * 10 'cm'  // 100 'cm2'

// Dates and Times

  // CQL Supports DateTimes and Times
  // Components
  // Partial DateTimes and Times
  // Timezone if not supplied is assumed based on the evaluation context
  // Date Comparison
  // Date Arithmetic
  // Now() and Today()
  // Duration and Difference

  // Literals (Constants in the CQL, as opposed to references to an identifier)
  @2014-01-25
  @2014-01-25T14:30:14.5

  @T12:00:00.0Z
  @T14:30:14.5-07:00

  @2014
  @2014-01
  @T14
  @T14:30

  // Date constructors
  DateTime(2014, 7, 5)
  Time(14, 30)

  // Date/Time Extraction
  date from @2014-01-25T14:30:14 // 2014-01-25
  time from @2014-01-25T14:30:14 // T14:30:14
  year from @2014-01-25          // 2014

  Now()
  Today()
  TimeOfDay()

  // Date Comparison
  @2014-01-15 = @2014-02-15                    // false
  @2014-01-15 < @2014-02-15                    // true
  @2014-01-15 <= @2014-02-15                   // true
  @2014-01-15 same year as @2014-02-15         // true
  @2012-01-15 same year or before @2014-02-15  // true
  @2012-01-15 before year of @2014-02-15       // true

  // Duration Quantities
  1 day
  2 years
  30 minutes
  1 'd'
  2 'a'
  30 'min'

  // Date Arithmetic
  Today() - 1 year
  @2014-02-01T14:30 + 30 minutes  // 2014-02-01T15:00
  @2014 + 24 months               // 2016

  // Duration and Difference
  duration in months between @2014-01-31 and @2014-02-01    // 0
  difference in months between @2014-01-31 and @2014-02-01  // 1

// Intervals

  // CQL Supports Intervals for Numbers and DateTime/Time Values
  // Open/Closed Ends
  // Comparing Intervals
  // Interval Operations

  Interval[3, 5)      // 3, 4
  Interval[3.0, 5.0)  // >= 3.0, < 5.0
  Interval[@2014-01-01T00:00:00.0, @2015-01-01T00:00:00.0]

  Interval[3, 5) contains 4  // true
  4 in Interval[3, 5)        // true

  start of Interval[3, 5)  // 3
  end of Interval[3, 5)    // 4

  width of Interval[3, 5)  // 2

  Interval[3, 5) = Interval[3, 4]           // true
  Interval[1, 2] before Interval[3, 4]      // true
  Interval[3, 4] after Interval[1, 2]       // true
  Interval[1, 2] meets Interval[3, 4]       // true
  Interval[1, 5] overlaps Interval[3, 6]    // true
  Interval[1, 2] begins Interval[1, 5]      // true
  Interval[2, 4] included in Interval[1, 5] // true
  Interval[1, 5] includes Interval[2, 4]    // true
  Interval[4, 5] ends Interval[1, 5]        // true

// Timing Phrases

  // Starts/Ends Before/After Start/End
  IntervalX starts before start IntervalY

  // Offset Before/After
  // Offset or More/Less Before/After
  IntervalX starts 3 days before start IntervalY
  IntervalX starts 3 days or more before start IntervalY

  // Within Offset of

  IntervalX starts within 3 days of start IntervalY

// String Manipulation

  // Strings use Single Quotes
  // Strings support escapes with a backslash (\)
  // String Comparison is Case-Sensitive
  // String Operators

  'John Doe'
  'John O\'Mally'
  'John Doe' = 'john doe' // false
  'Deer' < 'Doe'          // true

// Lists

  // Constructing Lists
  // Operating on Lists
  // Comparing Lists
  // Computing Lists

  { 1, 2, 3 }
  { 'active', 'completed', 'cancelled' }
  { 'a', 'b', 'c' }[0]                    // 'a'
  IndexOf({ 'a', 'b', 'c' }, 'b')         // 1
  IndexOf({ 'a', 'b', 'c' }, 'z')         // -1
  Count({ 'a', 'b', 'c' })                // 3
  { 1, 2, 3, 4, 5 } contains 4            // true
  4 in { 1, 2, 3, 4, 5 }                  // true
  exists ({ 1, 2, 3, 4, 5 })              // true
  exists ({ })                            // false

  X contains 3      // true
  3 in X            // true
  X includes Y      // true
  Y included in X   // true



// Aggregate Operators

// Terminology

// Patient Operators
