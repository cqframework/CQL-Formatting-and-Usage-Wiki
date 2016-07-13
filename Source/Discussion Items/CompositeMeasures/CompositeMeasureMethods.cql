// methods for the calculation of composite measures

// Opportunity Scoring
  // Combining scores from component measures

define CM1: Count(CN1) / Count(CD1)
define CM2: Count(CN2) / Count(CD2)
define CM3: Count(CN3) / Count(CD3)
define CS: Count(CN1 + CN2 + CN3) / Count(CD1 + CD2 + CD3)

// These methods compute a patient score as the first step

// All-or-nothing Scoring
  // Denominator of composite is the union of component denominators
  // Numerator of composite is 1 if all numerators are 1, 0 otherwise

// Linear Scoring
  // Denominator is sum of component denominators
  // Numerator is sum of component numerators

// Weighted Scoring
  // Denominator of composite is the union of component denominators
  // Each component is assigned some percentage weight

// And then apply some aggregation method to produce the final composite measure score
  // Basically, these are continuous variable measures where the measure observation
  // is some formula for calculating a patient score
  // This step may be applied to any population (provider, institution, population, etc)

// Rather than require measure authors to write the tedium, only require the
// unique inputs necessary for each calculation type.

// All composite measure types would need to specify the component measures
// For other methods, an aggregation method is required
// For Weighted scoring, the percentage weight of each measure is required

// Nothing prevents the use of libraries and direct CQL to write more complex composite measures,
// but these patterns would enable simple expression of what are so far the most common patterns
// for composites.
