library AppropriateUseOfAntiMRSAAntibiotics

/*
Proposed measure for Appropriate Use of Anti-MRSA Antibiotics
*/

/*
Working numerator statement:

Number of denominator eligible patients who have sterile site cultures negative 
for resistant Staphylococcus aureus isolates AND discontinuation of intravenous 
anti-MRSA antibiotic at or before 72-hours of therapy

Definitions:
Anti-MRSA antibiotic – For the purposes of this measure, anti-MRSA therapy 
includes Ceftaroline, Dalbavancin, Daptomycin, Linezolid, Oritavancin, Tedizolid, 
Telavancin, Tigecycline, Vancomycin

Sterile site – For the purposes of this measure, sterile sites include blood, 
cerebrospinal fluid, pleural fluid, pericardial fluid, peritoneal fluid, 
joint/synovial fluid, bone, internal body sites (lymph node, brain, heart, 
liver, spleen, vitreous fluid, kidney, pancreas, or ovary).

Numerator Quality-Data Coding Options for Reporting Satisfactorily:
IV anti-MRSA antibiotic discontinued at or before 72-hours of therapy when 
sterile site cultures are negative for resistant Staphylococcus aureus isolates
Performance Met: GXXXX: Documentation of discontinuation of IV anti-MRSA antibiotic 
at or before 72-hours of therapy after sterile site cultures are negative for 
resistant Staphylococcus aureus isolates
OR
IV anti-MRSA antibiotic NOT discontinued at or before 72-hours of therapy when 
sterile site cultures are negative for resistant Staphylococcus aureus isolates
Medical Performance Exclusion: GXXXX: Documentation of medical reasons for not 
discontinuing IV anti-MRSA antibiotic at or before 72-hours of therapy after 
sterile site cultures are negative for resistant Staphylococcus aureus isolates
*/

// Timeline:
// Initiate IV anti-MRSA Antibiotic
// Test for resistant Staphylococcus aureus isolates
// If negative, discontinue anti-MRSA Antibiotic within 72 hours

define "IV anti-MRSA Antibiotic":
  ["Medication, Administered": "X_Anti-MRSA Antibiotic"] M
    where M.route ~ "X_Intravenous"
    
define "Sterile Site Cultures for Resistant Staphylococcus Aureus Isolates":
  ["Laboratory Test, Performed": "Resistant Staphylococcus Aureus Isolates"] L
    where L.method ~ "X_Sterile Site Culture" // NOTE: method is the closest attribute in QDM here

  // MAYBE: Procedure performed?
  ["Procedure, Performed": "Sterile Site Culture"] P
    where P.anatomicalSiteLocation in "Sterile Sites"
    
define "Negative Sterile Site Cultures for Resistant Staphylococcus Aureus Isolates":
  "Sterile Site Cultures for Resistant Staphylococcus Aureus Isolates" L
    where L.result ~ "X_Negative"
    
define "IV anti-MRSA Antibiotic Appropriately Discontinued":
  "IV anti-MRSA Antibiotic" AntiMRSA
    with "Negative Sterile Site Cultures for Resistant Staphylococcus Aureus Isolates" NegativeCultures
      such that NegativeCultures.resultDatetime after start of AntiMRSA.relevantPeriod
    where AntiMRSA.relevantPeriod ends 72 hours on or before start of AntiMRSA.relevantPeriod
    
