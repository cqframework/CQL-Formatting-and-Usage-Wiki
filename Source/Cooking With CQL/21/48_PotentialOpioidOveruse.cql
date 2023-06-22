library PotentialOpioidOveruse version '0.1.000'

using QDM version '5.3'

include MATGlobalCommonFunctions version '1.0.000' called Global

codesystem "LOINC:2.46": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'
codesystem "SNOMEDCT:2016-03": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'
codesystem "RXNORM:2017-11": 'urn:oid:2.16.840.1.113883.6.88' version 'urn:hl7:version:2017-11'
codesystem "RXNORM:2016-09": 'urn:oid:2.16.840.1.113883.6.88' version 'urn:hl7:version:2016-09'
codesystem "RXNORM:2015-10": 'urn:oid:2.16.840.1.113883.6.88' version 'urn:hl7:version:2015-10'

valueset "ONC Administrative Sex": 'urn:oid:2.16.840.1.113762.1.4.1' 
valueset "Race": 'urn:oid:2.16.840.1.114222.4.11.836' 
valueset "Ethnicity": 'urn:oid:2.16.840.1.114222.4.11.837' 
valueset "Payer": 'urn:oid:2.16.840.1.114222.4.11.3591' 
valueset "Dihydrocodeine": 'urn:oid:2.16.840.1.113883.3.3157.1004.13' 
valueset "Levorphanol": 'urn:oid:2.16.840.1.113883.3.3157.1002.73' 
valueset "Tapentadol": 'urn:oid:2.16.840.1.113883.3.3157.1004.17' 
valueset "Fentanyl": 'urn:oid:2.16.840.1.113883.3.3157.1002.76' 
valueset "Morphine": 'urn:oid:2.16.840.1.113883.3.3157.1002.70' 
valueset "Codeine": 'urn:oid:2.16.840.1.113883.3.3157.1002.77' 
valueset "Hydrocodone": 'urn:oid:2.16.840.1.113883.3.3157.1002.75' 
valueset "Hydromorphone": 'urn:oid:2.16.840.1.113883.3.3157.1002.74' 
valueset "Oxycodone": 'urn:oid:2.16.840.1.113883.3.3157.1002.11' 
valueset "Oxymorphone": 'urn:oid:2.16.840.1.113883.3.3157.1002.12' 
valueset "Tramadol": 'urn:oid:2.16.840.1.113883.3.3157.1004.18' 
valueset "Office Visit": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001' 
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1025' 
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1023' 
valueset "Preventive Care Services - Other": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1030' 
valueset "Face to Face Interaction - No ED": 'urn:oid:2.16.840.1.113762.1.4.1080.2' 
valueset "Palliative Care": 'urn:oid:2.16.840.1.113883.3.600.1.1579' 
valueset "Hospice Care SNO": 'urn:oid:2.16.840.1.113883.3.3157.1004.20' 
valueset "All Cancer": 'urn:oid:2.16.840.1.113883.3.464.1003.108.12.1011' 
valueset "Sickle Cell Disease SNOMEDCT": 'urn:oid:2.16.840.1.113762.1.4.1029.33' 
valueset "Buprenorphine": 'urn:oid:2.16.840.1.113883.3.3157.1004.11' 
valueset "Meperidine": 'urn:oid:2.16.840.1.113883.3.3157.1002.72' 
valueset "Methadone": 'urn:oid:2.16.840.1.113883.3.3157.1002.71' 
valueset "Opium": 'urn:oid:2.16.840.1.113883.3.3157.1004.15' 
valueset "Butorphanol": 'urn:oid:2.16.840.1.113883.3.3157.1004.12' 
valueset "Nalbuphine": 'urn:oid:2.16.840.1.113883.3.3157.1004.14' 
valueset "Pentazocine": 'urn:oid:2.16.840.1.113883.3.3157.1004.16' 
valueset "Outpatient Consultation": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1008' 

code "Birthdate": '21112-8' from "LOINC:2.46" display 'Birth date'
code "Dead": '419099009' from "SNOMEDCT:2016-03" display 'Dead'

parameter "Measurement Period" Interval<DateTime>
parameter "Orders" List<MedicationOrder>

context Patient

define "SDE Ethnicity":
	["Patient Characteristic Ethnicity": "Ethnicity"]

define "SDE Payer":
	["Patient Characteristic Payer": "Payer"]

