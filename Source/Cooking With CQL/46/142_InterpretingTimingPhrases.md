# Interpreting Timing Phrases

Timing phrases allow natural language expression of interval and date/time comparisons. There are five categories of timing phrases:

* duration/difference calculation
* same as
* before/after
* within
* during/includes

## Duration and Difference
CQL supports calculation of calendar durations (years, months, weeks, days, hours, minutes, seconds, and milliseconds), where the _duration_ is the number of whole calendar periods between two date or date time values, and the _difference_ is the number of calendar boundaries crossed between two date or date time values.

For example:

```
months between @2014-01-01 and @2014-03-01
```

This example results in `2` because there are two full calendar months between `@2014-01-01` and `@2014-03-01`. However:

```
months between @2014-01-31 and @2014-02-01
```

This examples results in `0` because there is not a full calendar month between the two dates. To determine the number of boundaries crossed:

```
difference in months between @2014-01-31 and @2014-02-01
```

This example returns `1` because even though it's not a full month between the two dates, a month boundary was crossed.

Note that the `between` syntax can be used with or without the `duration in` prefix:

```
duration in months between @2014-01-31 and @2014-02-01
months between @2014-01-31 and @2014-02-01
```

When `between` is used without a prefix, `duration` is assumed.

## Same as
To directly compare two date/time values, you can use the standard equality operators:

```
@2020-07-30 = @2020-07-30
@2020-07-30 != @020-07-31
```

However, CQL also supports a `same as` timing phrase to support precision-based comparison of date/time values:

```
@2020-07-30 same as @2020-07-30
```

When used without a precision specifier as in the above example, the `same as` timing phrase is the same as equality. Precision specifiers can be used to compare date/time values to a specific precision:

```
@2020-07-30 same month as @2020-07-31
```

This returns true because the comparison only proceeds to the `month` precision.

## Relative comparison

To determine whether a date/time value is before or after another, CQL supports relative comparisons. As with equality, the standard relative comparison operators can be used:

```
@2020-07-30 < @2020-07-31
@2020-07-31 <= @2020-07-31
```

These comparisons both return true because the date July 30th, 2020 is _before_ July 31st, 2020, and July 31st is _on or before_ July 31st. As with direct comparison, CQL supports the `before` and `after` keywords:

```
@2020-07-30 before @2020-07-31 // equivalent to @2020-07-30 < @2020-07-31
@2020-07-31 on or before @2020-07-31 // equivalent to @2020-02-31 <= @2020-07-31
```

When no precision specifier is provided, these phrases are equivalent to the standard relative comparison operators. To compare to a particular precision:

```
@2020-07-30 before month of @2020-07-31
```

This comparison returns false, because although July 30th is _before_ July 31st, the comparison only proceeds to the _month_ and the months are the same.

## Direct comparison with offsets

Timing phrases for comparison can also include an _offset_, which allows a _duration_ to be considered as part of the comparison. For example:

```
@2020-07-01T09:30:00.0 1 hour before @2020-07-01T10:30:00.0
```

This returns true because 9:30AM on July 1st is exactly 1 hour before 10:30AM on July 1st. Note that this usage is a _direct_ comparison, not a relative comparison, so:

```
@2020-07-01T08:30:00.0 1 hour before @2020-07-01T10:30:00.0
```

This returns false because 8:30AM on July 1st is more than 1 hour before 10:30AM on July 1st. To support relative comparison with offsets, include the `or more` or `or less` keywords:

```
@2020-07-01T08:30:00.0 1 hour or more before @2020-07-01T10:30:00.0
```

The result of this comparison is true.

When using `or less`, the comparison is evaluated by considering an interval:

```
@2020-07-01T09:30:00.0 1 hour or less on or before @2020-07-01T10:30:00.0
```

The above comparison returns true because 9:30AM on July 1st, 2020 is 1 hour or less on or before 10:30AM on July 1st, 2020. This is equivalent to asking

```
@2020-07-01T09:30:00.0 >= (@2020-07-01T10:30:00.0 - 1 hour)
  and @2020-07-01T09:30:00.0 <= @2020-07-01T10:30:00.0
```

Some further examples using this timing phrase:
```
@2020-07-01T09:29:59.999 1 hour or less on or before @2020-07-01T10:30:00.0
```

This example returns false because 9:29:59.999AM on July 1st, 2020 is just barely more than 1 hour before 10:30AM on July 1st, 2020.

```
@2020-07-01T09:29:59.999 1 hour or less on or before hour of @2020-07-01T10:30:00.0
```
However, the above example returns true because the comparison only proceeds to the hour, and the hour, 9, is 1 hour or less before the hour, 10.

```
@2020-07-01T08:31:00.0 1 hour or less on or before @2020-07-01T10:30:00.0
```

The above example returns false because 8:31AM is more than 1 hour before 10:30AM (even though it is 1 hour and 59 minutes before).

To illustrate this point another way:

```
hours between @2020-07-01T08:31:00.0 and @2020-07-01T10:30:00.0 <= 1 // true
```

The above example returns true because the duration in hours between 8:31AM and 10:30 AM is less than or equal to 1 (even though there is 1 hour and 59 minutes between the two times, it's still less than or equal to 1 and the duration calculation is only looking for full hours).

```
difference in hours between @2020-07-01T08:31:00.0 and @2020-07-01T10:30:00.0 <= 1 // false
```

The above example returns false, because in using the `difference` calculation, we are indicating that we are concerned with the number of boundaries crossed, rather than the number of full hours, and two hour boundaries have been crossed between 8:31AM and 10:30AM.

Looking at another example, this time using `after` and to the `day`:

```
@2020-07-12T10:00:00.0 1 day after day of @2020-07-11T10:00:00.0 // true
```

The above example returns true because the comparison only proceeds to the day, and July 12th, 2020 is exactly 1 day after July 11th 2020.

```
@2020-07-11T23:59:59.999 1 day after day of @2020-07-11T10:00:00.0 // false
```

The above example returns false, again because the comparison only proceeds to the day, and July 11th, 2020 is the same day as July 11th, 2020, not the day after.

```
@2020-07-13T00:00:00.0 1 day after day of @2020-07-11T10:00:00.0 // false
```

And finally, the above example returns false because July 13th is _more than_ 1 day after July 11th.

Looking at another example, this time using `or less before` and `weeks`:

```
@2019-09-23 42 weeks or less before @2020-07-13 // true
```

The above example returns true because September 23rd, 2019 is 42 weeks or less before July 13th, 2020.

```
@2019-09-23T09:00:00.0 42 weeks or less before @2020-07-13T10:00:00.0 // false
```

Adding time into the comparison, the above example returns false, because 9:00AM on September 23rd is more than 42 weeks before July 13th 2020. Only 1 hour more, but still more.

```
@2019-09-23T09:00:00.0 42 weeks or less before day of @2020-07-13T10:00:00.0 // true
```

However, the above example returns true, because the comparison only proceeds to the day, September 23rd 2019 is 42 weeks before July 13th 2020, again because the time components are not considered in the comparison.

```
@2019-09-22T11:00:00.0 42 weeks or less before day of @2020-07-13T10:00:00.0 // false
```

And finally, the above example returns false, because the comparison proceeds to the day, and September 22nd 2019 is 1 day more than 42 weeks before July 13th 2020.


```
@2020-01-01T00:00:00.0 during Interval[@2020-01-01T00:00:00.0, @2020-01T10:30:00.00]
@2020-01-01T10:30:00.0 during Interval[@2020-01-01T00:00:00.0, @2020-01T10:30:00.00]
```

These examples return true because during is defined inclusively
