# Fluent Functions

[Fluent functions](https://cql.hl7.org/03-developersguide.html#fluent-functions) are a feature of Clinical Quality Language that allow functions to be called using _dot notation_ (i.e. using a `.` followed by the name of the function):

```cql
define fluent function isActive(condition Condition):
  condition.clinicalStatus ~ "active"
    or condition.clinicalStatus ~ "recurrence"
    or condition.clinicalStatus ~ "relapse"
```

With this definition, we can then use the `.isActive()` fluent function to determine whether a condition is active:

```cql
define "Active Conditions":
  [Condition] C
    where C.isActive()
```

Note that unlike non-fluent function definitions, fluent functions to not require the use of the library name when invoking a fluent function defined in another library.

Fluent functions can be defined on any type, including lists. For example:

```cql
define fluent function active(conditions List<Condition>):
  conditions C
    where C.clinicalStatus ~ "active"
      or C.clinicalStatus ~ "recurrence"
      or C.clinicalStatus ~ "relapse"
```

With this function we can operate on a list of conditions:

```cql
define "All Conditions":
  [Condition]

define "Active Conditions":
  "All Conditions".active()
```

Fluent functions can also be defined on choice types. For example:

```cql
define fluent function toInterval(choice Choice<DateTime, Quantity, Interval<DateTime>, Interval<Quantity>>):
  case
	  when choice is DateTime then
    	Interval[choice as DateTime, choice as DateTime]
		when choice is Interval<DateTime> then
  		choice as Interval<DateTime>
		when choice is Quantity then
		  Interval[Patient.birthDate + (choice as Quantity),
			  Patient.birthDate + (choice as Quantity) + 1 year)
		when choice is Interval<Quantity> then
		  Interval[Patient.birthDate + (choice.low as Quantity),
			  Patient.birthDate + (choice.high as Quantity) + 1 year)
		else
			null as Interval<DateTime>
	end
```

```cql
define "Procedures Within the Last Year":
  [Procedure] P
    where P.performed.toInterval() starts on or before Today() - 1 year
```

Fluent functions can be defined with multiple arguments:

```cql
define fluent function hasCategory(medicationRequest MedicationRequestProfile, category Code):
  exists (medicationRequest.category C
    where C ~ category
  )
```

The first argument is always the source (i.e. what the function is being called _on_), and the remaining arguments are then listed as normal:

```cql
define "Community Medication Requests":
  "Medication Requests" MR
    where MR.hasCategory("community")
```

