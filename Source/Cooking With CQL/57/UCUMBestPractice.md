# UCUM Best Practices

Although the Unified Code for Units of Measure (UCUM) is a code system, it requires specific handling for two reasons. First, it is a grammar-based code system with an effectively infinite number of codes, so membership tests must be performed computationally, rather than just by checking for existence of a code in a list; and second, because UCUM codes are so commonly used as part of quantity values, healthcare contexts typically provide direct mechanisms for using UCUM codes.

For these reasons, within quality artifacts in general, and quality measures specifically, UCUM codes should make use of the direct mechanisms wherever possible. In CQL logic, this means using the [Quantity literal](https://cql.hl7.org/02-authorsguide.html#quantities), rather than declaring UCUM codes as direct-reference codes as is recommended when using codes from other code systems. For example, when accessing a Body Mass Index (BMI) observation in CQL:

```cql
define "BMI Percentile in Measurement Period":
  [Observation: "BMI percentile"] BMIPercentile
    where BMIPercentile.status in {'final', 'amended', 'corrected'}
      and BMIPercentile.effective during "Measurement Period"
      and BMIPercentile.value is not null
      and BMIPercentile.value.code = 'kg/m2'
```

Notice the use of the UCUM code directly, as opposed to declaring a CQL `code` for the unit:

```cql
codesystem UCUM: 'http://unitsofmeasure.org'
code "kg/m2": 'kg/m2' from UCUM

define "BMI Percentile in Measurement Period":
  [Observation: "BMI percentile"] BMIPercentile
    where BMIPercentile.status in {'final', 'amended', 'corrected'}
      and BMIPercentile.effective during "Measurement Period"
      and BMIPercentile.value is not null
      and BMIPercentile.value.code = "kg/m2"
```
