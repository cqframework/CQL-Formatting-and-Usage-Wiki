
## Question:

I want to run an aggregate query on this list of tuples {value : uop, time : date} 
where uop is the urine output and I want to add values that have the same date and return that list however when I execute it, it just gets stuck somewhere. 

Below is the code and I was wondering if anyone can see anything obviously wrong with this or if anyone would have other suggestions.

```cql
define foley_uop : [Observation : Foley]

define foley_uop_temp :
  from foley_uop uop
    return Tuple {
        value : FHIRHelpers.ToDecimal(uop.value.value),
        time : ToDate(uop.effective)
    }
  sort by time asc

define first_uop : First(foley_uop_temp)

define daily_uop :
  foley_uop_temp uop
    aggregate R starting (List { {value : first_uop.value, time : first_uop.time } }):
      case 
        when uop.time same as Last(R).time then
          uop x  
            let
              daily_uop_value : x.value + Last(R).value
            return Tuple { value : daily_uop_value, time  : x.time }
        else
          R union 
          {
            uop x
              let
                daily_uop_value : x.value
              return Tuple { value : daily_uop_value, time  : x.time }
          }
      end
```

## Answer:

The first thing to note is that this can be done easily with the correlated sub-queries
discussed in the SubQueries topic:

```cql
define daily_uop_2:
  foley_uop_temp X
    return distinct { 
        time: X.time, 
        sum: Sum(foley_uop_temp I where I.time same as X.time return all I.value) 
    }
```

But to answer the question about how to do this with the `aggregate` clause:

> NOTE: The `aggregate` clause was introduced trial use in CQL 1.5 and is not yet widely implemented. The discussion that follows is based on the documented behavior of the operation

> NOTE: The `aggregate` clause is an _advanced_ feature of CQL, introduced to support an important class of recursive queries in CQL in a general way. The discussion that follows is necessarily technical.

The [`aggregate`](https://cql.hl7.org/03-developersguide.html#aggregate-queries
) clause in CQL has the following syntax:

```
<aggregate clause> ::=
  aggregate [(all | distinct)] <result alias> [<starting clause>] : <expression>

<starting clause> ::=
  starting (<simple literal> | <quantity | "("<expression>")")
```

The way the `aggregate` clause works, it returns the "accumulated" value after each iteration.
For simple aggregation, where you're just summing numbers, for example, this can be done by
just returning the result of the calculation.

As a simple example, the following expression is equivalent to the `Sum`, expressed using an aggregate query:

```cql
define ListOfInteger: { 1, 2, 3, 4, 5 }
define SumOfList: Sum(ListOfInteger)

define SumAsAggregate:
  ListOfInteger I
    aggregate Result starting 0: Result + I
```

For more complex aggregates, where the result is a List, the result of every iteration is
the accumulation at that point. Consider the rollout intervals example from the specification:

```cql
define "RolledOutIntervals":
  MedicationRequestIntervals M
    aggregate R starting (null as List<Interval<DateTime>>): R union ({
      M X
        let S: Max({ end of Last(R) + 1 day, start of X }),
          E: S + duration in days of X
        return Interval[S, E]
    })
```

In particular, the proposed query has an iteration step of:

```cql
      case 
        when uop.time same as Last(R).time then
          uop x  
            let
              daily_uop_value : x.value + Last(R).value
            return Tuple { value : daily_uop_value, time  : x.time }
        else
          R union 
          {
            uop x
              let
                daily_uop_value : x.value
              return Tuple { value : daily_uop_value, time  : x.time }
          }
      end
```

This is saying, if the time of the current iteration step is the same as the last step in the 
accumulating result, then return a Tuple with the value of the current step plus the value in the
last step.

Otherwise, return the current result plus a Tuple with the value for the current iteration step.

But this means that the accumulator will lose all but the current iteration everytime there is another
element with the same time.

To correct this, we need to return the entire accumulation in every step:

```
define DailyUoPAsAggregate:
  foley_uop_temp T
    aggregate Result starting (foley_uop_temp X where false):      
      (Result R where R.time != T.time)
        union
          ({ { 
              time: T.time, 
              value: T.value + Coalesce((Result SR where SR.time = T.time return SR.value).single(), 0.0) 
            } 
          })
```

This says:
Return the results accumulated so far without the current row, unioned with a row for the current
iteration + whatever is in the current accumulated results with the same time as the current iteration
