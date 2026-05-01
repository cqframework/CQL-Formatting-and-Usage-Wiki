library Test

include QICoreCommon version '2.0.000'

codesystem "StateCodes": 'http://example.org/fhir/CodeSystem/states'

Code { code: Address.state, system: "StateCodes" } in NewEnglandStatesVS

Address.state.toStateCode() in NewEnglandStatesVS

Note that there is a proposal in CQL to consider allowing on-the-fly code systems:

Code { code: Address.state, system: "http://example.org/fhir/CodeSystem/states" } in NewEnglandStatesVS
