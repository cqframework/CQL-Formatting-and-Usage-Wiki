library FluentOverloads

define function foo(): 1

define fluent function foo(i Integer): i

define q: from ({2,1}) sL sort by foo() asc

// Add these to a Library test:
define q1: from ({2,1}) sL sort by List{ foo() }[0] asc
define q2: from ({2,1}) sL sort by First(List{ foo() }) asc
define q3: from ({2,1}) sL sort by Tuple{ X: foo() }.X asc
define q4: from ({2,1}) sL sort by First(List{Tuple{ X: foo() }.X}) asc

// Figure out why this didn't resolve to the fluent function:
define q5: from ({2,1}) sL sort by (singleton from ((foo()) x return x)) asc