define "SDE Race":
	["Patient Characteristic Race": "Race"]

define "SDE Sex":
	["Patient Characteristic Sex": "ONC Administrative Sex"]

define "Age 12 or Older  Encounters":
	["Patient Characteristic Birthdate"] DOB
		where Global.CalendarAgeInYearsAt(DOB.birthDatetime, start of "Measurement Period")>= 12
			and exists ( "Encounters" )

define "Cancer Exclusion":
	exists ["Diagnosis": "All Cancer"] Cancer
		where Cancer.prevalencePeriod starts 1 year or less before start of "Measurement Period"
			or Cancer.prevalencePeriod starts during "Measurement Period"

define "Denominator":
	"Initial Population"

define "Denominator Exclusion":
	exists ( "Palliative Care Order" )
		or exists ( "Palliative Care Performed" )
		or ( "Hospice Exclusion" )
		or ( "Cancer Exclusion" )
		or ( "Sickle Cell Exclusion" )

define "Encounters":
	( ["Encounter, Performed": "Face to Face Interaction - No ED"]
		union ["Encounter, Performed": "Office Visit"]
		union ["Encounter, Performed": "Preventive Care Services - Established Office Visit, 18 and Up"]
		union ["Encounter, Performed": "Preventive Care Services-Initial Office Visit, 18 and Up"]
		union ["Encounter, Performed": "Outpatient Consultation"]
		union ["Encounter, Performed": "Preventive Care Services - Other"] ) Encounter
		where Encounter.relevantPeriod during "Measurement Period"

define "Hospice Exclusion":
	exists ( ["Intervention, Order": "Hospice Care SNO"]
		union ["Intervention, Performed": "Hospice Care SNO"]
		union ["Intervention, Recommended": "Hospice Care SNO"] ) Hospice
		where Hospice.authorDatetime during "Measurement Period"

define "Opioids Ordered":
	( ["Medication, Order": "Buprenorphine"]
		union ["Medication, Order": "Butorphanol"]
		union ["Medication, Order": "Codeine"]
		union ["Medication, Order": "Dihydrocodeine"]
		union ["Medication, Order": "Fentanyl"]
		union ["Medication, Order": "Hydrocodone"]
		union ["Medication, Order": "Hydromorphone"]
		union ["Medication, Order": "Levorphanol"]
		union ["Medication, Order": "Meperidine"]
		union ["Medication, Order": "Methadone"]
		union ["Medication, Order": "Morphine"]
		union ["Medication, Order": "Nalbuphine"]
		union ["Medication, Order": "Opium"]
		union ["Medication, Order": "Oxycodone"]
		union ["Medication, Order": "Oxymorphone"]
		union ["Medication, Order": "Pentazocine"]
		union ["Medication, Order": "Tapentadol"]
		union ["Medication, Order": "Tramadol"] ) Medication
		where Medication.authorDatetime during "Measurement Period"

define "Palliative Care Order":
	"Encounters" Encounter
		with ["Intervention, Order": "Palliative Care"] Care
			such that Care.authorDatetime during Encounter.relevantPeriod

define "Palliative Care Performed":
	"Encounters" Encounter
		with ["Intervention, Performed": "Palliative Care"] Care
			such that Care.relevantPeriod overlaps Encounter.relevantPeriod
				or Care.relevantPeriod starts during Encounter.relevantPeriod

define "Sickle Cell Exclusion":
	exists ["Diagnosis": "Sickle Cell Disease SNOMEDCT"] Sickle
		where Sickle.prevalencePeriod starts before start of "Measurement Period"
			or Sickle.prevalencePeriod starts during "Measurement Period"

define "Opioid Supply":
	"Cumulative Medication Duration"("Opioids Ordered")>= 90

define "Initial Population":
	( "Opioid Supply" )
		and exists ( "Age 12 or Older  Encounters" )

define "Results":
	"Is MME 90 Or More" M
	  return {
	    mmeOver90: M,
	    title:
	      if M
	      then 'High risk for opioid overdose - '
	            
	      description:
	        if M
	        then 'Total morphine milligram equivalent (MME) is ' + ToString(TotalMME) + '. Taper to less than 50.'
	        else 'Total morphine milligram equivalent (MME) is ' + ToString(TotalMME) + '. This falls within the accepted range.'
	  }

define "MME 90 or More":
	( "Buprenorphine Order"
		or "Butorphanol Order"
		or "XYZ Order" ) Medications
		where Medications > 90 'mg/d'

