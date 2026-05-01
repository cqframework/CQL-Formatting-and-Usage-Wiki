library TestValueSet

valueset "Value set": 'url'

define function "code in value set"(code Code, codes List<Code>):
    code in codes

define "call it":
    "code in value set"("Unit mismatch", "Value set")

define function "example"(code Code):
    code in "Value set"

define "call it":
    "overload"(Errors."Unit mismatch", "Value set")

define function "overload"(code Code, codes List<Code>):
    code in codes

define function "overload"(code Code, valueSet System.ValueSet):
    code in valueSet 

define fluent function toValueSet(codes List<Code>):
