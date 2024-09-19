# Stratifiers

Stratifiers are used in Measures to provide a breakdown of the cases in a population by different criteria, such as age or gender.

Any characteristic that can be determined from the data can be used to define a stratifier.

Typically, stratifiers are used to define a _complete partitioning_, meaning that for a given stratifier, each case is expected to fall into one and only one _stratum_, although this is not an enforced requirement.

## Stratifying by Age Group

The example measure EXM74 - Primary Caries Prevention as Offered by Dentists illustrates stratification by age groups.

The measure initial population is:

> Children, 1-20 years of age at the start of the measurement period, with a clinical oral evaluation by a dentist during the measurement period

```cql
define "Initial Population":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[1, 20]
    and exists ( "Qualifying Encounters" )
```

The denominator is the same as the initial population, and the numerator is:

> Children who receive two fluoride varnish applications on different days during the measurement period

```cql
define "Numerator":
  Count((([Procedure: "Fluoride Varnish Application for Children"]).isProcedurePerformed()) FluorideApplication
      where FluorideApplication.performed.toInterval() ends during day of "Measurement Period"
      return distinct date from 
      end of FluorideApplication.performed.toInterval()
  ) >= 2
```

The initial population is then stratified by:

> Population 1: Patients age 1-5 years at the start of the Measurement Period
> Population 2: Patients age 6-12 years at the start of the Measurement Period
> Population 3: Patients age 13-20 years at the start of the Measurement Period

```cql
define "Stratification 1":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[1, 5]

define "Stratification 2":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[6, 12]

define "Stratification 3":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[13, 20]
```

This is a patient-based proportion measure, so the _population basis_ (i.e. the type of criteria based on what the types of individual cases in the population) is `boolean`:

```json
{
    "url": "http://hl7.org/fhir/us/cqfmeasures/StructureDefinition/cqfm-populationBasis",
    "valueCode": "boolean"
}
```

These stratifiers are expressed as population criteria, so they result in a `boolean` value, just like all the other population criteria.

In addition, these stratifiers partition the initial population into 3 groups, based on the patient's age. The partition is complete, and uses the [appliesTo](https://build.fhir.org/ig/HL7/cqf-measures/StructureDefinition-cqfm-appliesTo.html) extension to indicate that the stratification should be applied to the initial population:

```json
{
    "id": "b4b470c5-adca-4b31-bd80-9717d6ebfe87",
    "extension": [{
        "url": "http://hl7.org/fhir/us/cqfmeasures/StructureDefinition/cqfm-appliesTo",
        "valueCodeableConcept": {
            "coding": [{
                "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                "code": "initial-population",
                "display": "Initial Population"
            }]
        }
    }],
    "description": "Population 1: Patients age 1-5 years at the start of the Measurement Period",
    "criteria": {
        "language": "text/cql-identifier",
        "expression": "Stratification 1"
    }
}, {
    ...
}
```    

The `appliesTo` extension allows the stratifier to specify which population should be stratified:

>  Indicates the population that this stratifier should apply to. If no appliesTo extension is present, the stratifier is calculated based on the result of the population calculation (e.g. the calculated numerator for a proportion scoring).

In the absence of this extension, the stratifier would be applied to the numerator, since this is a proportion measure.

The result of this stratification is then reported as:

```json
{
    "stratifier": [{
        "id": "b4b470c5-adca-4b31-bd80-9717d6ebfe87",
        "stratum": [{
            "value": { "text": "true" },
            "population": [{
                "code": {
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                        "code": "initial-population",
                        "display": "Initial Population"
                    }]
                },
                "count": 33
            }],
            "measureScore": {
                "value": 0.33
            }
        }]
    }, {
        "id": "d7c07980-4cab-4f35-a00b-216b17f3f08c",
        "stratum": [{
            "value": { "text": "true" },
            "population": [{
                "code": {
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                        "code": "initial-population",
                        "display": "Initial Population"
                    }]
                },
                "count": 33
            }],
            "measureScore": {
                "value": 0.33
            }
        }]
    }, {
        "id": "d7a5caa5-6309-4572-b76a-e5c1ca50b0cb",
        "stratum": [{
            "value": { "text": "true" },
            "population": [{
                "code": {
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                        "code": "initial-population",
                        "display": "Initial Population"
                    }]
                },
                "count": 34
            }],
            "measureScore": {
                "value": 0.34
            }
        }]
    }]
}
```

