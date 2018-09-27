/*
This is Zi from NCQA. I’m having a CQL problem when writing specifications for the 
HEDIS Immunizations for Adolescents (IMA) measure, and wondering if you would like 
to help or discuss it at the Cooking with CQL webinar. The narrative specifications 
for this measure can be found in the attachment from the PDF page 22-25 (page number 76-79).

My question is that in order to get a numerator hit, members should take a certain vaccine, 
take Tdap for example, between their 10th and 13th birthdays. The operators we usually use 
to define the period between members’ birthdate and events don’t work in this context. 
For example, if I use CalendarAgeInYearsAt as follows, the member probably got the 
vaccine any day during his or her 13th years of age, rather than the exact 13th birthdate.
*/
 
exists ( ["Patient Characteristic Birthdate"] Birthdate
   where Global."CalendarAgeInYearsAt"(Birthdate.birthDatetime, start of "Measurement Period")>= 10
     and Global."CalendarAgeInYearsAt"(Birthdate.birthDatetime, end of "Measurement Period")= 13

/*
If I switch to CalendarAgeInDaysAt, there’s an issue about leap years. I know the eCQMs 
use CalendarAgeInDaysAt for the Childhood Immunization Status (CIS) and the infant 
immunization measure and use 730 days to refer to 2 years of age. However, since the 
age range of IMA is larger, it’s not practical to neglect the leap year issue and 
use 365*13. I’ve done the math and concluded that depending on whether you were 
born before or after the leap day, you might get different numbers of leap years 
before your 13th birthday.
 
It’s just the specific 13th birthdate that is making things so complicated. I’m 
trying to find an operator that only looks at the period between birthdates, 
something like Interval [11th birthdate, 13th birthdate]. No luck in finding it 
in the HL7 CQL guide so far.

Do you have any suggestion please?
*/


Immunization.relevantPeriod during Interval[Patient.birthDate + 9 years, Patient.birthDate + 13 years]