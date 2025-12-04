This topic documents proposed updates to the [AllergyIntolerance Patterns](https://build.fhir.org/ig/HL7/us-cql-ig/patterns-allergy.html) topic in the US CQL IG.

#### Abatement and prevalence interval

Abatement for an AllergyIntolerance can be represented in multiple ways:

* [`.abatement()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,abatement,-%28allergyIntolerance%20AllergyIntolerance): Returns the abatement of the given AllergyIntolerance, if present
* [`.resolutionAge()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,resolutionAge,-%28allergyIntolerance%20AllergyIntolerance): Returns the resolutionAge of the given AllergyIntolerance, if present

Using these options, an abatement, as well as a prevalence interval, can be calculated:

* [`.abatementInterval()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,abatementInterval,-%28allergyIntolerance%20AllergyIntolerance): Returns an interval representing the normalized abatement of the given AllergyIntolerance resource.
* [`.prevalenceInterval()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,prevalenceInterval,-%28allergyIntolerance%20AllergyIntolerance): Returns an interval representing the normalized prevalence period of the given AllergyIntolerance resource

#### Clinical and verification status

To facilitate checking allergy intolerance status, the following functions are defined in the FHIRCommon library. The `is...` functions operate on a single AllergyIntolerance (and so are typically used within a `where` clause), while the other functions operate on a list of AllergyIntolerance resources, and so are typically used when dealing with an entire set of resources as a single expression:

* [`.isActive()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isActive,-%28allergyIntolerance%20FHIR)
* [`.active()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,active,-%28allergyIntolerances%20List)
* [`.isInactive()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isInactive,-%28allergyIntolerance%20FHIR)
* [`.inactive()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,inactive,-%28allergyIntolerances%20List)
* [`.isResolved()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isResolved,-%28allergyIntolerance%20FHIR)
* [`.resolved()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,resolved,-%28allergyIntolerances%20List)

The AllergyIntolerance resource also has a verificationStatus element to represent information such as whether the allergy has been confirmed. The element is not required, but if it is present, it is a modifier element, and has the potential to negate the information the resource is conveying (e.g. the `refuted` status). For most usage, when application intent is looking for positive evidence of an allergy, the verification statuses of `refuted` and `entered-in-error` should be excluded if `verificationStatus` is present:

```cql
define "Verified Allergies":
  [AllergyIntolerance] VerifiedAllergyIntolerance
    where VerifiedAllergyIntolerance.verificationStatus is not null implies
      (VerifiedAllergyIntolerance.verificationStatus ~ "confirmed"
        or VerifiedAllergyIntolerance.verificationStatus ~ "unconfirmed"
      )
```

To support reuse of this pattern, the FHIRCommon library defines the `isVerified` and `verified` functions, along with other functions for testing verification status. As with the clinical status functions there are two sets, one using an `is` prefix, that are used with single AllergyIntolerance instances, and one set without, used with sets of AllergyIntolerance resources.

* [`.isVerified()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isVerified,-%28allergyIntolerance%20FHIR)
* [`.verified()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,verified,-%28allergyIntolerance%20FHIR)
* [`.isConfirmed()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isConfirmed,-%28allergyIntolerance%20FHIR)
* [`.confirmed()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,confirmed,-%28allergyIntolerances%20List)
* [`.isUnconfirmed()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isUnconfirmed,-%28allergyIntolerance%20FHIR)
* [`.unconfirmed()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,unconfirmed,-%28allergyIntolerances%20List)
* [`.isRefuted()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,isRefuted,-%28allergyIntolerance%20FHIR)
* [`.refuted()`](https://hl7.org/fhir/uv/cql/Library-FHIRCommon.html#:~:text=define%20fluent%20function-,refuted,-%28allergyIntolerances%20List)


> These changes are proposed for inclusion in the US CQL IG: (https://jira.hl7.org/browse/FHIR-53460)