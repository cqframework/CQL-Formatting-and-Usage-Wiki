This topic is a summary of the [Meausre Stratification](https://build.fhir.org/clinicalreasoning-quality-reporting.html#stratification) topic in the upcoming R6 normative ballot of the FHIR specification.

# Measure Stratification 

Measure stratification is specified using the `stratifier` element of the Measure resource. Stratification can be defined in two different ways:

1. Criteria-based: Criteria are specified as population expressions with the same population basis as the rest of the population criteria in the measure (e.g. `CMS146.AgesUpToNine`)
2. Value-based: Criteria are specified as an expression that is evaluated for each member of the population, yielding a stratum value (e.g. `Patient.deceased`)

## Criteria-based Stratifiers

Using criteria-based stratifiers is the most straightforward stratification approach as it is simply another set of population criteria for the measure. The expressions used to define criteria-based stratifiers must be consistent with the basis of the measure (i.e. they must return the same type as all the other population criteria expressions in the measure). For example, consider stratification into three age ranges: `0-20`, `21-40`, `41+`.

NOTE: These examples are deliberately ignoring the measurement period, as well as the fact that age a moving point. Real measures will of course need to take these factors into account, but these examples are focusing solely on the structural representation of the various approaches to stratification.

### Subject-based

Consider a simple, subject-based proportion measure:

Percentage of patients with a well-visit

```cql
define "Denominator":
  Patient.active is true

define "Numerator":
  exists ([Encounter: "Well-Visit Encounter Codes"])
```

Criteria-based stratification by age range is then expressed as:

```cql
define "Stratifier P0Y--P21Y":
  Patient.ageInYears() between 0 and 20

define "Stratifier P21Y--P41Y":
  Patient.ageInYears() between 21 and 40

define "Stratifier P41Y--P9999Y":
  Patient.ageInYears() >= 41
```

### Non-subject-based

Next, consider a simple, encounter-based proportion measure:

Percentage of well-visits with a blood pressure observation

```cql
define "Denominator":
  [Encounter: "Well-Visit Encounter Codes"]

define "Numerator":
  [Encounter: "Well-Visit Encounter Codes"] E
    with [Observation: "Blood Pressure Observation Codes"] O such that O.issued during E.period
```

Criteria-based stratification by age range is then expressed as:

```cql
define "Stratifier P0Y--P21Y":
  [Encounter: "Well-Visit Encounter Codes"] E
    where Patient.ageInYears() between 0 and 20

define "Stratifier P21Y--P41Y":
  [Encounter: "Well-Visit Encounter Codes"] E
    where Patient.ageInYears() between 21 and 40

define "Stratifier P41Y--P9999Y":
  [Encounter: "Well-Visit Encounter Codes"] E
    where Patient.ageInYears() >= 41
```

## Value-based Stratifiers

Value-based stratifiers are expressed as a set of stratifier components, each one identifying a path or an expression that returns a value from each member of the population being stratified. Using the same simple example measures as above:

Subject-based, valued-based, as a path, stratification by gender:

```xml
<stratifier>
  <component>
    <criteria>
      <expression value="gender"/>
    </criteria>
  </component>
</stratifier>
```

Note that with value-based stratifiers represented as a path, the value is an expression written from the perspective of the measure subject (Patient in this case) for subject-based measures, but the measure basis for non-subject-based measures.

Subject-based, value-based, as an expression

```cql
define "Age Range Stratifier":
  case
    when Patient.ageInYears() between 0 and 20 then 'P0Y--P21Y'
    when Patient.ageInYears() between 21 and 40 then 'P21Y--P41Y'
    when Patient.ageInYears() >= 41 then 'P41Y--P9999Y'
    else null
  end
```

The first thing to note here is that this approach required defining only a single `stratifier` element, "Age Range Stratifier", rather than the criteria-based approach, which required defining a `stratifier` element for each stratification group. Obviouisly, the more stratification groups, the more economical this approach becomes.

### Non-subject-based

Non-subject-based, value-based, as an expression

```cql
define function "Age Range Stratifier"(encounter Encounter):
  case
    when Patient.ageInYearsAt(start of encounter.period) between 0 and 20 then 'P0Y--P21Y'
    when Patient.ageInYearsAt(start of encounter.period) between 21 and 40 then 'P21Y--P41Y'
    when Patient.ageInYearsAt(start of encounter.period) >= 41 then 'P41Y--P9999Y'
    else null
  end
```

Note that with value-based stratifiers represented as an expression, the expression is written from the perspective of the measure subject, but also defines a parameter with the type of the basis. This is the same approach used to calculate measure observations, because the stratifier expression must be evaluated for each member of the population to determine the stratum value to which that member of the population belongs.

### Multi-component Stratifiers

While criteria-based stratifiers are expressed using the stratifier.criteria element, value-based stratifiers are specified using any number of component elements. Each component of the stratifier specifies an expression that returns the value of that component of the stratifier for members of the population. The advantage of using component stratifiers is that the combinations are computed, rather than having to be constructed explicitly in the logic. For example, consider the case of stratifying by age-range and gender, for the subject-based example measure:

```cql
define "Stratifier P0Y--P21Y":
  Patient.ageInYears() between 0 and 20

define "Stratifier P21Y--P41Y":
  Patient.ageInYears() between 21 and 40

define "Stratifier P41Y--P9999Y":
  Patient.ageInYears() >= 41

define "Stratifier Male":
  Patient.gender = 'male'

define "Stratifier Female":
  Patient.gender = 'female'
```

To do this using criteria-based stratifiers would require specifying a stratifier expression for each possible combination of age range group and gender. With even larger stratifications, this quickly becomes untenable. Value-based stratifiers simplify this, so the stratification can be expressed as:

```cql
define "Age Range Stratifier":
  case
    when Patient.ageInYearsAt(start of Encounter.period) between 0 and 20 then 'P0Y--P21Y'
    when Patient.ageInYearsAt(start of Encounter.period) between 21 and 40 then 'P21Y--P41Y'
    when Patient.ageInYearsAt(start of Encounter.period) > 41 then 'P41Y--P9999Y'
    else null
  end

define "Gender Stratifier":
  Patient.gender

define "Age Range and Gender Stratifier":
  "Age Range Stratifier" + ':' + Coalesce("Gender Stratifier", 'Unknown')
```

This is better, in that it only requires the creation of a single stratifier element referencing the "Age Range and Gender Stratifier" expression, but it arbitrarily forces construction of stratum values by combining the values from the other stratifiers. Instead, multi-component stratifiers allow this to be done directly:

```xml
<stratifier>
  <component>
    <criteria>
      <expression value="Age Range Stratifier"/>
    </criteria>
  </component>
  <component>
    <criteria>
      <expression value="Gender Stratifier"/>
    </criteria>
  </component>
</stratifier>
```

### Using Value Sets for Stratification

It is often the case that the set of possible values for a stratifiers is known and expressible using a terminology. When this is the case, the valueSet element of the stratifier may be used. When this is done, the value set used must be consistent with the other aspects of the stratifier definition. For example, given the "Age Range Stratifier" above, a value set with codes from the [Time Period Ranges](https://terminology.hl7.org/7.0.0/CodeSystem-time-period-ranges.html) code system can be used to provide the expected possible values as part of the stratifier specification:

```json
{
  "resourceType": "ValueSet",
  "url": "http://example.org/ValueSet/example-age-ranges",
  ...
  "compose" : {
    "include" : [{
      "system" : "http://terminology.hl7.org/CodeSystem/time-period-ranges",
      "concept": [{
        "code": "P0Y--P21Y",
        "display": "0 to 20 years"
      }, {
        "code": "P21Y--P41Y",
        "display": "21 to 40 years"
      }, {
        "code": "P41--P9999Y",
        "display": "41+ years"
      }]
    }]
  }
}
```

This can be used as the `valueSet` element of the stratifier:

```xml
<stratifier>
  <component>
    <valueSet value="http://example.org/ValueSet/example-age-ranges"/>
  </component>
</stratifier>
```

Note that ValueSet stratifiers can be used with or without a computable expression that determines the value. However, if they are used together, they must be consistent (i.e. the expression must always evaluate to a value that is a member of the value set).

> In R4, this is accomplished with the [cqm-valueSet](https://hl7.org/fhir/uv/cqm/StructureDefinition-cqm-valueSet.html) extension as specified in the [CQMComputableMeasure](https://hl7.org/fhir/uv/cqm/StructureDefinition-cqm-computablemeasure.html) profile.

## Overlapping Strata

Typically, stratifiers are constructed such that every member of a given population falls into one and only one stratum (i.e. the strata are disjoint groups). However, this is not required to be the case, so care must be taken to ensure stratifiers are expressed correctly. For example, consider the following stratifiers:

* Age up to 1 week
* Age up to 1 month
* Age up to 1 year

The implied intent is that these stratum are disjoint, but consider this criteria-based representation of this stratifier:

```cql
define "Age Up To 1 Week":
  AgeInDays() <= 7

define "Age Up To 1 Month":
  AgeInMonths() <= 1

define "Age Up To 1 Year":
  AgeInYears() <= 1
```

An infant aged 1 week or less would appear in all 3 groups.

Consider the value-based expression:

```cql
define "Age Range":
  case
    when AgeInDays() <= 7 then 'P0D--P8D'
    when AgeInMonths() <= 1 then 'P8D--P2M'
    when AgeInYears() <= 1 then 'P2M--P2Y'
    else null
  end
```

And the actually equivalent criteria-based expression:

```cql
define "Age Up To 1 Week":
  AgeInDays() <= 7

define "Age 8 Days To 1 Month":
  AgeInDays() >= 8 and AgeInMonths() <= 1

define "Age 2 Months To 1 Year":
  AgeInMonths() >= 2 and AgeInYears() <= 1
```

