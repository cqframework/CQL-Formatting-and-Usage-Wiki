library TestConvert

/*
@description: Determines whether failed conversions will result in a run-time error or a null result with a warning
@comments: With this parameter set to 'Error', failed conversions will result in a runtime error.
With this parameter set to 'Warning' failed conversions will result in a Warning and the function returning 'null'.
*/
parameter ErrorSeverity String default 'Warning'

/*
@description: Returns the value of the given Quantity, interpreted as an Integer if it is safe to do so.
@comments: A Quantity value can be safely interpreted as an integer if it has no decimal component (i.e. zeros after the decimal),
and it has the default UCUM unit of '1'
*/
define function ToInteger(value Quantity):
  case
    when Abs(value.value - Truncate(value.value)) > 0.00000001 then 
      Message(null, true, 'ToInteger.InvalidArgument', ErrorSeverity, 'The quantity has a non-zero decimal component and cannot be safely interpreted as an Integer')
    when value.unit != '1' then // Add support for UCUM Annotations
      Message(null, true, 'ToInteger.InvalidUnit', ErrorSeverity, 'The quantity has non-default units specified and cannot be safely interpreted as an Integer')
    else
      Truncate(value.value)
  end

/*
@description: Returns the value, interpreted as an Integer
@comments: If the input is a Quantity, the result is the same as invoking `ToInteger(value as Quantity)`.
If the input is an Integer, the result is the same as invoking `value as Integer`
*/
define function ToInteger(value Choice<Integer, Quantity>):
  if value is Quantity then 
    ToInteger(value as Quantity)
  else 
    value as Integer

define TestToInteger1:
  ToInteger(1.0 '1') = 1

define TestToInteger2:
  ToInteger(-1.0 '1') = -1

define TestToIntegerFail:
  ToInteger(1.0 'g') is null

define TestToIntegerFail2:
  ToInteger(1.1 '1') is null

define TestToIntegerFail3:
  ToInteger(-1.1 '1') is null

