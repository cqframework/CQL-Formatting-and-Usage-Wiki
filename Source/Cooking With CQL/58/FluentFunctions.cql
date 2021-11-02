/*
@seealso: https://github.com/cqframework/clinical_quality_language/wiki/Well-Known-CQL-Documentation-Tags
*/
library FluentFunctions

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'

include Concepts called Cx
include FHIRCommon called FC

include MATGlobalCommonFunctionsFHIR4 called Global
include VTEFHIR4 called VTE

parameter "Measurement Period" Interval<DateTime>

context Patient

/*
Expression Definitions
@seealso: https://cql.hl7.org/02-authorsguide.html#statements
*/
define Four:
  4

/*
Function Definitions
@seealso: https://cql.hl7.org/03-developersguide.html#defining-functions
*/
define function Plus(x Integer, y Integer):
  x + y

/*
Expected result: true
*/
define TestPlus: Plus(2, 2) = 4

/*
Fluent Functions
@seealso: https://cql.hl7.org/03-developersguide.html#fluent-functions

Provide guidance about fluent function naming, point out that it's possible to define fluent functions with the same name in different libraries, so try to use unique names.
*/
define fluent function plus(x Integer, y Integer):
  Plus(x, y)

define fluent function minus(x Integer, y Integer):
  x - y

define Testplus:
  2.plus(2).minus(12)

/*
Note that if you define a function as fluent, it can only be invoked fluently. The
following invocation results in an error:
define TestplusNotFluent: plus(2, 2)
*/

/*
Example with Global."Normalize Interval":
*/
define "Flexible Sigmoidoscopy Performed":
  [Procedure: Cx."Flexible Sigmoidoscopy"] FlexibleSigmoidoscopy
	  where FlexibleSigmoidoscopy.status = 'completed'
		  and Global."Normalize Interval"(FlexibleSigmoidoscopy.performed) ends 5 years or less on or before end of "Measurement Period"

define fluent function toInterval(choice Choice<FHIR.dateTime, FHIR.Period, FHIR.Timing, FHIR.instant, FHIR.string, FHIR.Age, FHIR.Range>):
  Global."Normalize Interval"(choice)

define "Flexible Sigmoidoscopy Performed (2)":
  [Procedure: Cx."Flexible Sigmoidoscopy"] FlexibleSigmoidoscopy
	  where FlexibleSigmoidoscopy.status = 'completed'
      and FlexibleSigmoidoscopy.performed.toInterval() ends 5 years or less on or before end of "Measurement Period"

/*
Example with Extensions:
*/

/*
@description: Surfaces the [birthsex](http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex) extension defined in USCore.
@comment: This function returns the value of the birthsex extension as a code
@extension: http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex
*/
define fluent function birthsex(patient Patient):
  FC.Extension(patient, 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex').value as code

define TestBirthSex:
  Patient.birthsex()

/*
Example with complex extensions:
*/

/*
@description: Surfaces the [procedure](http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter-procedure)
extension defined in QICore.
@comment: This function returns a tuple with elements for each subextension (type, rank, and procedure).
@extension: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter-procedure
*/
define fluent function procedure(encounter Encounter):
  (FC.Extensions(encounter, 'http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter-procedure')) E
    return {
      type: FC.Extension(E, 'type').value as CodeableConcept,
      rank: FC.Extension(E, 'rank').value as positiveInt,
      procedure: FC.Extension(E, 'procedure').value as Reference
    }

define fluent function getId(reference Reference):
  Global.GetId(reference.reference)

define "Encounter With First ICU Stay With Principal Procedure of SCIP VTE Selected Surgery":
  from
    "Encounter With ICU Location" QualifyingEncounterICU,
    "SCIP VTE Selected Surgery" SelectedProcedure
    let EncounterProcedure: Global.GetExtension ( QualifyingEncounterICU, 'qicore-encounter-procedure' )
    where FHIRHelpers.ToInteger ( Global.GetExtension ( EncounterProcedure, 'rank' ).value as FHIR.positiveInt ) = 1
      and Global.GetId ( FHIRHelpers.ToString ( ( Global.GetExtension ( EncounterProcedure, 'procedure' ).value as FHIR.Reference ).reference ) ) = SelectedProcedure.id
      and date from (
        end of Global."Normalize Interval" ( SelectedProcedure.performed )
      ) during VTE."CalendarDayOfOrDayAfter" ( VTE."StartOfFirstICU" ( QualifyingEncounterICU ) )
    return QualifyingEncounterICU

define "Encounter With First ICU Stay With Principal Procedure of SCIP VTE Selected Surgery (2)":
  from
    "Encounter With ICU Location" QualifyingEncounterICU,
    "SCIP VTE Selected Surgery" SelectedProcedure
    let EncounterProcedure: singleton from (
      (QualifyingEncounterICU.procedure()) P
        where P.rank = 1
          and P.procedure.getId() = SelectedProcedure.id // NOTE: Should talk about using "reference()" here on a future call
    )
  where date from end of SelectedProcedure.performed.toInterval()
    during VTE.CalendarDayOfOrDayAfter(VTE.StartOfFirstICU(QualifyingEncounterICU))
  return QualifyingEncounterICU

// Supporting definitions from ICUVTE
define "Encounter With ICU Location":
  "Encounter With Age Range and Without VTE Diagnosis or Obstetrical Conditions" QualifyingEncounter
  	where exists (QualifyingEncounter.location Location
				where Global.GetLocation(Location.location).type in Cx."Intensive Care Unit"
  			and Location.period during QualifyingEncounter.period
  	)

define "Encounter With Age Range and Without VTE Diagnosis or Obstetrical Conditions":
  ( Global."Inpatient Encounter" InpatientEncounter
      where "AgeInYearsAt"(start of InpatientEncounter.period) >= 18
  )
    intersect "Admission Without VTE or Obstetrical Conditions"

define "Admission Without VTE or Obstetrical Conditions":
  Global."Inpatient Encounter" InpatientEncounter
    where not (exists (Global.EncounterDiagnosis(InpatientEncounter)) EncounterDiagnosis
          where (EncounterDiagnosis.code in Cx."Obstetrics"
						or EncounterDiagnosis.code in Cx."Venous Thromboembolism"
						or EncounterDiagnosis.code in Cx."Obstetrics VTE"
	         )
    )

define "SCIP VTE Selected Surgery":
  (	["Procedure": Cx."General Surgery"]
		union ["Procedure": Cx."Gynecological Surgery"]
		union ["Procedure": Cx."Hip Fracture Surgery"]
		union ["Procedure": Cx."Hip Replacement Surgery"]
		union ["Procedure": Cx."Intracranial Neurosurgery"]
		union ["Procedure": Cx."Knee Replacement Surgery"]
		union ["Procedure": Cx."Urological Surgery"] ) Procedure
		where Procedure.status = 'completed'
