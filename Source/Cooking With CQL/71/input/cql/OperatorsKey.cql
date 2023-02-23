/*
Operators

Comparisons
Equality vs Equivalence
Arithmetic
Rounding and Exponents
String Manipulation
Date Comparison
Date Arithmetic
Calendar Durations vs UCUM
Duration and Difference
Conditionals
Operator Precedence
*/
library OperatorsKey

// # String Equality and Equivalence

define "String Equality":
  ('Abel' = 'abel') is false

define "String Equivalence":
  ('Abel' ~ 'abel') is true

define "String Comparison":
  ('Abel' < 'abel') is true

define "String Inequality":
  ('Abel' != 'abel') is true

define "String Inequivalence":
  ('Abel' !~ 'abel') is false

define "String Equality With Null":
  ('Abel' = null) is null

define "String Equivalence With Null":
  ('Abel' ~ null) is false

// # Equality vs Equivalence

define T1: { X: 1, Y: null }
define T2: { X: 1, Y: null }
define T3: { X: 1, Y: 2 }

define TEqual:
  (T1 = T2) is true

define TEqualWithNull:
  (T2 = T3) is null

define TEquivalent:
  (T2 ~ T3) is false

define C1:
  Code {
    code: 'ABC',
    display: 'Code ABC',
    system: 'http://example.com',
    version: '2017-01'
  }

define C2:
  Code {
    code: 'ABC',
    display: 'Variant Description',
    system: 'http://example.com',
    version: '2017-05'
  }

define CEqual:
  (C1 = C2) is false

define CEquivalent:
  (C1 ~ C2) is true

// # Arithmetic Operators

define "Standard Precedence":
  (2 + 5 * 10 = 52) is true

define "Force Precedence":
  ((2 + 5) * 10 = 70) is true

define "Division Always Results in a Decimal":
  (10 / 2 = 5.0) is true

define "Truncated Divide for Integer Division":
  (10 div 2 = 5) is true

define "Modulo is the Remainder":
  (10 mod 2 = 0) is true

define "Negation":
  (-(10) = -10) is true

define "Absolute Value":
  (Abs(-10) = 10) is true

define "Successor Of":
  (successor of 1 = 2) is true

define "Predecessor Of":
  (predecessor of 1 = 0) is true

define "Minimum Integer":
  (minimum Integer = -2147483647 - 1) is true

define "Maximum Integer":
  (maximum Integer = 2147483647) is true

// # Rounding And Exponents

define "Default Round":
  (Round(5.5) = 6) is true

define "Precision Round":
  (Round(5.55, 1) = 5.6) is true

define "Truncate":
  (Truncate(5.5) = 5) is true

define "Truncate Negative":
  (Truncate(-5.5) = -5) is true

define "Floor":
  (Floor(5.5) = 5) is true

define "Floor Negative":
  (Floor(-5.5) = -6) is true

define "Ceiling":
  (Ceiling(5.5) = 6) is true

define "Ceiling Negative":
  (Ceiling(-5.5) = -5) is true

define "Integer Exponent":
  (2 ^ 5 = 25) is true

define "Decimal Exponent":
  (25 ^ 0.5 = 5) is true

define "Logarithm Base 5":
  (Log(25, 5) = 2) is true

define "Logarithm Base 25":
  (Log(5, 25) = 0.5) is true

define "Natural Logarithm":
  (Ln(10) = 2.30258209288405) is true

define "Exponent":
  (Exp(2.30258509288405) = 10) is true

// # String Manipulation

define "String Concatenate":
   'AB' + 'CD' = 'ABCD'

define "String Concatenate With Nulls":
  'AB' + null

define "String Null Concatenate":
  'AB' & null & 'CD'

define "String Length":
  Length('ABCD')

define "String Indexer":
  'ABCD'[0]

define "PositionOf":
  PositionOf('C', 'ABCDCBA')

define "LastPositionOf":
  LastPositionOf('C', 'ABCDCBA')

define "StartsWith":
  StartsWith('AB', 'ABCDCBA')

define "EndsWith":
  EndsWith('AB', 'ABCDCBA')

define "Matches":
  Matches('ABCD', 'AB.*')

define "ReplaceMatches":
  ReplaceMatches('ABCD', 'C', 'X')

// # Date Comparisons

define "Date Equal":
  @2014-01-15 = @2014-02-15

define "Date Less Than":
  @2014-01-15 < @2014-02-15

define "Date Less Or Equal":
  @2014-01-15 <= @2014-02-15

define "Same Year As":
  @2014-01-15 same year as @2014-02-15

define "Same Year Or Before":
  @2012-01-15 same year or before @2014-02-15

define "Before Year Of":
  @2012-01-15 before year of @2014-02-15

// # Date Arithmetic

define "Day Quantity":
  1 day

define "Years Quantity":
  2 years

define "Minutes Quantity":
  30 minutes

define "UCUM Days":
  1 'd'

define "UCUM Annum":
  2 'a'

define "UCUM Minutes":
  30 'min'

define "1 Year Ago":
  Today() - 1 year

define "Add 30 Minutes":
  @2014-02-01T14:30 + 30 minutes

define "Add 24 Months":
  @2014 + 24 months

define "Calendar Years Equivalent To UCUM Annum (a)":
  1 year ~ 1 'a'

define "Calendar Months Equivalent To UCUM Month (mo)":
  1 month ~ 1 'mo'

define "Calendar Weeks Equal To UCUM Weeks (wk)":
  1 week = 1 'wk'

define "Calendar Days Equal To UCUM Days (d)":
  1 day = 1 'd'

define "Calendar Hours Equal To UCUM Hours (h)":
  1 hour = 1 'h'

define "Calendar Minutes Equal To UCUM Minutes (min)":
  1 minute = 1 'min'

define "Calendar Seconds Equal To UCUM Seconds (s)":
  1 second = 1 's'

define "Calendar Milliseconds Equal To UCUM Milliseconds (ms)":
  1 millisecond = 1 'ms'

// # Duration And Difference

define "Duration In Months Between":
  duration in months between @2014-01-31 and @2014-02-01

define "Difference In Months Between":
  difference in months between @2014-01-31 and @2014-02-01

// # Conditionals

define strength:
  10.0 'mg/mL'

define "If Conditional":
  if strength.value < 0.1 then
    Quantity {
      value: strength.value * 1000,
      unit: 'mcg' + Substring(strength.unit, 2)
    }
  else
    strength

define unit:
  'MG/ACTUAT'

define "Selected Case Conditional":
  case unit
    when 'MG' then 'mg'
    when 'MG/ACTUAT' then 'mg/{actuat}'
    when 'MG/HR' then 'mg/h'
    when 'MG/ML' then 'mg/mL'
    else '{' + unit + '}'
  end

define doseFormCode:
  316897

define "Conditional Case":
  case
    when doseFormCode = 316897 then 12.6
    else 30
  end