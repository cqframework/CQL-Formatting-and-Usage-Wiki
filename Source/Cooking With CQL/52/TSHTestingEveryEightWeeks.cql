library TSHTestingEveryEightWeeks

using QDM version '5.5'

/*
The measure is to look for patients for whom TSH testing is performed at least once
every 8 weeks while receiving an ICI for a maximum duration of 1 year from the start
of ICI therapy. Therapy given from prior year through the measurement period. For
instance, if the measurement is 2021, we are only interested in therapy that starts in
2020. The therapy could end in 2020, or 2021, or does not end at all. Also, for the
purposes of the measure, we are only interested within 1 year of therapy from the
start of therapy. For example, if the patient starts therapy in January 2020 and
ends therapy March 2021 (that’s more than 1 year), we are only interested in
January 2020 – January 2021. The first 8-week time interval calculation begins
with the patient’s therapy start date. The actual date of each test does not
influence the subsequent intervals. The result is to calculate if the patient got
at least 1 TSH test per each 8-week period (Week 0-8, week 8-16, week 16-24,
week 24-32, week 32-40, week 40-48, week 48-56).

Calculation of the intervals using the following:

           Bin 1: Week 0-8 from therapy start date
           Bin 2: Week 8-16 from therapy start date
           Bin 3: Week 16-24 from therapy start date
           Bin 4: Week 24-32 from therapy start date
           Bin 5: Week 32-40 from therapy start date
           Bin 6: Week 40-48 from therapy start date
           Bin 7: Week 48-56 from therapy start date

       If patient stops therapy before exactly 12 months (1-year) from therapy start date,
       look for 1 TSH test within the bin the patient therapy end date falls into

       If patient is still on therapy when they reach 1-year from therapy start date,
       look for a final TSH test within bin 7 (week 48-56)

       If patient is on therapy for < 8 weeks, look for 1 TSH test within bin 1
*/

valueset "Cancer": 'TBD'
valueset "Immune Checkpoint Inhibitor": 'TBD'
valueset "Thyrotropin [Units/volume] in Serum or Plasma": 'TBD'
valueset "Thyroxine (T4) free [Mass/volume] in Serum or Plasma": 'TBD'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Initial Population":
  exists "Cancer Diagnosis"

define "Cancer Diagnosis":
  ["Diagnosis": "Cancer"] Cancer
    where Cancer.prevalencePeriod overlaps "Measurement Period"

define "Denominator":
  exists "ICI Therapy"

define "ICI Therapy":
  ["Medication, Administered": "Immune Checkpoint Inhibitor"] ICI
    where ICI.relevantPeriod starts 1 year or less before start of "Measurement Period"

define "Numerator":
  ("Distinct Lab and Bin" contains "Required Bins")
    and ("Required Bins") < Count("Distinct Lab and Bin")
    and Count("Abnormal TSH") = Count("Lab T4")

// BTR -> Based on the name of this expression, I expected this to be an ICI Therapy that
// starts within the 8 week interval of another ICI Therapy, but the logic is looking
// for ICI Therapy without a prior ICI Therapy more than 8 weeks prior
// Effectively, this expression will return all ICI Therapies within the first 8 weeks of the
// first ICI therapy, is that correct?
// The intent is to ensure that all the ICI therapies under consideration are at most 8 weeks apart and
// that there is a continuous administration
// TODO: Capture the case that we want to include ICI Therapy from the prior year, but only if it's more than 8 weeks from the last course
define "ICI Starts Within 8 weeks Interval":
  "ICI Therapy" Therapy
    without "ICI Therapy" PriorTherapy
      such that PriorTherapy !~ Therapy
        and PriorTherapy.relevantPeriod starts 57 days or more before day of start of Therapy.relevantPeriod

define "Start of ICI":
  Min("ICI Starts Within 8 weeks Interval" ICITherapy
      return start of ICITherapy.relevantPeriod
  )

define "End of ICI":
  Min({
    end of "Measurement Period", "Start of ICI" + 1 year, Max("ICI Starts Within 8 weeks Interval" Therapy
        return
        end of Therapy.relevantPeriod
    )}
  )

define "Abnormal TSH":
  ["Laboratory Test, Performed": "Thyrotropin [Units/volume] in Serum or Plasma"] LabT
    where ( LabT.resultDatetime during Interval["Start of ICI", "Start of ICI" + 56 weeks )
        or LabT.relevantDatetime during Interval["Start of ICI", "Start of ICI" + 56 weeks )
    )
      and ( LabT.result < 0.40 'm[IU]/L'
          or LabT.result > 5.50 'm[IU]/L'
      )

define "Distinct Lab and Bin":
  distinct "Test Lab and Bin"

define "Lab T4":
  ["Laboratory Test, Performed": "Thyroxine (T4) free [Mass/volume] in Serum or Plasma"]

define "Lab TSH":
  ["Laboratory Test, Performed": "Thyrotropin [Units/volume] in Serum or Plasma"] TSH
    where TSH.relevantDatetime during Interval["Start of ICI", "Start of ICI" + 56 weeks )
      and TSH.result >= 0.40 'm[IU]/L'
      and TSH.result <= 5.50 'm[IU]/L'

define "Required Bins":
  (weeks between "Start of ICI" and "End of ICI") div 8

define "Test Lab":
  "Lab TSH"
    union ("Abnormal TSH" AbTSH
        with "Lab T4" T4
          such that (T4.relevantDatetime same as AbTSH.relevantDatetime
              or T4.relevantDatetime 1 week or less after AbTSH.relevantDatetime)
    )

define "Test Lab and Bin":
  "Test Lab" LT
    where exists ("Test Lab" PriorLT
        where PriorLT.relevantDatetime 8 weeks or less after day of "Start of ICI"
          or LT.relevantDatetime 9 weeks or more after day of "Start of ICI"
    )
    return (Ceiling(weeks between "Start of ICI" and LT.relevantDatetime) div 8 )


// It should work the way it is written, though I'm a little unsure about the behavior of
// the "Test Lab and Bin" expression.
// It might be more clear to do something like this:
// This returns the bin numbers, 1 through n
define "ICI Therapy Bins":
  expand Interval[1, "Required Bins"]

// Then use the bin numbers to construct 8 week intervals, beginning at the start of ICI
define "ICI Therapy Bin Periods":
  "ICI Therapy Bins" Bin
    return Interval["Start of ICI" + ((Bin - 1) * 8 weeks), "Start of ICI" + (Bin * 8 weeks))

// Then look for bin periods that contain the expected tests
define "ICI Therapy Bin Periods with Required Test Lab":
  "ICI Therapy Bin Periods" Period
    with "Test Lab" LT
      such that LT.relevantDatetime during Period

// Then in the numerator:
define "Proposed Numerator":
  Count("ICI Therapy Bin Periods with Required Test Lab") = "Required Bins"