define "Buprenorphine Order":
	(["Medication, Order": "Buprenorphine"] Buprenorphine
	where Buprenorphine.frequency "ToDaily"(frequency),
	and Buprenorphine.dosage > 0 'mg' * 11
	and Buprenorphine.authorDatetime during "Measurement Period"
	sort by dosage).result as Integer

define function "GetDailyDose"(doseQuantity ingredientCode Code, strength Quantity, doseQuantity Quantity, dosesPerDay Decimal ):
	case
	// if dose unit in actual mass units (mg or mcg -- when it's a single med) --> daily dose = numTimesPerDay * dose
	when doseQuantity.unit in { 'mg', 'mcg' } then
	Quantity { value: dosesPerDay * doseQuantity.value, unit: doseQuantity.unit }
	
	// if doseQuantity is in actual volume units (mL) --> daily dose = numTimesPerDay * dose * strength
	when doseQuantity.unit = 'mL' and (PositionOf('/mL', strength.unit) = Length(strength.unit) - 3) then
	Quantity { value: dosesPerDay * doseQuantity.value * strength.value, unit: Substring(strength.unit, 0, PositionOf('/', strength.unit)) }
	
	// if doseQuantity is not in actual units (e.g., 1 tab, 1 spray -- when it's a combo med with a unit of tablet, or it's mg/actuat) --> daily dose = numTimesPerDay * dose value * strength value
	else
	Quantity { value: dosesPerDay * doseQuantity.value * strength.value, unit: Substring(strength.unit, 0, PositionOf('/', strength.unit)) }
	end

define function "GetDailyDoseDescription"(dose ingredientCode Code, ingredientName String, strength Quantity, doseQuantity Quantity, dosesPerDay Decimal, dailyDose Quantity ):
	/*
	Builds a description for the daily dose for an ingredient
	*/
	case
	// if dose unit in actual mass units (mg or mcg -- when it's a single med)
	when doseQuantity.unit in { 'mg', 'mcg' } then
	ingredientName + ' ' + ToString(dosesPerDay) + '/d * ' + ToString(doseQuantity) + ' = ' + ToString(dailyDose)
	
	// if doseQuantity in actual volume units (mL) or not in actual units (e.g. 1 tab, 1 spray)
	else
	ingredientName + ' ' + ToString(dosesPerDay) + '/d * ' + ToString(doseQuantity) + ' * ' + ToString(strength) + ' = ' + ToString(dailyDose)
	end

define function "GetMedicationName"(RxNorncode rxNormCode Code ):
	SingletonFrom([MED_DRUG: DRUG_RXCUI in rxNormCode]).DRUG_NAME

