## CQLIT-420

https://oncprojectracking.healthit.gov/support/projects/CQLIT/issues/CQLIT-420

CQLIT-420 CMS125v12 Unexpected error during execution
Summary: There was an error in one test case, but main issue is relating to mastectomy procedures esp w laterality so issue is to align logic to FHIR data structure.  
Description: "The following error occurred in the cql-execution engine: Encountered unexpected error during execution. Error Message: Cannot read properties of undefined (reading 'filter') CQL Library: BreastCancerScreeningFHIR|0.0.001 Expression: FunctionRef ELM Local ID: 126 CQL Locator: 91:25-91:67"
I imported my test cases, and some of them are giving the following error, as well as the entire test case bundle not running with the same error.
"The following error occurred in the cql-execution engine: Encountered unexpected error during execution. Error Message: Cannot read properties of undefined (reading 'filter') CQL Library: BreastCancerScreeningFHIR|0.0.001 Expression: FunctionRef ELM Local ID: 126 CQL Locator: 91:25-91:67" 
