library TestUCUM

//define Test: 1 'a' = 1 year
//define Test2: null is Any
//define Test3: 1 != null

define Test4: { x: 1, y: null } = { x: 1, y: 2 }
define Test5: { x: 1, y: null } = { x: 1, y: null }

//define Test6: { x: 1 } = { x: 1, y: 2 }

define "String Null Concatenate":
  'AB' & null & 'CD'