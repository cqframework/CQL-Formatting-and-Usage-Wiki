# Terminology In CQL

Inspired by this thread: https://chat.fhir.org/#narrow/stream/179220-cql/topic/CQL.20Coding/near/453627548

This topic provides a basic introduction to terminology in FHIR and CQL as well as collected resources for digging deeper.

## Terminology

Terminology (i.e. coded values) in FHIR is represented with two main resources:

* CodeSystem
* ValueSet

### CodeSystem

A CodeSystem:

* Represents a single system of coded concepts
    * Also called terminology, ontology, or vocabulary
* Not intended for distribution, rather as a description of the code system and it’s properties. May contain content, but not necessarily (or maybe partially)
* May be enumerated, or may have a formal grammar, or both
* Can be validated
    * It’s always possible to tell, given a specific code, whether it is a member of that system
* Can have associated properties
    * Hierarchies and grouping

### ValueSet

* Represents a collection of codes from one or more systems
* Can have a _definition_ and/or _expansion_
* Definition
    * Instructions for how to build the contents of the value set (i.e. membership criteria)
* Expansion
    * Explicit listing of the members of the value set

Definitions can be "intensional", meaning that they are defined in terms of expressive criteria:

```
code 73211009 | Diabetes mellitus (disorder) | and all child codes, recursively
```

Or they can be "extensional", meaning that they are an explicit enumeration of codes:

```
73211009 | Diabetes mellitus (disorder)
46635009 | Diabetes mellitus type 1 (disorder)
31321000119102 | Diabetes mellitus type 1 without retinopathy (disorder)
...
```

In either case, the _definition_ can be used to calculate an _expansion_. In FHIR, this is done with the $expand operation.

For much more detailed documentation on the use of Terminology in FHIR, refer to the [Terminology](http://hl7.org/fhir/terminology-module.html)

For documentation on the use of terminology in CQL with FHIR, refer to:

* [Code Systems](https://hl7.org/fhir/uv/cql/using-cql.html#code-systems)
* [Value Sets](https://hl7.org/fhir/uv/cql/using-cql.html#value-sets)
* [Codes](https://hl7.org/fhir/uv/cql/using-cql.html#codes)
* [Concepts](https://hl7.org/fhir/uv/cql/using-cql.html#concepts)
* [Use of Terminologies](https://hl7.org/fhir/uv/cql/patterns.html#use-of-terminologies)

For documentation on the use of terminology as part of testing CQL with the VSCode Plugin, refer to:

* [Using Terminology](https://github.com/cqframework/vscode-cql/wiki/User-Guide#using-terminology)

