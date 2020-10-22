/*
Calculating proportion of medication days covered for HEDIS measures

(SAA, in particular). Do any of you have experience with these types of calculations?

Specifically, the SAA specification has two requirements for calculating the number of days covered that I’m having difficulties handling together in CQL:

1.       If multiple prescriptions for different medications [i.e. different value sets] are dispensed on different days, count each day within the treatment period only once toward the numerator.

2.       If multiple prescriptions for the same medication [i.e. same value set] are dispensed on different days, sum the days supply and use the total to calculate the number of days covered.

These two requirements together require that I avoid counting each day within the treatment period more than once. If I simply use the Collapse operation on all medication relevant periods, I will handle the first requirement but miss overlapping periods in the second requirement. But If I use the Collapse operation and naively tack on overlapping days from the second requirement, then I may count days within the treatment period more than once (I could even end up with a number of days covered that exceeds the number of days in the treatment period).

Ultimately, my question is this: is there a way in CQL to handle this type of calculation? (If you need more elaboration, I can add it. It’s difficult to explain this in writing.)
*/