define function "GetIngredients"(rxNormCode (rxNormCode Code ):
	(
	[MED_SCDC_FOR_DRUG: DRUG_RXCUI in rxNormCode] SD
	return {
	rxNormCode: rxNormCode,
	component: SingletonFrom([MED_SCDC: SCDC_RXCUI in SD.SCDC_RXCUI]),
	ingredientCode: SingletonFrom([MED_INGREDIENT_FOR_SCDC: SCDC_RXCUI in SD.SCDC_RXCUI]).INGREDIENT_RXCUI,
	doseFormCode: SingletonFrom([MED_DRUG_DOSE_FORM: DRUG_RXCUI in SD.DRUG_RXCUI]).DOSE_FORM_RXCUI // Could potentially look this up only once...
	}
	) C
	let
	ingredient: SingletonFrom([MED_INGREDIENT: INGREDIENT_RXCUI in C.ingredientCode]),
	
	return {
	rxNormCode: rxNormCode,
	ingredientCode: C.ingredientCode,
	ingredientName: ingredient.INGREDIENT_NAME,
	strength:
	EnsureMicrogramQuantity(
	Quantity {
	value: C.component.STRENGTH_VALUE,
	unit: ToUCUM(C.component.STRENGTH_UNIT)
	}
	)
	}

define function "ToDailyCode"(Frequency Code ):
	case Frequency
	    when "PRN" then 3
	    // etc.
	    else null
	  end
	  
	 /* https://www.hl7.org/fhir/valueset-medication-as-needed-reason.json.html*/

define function "ToDailyFrequencyChoiceQuantityCode"(Frequncy <Quantity, Code> ):
	case Frequency
	    when Frequency is Quantity then ToDaily(Frequency as Quantity)
	    else"ToDaily Code" as Code
	  end

define function "ToDailyFrequencyQuantity"(Frequency Quantity ):
	case Frequency.unit when 'h' then ( 24.0 / Frequency.value ) when 'min' then ( 24.0 / Frequency.value ) * 60 when 's' then ( 24.0 / Frequency.value ) * 60 * 60 when 'd' then ( 24.0 / Frequency.value ) / 24 when 'wk' then ( 24.0 / Frequency.value ) / ( 24 * 7 ) when 'mo' then ( 24.0 / Frequency.value ) / ( 24 * 30 ) // assuming 30 days in month when 'a' then ( 24.0 / Frequency.value ) / ( 24 * 365 ) // assuming 365 days in year else null end

define function "ToUCUM"(unit String ):
	case unit
	when 'MG' then 'mg'
	when 'MG/ACTUAT' then 'mg/{actuat}'
	when 'MG/HR' then 'mg/h'
	when 'MG/ML' then 'mg/mL'
	else 'unknown{' + unit + '}'

define function "EnsureMicrogramQuantity"(strength strength Quantity ):
	if strength.value < 0.1 and (PositionOf('mg', strength.unit) = 0) then
	Quantity {
	value: strength.value * 1000,
	unit: 'mcg' + Substring(strength.unit, 2)
	}
	else
	strength

/*Flatten to construct a single list from a list of lists*/
define function "CalculateMMEs"(Medications medications List<Tuple { rxNormCode Code, doseQuantity Quantity, dosesPerDay Decimal }> ):
	Flatten(
	medications M
	let Ingredients: GetIngredients(M.rxNormCode)
	return
	Ingredients I
	let
	adjustedDoseQuantity: EnsureMicrogramQuantity(M.doseQuantity),
	dailyDose: GetDailyDose(I.ingredientCode, I.strength, I.doseFormCode, adjustedDoseQuantity, M.dosesPerDay),
	factor: GetConversionFactor(I.ingredientCode, dailyDose, I.doseFormCode)
	return {
	rxNormCode: M.rxNormCode,
	doseQuantity: adjustedDoseQuantity,
	dosesPerDay: M.dosesPerDay,
	ingredientCode: I.ingredientCode,
	ingredientName: I.ingredientName,
	strength: I.strength,
	dailyDose: dailyDose,
	dailyDoseDescription: GetDailyDoseDescription(I.ingredientCode, I.ingredientName, I.strength, adjustedDoseQuantity, M.dosesPerDay, dailyDose),
	conversionFactor: factor,
	mme: Quantity {
	value: dailyDose.value * factor,
	unit: dailyDose.unit + '/d'
	}
	}
	)

define function "Cumulative Medication Duration"(Medication List<"Medication, Order"> ):
	Sum((collapse(Medication.relevantPeriod))CMD
			return duration in days of CMD
	)

define function "GetConversionFactor"(Ingredient List<Code> ):
	case Ingredient when "Buprenorphine" then 11 when "Butorphanol" then 7 when "Codeine" then 0.15 when "Dihydrocodeine" then 0.25 when "Fentanyl" then 7.20 when "Hydrocodone" then 1 when "Hydromorphone" then 4 when "Levorphanol" then 11 when "Meperidine" then 0.1 when "Methadone" then 3 when "Morphine" then 1 when "Nalbuphine" then 1 when "Opium" then 1 when "Oxycodone" then 1.5 when "Oxymorphone" then 3 when "Pentazocine" then 0.37 when "Tapentadol" then 0.4 when "Tramadol" then 0.1 else 0 end

/*Calculates daily frequency given frequency within a period*/
define function "ToDaily"(Frequency Quantity ):
	/*
	Calculates daily frequency given frequency within a period
	*/
	case Frequency.unit when 'h' then ( 24.0 / Frequency.value ) when 'min' then ( 24.0 / Frequency.value ) * 60 when 's' then ( 24.0 / Frequency.value ) * 60 * 60 when 'd' then ( 24.0 / Frequency.value ) / 24 when 'wk' then ( 24.0 / Frequency.value ) / ( 24 * 7 ) when 'mo' then ( 24.0 / Frequency.value ) / ( 24 * 30 ) /* assuming 30 days in month*/ when 'a' then ( 24.0 / Frequency.value ) / ( 24 * 365 ) /* assuming 365 days in year*/ else null end

