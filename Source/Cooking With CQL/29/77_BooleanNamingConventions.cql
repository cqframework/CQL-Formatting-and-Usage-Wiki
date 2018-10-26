library BooleanNamingConventions

using QDM version '5.3'

parameter "Measurement Period" Interval<DateTime>

/*
The current recommendation in the CQL Style Guide is:

* DO create definition names that are clear and indicate result type (a yes/no 
  should be named like a question [for example, “Is” or “Has”]

Feedback we’ve received...

> Feedback from measure developers:

>> using “Is” or “Has” in statements is too repetitive and makes it difficult to locate when several define statements start with the same word
>> to use “has,” would also need to use “exists” in the definition
>> agree that everything can’t be limited to a Boolean (need to include lists sometimes)

> External feedback:

>> using “Is” or “Has” makes statements more human readable

> Vendor feedback:

>> include "Is" or "Has" For Booleans only
*/

/*
The intent of the style guide conventions is to make sure that definition names
clearly communicate the "type" of things that will be in the definition. This
makes it easier to read and understand what a definition means when it appears in 
another expression.
*/

/*
Looking at an example from CMS122v7:
*/

define "Has Most Recent Elevated Hba1c":
	Last(["Laboratory Test, Performed": "HbA1c Laboratory Test"] HighHbA1c
			where HighHbA1c.relevantPeriod during "Measurement Period"
				and HighHbA1c.result is not null
			sort by resultDatetime
	).result > 9 '%'

define "Has Most Recent HbA1c Without Result":
	Last(["Laboratory Test, Performed": "HbA1c Laboratory Test"] HbA1cNoResult
			where HbA1cNoResult.relevantPeriod during "Measurement Period"
			sort by resultDatetime
	).result is null

define "Has No Record Of HbA1c":
	not exists ["Laboratory Test, Performed": "HbA1c Laboratory Test"] NoHbA1c
		where NoHbA1c.relevantPeriod during "Measurement Period"

define "Numerator":
	"Has Most Recent Elevated Hba1c"
		or "Has Most Recent HbA1c Without Result"
		or "Has No Record Of HbA1c"


