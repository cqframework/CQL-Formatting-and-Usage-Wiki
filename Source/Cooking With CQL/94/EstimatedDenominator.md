This topic discusses modeling measures that involve estimated denominators, i.e. measures where the denominator value is provided by other means, rather than derived from data in the source system.

For this discussion, we'll consider a measles indicator from the WHO SMART Guideline for Measles Immunizations:

```
Library: IMMZ.IND.12 Logic
Immunization coverage for Measles and rubella containing vaccine, 1st dose 
The percentage in the target population who have received one dose of measles and rubella vaccine during reporting period

Numerator: Number of measles and rubella doses (1st dose) administered through routine services during reporting period
Numerator Computation: COUNT of immunization events WHERE "Vaccine type" = "Measles and rubella containing vaccines"  for the first dose in the primary series AND "Date and time of vaccination" is during the reporting period
Denominator: Number in target group
Denominator Computation: As defined by the Member States

References: WHO Immunization facility analysis guide;WHO Handbook on immunization data
```

This indicator definition allows implementing member states to define the denominator. In some cases, the denominator is pulled from source system data, but in some cases, the denominator is based on population estimates from the region, rather than source system data.

To support this approach, instead of modeling the measure as a simple proportion measure, we set the measure up as a ratio of continuous variables. This allows to control how the counting is performed for both the numerator and denominator values.

Because it is a ratio measure, we can define different bases for the denominator and numerator, so while the numerator will be patient-based, the denominator will be location-based:

```cql
/*
 * As defined by Member State, but defaulted based on locations with encounters
 */
define "Denominator Initial Population":
  [Location] L
    with "Encounter During Measurement Period" E
     such that E.location.references(L)

define "Denominator":
  "Denominator Initial Population"
```

By default, this sets up the denominator as the set of locations that had patient encounters.

```cql
define function "Denominator Observation"(location Location):
  Count(
    "Encounter During Measurement Period" E
      where E.location.references(location)
      return E.subject
  )
```

And we can simply provide a default observation function that counts the number of patients with encounters at each location.

For the numerator, this is modeled in the same way that a typical patient-based proportion measure would be:

```cql
define "Numerator Initial Population":
  exists ("Encounter During Measurement Period")

/*
 * Numerator: Number of measles and rubella doses (1st dose) administered through routine services during reporting period
 * Numerator Computation: COUNT of immunization events WHERE "Vaccine type" = "Measles and rubella containing vaccines"  for the first dose in the primary series AND "Date and time of vaccination" is during the reporting period
 */
define "Numerator":
  exists (
  	Elements."MCV Doses Administered to Patient During Measurement Period" I
	    where I.protocolApplied.only().doseNumber = 1
  )

define function "Numerator Observation"():
  if "Numerator" then 1 else 0
```

And then the numerator observation is just a 1 if the patient is in the numerator, and a 0 otherwise.

By setting up the measure in this way, we can allow implementing systems to define their own denominator observation, substituting counts of patients from the source system data with estimated counts for the location.