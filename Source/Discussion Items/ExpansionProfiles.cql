
// Corresponds to SVS call to VSAC with OID and Version
valueset "Limited Life Expectancy Grouping Value Set": '2.16.840.1.113883.3.526.3.1259' version '2016 April'

// Actual SVS in VSAC supports retrieval by profileId or version
valueset "Limited Life Expectancy Grouping Value Set": 'urn:oid:2.16.840.1.113883.3.526.3.1259' version 'urn:version:2016 April'
valueset "Limited Life Expectancy Grouping Value Set": 'urn:oid:2.16.840.1.113883.3.526.3.1259' version 'urn:profile:2016 April'

valueset "Limited Life Expectancy Grouping Value Set": 'urn:oid:2.16.840.1.113883.3.526.3.1259' version 'urn:version:2016 April'

codesystem "SNOMED-CT": 'urn:oid:2.16.840.1.113883.96'

// Alternative that makes the code system versions explicit within the CQL, rather than implicit in the "profile" definition
codesystem "SNOMED-CT": '2.16.840.1.113883.3.96' version '2016A'
valueset "Limited Life Expectancy Grouping Value Set": '2.16.840.1.113883.3.526.3.1259' codesystems { "SNOMED-CT" }


["Medication, Administered"]

ELM Retrieve: "Medication, Administered" where NegationRationale is null

["Medication, Not Administered"]

"Medication, Administered" where NegationRationale is not null

"Procedure" where status in PositiveCodes
