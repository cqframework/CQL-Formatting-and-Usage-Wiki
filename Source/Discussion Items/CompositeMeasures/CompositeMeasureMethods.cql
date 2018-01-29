// methods for the calculation of composite measures

// Opportunity Scoring
  // Defined as a proportion measure where
    // Patient is in the initial population if they are in the initial population of any component
    // Patient is in the denominator if they are in the denominator of any component
    // Patient is in the numerator if they are in the numerator of any component

// All-or-nothing Scoring
  // Defined as a proportion measure where
    // Patient is in the initial population if they are in the initial population of any component
    // Patient is in the denominator if they are in the denominator of any component
    // Patient is only in the numerator if they are in the numerators of all components

// Component-level Linear Combination
  // Defined as the average of measure scores, evaluated at the population level, not patient-level
  
// Patient-level Linear Combination
  // Defined as a continuous variable measure where
    // Patient is in the initial population if they are in the initial population of any component
    // Patient is in the measure population if they are in the denominator of any component
    // Measure observation is the percentage of components in which the patient is in the numerator
    // Measure observations are aggregated using Average

// Weighted Scoring
  // Defined as the weigthed average of measure scores, evaluated at the population level, not patient-level

// Rather than require measure authors to write the tedium, only require the
// unique inputs necessary for each calculation type.

// All composite measure types would need to specify the component measures
// For other methods, an aggregation method is required
// For Weighted scoring, the percentage weight of each measure is required

// Nothing prevents the use of libraries and direct CQL to write more complex composite measures,
// but these patterns would enable simple expression of what are so far the most common patterns
// for composites.

// Patient-based proportion measures
// Episode-based proportion measures
// Ratio measures?
// Continuous variable measures?

