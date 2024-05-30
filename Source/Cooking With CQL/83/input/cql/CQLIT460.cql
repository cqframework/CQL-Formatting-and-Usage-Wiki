library CQLIT460


/*
    |--------|
       |-----|
*/
define "Overlaps.IntegerIntervalOverlapsTrue": 
  Interval[1, 10] overlaps Interval[4, 10]

/*
        |-----|
        |-----|    
*/
define "Overlaps.IntegerIntervalOverlapsTrue2":
  Interval[4, 10] overlaps Interval[4, 10]

/*
             |---------|
       |-----|
*/
define "Overlaps.IntegerIntervalOverlapsTrue3":
  Interval[10, 20] overlaps Interval[4, 10]

/*
        |-----|
        |-----|    
*/
define "OverlapsBefore.IntegerIntervalOverlapsBeforeFalse2":
  Interval[4, 10] overlaps before Interval[4, 10]

/*
        |-----|
        |-----|    
*/
define "OverlapsAfter.IntegerIntervalOverlapsAfterFalse2":
  Interval[4, 10] overlaps after Interval[4, 10]

/*
    |--------|
              |--------|
*/
define "Overlaps.IntegerIntervalOverlapsFalse": 
  Interval[1, 10] overlaps Interval[11, 20]

/*
    |--------|
       |-----|
*/
define "OverlapsBefore.IntegerIntervalOverlapsBeforeTrue": 
  Interval[1, 10] overlaps before Interval[4, 10]

/*
       |-----|
    |--------|
*/
define "OverlapsBefore.IntegerIntervalOverlapsBeforeFalse": 
  Interval[4, 10] overlaps before Interval[1, 10]

/*
       |----------|
    |--------|
*/
define "OverlapsAfter.IntegerIntervalOverlapsAfterTrue": 
  Interval[4, 15] overlaps after Interval[1, 10]

/*
       |-----|
    |--------|
*/
define "OverlapsAfter.IntegerIntervalOverlapsAfterFalse": 
  Interval[4, 10] overlaps after Interval[1, 10]

