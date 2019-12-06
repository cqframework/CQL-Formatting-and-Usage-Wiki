[1]
https://github.com/esacinc/CQL-Formatting-and-Usage-Wiki/blob/master/Source/Cooking%20With%20CQL/40/101_EntityExamples.cql#L4

Hi Bryn,

In case you cover this in Cooking with CQL, [1] is a line that uses the
CQL "is" operator, but Bonnie does not support that.

Based on CMS149, I was experimenting with this

define "My Qualifying Encounters":
   ( distinct ( flatten ( from
           "Dementia Encounter" Enc1,
           "Dementia Encounter" Enc2
           let Org1: ( Enc1.participant as "Organization" ),
           Org2: ( Enc2.participant as "Organization" )
           where Org1 is not null
             and Org2 is not null
             and start of Enc2.relevantPeriod 1 day or more after start
of Enc1.relevantPeriod
             and Org1.identifier ~ Org2.identifier
           return all { Enc1, Enc2 }
       )
     )
   )
