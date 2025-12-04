This topic documents some best-practices for timing-related calculations.

### Date, Time, and DateTime Values

Comparing `Date` and `DateTime` values results in implicit conversion of the `Date` to a `DateTime` with `null` components, and this can lead to unexpected partial comparison case. Authors should be explicit about precision when comparing `Date` and `DateTime` values, as comparing with mismatched precision can yield `null` results (which are often intepreted as `false`). In most cases, using `day of` precision is appropriate when comparing a `Date` and a `DateTime`.

In addition, authors should consider using `day of` when comparing between events within a specific period (such as within the measurement period) and date values are clinically appropriate, and should consider using `minute of` or `second of` precision when comparing between events where time values are clinically appropriate.

For more information on `Date`, `DateTime`, and `Time` comparison, see [Comparing Dates and Times](https://cql.hl7.org/02-authorsguide.html#comparing-dates-and-times) in the CQL Author's Guide.

> Note that a new feature of CQL R2, [_default comparison precision_](https://cql.hl7.org/2025Sep/03-developersguide.html#defaultcomparisonprecision) may be useful in supporting this best practice.

### Time-Valued Quantities
{: #time-valued-quantities}

For time-valued quantities, in addition to the definite duration UCUM units, CQL defines calendar duration keywords to support calendar-based durations and arithmetic. For example, UCUM defines an annum ('a') as 365.25 days, whereas the year ('year') duration in CQL is specifically a calendar year. This difference is important, especially when performing calendar arithmetic.

For example, if we take a DateTime and subtract a calendar year

```cql
@2019-01-01T05:00:00 - 1 year
```

This results in `2018-01-01T05:00:00`

However, if we take the same DateTime and subtract a UCUM annum

```cql
@2019-01-01T05:00:00 - 1 'a'
```

This results in run-time error because a UCUM annum is defined as 365.25 days and this value should never be used for calendar arithmetic. If this is truly the intended calculation, authors must convert the annum to seconds:

```cql
@2019-01-01T05:00:00 - convert 1 'a' to 's'
```

This results in `2017-12-31T23:00:00`.

Note carefully that when implicitly converting FHIR `Duration` values to CQL, a UCUM `annum` is converted to a calendar year, and a UCUM `mo` is converted to a calendar month. This is because when years and months appear in FHIR durations, it almost universally the intent that they represent calendar durations, rather than definite-time durations:

```cql
Patient.birthDate + (Condition.onset as Age)
```

If the duration in value in FHIR truly represents a definite-time duration, conversion to seconds is required in order to perform the date/time calculation.

See the definition of the [Quantity](https://cql.hl7.org/2020May/02-authorsguide.html#quantities) type in the CQL Author's Guide, as well as the [Date/Time Arithmetic](https://cql.hl7.org/02-authorsguide.html#datetime-arithmetic) discussion for more information.

> These best-practices are proposed for inclusion in the base specification (https://jira.hl7.org/browse/FHIR-53145) as well as the Using CQL With FHIR Specification (https://jira.hl7.org/browse/FHIR-53575).