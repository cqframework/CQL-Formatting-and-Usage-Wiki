library TestCMS117 version '5.1.021'

using QDM version '5.3'

valueset "Office Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001'

parameter "Measurement Period" Interval<DateTime>

context Patient

