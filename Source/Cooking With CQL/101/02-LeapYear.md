This topic discusses leap year handling in the specification.

The question recently arose, How does the CQL standard handle leap year calculation?

The answer is that we follow ISO-8601 calendar semantics and specifically define a calendar year as:

> time interval which starts at a certain time of day at a certain calendar date of the calendar year and ends at the same time of day at the same calendar date of the next calendar year, if it exists. In other cases, the ending calendar day has to be agreed on.

[Source](https://cql.hl7.org/05-languagesemantics.html#definitions)

The agreement about "ending calendar day" for the CQL specification is captured in the definition of date/time arithmetic:

> The year, positive or negative, is added to the year component of the date or time value. If the resulting year is out of range, an error is thrown. If the month and day of the date or time value is not a valid date in the resulting year, the **last day of the calendar month is used**. For example, DateTime(2012, 2, 29, 0, 0) + 1 year = DateTime(2013, 2, 28, 0, 0). The resulting date or time value will have the same time components.

[Source](https://cql.hl7.org/05-languagesemantics.html#datetime-arithmetic-1)