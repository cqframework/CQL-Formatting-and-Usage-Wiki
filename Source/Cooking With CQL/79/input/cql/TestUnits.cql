library TestUnits

define TestMilligrayCenitmeters: 5 'mGy.cm'

define fluent function unitsEqual(x System.Quantity, y System.Quantity):
  Quantity { value: 1.0, unit: x.unit } = Quantity { value: 1.0, unit: y.unit }

define fluent function unitsEquivalent(x System.Quantity, y System.Quantity):
  Quantity { value: 1.0, unit: x.unit } ~ Quantity { value: 1.0, unit: y.unit }

