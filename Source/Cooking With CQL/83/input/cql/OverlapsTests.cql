library OverlapsTests

define "Overlaps.TestOverlapsNull": Interval[null, null] overlaps Interval[1, 10]

define "Overlaps.IntegerIntervalOverlapsTrue": Interval[1, 10] overlaps Interval[4, 10]

define "Overlaps.IntegerIntervalOverlapsFalse": Interval[1, 10] overlaps Interval[11, 20]

define "Overlaps.DecimalIntervalOverlapsTrue": Interval[1.0, 10.0] overlaps Interval[4.0, 10.0]

define "Overlaps.DecimalIntervalOverlapsFalse": Interval[1.0, 10.0] overlaps Interval[11.0, 20.0]

define "Overlaps.QuantityIntervalOverlapsTrue": Interval[1.0 'g', 10.0 'g'] overlaps Interval[5.0 'g', 10.0 'g']

define "Overlaps.QuantityIntervalOverlapsFalse": Interval[1.0 'g', 10.0 'g'] overlaps Interval[11.0 'g', 20.0 'g']

define "Overlaps.DateTimeOverlapsTrue": Interval[DateTime(2012, 1, 5), DateTime(2012, 1, 25)] overlaps Interval[DateTime(2012, 1, 15), DateTime(2012, 1, 28)]

define "Overlaps.DateTimeOverlapsFalse": Interval[DateTime(2012, 1, 5), DateTime(2012, 1, 25)] overlaps Interval[DateTime(2012, 1, 26), DateTime(2012, 1, 28)]

define "Overlaps.TimeOverlapsTrue": Interval[@T10:00:00.000, @T19:59:59.999] overlaps Interval[@T12:00:00.000, @T21:59:59.999]

define "Overlaps.TimeOverlapsFalse": Interval[@T10:00:00.000, @T19:59:59.999] overlaps Interval[@T20:00:00.000, @T21:59:59.999]

define "OverlapsBefore.TestOverlapsBeforeNull": Interval[null, null] overlaps before Interval[1, 10]

define "OverlapsBefore.IntegerIntervalOverlapsBeforeTrue": Interval[1, 10] overlaps before Interval[4, 10]

define "OverlapsBefore.IntegerIntervalOverlapsBeforeFalse": Interval[4, 10] overlaps before Interval[1, 10]

define "OverlapsBefore.DecimalIntervalOverlapsBeforeTrue": Interval[1.0, 10.0] overlaps before Interval[4.0, 10.0]

define "OverlapsBefore.DecimalIntervalOverlapsBeforeFalse": Interval[4.0, 10.0] overlaps before Interval[1.0, 10.0]

define "OverlapsBefore.QuantityIntervalOverlapsBeforeTrue": Interval[1.0 'g', 10.0 'g'] overlaps before Interval[5.0 'g', 10.0 'g']

define "OverlapsBefore.QuantityIntervalOverlapsBeforeFalse": Interval[5.0 'g', 10.0 'g'] overlaps before Interval[1.0 'g', 10.0 'g']

define "OverlapsBefore.DateTimeOverlapsBeforeTrue": Interval[DateTime(2012, 1, 5), DateTime(2012, 1, 25)] overlaps Interval[DateTime(2012, 1, 15), DateTime(2012, 1, 28)]

define "OverlapsBefore.DateTimeOverlapsBeforeFalse": Interval[DateTime(2012, 1, 5), DateTime(2012, 1, 25)] overlaps Interval[DateTime(2012, 1, 26), DateTime(2012, 1, 28)]

define "OverlapsBefore.TimeOverlapsBeforeTrue": Interval[@T10:00:00.000, @T19:59:59.999] overlaps Interval[@T12:00:00.000, @T21:59:59.999]

define "OverlapsBefore.TimeOverlapsBeforeFalse": Interval[@T10:00:00.000, @T19:59:59.999] overlaps Interval[@T20:00:00.000, @T21:59:59.999]

define "OverlapsAfter.TestOverlapsAfterNull": Interval[null, null] overlaps after Interval[1, 10]

define "OverlapsAfter.IntegerIntervalOverlapsAfterTrue": Interval[4, 15] overlaps after Interval[1, 10]

define "OverlapsAfter.IntegerIntervalOverlapsAfterFalse": Interval[4, 10] overlaps after Interval[1, 10]

define "OverlapsAfter.DecimalIntervalOverlapsAfterTrue": Interval[4.0, 15.0] overlaps after Interval[1.0, 10.0]

define "OverlapsAfter.DecimalIntervalOverlapsAfterFalse": Interval[4.0, 10.0] overlaps after Interval[1.0, 10.0]

define "OverlapsAfter.QuantityIntervalOverlapsAfterTrue": Interval[5.0 'g', 15.0 'g'] overlaps after Interval[1.0 'g', 10.0 'g']

define "OverlapsAfter.QuantityIntervalOverlapsAfterFalse": Interval[5.0 'g', 10.0 'g'] overlaps after Interval[1.0 'g', 10.0 'g']

define "OverlapsAfter.DateTimeOverlapsAfterTrue": Interval[DateTime(2012, 1, 15), DateTime(2012, 1, 28)] overlaps Interval[DateTime(2012, 1, 5), DateTime(2012, 1, 25)]

define "OverlapsAfter.DateTimeOverlapsAfterFalse": Interval[DateTime(2012, 1, 26), DateTime(2012, 1, 28)] overlaps Interval[DateTime(2012, 1, 5), DateTime(2012, 1, 25)]

define "OverlapsAfter.TimeOverlapsAfterTrue": Interval[@T12:00:00.000, @T21:59:59.999] overlaps Interval[@T10:00:00.000, @T19:59:59.999]

define "OverlapsAfter.TimeOverlapsAfterFalse": Interval[@T20:00:00.000, @T21:59:59.999] overlaps Interval[@T10:00:00.000, @T19:59:59.999]

