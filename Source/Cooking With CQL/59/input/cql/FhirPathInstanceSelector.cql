// Proposal is to promote the CQL instance selector into the FHIRPath expression grammar

/*
CQL Instance Selector:

instanceSelector
    : namedTypeSpecifier '{' (':' | (instanceElementSelector (',' instanceElementSelector)*)) '}'
    ;

instanceElementSelector
    : referentialIdentifier ':' expression
    ;

namedTypeSpecifier
    : (qualifier '.')* referentialOrTypeNameIdentifier
    ;

qualifier
    : identifier
    ;

// Reserved words that are also type names
typeNameIdentifier
    : 'Code'
    | 'Concept'
    | 'date'
    | 'time'
    ;

// Keyword identifiers are keywords that may be used as identifiers in a referential context
// Effectively, keyword except reservedWord
keywordIdentifier
    : 'asc'
    | 'ascending'
    | 'by'
    | 'called'
    | 'code'
    | 'codesystem'
    | 'codesystems'
    | 'concept'
    | 'contains'
    | 'context'
    | 'date'
    | 'default'
    | 'define'
    | 'desc'
    | 'descending'
    | 'display'
    | 'div'
    | 'end'
    | 'ends'
    | 'except'
    | 'fluent'
    | 'function'
    | 'implies'
    | 'include'
    | 'includes'
    | 'intersect'
    | 'library'
    | 'meets'
    | 'mod'
    | 'or after'
    | 'or before'
    | 'or less'
    | 'or more'
    | 'overlaps'
    | 'parameter'
    | 'predecessor'
    | 'private'
    | 'public'
    | 'start'
    | 'starting'
    | 'starts'
    | 'successor'
    | 'time'
    | 'timezoneoffset'
    | 'union'
    | 'using'
    | 'valueset'
    | 'version'
    | 'where'
    | 'width'
    | 'xor'
    ;

referentialIdentifier
    : identifier
    | keywordIdentifier
    ;

referentialOrTypeNameIdentifier
    : referentialIdentifier
    | typeNameIdentifier
    ;

identifier
    : IDENTIFIER
    | DELIMITEDIDENTIFIER
    | QUOTEDIDENTIFIER
    ;

QUOTEDIDENTIFIER
    : '"' (ESC | .)*? '"'
    ;
