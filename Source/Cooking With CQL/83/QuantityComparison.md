# Quantity Comparison

## Question

This CQL ran correctly a month ago:

```cql
define AllObservations:
  [Observation]

define "Weight Observations":
  [Observation: "Body Weight"]

define "Last body weight observation":
   Last([Observation: "Body Weight"] O
         where O.status in { 'final', 'amended', 'corrected' }
         sort by effective ascending)

define "Last known body weigth":
    "Last body weight observation".value

define "Last known body weigth exceeds 60 kg":
    "Last body weight observation".value as FHIR.Quantity > 60000 'g'
```

But now using CQL Runner:

1. The `sort by effective ascending` results in a "Type org.hl7.fhir.r4.model.DateTimeType is not comparable", and
2. The "Last known body weigth exceeds 60 kg" returns `null`

## Answer

The [CQL Runner](https://cql-runner.dataphoria.org/) is an online tool that allows users to evaluate CQL libraries. The runner has been available for many years, but had not been updated in quite a while. We recently updated the runner to use the latest available translator and engine, which has fixes for some issues that were present in this example.

1. The error being thrown for the `sort by effective` is because effective is a choice type in FHIR, representable as `dateTime`, `Period`, `Timing` or `instant`. Although FHIRHelpers is included, the translator is not able to resolve those choices to a single value suitable for comparison as part of an ordering step. Adding `.value` to the `effective` will address this (although it won't address the larger issue of how to deal with data that is represented using a Period or Timing; for that, use `FHIRCommon.toInterval()`

2. The `"Last known body weigth exceeds 60 kg"` returning `null` is because the engine does not fully support unit comparison. CQL allows engines to return `null` when asked to perform an unsupported unit comparison (see the implementation note in the [Quantity Operators](https://cql.hl7.org/02-authorsguide.html#quantity-operators) topic). To correct this, change the quantity literal from `60000 'g'` to `60 'kg'`. Note that this means the data must be represented using `kg`, or the result will be `null`.

The reason these errors are occurring now is that the version of the engine that was in CQL Runner was quite old, and these are both known issues with older versions of the engine that have since been corrected, and now that the CQL Runner was updated, it is using the newer engine which corrects the handling for both these issues.