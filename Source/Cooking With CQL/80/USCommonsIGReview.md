# USCommons IG Review

The US Commons IG is a content IG that provides common resources for using CQL with FHIR in the US Realm, providing common data access expressions that are aligned with the US Core implementation guide.

The content for this implementation guide is currently in development in the CQFramework github organization:

http://github.com/cqframework/cqf-us

This content IG is set up to automatically publish updates to the continuous build site here:

http://build.fhir.org/ig/cqframework/cqf-us

The implementation guide has the following main resources:

## USCoreCommon Library

This library is the analog of QICoreCommon but for working with USCore directly

https://github.com/cqframework/cqf-us/blob/master/input/cql/USCoreCommon.cql

## USCoreElements Library

This library is the analog of CQMCommon, but more general in intended scope, and focused on support initial population expressions of prior authorization questionnaires as the first supported use case.

https://github.com/cqframework/cqf-us/blob/master/input/cql/USCoreElements.cql

## Humana Uniform Pharmacy Prior Authorization Request

Questionnaire: 
https://build.fhir.org/ig/cqframework/cqf-us/branches/master/Questionnaire-UPPARFQuestionnaire.html

Initial Expressions Library: 
https://github.com/cqframework/cqf-us/blob/master/input/cql/UPPARFInitialExpressions.cql

## Genetic Molecular Testing Prior Authorization Request

Questionnaire:
https://build.fhir.org/ig/cqframework/cqf-us/branches/master/Questionnaire-GMTPQuestionnaire.html

Initial Expressions Library:
https://github.com/cqframework/cqf-us/blob/master/input/cql/GMTPInitialExpressions.cql

## Medical Benefit Outpatient Drug Authorization Form

Questionnaire:
https://build.fhir.org/ig/cqframework/cqf-us/branches/master/Questionnaire-MBODAQuestionnaire.html

Initial Expressions Library:
https://github.com/cqframework/cqf-us/blob/master/input/cql/MBODAInitialExpressions.cql

## Testing the Questionnaire Content

### Unit Testing

The IG source includes test content that can be used to unit test the population expressions for each library:

https://github.com/cqframework/cqf-us/tree/master/input/tests/library

This testing can be performed with VSCode using the CQL plugin. See the [VSCode CQL Users Guide](https://github.com/cqframework/vscode-cql/wiki/User-Guide) for more details.

### Integration Testing

In addition, the IG includes Postman collections for each questionnaire that can be used to perform some server-level integration testing:

https://github.com/cqframework/cqf-us/tree/master/postman

This testing can be performed with the latest version of the CQF Ruler (most recently tested with the 0.15.0-SNAPSHOT using a local build). Follow the instructions in the CQF Ruler readme for getting an image or a local build established (it will by default be available on localhost:8080/fhir, which is where the Postman collections are preconfigured to request).

Use the "Import" feature of Postman to import the Postman collections from a local clone of the IG github repository.