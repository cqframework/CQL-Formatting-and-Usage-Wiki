library Overlaps

using QDM version '5.3'

/*
What is the expected result of an Overlaps when one of the intervals contains a null boundary?
*/

/*
http://cql.hl7.org/09-b-cqlreference.html#overlaps

If the:
  "ending point of the first interval is greater than or equal to the starting point of the second"
  and
  "starting point of the first interval is less than or equal to the ending point of the second"
  
In other words:

A overlaps B =>
  end of A >= start of B 
    and start of A <= end of B

A overlaps before B =>
  end of A >= start of B
    and start of A < start of B
    
A overlaps after B =>
  start of A <= end of B
    and end of A > end of B
*/

define I: Interval[@2018-06-01, @2018-06-30]

define T1: Interval[@2018-01-01, @2018-01-31]
define T2: Interval[@2018-01-01, @2018-12-31]
define T3: Interval[@2018-03-01, @2018-06-15]
define T4: Interval[@2018-06-01, @2018-06-30]
define T5: Interval[@2018-06-10, @2018-06-15]
define T6: Interval[@2018-06-15, @2018-07-31]
define T7: Interval[@2018-07-01, @2018-07-31]

/*
Visually, we can depict this as:

I                   |-------|

T1    |-------|
T2    |-----------------------------------|
T3              |-------|
T4                  |-------|
T5                    |---|
T6                      |-------|
T7                                |-------|
*/

/*
When interval boundaries are not present, there are two possible interpretations:
1) When a boundary is not present and the boundary is _closed_:
*/

define T8: [null, @2018-06-15]
define T9: [@2018-06-15, null]

/*
In this case, the interval is considered to continue indefinitely in the
direction of the boundary.

I                   |-------|

T8    <-----------------|
T9                      |----------------->
*/

/*
2) Whan a boundary is not present and the boundary is _open_:
*/

define T10: (null, @2018-06-15]
define T11: [@2018-06-15, null)


/*
In this case, the boundary is considered unknown and so the result is null:

I                   |-------|

T8                   ?--|
T9                      |--?
*/