> NOTE: `false` results are omitted here because they are redundant.

## Example - Stratifying by Principal Diagnosis

The example measure EXM55 - Median Embergency Department Visit Duration illustrates stratification by principal diagnosis.

The initial population is:

> Inpatient encounters during the measurement period with an emergency department visit that ends one hour or less before the start of the encounter

```cql
define "Initial Population" :
  "Inpatient Encounter" Encounter
    with ["Encounter" : "Emergency Department Visit"] ED
     such that ED.status = 'finished'
       and ED.period ends 1 hour or less before start of Encounter.period
```

The measure population is the same as the initial population, and the measure observation is:

```cql
define function "Measure Observation" (Encounter "Encounter" ):
  duration in minutes of "Related ED Visit"(Encounter).period
```

The result is then stratified by whether the prinicipal diagnosis is in the "Psychiatric/Mental Health Patient" value set:

> Stratification 1: Principal diagnosis in "Psychiatric/Mental Health Patient"
> Stratification 2: Principal diagnosis not in "Psychiatric/Mental Health Patient"
> Stratification 3: No principal diagnosis

```cql
define "Stratification 1" :
  "Inpatient Encounter" Encounter
    where not (PrincipalDiagnosis(Encounter).code in "Psychiatric/Mental Health Patient")

define "Stratification 2" :
  "Inpatient Encounter" Encounter
    where PrincipalDiagnosis(Encounter).code in "Psychiatric/Mental Health Patient"

define "Stratification 3" :
  "Inpatient Encounter" Encounter
    where PrincipalDiagnosis(Encounter) is null
```

This measure is an encounter-based continuous-variable measure, so the population criteria return a list of encounters, and the stratification criteria are expressed in this same way. The stratification is then computed using standard population semantics (i.e. intersection).

Note that this stratification is a complete partition (i.e. every encounter in the measure population appears in one and only one of these stratifiers). This is the reason for the third stratifier, to capture measure population encounters that do not have a principal diagnosis.

This is then reported as:

```json
{
    "stratifier": [{
        "code": {
            "text": "Stratification 1"
        },
        "stratum": [{
            "value": { "text": "true" },
            "population": [{
                "code": {
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                        "code": "initial-population",
                        "display": "Initial Population"
                    }]
                },
                "count": 33
            }],
            "measureScore": {
                "value": 18,
                "code": "min",
                "system": "http://unitsofmeasure.org"
            }
        }]
    }, {
        "code": {
            "text": "Stratification 2"
        },
        "stratum": [{
            "value": { "text": "true" },
            "population": [{
                "code": {
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                        "code": "initial-population",
                        "display": "Initial Population"
                    }]
                },
                "count": 33
            }],
            "measureScore": {
                "value": 28,
                "code": "min",
                "system": "http://unitsofmeasure.org"
            }
        }]
    }, {
        "code": {
            "text": "Stratification 3"
        },
        "stratum": [{
            "value": { "text": "true" },
            "population": [{
                "code": {
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                        "code": "initial-population",
                        "display": "Initial Population"
                    }]
                },
                "count": 34
            }],
            "measureScore": {
                "value": 15
                "code": "min",
                "system": "http://unitsofmeasure.org"
            }
        }]
    }]
}
```

## Example - Stratifying by Gender

So far, these examples have used population criteria to describe the stratification. In other words, the stratifier criteria are expressed in terms of the same population basis as all the other population criteria in the measure. This approach is flexible enough to accomodate stratification by any value that can be determined from the data, stratifiers can be as sophisticated as needed to meet measure intent.

However, another approach to stratification involves providing an expression that directly returns the stratum value for each case. In other words, rather than specifying separate stratifier criteria for each group, define a stratifier criteria that directly returns the group value.

Consider the criteria required to stratify by gender using the population criteria approach:

```cql
define "Stratification 1":
  Patient.gender = 'male'

define "Stratification 2":
  Patient.gender = 'female'

define "Stratification 3":
  Patient.gender = 'other'

define "Stratification 4":
  Patient.gender = 'unknown'

define "Stratification 5":
  Patient.gender is null
```

For a patient-based proportion measure, this stratification will provide a complete partitioning of the population. However, by using the direct stratum value approach, we can simply define a stratifier that returns the stratum value for the case:

```cql
define "Stratification by Gender":
  Patient.gender
```

This is functionally the same stratifier, but expressed by directly returning the stratum value, rather than partitioning the population.

