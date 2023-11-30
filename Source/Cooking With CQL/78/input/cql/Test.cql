library Test

valueset TestValueSet: 'blah'

define IntervalValue: Interval[@2023-11-30T11:30:00.000Z, @2023-11-30T11:30:00.000Z]

define TestPhrase: IntervalValue starts same day or after start IntervalValue

define TestValueSetReference: TestValueSet
define TestValueSetId: TestValueSet.id
//define TestValueSetName: TestValueSet.name
