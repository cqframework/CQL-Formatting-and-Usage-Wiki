# Consecutive SPO2 Readings

Inspired by this chat: 
https://chat.fhir.org/#narrow/stream/179220-cql/topic/CQL.20Language.20Syntax.2F.20documentation

## Question:

I'd like to list patients who have at least 3 SPO2 readings <92% (observations) for at least the last three days ( I.e. a minimum of 9 obs - 3 per day meeting the criteria).

Is it possible to do this kind of analysis in CQL and if so where can I find an example/ documentation covering this?

## Answer:

With thanks to Evan Machusak for providing this answer:

Define a function that pulls final, amended, and corrected Observations in the SPO2 Value Set on a given date, and with an observed value below 92%

```cql
define function LowSPO2(onDate Date):
  from [Observation: "SPO2 Value Set"] O // these will be observations related to one patient
    where O.status in { 'final', 'amended', 'corrected' }
      and date from start of O.effective.toInterval() = onDate
      and O.value < 0.92 '%'
```

Then you can use that function to count the number of "low SPO2 observations" on each of the last 3 days where "last" is with respect to the "Index Date" parameter

```cql
define "SPO2 Below 92 Within 3 Days":
  Count(LowSPO2("Index Date" - 1 day)) >= 3
    and Count(LowSPO2("Index Date" - 2 days)) >= 3
    and Count(LowSPO2("Index Date" - 3 days)) >= 3
```

One consideration is that breaking these out into "data elements" has some potential advantages:

```cql
define "SPO2 Observation":
  [Observation: "SPO2 Value Set"] O
    where O.status in { 'final', 'amended', 'corrected' }

define "Low SPO2 Observation":
  "SPO2 Observation" O
    where O.value < 0.92 '%'

define function LowSPO2Revised(onDate Date):
  "Low SPO2 Observation" O
    where date from start of O.effective.toInterval() = onDate
```

1. Defining the data elements independent of the time period allows them to be reused more effectively
2. Defining "Low SPO2 Observation" as a separate expression allows that result to be potentially used as an "intermediate". This can be helpful for debugging purposes, and can also be helpful for implementations that may be able to reuse the results of the expression, rather than having to recalculate (and potentially even re-retrieve) the data multiple times.