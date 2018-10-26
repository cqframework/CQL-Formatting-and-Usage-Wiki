library CalendarAgeInDaysCalculation
/*
My question is that in order to get a numerator hit, members should take a certain vaccine, 
take Tdap for example, between their 10th and 13th birthdays. The operators we usually use 
to define the period between members’ birthdate and events don’t work in this context. 
For example, if I use CalendarAgeInYearsAt as follows, the member probably got the 
vaccine any day during his or her 13th years of age, rather than the exact 13th birthdate.
*/
 
exists ( ["Patient Characteristic Birthdate"] Birthdate
   where Global."CalendarAgeInYearsAt"(Birthdate.birthDatetime, start of "Measurement Period")>= 10
     and Global."CalendarAgeInYearsAt"(Birthdate.birthDatetime, end of "Measurement Period") <= 13

/*
If I switch to CalendarAgeInDaysAt, there’s an issue about leap years. I know the eCQMs 
use CalendarAgeInDaysAt for the Childhood Immunization Status (CIS) and the infant 
immunization measure and use 730 days to refer to 2 years of age. However, since the 
age range of IMA is larger, it’s not practical to neglect the leap year issue and 
use 365*13. I’ve done the math and concluded that depending on whether you were 
born before or after the leap day, you might get different numbers of leap years 
before your 13th birthday.
*/

/*
The age calculations are really just a short-hand for a duration calculation between the patient's birth date
and either today, or some "as of" date such as the encounter start date, or the measurement period end.
Because the duration operators are defined to account for calendar semantics (including leap years), the
duration calculations work as expected for calculating age. So an approach to this could be to
just use the date arithmetic functions to determine the actual birth dates in question,
and then construct an interval covering that range:
*/

Immunization.relevantPeriod during Interval[date from Patient.birthDatetime + 10 years, date from Patient.birthDatetime + 13 years]