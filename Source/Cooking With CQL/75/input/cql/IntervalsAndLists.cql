/*
Intervals and Lists

Intervals
Comparing Intervals
Timing Phrases
List Values
List Operations
Aggregates
Lists of Strings
Lists of Lists
Lists of Intervals

Modify Each Expression so that it returns True, if it doesn't already
*/
library IntervalsAndLists

// # Intervals And Lists

define "Closed-Open Interval":
  Interval[3, 5)

define "Closed-Open Decimal Interval":
  Interval[3.0, 5.0)

define "Closed-Closed DateTime Interval":
  Interval[@2014-01-01T00:00:00.0, @2015-01-01T00:00:00.0]

define "Interval Contains":
  Interval[3, 5) contains 4

define "Interval In":
  4 in Interval[3, 5)

define "Start Of Interval":
  start of Interval[3, 5)

define "End of Interval":
  end of Interval[3, 5)

define "Width of Interval":
  width of Interval[3, 5)

define "Size of Interval":
  Size(Interval[3, 5))

define "Interval Equality":
  Interval[3, 5) = Interval[3, 4]

define "Interval Before":
  Interval[1, 2] before Interval[3, 4]

define "Interval After":
  Interval[3, 4] after Interval[1, 2]

define "Interval Meets":
  Interval[1, 2] meets Interval[3, 4]

define "Interval Overlaps":
  Interval[1, 5] overlaps Interval[3, 6]

define "Interval Starts":
  Interval[1, 2] starts Interval[1, 5]

define "Interval Included In":
  Interval[2, 4] included in Interval[1, 5]

define "Interval Includes":
  Interval[1, 5] includes Interval[2, 4]

define "Interval Ends":
  Interval[4, 5] ends Interval[1, 5]

// # Timing Phrases

define IntervalX:
  Interval[@2021-03-01, @2021-03-10]

define IntervalY:
  Interval[@2021-03-04, @2021-03-30]

define "Interval Starts Before Start":
  IntervalX starts before start IntervalY

define "Interval Starts 3 Days Before Start":
  IntervalX starts 3 days before start IntervalY

define "Interval Starts 3 Days Or More Before Start":
  IntervalX starts 3 days or more before start IntervalY

define "Interval Starts Within 3 days of Start":
  IntervalX starts within 3 days of start IntervalY

// # List Values

define "Integer List":
  { 1, 2, 3, 4, 5 }

define "Choice List":
  { 1, 'abc', null }

define "Tuple List":
  { { X: 1, Y: 1 }, { X: 2, Y: 2 } }

define "List Indexer":
  { 'a', 'b', 'c'}[1]

define "List Index Of":
  IndexOf({ 1, 2, 3 }, 2)

define "List Contains":
  { 1, 'abc', null } contains null

define "List Length":
  Length({ 1, 'abc', null })

define "List First":
  First({ 1, 2, 3 })

define "List Last":
  Last({ 1, 2, 3 })

define "Singleton From":
  singleton from { 1 }

// This will throw a run-time error, stopping evaluation of the library
//define "Singleton From (Error)":
//  singleton from { 1, 2, 3 }

define "List Take":
  Take({ 1, 2, 3, 4 }, 2)

define "List Skip":
  Skip({ 1, 2, 3, 4 }, 2)

define "List Tail":
  Tail({ 1, 2, 3, 4 })

define "ListX":
  { 1, 2, 3, 4, 5 }

define "ListY":
  { 2, 3, 4 }

define "List Contains (2)":
  ListX contains 3

define "List In (2)":
  3 in ListX

define "List Includes":
  ListX includes ListY

define "List Included In":
  ListY included in ListX

// # List Union

define ListA: { 1, 2, 3, 4, 5 }

define ListB: { 4, 5, 6, 7, 8 }

define "List Union":
  ListA union ListB

define "Choice List Union":
  { 1, 2, 3 } union { 'a', 'b', 'c' }

define "List Intersect":
  ListA intersect ListB

define "List Except":
  ListA except ListB

// # Aggregates

define "Aggregate Count":
  Count({ 1, 2, 3, null})

define "Aggregate Sum":
  Sum({ 1, 2, 3, null })

define "Aggregate Min":
  Min({ 1, 2, 3, null })

define "Aggregate Max":
  Max({ 1, 2, 3, null })

define "Aggregate Avg":
  Avg({ 1, 2, 3, null })

define "Aggregate Median":
  Median({ 1, 2, 3, null })

define "Aggregate Mode":
  Mode({ 1, 2, 3, null })

define "Aggregate Variance":
  Variance({ 1, 2, 3, null })

define "Aggregate StdDev":
  StdDev({ 1, 2, 3, null })

define "Aggregate Population Variance":
  PopulationVariance({ 1, 2, 3, null })

define "Aggregate Population StdDev":
  PopulationStdDev({ 1, 2, 3, null })

define "Aggregate All True":
  AllTrue({ true, false, true })

define "Aggregate Any True":
  AnyTrue({ true, false, true })

// # Lists of Strings

define "Combine Expression":
  Combine({ 'ab', 'cd', 'ef' })

define "Combine With Separator":
  Combine({ 'completed', 'refused', 'pending' }, ';')

define "Split Expression":
  Split('completed;refused;pending', ';')

// # Lists of Lists

define "Flatten Expression":
  flatten { { 1, 2, 3 }, { 2, 3, 4 }, { 3, 4, 5 } }

define "Distinct Expression":
  distinct { 1, 2, 3, 2, 3, 4, 3, 4, 5 }

define "Flatten Not Recursive":
  { { 1, 2, 3 }, { { 'a', 'b' }, { 'x', 'y' } } }

define "Flatten Lists and Elements":
  { { 1, 2, 3 }, 2, 3, 4 }

// # Lists of Intervals

define "Collapse Expression":
  collapse { Interval[1, 6], Interval[3, 7], Interval[9, 12] }

define "Expand Expression":
  expand { Interval[1, 7], Interval[9, 12] }

// This overload of expand was introduced STU in 1.5 and is
// not yet implemented in the Java-based CQL engine
//define "Expand Interval Expression":
//  expand Interval[1, 10] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
