/*
I'm currently writing a CQL library (with QDM 5.5) to calculate the Proportion
of Days Covered for the numerator of the SAA measure (HEDIS MY2020),

I attached two screenshots of the numerator instructions and the instructions
for calculating the number of days covered for dispenses. I also attached a CQL
file for the numerator piece of SAA.

My issue, in short, is that the SAA specification has two requirements for
calculating the number of days covered for oral medications (QDM: Medication, Dispensed)
that I'm having difficulties handling together in CQL:

* If multiple oral prescriptions for different medications [i.e. different medication
  lists / value sets] are dispensed on different days, count each day within the
  treatment period only once toward the numerator.
* If multiple oral prescriptions for the same medication [i.e. same value set]
  are dispensed on different days, sum the days supply and use the total to
  calculate the number of days covered.

These two requirements together require that I avoid counting each day within the
treatment period more than once. If I simply use the Collapse operation on all
medication relevant periods, I will handle the first requirement but miss
overlapping periods in the second requirement. But If I use the Collapse
operation and naively tack on overlapping days from the second requirement,
then I may count days within the treatment period more than once (I could even
end up with a number of days covered that exceeds the number of days in the treatment period).

For example, I have three oral dispenses from the same medication list below.

Dispense 1: 1/1 - 1/4 (4 days supply)

Dispense 2: 1/2 - 1/5 (4 days supply)

Dispense 3: 2/1 - 2/4  (4 days supply)

  [----]
     [----]

                        [----]

The HEDIS spec instructs that I add together the days supply for oral medications
dispensed on different dates. That will be 12 days. But I also need to recalculate
the covered periods, which should be this:

Covered Period 1: 1/1 - 1/8 (8 days supply)

Covered Period 2: 2/1 - 2/4 (4 days supply)

  [--------]    [----]

I'm unsure how to do this type of calculation in pure CQL, especially for more
complicated examples. In short, I need to be able to take the overlapping days
and fill in gap days from left to right. If I simply add the overlapping days to
the end, then I'll get inaccurate covered periods, which could affect the final
PDC calculation.

Is there a way in CQL to handle this type of calculation?
*/

/*
Answer:
Yes, focusing only on the question of how to "roll out" intervals. In the 1.5
version of CQL, we introduced an operator specifically to support this type of
operation, using a new clause, "aggregate":

http://build.fhir.org/ig/HL7/cql/03-developersguide.html#aggregate-queries

Factorial Example:
*/

define FactorialOfFive:
  ({ 1, 2, 3, 4, 5 }) Num
    aggregate Result starting 1: Result * Num

/*
Rollout Intervals Example:
*/

define "RolledOutIntervals":
  MedicationRequestIntervals M
    aggregate R starting (null as List<Interval<DateTime>>): R union ({
      M X
        let S: Max({ end of Last(R) + 1 day, start of X }),
          E: S + duration in days of X
        return Interval[S, E]
    })
