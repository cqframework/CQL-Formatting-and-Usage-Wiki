library TestPJMCQLIT266 version '0.0.006'

/*testing only*/

//using QDM version '5.5'

include MATGlobalCommonFunctions version '6.2.000' called Global

codesystem "LOINC": 'urn:oid:2.16.840.1.113883.6.1'

valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837'
valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1'
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591'
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836'

code "Birth date": '21112-8' from "LOINC" display 'Birth date'

parameter "Measurement Period" Interval<DateTime>

/*
context Patient

define "SDE Ethnicity":
  ["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer":
  ["Patient Characteristic Payer": "Payer"]

define "SDE Race":
  ["Patient Characteristic Race": "Race"]

define "SDE Sex":
  ["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Initial Population":
  exists ( ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      where Global."CalendarAgeInYearsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) in Interval[18, 75 )
  )

define "Denominator":
  "Initial Population"

define "Numerator":
  "TargetPop"
    and (  exists ( "Question1x" )
        or exists ( "Question2x" )
        or exists ( "Question3x" )
        or exists ( "Question3x2" )
        or exists ( "Question3x3" )
        or exists ( "Question4x" )
        or exists ( "Question4x2" )
        or exists ( "Question4x3" )
        or exists ( "Question4x4" )
        or exists ( "Question4x5" )
        or exists ( "Question4x6" )
        or exists ( "Question5x" )
        or exists ( "Question5x2" )
        or exists ( "Question5x3" )
        or exists ( "Question6x" )
        or exists ( "Question6x1" )
        or exists ( "Question6x2" )
        or exists ( "Question6x3" )
        or exists ( "Question6x4" )
        or exists ( "Question6x5" )
        or exists ( "Question6x6" )
        or exists ( "Question7x" )
        or exists ( "Question8x" )
        or exists ( "Question9xA" )
    )

define "TargetPop":
  exists ( ["Patient Characteristic Birthdate": "Birth date"] BirthDate
      where Global."CalendarAgeInYearsAt" ( BirthDate.birthDatetime, start of "Measurement Period" ) in Interval[65, 75 )
  )
*/

// Integer defaults to per 1
// Interval as Integer, closed
define "Question1x":
  expand { Interval [ 1, 5 ] }

// Interval as Integer, open HI
define "Question2x":
  expand { Interval [ 1, 5 ) }

// Decimal defaults to per 1
// Interval as Decimal, closed HI
define "Question3x":
  expand { Interval [ 1.0, 5.0 ] }

define "Question3x2":
  expand { Interval [ 1.0, 5.0 ] } per 2.0

define "Question3x3":
  expand { Interval [ 1.0, 5.0 ] } per 0.1

// Interval as Decimal, open HI
define "Question4x":
  expand { Interval [ 1.0, 5.0 ) }

define "Question4x2":
  expand { Interval [ 1.0, 5.0 ) } per 2.0

define "Question4x3":
  expand { Interval [ 1.0, 5.0 ) } per 0.1

define "Question4x4":
  expand { Interval [ 1.00, 5.00 ) } per 0.1

define "Question4x5":
  expand { Interval [ 1.50, 5.50 ) } per 0.1

define "Question4x6":
  expand { Interval [ 1.55, 5.55 ) } per 0.1

// Interval as Decimal, open LO
define "Question5x":
  expand { Interval ( 1.0, 5.0] }

define "Question5x2":
  expand { Interval ( 1.0, 5.0] } per 2.0

define "Question5x3":
  expand { Interval ( 1.0, 5.0] } per 0.1

// Interval as Decimal, open LO HI
define "Question6x":
  expand { Interval ( 1.0, 5.0 ) }

define "Question6x1":
  expand { Interval ( 1.00, 5.00 ) }

define "Question6x2":
  expand { Interval ( 1.0, 5.0 ) } per 2.0

define "Question6x3":
  expand { Interval ( 1.0, 5.0 ) } per 0.1

define "Question6x4":
  expand { Interval ( 1.00, 5.00 ) } per 0.1

define "Question6x5":
  expand { Interval ( 1.50, 5.50 ) } per 0.1

define "Question6x6":
  expand { Interval ( 1.55, 5.55 ) } per 0.1

// Interval as Date
define "Question7x":
  expand { Interval[@2018-01-01, @2018-01-05]} per day

define "Question8x":
  expand { Interval[@2018-01-01T01:30:00, @2018-01-05T18:30:00]} per day

define "Question9xA":
  expand { Interval[@2018-01-01, @2018-01-31]} per day

//define "Question9xB":
//  expand { Interval[@2018-01-01,null]} per day
