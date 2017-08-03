library Fulfills

using QDM version '5.3'

context Patient

define "Referral":
  ["Intervention, Performed": "Referral"]
  
define "Assessment":
  ["Assessment, Performed"]
  
define "Communication":
  ["Communication: From Provider To Provider"]
  
// Represent fulfillment using Communication:
define "Fulfills With Communication":
  "Communication" C
    where exists ("Referral" R where R.id in C.relatedTo)
    
// Represent fulfillment using Assessment:    
define "Fulfills With Assessment":
  "Assessment" A
    where exists ("Referral" R where R.id in A.relatedTo)
    
