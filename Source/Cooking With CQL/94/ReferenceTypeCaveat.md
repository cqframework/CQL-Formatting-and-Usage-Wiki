It looks like this is referring to the [`Location.type`](https://hl7.org/fhir/R4/location-definitions.html#Location.type) element:

```cql
define fluent function isNotAtProceduralHospitalLocation(encounter Encounter):
  not exists (
    encounter.location EncounterLocation
      where EncounterLocation.location.type in "Procedural Hospital Locations"
  )
```

But.... it's not. [`Encounter.location.location`](https://hl7.org/fhir/R4/encounter-definitions.html#Encounter.location.location) is a [`Reference`](https://hl7.org/fhir/R4/references.html#Reference), which does have a [`type`](https://hl7.org/fhir/R4/references-definitions.html#Reference.type) element, but it is the FHIR Resource Type, not at all the same thing as the `Location.type` element.

The function does compile because the `type` element is a `uri`, which is represented in CQL as a `String` and so is allowed to appear on the left-hand side of a value set membership test, but it definitely does not result in the expected intent of asking whether the `type` element of the `Location` referenced by the `Encounter.location.location` reference has any codes in the `"Procedural Hospital Locations"` value set.

To correct the function so that it provides the expected intent, use:

```cql
define fluent function isNotAtProceduralHospitalLocation(encounter Encounter):
  not exists (
    encounter.location EncounterLocation
      with [Location] Location
        such that EncounterLocation.references(Location)
          and Location.type in "Procedural Hospital Locations"
  )
```

In addition, as part of feedback about the use of this function, it was recommended that a direct-reference code be used, rather than a value set:

```cql
codesystem "LocationRoles":	'http://terminology.hl7.org/CodeSystem/v3-RoleCode'
code "ER": 'ER' from  "LocationRoles" display 'Emergency room'

define fluent function isNotAtProceduralHospitalLocation(encounter Encounter):
  not exists (
    encounter.location EncounterLocation
      with [Location] Location
        such that EncounterLocation.location.references(Location)
          and exists (
            Location.type LocationType
              where LocationType ~ "ER"
          )
  )
```

Alternatively, using the "includesCode" fluent function:

```cql
define fluent function isNotAtProceduralHospitalLocation(encounter Encounter):
  not exists (
    encounter.location EncounterLocation
      with [Location] Location
        such that EncounterLocation.location.references(Location)
          and Location.type.includesCode("ER")
  )
```

NOTE: Given the change to the use of the ER code directly, would isNotAtEmergencyDepartmentLocation() be a better name?