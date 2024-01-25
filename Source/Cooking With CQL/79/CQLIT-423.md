## CQLIT-423

https://oncprojectracking.healthit.gov/support/projects/CQLIT/issues/CQLIT-423

CQLIT-423 CMS117 CMS0117 v12 QDM

Summary: Day precision whthout expression containing 'date less than 1 day before date'
Description: I am experiencing an issue where I am seeing 99% coverage for Childhood Immunization Status (CMS117) in Bonniev5.1.5 although I expected 100% coverage. Upon reviewing the highlighting, the "All Hib Vaccinations" and "All Rotavirus Vaccinations" definitions are not fully meeting highlighting although I have test cases that cover these two criteria. Please advise. 
Code snippet:
such that date from start of Global."NormalizeInterval"( AllRotavirusDoses1.relevantDatetime, AllRotavirusDoses1.relevantPeriod ) less than 1 day before date from start of Global."NormalizeInterval"( AllRotavirusDoses2.relevantDatetime, AllRotavirusDoses2.relevantPeriod )

```cql
define "All Hib Vaccinations":
  "Hib 3 or 4 Dose Immunizations" AllHibDoses1
    without "Hib 3 or 4 Dose Immunizations" AllHibDoses2
      such that date from start of Global."NormalizeInterval" ( AllHibDoses1.relevantDatetime, AllHibDoses1.relevantPeriod ) less than 1 day before date from start of Global."NormalizeInterval" ( AllHibDoses2.relevantDatetime, AllHibDoses2.relevantPeriod )
```

```cql
define "All Rotavirus Vaccinations":
  "Rotavirus 2 or 3 Dose Immunizations" AllRotavirusDoses1
    without "Rotavirus 2 or 3 Dose Immunizations" AllRotavirusDoses2
      such that date from start of Global."NormalizeInterval" ( AllRotavirusDoses1.relevantDatetime, AllRotavirusDoses1.relevantPeriod ) less than 1 day before date from start of Global."NormalizeInterval" ( AllRotavirusDoses2.relevantDatetime, AllRotavirusDoses2.relevantPeriod )
```

Both of these expressions contain the timing phrase `less than 1 day before date from start`. This is an impossible condition to satisfy because of the day precision, there is no way for two dates to be on the same day, but also be before. Consider using `starts same day or after` instead:

```cql
define "All Hib Vaccinations":
  "Hib 3 or 4 Dose Immunizations" AllHibDoses1
    without "Hib 3 or 4 Dose Immunizations" AllHibDoses2
      such that Global."NormalizeInterval" ( AllHibDoses1.relevantDatetime, AllHibDoses1.relevantPeriod ) starts same day or after start of Global."NormalizeInterval" ( AllHibDoses2.relevantDatetime, AllHibDoses2.relevantPeriod )
```

```cql
define "All Rotavirus Vaccinations":
  "Rotavirus 2 or 3 Dose Immunizations" AllRotavirusDoses1
    without "Rotavirus 2 or 3 Dose Immunizations" AllRotavirusDoses2
      such that Global."NormalizeInterval" ( AllRotavirusDoses1.relevantDatetime, AllRotavirusDoses1.relevantPeriod ) starts same day or after start of Global."NormalizeInterval" ( AllRotavirusDoses2.relevantDatetime, AllRotavirusDoses2.relevantPeriod )
```
