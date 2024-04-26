# Test On ART

This topic discusses a question from the CQL Zulip thread:

[CQL Coding](https://chat.fhir.org/#narrow/stream/179220-cql/topic/CQL.20Coding)

## Question

Was hoping that I could get assistance with CQL coding that I'm writing.

```cql
define "Stopped ART at Facility during the measurement period":
  [EpisodeOfCare] EOS
    where EOS.type.coding.code.value ~ { 'On ART' }
      and (exists ({
        EOS.statusHistory.status contains 'finished'
          and EOS.statusHistory.period ends after start of "Measurement Period"
          and EOS.statusHistory[0].period ends before end of "Measurement Period"
      }))
```

I am defining an episode of care where I want to filter EOS.type match the concept on ART. However, there is a discrepancy between a FHIR.concept and system.concept list and I couldn't use the ToConcept function from FhirHelpers library because of a type mismatch. Is it because it's a list instead of just one codeableconcept? I am using FHIR 4.0.1.

Additionally, I am trying to traverse a list of periods to say that the statement is true if any of the list of fhir periods in EOS.statusHistory.period ends after start of measurement period. However again there seems to be a type mismatch because EOS.statusHistory.period is a list of periods and not just a period. I tried to flatten and I tried to use AnyOf to say this is true if any of the periods in the list meet this criteria. But the code says it's still not valid.

## Discussion

### Terminology

The submitted example is using:

```cql
  where EOS.type.coding.code.value ~ { 'On ART' }
```

This is accessing all the way down to the `value` element of the `CodeableConcept.coding.code`, which is asking CQL to perform direct string-based matching on the code value. When dealing with terminology, this isn't best practice, because it doesn't include a system comparison. CQL provides terminology types as a first-class element of the language, and any terminology testing should be done using these capabilities. So rather than trying to do string-matching with the code, the recommended approach is to declare the terminology we want to use.

In addition, best-practice with terminology matching is to establish a value set that can be used to perform the terminology match, rather than selecting a specific code. This approach allows the "concept" of "On ART" to be referenced as a value set within the CQL, but then what actual code (or codes) are used to actually determine that are defined in that value set, rather than within the CQL library directly.

For this example, we will just declare an example code system and value set to support the terminology match:

```cql
codesystem ARTCodes: 'http://example.org/fhir/CodeSystem/art-codes'
valueset "On ART": 'http://example.org/fhir/ValueSet/on-art'
```

This sets up an example code system, and an example value set `"On ART"` that we can use as a placeholder within the CQL until we have actual terminologies determined.

To use this then, note that the `type` element in [EpisodeOfCare (R4)](http://hl7.org/fhir/R4/episodeofcare.html) is defined as a CodeableConcept with cardinality 0..*. We can then use the terminology membership operator in CQL (`in`) to identify the EpisodeOfCare resources:

```cql
define "On ART Episode Of Care":
  [EpisodeOfCare] EOC
    where EOC.type in "On ART"
```

And note that we can also use the retrieve to express this restriction more succinctly:

```cql
define "On ART Episode Of Care":
  [EpisodeOfCare: type in "On ART"]
```

And note further that since the _primary code path_ for EpisodeOfCare is `type`, we can also omit the `type` reference in the retrieve:

```cql
define "On ART Episode Of Care":
  [EpisodeOfCare: "On ART"]
```

Next, we want to limit to episodes of care that ended during the measurement period.

The submitted example is using:

```
and (exists ({
  EOS.statusHistory.status contains 'finished'
    and EOS.statusHistory.period ends after start of "Measurement Period"
    and EOS.statusHistory[0].period ends before end of "Measurement Period"
})
```

Because the submitted example is in a query context with the `EOS` alias, and because `statusHistory` is a list-valued element (cardinality 0..*), the conditions in this expression are evaluating as FHIRPath expressions, resulting in lists. For example:

```cql
EOS.statusHistory.status
```

The result of this expression is a `List<FHIR.string>`, but what we really need is to evaluate each `statusHistory` element, so the solution is to set up a sub-query on the `EOS.statusHistory` element:

```cql
  EOS.statusHistory H
    where H.status = 'finished'
```

The measurement period filter is testing that `period ends after start` and `period ends before end` of the measurement period, this can now be simplified to:

```cql
H.period ends during "Measurement Period"
```

Putting all of this together, we have:

```cql
define "Stopped ART at Facility during the measurement period":
  [EpisodeOfCare: "On ART"] EOS
    where exists (EOS.statusHistory H
         where H.status = 'finished'
           and H.period ends during "Measurement Period"
      )
```