Of course, in order to make use of this approach, the expression must return a value that represents the stratification grouping, as shown in the next example.

## Example - Stratification by Age Group Directly

Revisiting the stratification by age group example above:

```cql
define "Stratification 1":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[1, 5]

define "Stratification 2":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[6, 12]

define "Stratification 3":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[13, 20]
```

This could be expressed as a stratum value using:

```cql
define "Stratification by Age Group":
  case
    when AgeInYearsAt(date from start of "Measurement Period") in Interval[1, 5] then "1Y--5Y"
    when AgeInYearsAt(date from start of "Measurement Period") in Interval[6, 12] then "6Y--12Y"
    when AgeInYearsAt(date from start of "Measurement Period") in Interval[13, 20] then "13Y--20Y"
    else null
  end
```

Note that these codes are expressed using an "ISO 8601-Derived Periods" approach that uses ISO 8601 to express an interval of calendar periods as a code.

This stratifier is then expressed in the measure as:

```json
{
    "description": "Stratification by Age Groups (1 to 5, 6 to 12, and 13 to 20 years)",
    "criteria": {
        "language": "text/cql-identifier",
        "expression": "Stratification by Age Group"
    }
}
```

This results in the measure being stratified by these age groups:

```json
{
    "stratifier": [{
        "stratum": [{
            "value": { "text": "1Y--5Y" },
            "population": [{
                "code": {
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                        "code": "numerator",
                        "display": "Numerator"
                    }]
                },
                "count": 33
            }],
            "measureScore": {
                "value": 0.33
            }
        }, {
            "value": { "text": "6Y--12Y" },
            "population": [{
                "code": {
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                        "code": "numerator",
                        "display": "Numerator"
                    }]
                },
                "count": 33
            }],
            "measureScore": {
                "value": 0.33
            }
        }, {
            "value": { "text": "13Y--20Y" },
            "population": [{
                "code": {
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                        "code": "numerator",
                        "display": "Numerator"
                    }]
                },
                "count": 34
            }],
            "measureScore": {
                "value": 0.34
            }
        }]
    }]
}
```

## Stratifying by Age Group and Gender

This same approach can be used to provide for combination stratifiers, such as stratifying by age group and gender combined:

```cql
define "Stratification by Age Group":
  case
    when AgeInYearsAt(date from start of "Measurement Period") in Interval[1, 5] then "1Y--5Y"
    when AgeInYearsAt(date from start of "Measurement Period") in Interval[6, 12] then "6Y--12Y"
    when AgeInYearsAt(date from start of "Measurement Period") in Interval[13, 20] then "13Y--20Y"
    else null
  end

define "Stratification by Gender":
  Patient.gender

define "Stratification by Age Group and Gender":
  "Stratification by Age Group" + ":" + Patient.gender.code
```

This results in a stratum value that is the combined representation of the age group and the gender value:

```
1Y--5Y:male
```

This works, but requires the construction of a representation of the stratum value. Rather than require this, the Measure and MeasureReport resources support _component stratifiers_ that allow multiple criteria to be used to define a stratification. In the Measure, rather than specify a single criteria for the stratifier, we can use the `component` element to specify both criteria:

```json
{
    "stratifier": [{
        "component": [{
            "code": { "text": "Age Group" },
            "description": "Stratification by Age Groups (1 to 5, 6 to 12, and 13 to 20 years)",
            "criteria": {
                "language": "text/cql-identifier",
                "expression": "Stratification by Age Group"
            }
        }, {
            "code": { "text": "Gender" },
            "description": "Stratification by Gender",
            "criteria": {
                "language": "text/cql-identifier",
                "expression": "Stratification by Gender"
            }
        }]
    }]
}
```

This stratifier is then reported as:

```json
{
    "stratifier": [{
        "stratum": [{
            "component": [{
                "code": { "text": "Age Group" },
                "value": { "text": "1Y--5Y" }
            }, {
                "code": { "text": "Gender" },
                "value": { "text": "male" }
            }],
            "population": [{
                "code": {
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                        "code": "numerator",
                        "display": "Numerator"
                    }]
                },
                "count": 16
            }],
            "measureScore": {
                "value": 0.16
            }
        }, {
            "component": [{
                "code": { "text": "Age Group" },
                "value": { "text": "1Y--5Y" }
            }, {
                "code": { "text": "Gender" },
                "value": { "text": "female" }
            }],
            "population": [{
                "code": {
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                        "code": "numerator",
                        "display": "Numerator"
                    }]
                },
                "count": 17
            }],
            "measureScore": {
                "value": 0.17
            }
        }, {
            ...
        }]
    }]
}
```

