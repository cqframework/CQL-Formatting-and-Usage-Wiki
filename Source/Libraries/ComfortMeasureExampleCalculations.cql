define Case1EDArrivalDateTime: @2017-01-01T08:00:00.000
define Case1EDDepartureDateTime: @2017-01-01T10:00:00.000
define Case1AdmissionDate: @2017-01-01T10:30:00.000
define Case1ComfortMeasures: @2017-01-01T09:00:00.000

define Case2EDArrivalDateTime: @2017-01-01T08:00:00.000
define Case2EDDepartureDateTime: @2017-01-01T10:00:00.000
define Case2AdmissionDate: @2017-01-01T10:30:00.000
define Case2ComfortMeasures: @2017-01-01T07:00:00.000

define Case3EDArrivalDateTime: @2017-01-01T08:00:00.000
define Case3EDDepartureDateTime: @2017-01-01T10:00:00.000
define Case3AdmissionDate: @2017-01-01T12:00:00.000
define Case3ComfortMeasures: @2017-01-01T09:00:00.000

define Case4EDArrivalDateTime: @2017-01-01T08:00:00.000
define Case4EDDepartureDateTime: @2017-01-01T10:00:00.000
define Case4AdmissionDate: @2017-01-01T12:00:00.000
define Case4ComfortMeasures: @2017-01-01T07:00:00.000

define Case1: Case1ComfortMeasures during Interval[
  ToDate(Start(Case1EDArrivalDateTime, Case1EDDepartureDateTime, Case1AdmissionDate)), 
  ToDate(Start(Case1EDArrivalDateTime, Case1EDDepartureDateTime, Case1AdmissionDate) + 2 days))

define Case2: Case2ComfortMeasures during Interval[
  ToDate(Start(Case2EDArrivalDateTime, Case2EDDepartureDateTime, Case2AdmissionDate)), 
  ToDate(Start(Case2EDArrivalDateTime, Case2EDDepartureDateTime, Case2AdmissionDate) + 2 days))

define Case3: Case3ComfortMeasures during Interval[
  ToDate(Start(Case3EDArrivalDateTime, Case3EDDepartureDateTime, Case3AdmissionDate)), 
  ToDate(Start(Case3EDArrivalDateTime, Case3EDDepartureDateTime, Case3AdmissionDate) + 2 days))

define Case4: Case4ComfortMeasures during Interval[
  ToDate(Start(Case4EDArrivalDateTime, Case4EDDepartureDateTime, Case4AdmissionDate)), 
  ToDate(Start(Case4EDArrivalDateTime, Case4EDDepartureDateTime, Case4AdmissionDate) + 2 days))

define function ToDate(Value DateTime):
  DateTime(year from Value, month from Value, day from Value, 0, 0, 0, 0, timezone from Value)

define function Start(EDArrival DateTime, EDDeparture DateTime, HospitalAdmission DateTime):
  if EDDeparture 1 hour or less on or before HospitalAdmission then
    EDArrival
  else
    HospitalAdmission
