/*
  Surgical Pathology for Lung Carcinoma and Non Small Cell Lung Cancer
*/

/*
  Initial Population
    AND: Age>= 18 year(s) at: "Measurement Period"
    AND: Occurrence A of $SurgicalPathology
    AND: "Laboratory Test, Performed: Collection Method (result: Lung Resection)" consurrent with Occurrence A of $SurgicalPathology
    AND: Union of:
      Occurrence A of $LungCAFinalDx
      Occurrence A of $NSCLCFinalDx

  Denominator
    AND: Initial Population

  Denominator Exclusions
    OR: "Laboratory Test, Performed: Path Report Comment (result: Insufficient Tissue)" concurrent with Occurrence A of $SurgicalPathology

  Numerator
    AND:
      OR:
        AND: Occurrence A of $LungCAFinalDx
        AND: "Laboratory Test, Performed: Primary Tumor (result)" concurrent with Occurrence A of $SurgicalPathology
        AND: "Laboratory Test, Performed: Regional Lymph Node (result)" concurrent with Occurrence A of $SurgicalPathology
      OR:
        AND: Occurrence A of $NSCLCFinalDx
        AND: "Laboratory Test, Performed: Primary Tumor (result)" concurrent with Occurrence A of $SurgicalPathology
        AND: "Laboratory Test, Performed: Regional Lymph Node (result)" concurrent with Occurrence A of $SurgicalPathology
        AND: "Laboratory Test, Performed: Histology Type (result: NSCLC Specified Lung Histology Types)" concurrent with Occurrence A of $SurgicalPathology
        AND NOT: "Laboratory Test, Performed: Histology Type (result: NSCLC NOS Lung Histology Types)" concurrent with Occurrence A of $SurgicalPathology

  Numerator Exclusions
    None

  Denominator Exceptions
    OR:
      AND: Laboratory Test, Performed not done: Pathology Medical Reason" for "Primary Tumor" concurrent with Occurrence A of $SurgicalPathology
      AND: "Laboratory Test, Performed not done: Pathology Medical Reason" for "Regional Lymph Node" concurrent with Occurrence A of $SurgicalPathology
    OR: "Laboratory Test, Performed not done: Pathology Medical Reason" for "Histology Type" concurrent with Occurrence A of $SurgicalPathology

  Stratification
    None

  $SurgicalPathology
    "Laboratory Test, Performed: Surgical Pathology Study" during "Measurement Period"

  $LungCAFinalDx
    "Laboratory Test, Performed: Path Report Final Diagnosis" satisfies all:
      (result: Lung Carcinoma, No NSCLC)
      (result: Principal)
    concurrent with Occurrence A of $SurgicalPathology

  $NSCLCFinalDx
    "Laboratory Test, Performed: Path Report Final Diagnosis" satisfies all:
      (result: Non Small Cell Lung Cancer)
      (result: Principal)
    concurrent with Occurrence A of $SurgicalPathology
*/
