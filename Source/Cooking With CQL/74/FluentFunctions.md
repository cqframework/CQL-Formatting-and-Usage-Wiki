# Fluent Functions

[Fluent functions](https://cql.hl7.org/03-developersguide.html#fluent-functions) are a feature of Clinical Quality Language that allow functions to be called using _dot notation_ (i.e. using a `.` followed by the name of the function):

```cql
define fluent function "confirmed"(conditions List<Condition>):
  conditions C where C.verificationStatus ~ "Condition Confirmed"

define fluent function "active"(conditions List<Condition>):
  conditions C where C.clinicalStatus ~ "Condition Active"
    and C.abatement is null

define fluent function "activeOrRecurring"(conditions List<Condition>):
  conditions C
    where C.clinicalStatus ~ "Condition Active"
      or C.clinicalStatus ~ "Condition Recurrence"
      or C.clinicalStatus ~ "Condition Relapse"
```

