This topic documents proposed updates to the [Patient Patterns](https://build.fhir.org/ig/HL7/us-cql-ig/patterns-patient.html) page in the US CQL IG.

#### Patient name

Although patient name will typically already be known and established by application context, patterns for accessing and displaying patient name are provided for applications that may still need to establish, discover, or display this information.

Because FHIR allows for multiple names for different uses, as well as different usage periods, the _name_ of a patient is not always straightforward to determine. For completeness, the US Core Elements library defines several functions for accessing the name of a Patient. In the most common case, the `.name()` function can be used:

```cql
Patient.name()
```

The name function is just the first official, usual, or non-official non-usual name that is defined for the Patient. The avaiable name functions defined in the US Core Elements library are:

##### name()

**description:** Returns the first official, usual, or other name

This function returns the first _official_ name if present, otherwise the first _usual_ name, otherwise
the first non-official, non-usual name. In each case, the function returns the most recent name that either has no 
period specified, or has a period overlapping today.

```cql
define fluent function name(practitioner Practitioner):
  Coalesce(practitioner.officialName().first(), practitioner.usualName().first(), practitioner.firstNonOfficialNonUsualName())
```

##### usualName()

**description:** Returns the first usual name

This function returns the first _usual_ name for a patient. The most recent name entry is return that
either has no period specified, or has a period overlapping today.

```cql
define fluent function usualName(patient Patient):
  patient.name name
    where name.use ~ 'usual'
      and name.period is not null implies name.period includes Today()
    sort by start of period desc
```

##### officialName

**description:** Returns the first official name

This function returns the first _official_ name for a patient. The most recent name entry is return that
either has no period specified, or has a period overlapping today.

```cql
define fluent function officialName(patient Patient):
  patient.name name
    where name.use ~ 'official'
      and name.period is not null implies name.period includes Today()
    sort by start of period desc
```

##### firstNonOfficialNonUsualName()

**description:** Returns the first non-official, non-usual name

 This function returns the first non-official, non-usual name for a patient. The most recent name entry is return that
either has no period specified, or has a period overlapping today.

```cql
define fluent function firstNonOfficialNonUsualName(patient Patient):
  First(
    patient.name name
      where not(name.use ~ 'official') and not(name.use ~ 'usual')
        and name.period is not null implies name.period includes Today()
      sort by start of period desc
  )
```

#### Human name functions

In addition, the library defines functions for common use cases for the HumanName type:

```cql
define fluent function firstName(name HumanName):
  name.given.first()

define fluent function middleNames(name HumanName):
  Combine(Skip(name.given, 1), ' ')

define fluent function lastName(name HumanName):
  name.family

define fluent function firstMiddleLast(name HumanName):
  Combine(name.given, ' ') + ' ' + name.family

define fluent function lastFirstMiddle(name HumanName):
  name.family + ', ' + Combine(name.given, ' ')
```

#### Patient birthDate

Typically, patient birthDate is just represented using the birthDate element:

```cql
Patient.birthDate
```

However, FHIR also defines a `birthTime` extension, and applications that want to consider this level of specificity when determining patient age can make use of this extension.

Since the birthTime extension is defined in the extensions pack, it can be used anywhere, and the FHIRCommon CQL library defines a function for accessing it, as well as a function for accessing the birthDate as a dateTime, considering this birthTime extension if present:

```cql
Patient.birthTime()
Patient.birthDateTime()
```

##### birthTime()

**description:** Returns the birthTime of the patient, if present

This function returns the value of the birthTime extension, if present, null otherwise.

```cql
define fluent function birthTime(patient Patient):
  patient.birthDate.ext('http://hl7.org/fhir/StructureDefinition/patient-birthTime').value as dateTime
```

##### birthDateTime()

**description:** Returns the birth date (and time if present) (as a DateTime)

This function returns the birthTime of the patient, if present, else the birthDate of the patient as a DateTime

```cql
define fluent function birthDateTime(patient Patient):
  Coalesce(patient.birthTime().value, patient.birthDate.toDateTime())
```

#### Patient age

Patient information includes the birth date, and CQL provides a built-in function to calculate the age of a patient, either current age (i.e. as of now), or _as of_ a particular date. In quality improvement artifacts, age is typically calculated _as of_ a particular date. In the context of a Questionnaire, this is typically just today's date, and can be accessed using the `ageInYears()` function:

```cql
define "Patient Age Between 50 and 75":
  Patient.ageInYears() between 50 and 75
```

> NOTE: The [AgeAt](https://cql.hl7.org/09-b-cqlreference.html#ageat) functions in CQL use the data model (US Core in this case) to understand how to access the patient's birth date information.

> NOTE: CQL supports age calculation functions using both `Date` and `DateTime` values. In both cases the function is shorthand for a date/datetime duration calculation. If the `DateTime` overloads are used, note that the timezone offset is considered and there may be edge cases that result in unexpected results, depending on how large the timezone offset is from the execution timestamp. To avoid these edge cases, best practice is to use the `date from` extractor as shown in the above pattern to ensure the `Date` calculation is used.

The US Core Elements library defines the following patient age calculation functions:

##### ageInDaysAt()

**description:** Returns the age in days of the patient as of the given date, using birth time if known

This function returns the number of whole days between the patient birth date 
and the asOf date. If the patient has a birthTime, the calculation is performed using the 
birthDateTime, and the time component of the asOf parameter is considered. Note that when 
the birth time is known, timezone offset normalization will be used.

```cql
define fluent function ageInDaysAt(patient Patient, asOf DateTime):
  if patient.birthTime() is not null then
    CalculateAgeInDaysAt(Patient.birthDateTime(), asOf)
  else
    CalculateAgeInDaysAt(Patient.birthDate, date from asOf)
```

##### ageInDays()

**description:** Returns the current age in days of the patient, using birth time if known

This function returns the number of whole days between the patient birth date 
and the current date. If the patient has a birthTime, the calculation is performed using the 
birthDateTime and Now(), otherwise the calculation is performed using Today(). Note that when 
the birth time is known, timezone offset normalization will be used.

```cql
define fluent function ageInDays(patient Patient):
  if patient.birthTime() is not null then
    CalculateAgeInDaysAt(Patient.birthDateTime(), Now())
  else
    CalculateAgeInDaysAt(Patient.birthDate, Today())
```

##### ageInMonthsAt()

**description:** Returns the age in months of the patient as of the given date, using birth time if known

This function returns the number of whole calendar months between the patient birth date 
and the asOf date. If the patient has a birthTime, the calculation is performed using the 
birthDateTime, and the time component of the asOf parameter is considered. Note that when 
the birth time is known, timezone offset normalization will be used.

```cql
define fluent function ageInMonthsAt(patient Patient, asOf DateTime):
  if patient.birthTime() is not null then
    CalculateAgeInMonthsAt(Patient.birthDateTime(), asOf)
  else
    CalculateAgeInMonthsAt(Patient.birthDate, date from asOf)
```

##### ageInMonths()

**description:** Returns the current age in months of the patient, using birth time if known

This function returns the number of whole calendar months between the patient birth date 
and the current date. If the patient has a birthTime, the calculation is performed using the 
birthDateTime and Now(), otherwise the calculation is performed using Today(). Note that when 
the birth time is known, timezone offset normalization will be used.

```cql
define fluent function ageInMonths(patient Patient):
  if patient.birthTime() is not null then
    CalculateAgeInMonthsAt(Patient.birthDateTime(), Now())
  else
    CalculateAgeInMonthsAt(Patient.birthDate, Today())
```

##### ageInYearsAt()

**description:** Returns the age in years of the patient, as of the given date

This function returns the number of whole calendar years between the patient birth 
date and the given date. Regardless of whether the patient has a birthTime, the calculation is
performed using only the birth date. If the given date has a time component, it is ignored, on 
the grounds that birth time is almost universally not considered when determining age in years.

```cql
define fluent function ageInYearsAt(patient Patient, asOf DateTime):
  CalculateAgeInYearsAt(Patient.birthDate, date from asOf)
```

##### ageInYears()

**description:** Returns the current age in years of the patient

This function returns the number of whole calendar years between the patient birth 
date and the current date. Regardless of whether the patient has a birthTime, the calculation is
performed using only the birth date and Today(), on the grounds that birth time is almost universally 
not considered when determining age in years.

```cql
define fluent function ageInYears(patient Patient):
  CalculateAgeInYearsAt(Patient.birthDate, Today())
```

> These changes are proposed for inclusion in the US CQL IG: (https://jira.hl7.org/browse/FHIR-53458)