And note finally that component stratifiers work with the population stratifier approach as well, the stratifier combinations just need to be spelled out explicitly:

```cql
define "Age 1 to 5":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[1, 5]

define "Age 6 to 12":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[6, 12]

define "Age 13 to 20":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[13, 20]

define "Gender Male":
  Patient.gender = 'male'

define "Gender Female":
  Patient.gender = 'female'
```

In the measure this is specified as multiple stratifiers:

```json
{
    "stratifier": [{
        "code": { "text": "Age Group 1 to 5, Gender Male" },
        "component": [{
            "code": { "text": "Age Group 1 to 5" },
            "criteria": {
                "language": "text/cql-identifier",
                "expression": "Age Group 1 to 5"
            }
        }, {
            "code": { "text": "Gender Male" },
            "criteria": {
                "language": "text/cql-identifier",
                "expression": "Gender Male"
            }
        }]
    }, {
        "code": { "text": "Age Group 1 to 5, Gender Female" },
        "component": [{
            "code": { "text": "Age Group 1 to 5" },
            "criteria": {
                "language": "text/cql-identifier",
                "expression": "Age Group 1 to 5"
            }
        }, {
            "code": { "text": "Gender Female" },
            "criteria": {
                "language": "text/cql-identifier",
                "expression": "Gender Female"
            }
        }]
    }, {
        "code": { "text": "Age Group 6 to 12, Gender Male" },
        "component": [{
            "code": { "text": "Age Group 6 to 12" },
            "criteria": {
                "language": "text/cql-identifier",
                "expression": "Age Group 6 to 12"
            }
        }, {
            "code": { "text": "Gender Male" },
            "criteria": {
                "language": "text/cql-identifier",
                "expression": "Gender Male"
            }
        }]
    }, {
        "code": { "text": "Age Group 6 to 12, Gender Female" },
        "component": [{
            "code": { "text": "Age Group 6 to 12" },
            "criteria": {
                "language": "text/cql-identifier",
                "expression": "Age Group 6 to 12"
            }
        }, {
            "code": { "text": "Gender Female" },
            "criteria": {
                "language": "text/cql-identifier",
                "expression": "Gender Female"
            }
        }]
    }, {
        "code": { "text": "Age Group 13 to 20, Gender Male" },
        "component": [{
            "code": { "text": "Age Group 13 to 20" },
            "criteria": {
                "language": "text/cql-identifier",
                "expression": "Age Group 13 to 20"
            }
        }, {
            "code": { "text": "Gender Male" },
            "criteria": {
                "language": "text/cql-identifier",
                "expression": "Gender Male"
            }
        }]
    }, {
        "code": { "text": "Age Group 13 to 20, Gender Female" },
        "component": [{
            "code": { "text": "Age Group 13 to 20" },
            "criteria": {
                "language": "text/cql-identifier",
                "expression": "Age Group 13 to 20"
            }
        }, {
            "code": { "text": "Gender Female" },
            "criteria": {
                "language": "text/cql-identifier",
                "expression": "Gender Female"
            }
        }]
    }]
}
```

And this stratification would then be reported as:

```json
{
    "stratifier": [{
        "code": { "text": "Age Group 1 to 5, Gender Male" },
        "stratum": [{
            "component": [{
                "code": { "text": "Age Group 1 to 5" },
                "value": { "text": "true" }
            }, {
                "code": { "text": "Gender Male" },
                "value": { "text": "true" }
            }],
            "population": [{
                "code": {
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                        "code": "numerator",
                        "display": "Numerator"
                    }]
                },
                "count": 16
            }],
            "measureScore": {
                "value": 0.16
            }
        }]
    }, {
        "code": { "text": "Age Group 1 to 5, Gender Female" },
        "stratum": [{
            "component": [{
                "code": { "text": "Age Group 1 to 5" },
                "value": { "text": "true" }
            }, {
                "code": { "text": "Gender Female" },
                "value": { "text": "true" }
            }],
            "population": [{
                "code": {
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                        "code": "numerator",
                        "display": "Numerator"
                    }]
                },
                "count": 17
            }],
            "measureScore": {
                "value": 0.17
            }
        }]
    }, {
        ...
    }]
}
```

