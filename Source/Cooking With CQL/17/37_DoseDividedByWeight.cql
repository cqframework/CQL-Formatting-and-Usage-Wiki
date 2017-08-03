library DoseDividedByWeight

using QDM version '5.0.2'

context Patient

// This could potentially work, but represents some quite challenging unit
// calculation functionality.
define "Dose Divided By Weight":
  ["Medication, Order": "Medications"] M
    with ["Physical Exam, Performed": "Weight"] W
      such that M.dosage / W.result < 10 'mg/[lb_av]'
      
// As of 8/1, this functionality is not available in Bonnie, but is in the
// testing phase and should be available within 1 to 2 weeks.
// Waiting to hear whether I can use this example prior to that deploy.