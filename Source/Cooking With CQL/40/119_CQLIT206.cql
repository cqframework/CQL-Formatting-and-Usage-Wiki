/*
https://oncprojectracking.healthit.gov/support/browse/CQLIT-206
*/

/*
TestPJMCQL206BCG.cql loads into MAT and passed preliminary testing correctly in Bonnie.
Explanation is included within the commented paragraphs.

The Screenshot from 2019-11-30.png shows results of basic testing.
The PASS/FAIL indicates the NUMERATOR result and the name indicates the data elements selected.
The spreadsheet contains the datatype and attribute selections.

The "Qualifying Encounter" definition loads into MAT but caused difficulty within
the IPP so the expression was used directly in the IPP. (Alternatively, the combined
IPP expression could be used as the "Qualifying Encounter" definition which would
allow the IPP to be defined as "Qualifying Encounters")

The IPP requires boolean expression which was satisfied with the exists operator to
combine results from different datatypes (Diagnosis, Encounter, and Procedure).
https://github.com/esacinc/CQL-Formatting-and-Usage-Wiki/wiki/Authoring-Measures-in-CQL

The "Most Recent Bladder Cancer Staging Tumor Ta HG, Tis, T1" contains ~ equivalence
expressions with SNOMED codes and a VSAC oid containing SNOMED/ICD-10. The in operator
returns true if the given element is in the given list.

The "Most Recent Bladder Cancer Staging Tumor Ta HG, Tis, T1" datatype refers to
"Procedure, Performed" with the result attribute as the data element that may hold
the SNOMED code representing the tumor staging. This may not fully reflect the EHR
where this data could be in a pathology report, the medical history, diagnosis/problem
list or text note. In a pathology report, it may be represented as a LOINC code.
*/
