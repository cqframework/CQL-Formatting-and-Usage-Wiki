Timezone and Precision Test Cases:

1. Comparison calculations
2. "Day Of" calculations
3. Timezone Normalization calculations
4. Boundary calculations
5. Measure Period value

For the purposes of testing measure logic, the following test cases must be possible to construct:

# Comparison Calculations

For comparison calculations, consider the example calculation using the timing phrase `starts on or before`

```cql
define ProcedureStartsOnOrAfter:
  [Encounter] E
    with [Procedure] P
      such that P.performed.toInterval() starts on or after start E.period
```

To validate this logic behaves as expected, test cases may be constructed to ensure that:

1. An encounter with a procedure that starts before does not return
2. An encounter with a procedure that starts at the same time does return
3. An encounter with a procedure that starts after does return

If the user enters the following date and time for the start of the encounter:

```
2026-01-01 at 10:00 AM
```

The expectation is that an Encounter resource would be created with:

```json
{
    ...
    "period": {
        "start": "2026-01-01T10:00:00Z",
        ...
    },
    ...
}
```

Consistent with expectations for FHIR data, if seconds are not provided they may be zero-filled.

However, if the user enters the following value for the start of the encounter:

```
2026-01-01
```

i.e. a date with no time, the expectation is that an Encounter resource would be created with:

```json
{
    ...
    "period": {
        "start": "2026-01-01"
        ...
    },
    ...
}
```

as it may be the case that systems provide dates with no time components, including no timezone offset.

To ensure measure intent can be adequately tested with respect to time comparison, measure developers must be able to construct tests that meet these expectations.

# "Day Of" Calculations

"Day Of" calculations are critical for clinical logic, as many aspects of clinical care are tied to the "day" (i.e. midnight), rather than absolute time lapsed. For "day of" calculations, consider the following example calculation:

```cql
define ProcedureSameDayAs:
  [Encounter] E
    with [Procedure] P
      such that P.performed.toInterval() starts same day as start E.period
```

To validate this logic behaves as expected, test cases may be consutructed to ensure that:

1. A procedure that starts at 11:00 PM the night before the encounter does _not_ meet measure intent
2. A procedure that starts at exactly the same time as the encounter does meet measure intent
3. A procedure that starts the day of the encounter but after the start of the encounter does meet measure intent

Here again, if the user enters the following date and time for the start of the encounter:

```
2026-01-01 at 10:00 AM
```

The expectation is that an Encounter resource would be created with:

```json
{
    ...
    "period": {
        "start": "2026-01-01T10:00:00Z",
        ...
    },
    ...
}
```

And the following date and time for the start of the procedure:

```
2025-12-31 11:00 PM
```

The expectation is that a Procedure resource would be created with:

```json
{
    ...
    "performedPeriod": {
        "start": "2025-12-31T23:00:00Z",
        ...
    },
    ...
}
```

And here again, it should be possible to create a test case that supports when a time is not provided:

```
2025-12-31
```

resulting in:

```json
{
    ...
    "performedPeriod": {
        "start": "2025-12-31",
        ...
    },
    ...
}
```

# Timezone Normalization

A timezone edge case that occurs with clinical data is when two events in the same patient record are recorded in different timezone offsets. For example, the emergency department admission may be in a different timezone than the hospital admission for the same episode. When this occurs, timezone normalization is a key CQL logic expectation to ensure consistent handling. For timezone normalization, consider the following example calculation:

```cql
define ProcedureWithin24Hours:
  [Encounter] E
    with [Procedure] P
      such that P.performed.toInterval() starts 24 hours or less after start of E.period
```

This is admittedly an edge case, but it is known to occur, and worth discussion about how we can best ensure cases such as these are handled correctly.


# Boundary Calculations

Boundary calculations involve determining the number of date/time boundaries crossed, rather than the absolute duration. For boundary calculations, consider the following example calculation:

```cql
define ProceduresMoreThan2DaysAfter:
  [Encounter] E
    with [Procedure] P
      such that difference in days between start of P.performed.toInterval() and start of E.period >= 2
```

To validate that this logic behaves as expected, test cases may be constructed to ensure that:

1. A procedure that starts the same day as the encounter does not meet intent
2. A procedure that starts exactly two days after does meet intent
3. A procedure that starts more than two days after does meet intent

If a user enters the following values:

```
Encounter start: 2026-01-01 at 10:00 AM
Procedure start: 2026-01-03 at 2:00 PM
```

The expectation is that an Encounter would be created with:

```json
{
    ...
    "performedPeriod": {
        "start": "2026-01-01T10:00:00Z",
        ...
    },
    ...
}
```

and a Procedure with

```json
{
    ...
    "performedPeriod": {
        "start": "2026-01-03T14:00:00Z",
        ...
    },
    ...
}
```

# Measure Period Value

As part of measure logic, measure developers often provide the default value for the measurement period, such as:

```cql
parameter "Measurement Period" Interval<DateTime>
  default Interval[@2026-01-01T00:00:00Z, @2027-01-01T00:00:00Z)
```

When this is done, if all the test cases are provided using UTC, the measurement period default should be as well, to ensure that test cases perform as expected.

