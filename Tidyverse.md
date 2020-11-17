---
title: "Tidyverse"
---


# Introduction to Tidyverse

## Idealogy behind R for Data Science

Tidyverse is a collection of R packages that enables tools for data science, and is 
especially useful for data wrangling, manipulation, visualization, and communication
of large data sets. Extensions of tidyverse 
also enable direct connections and manipulation with SQL databases (e.g, dbplyr). Here
we briefly introduce some main concepts when this programming, all derived directly from
the open access book R for Data Science by Garrett Grolemund and Hadley Wickham (which 
can be found [here](https://r4ds.had.co.nz/)). 

As you can read [here](https://r4ds.had.co.nz/introduction.html), the main idea behind
using tidyverse is that exploratory data analysis in R is composed of a few main steps:
first is importing and tidying data, then iteratively transforming, visualising, and
modeling data to understand patterns held by them, and finally communicating results
effectively. Tidyverse was designed as a programming method and collection of functions
that are focused on easing these tasks into a simple uniform routine that can be applied
to any dataset. Standardizing the approach taken toward any data science project then 
aids reproducability of any project as well as the ability to collaborate on a project.

## The foundation: tibbles, tidy data, and piping

### Tibbles

First we need to install and load Tidyverse. After that we can have a look at what at 
the main form of data storage, called a tibble:

```r
install.packages('tidyverse')
install.packages('nycflights13') # this is an example data package
```


```
## ── [1mAttaching packages[22m ─────────────────────────────────────── tidyverse 1.3.0 ──
```

```
## [32m✔[39m [34mggplot2[39m 3.3.2     [32m✔[39m [34mpurrr  [39m 0.3.4
## [32m✔[39m [34mtibble [39m 3.0.4     [32m✔[39m [34mdplyr  [39m 1.0.2
## [32m✔[39m [34mtidyr  [39m 1.1.2     [32m✔[39m [34mstringr[39m 1.4.0
## [32m✔[39m [34mreadr  [39m 1.4.0     [32m✔[39m [34mforcats[39m 0.5.0
```

```
## ── [1mConflicts[22m ────────────────────────────────────────── tidyverse_conflicts() ──
## [31m✖[39m [34mdplyr[39m::[32mfilter()[39m masks [34mstats[39m::filter()
## [31m✖[39m [34mdplyr[39m::[32mlag()[39m    masks [34mstats[39m::lag()
```


```r
library(nycflights13)
```

Note that a tibble is essentially the same as a data frame (for example made with data.frame) but with some useful information printed (e.g., dimensions and data types), as well as some restrictions placed on how it an be manipulated. These help prevent common errors. For example, recycling is possible as it is in data frames but less flexible:


```r
flights$year <- c(2013, 2014)
try(flights$year <- rep(2014, 7))
```

## Tidy data
In addition, the above data may look like a standard data set obtained from anywhere,
but it is not. It has already been formatted as 'tidy data'. Although data can be 
represented a variety of ways in tables for visualization, but for data manipulation
and analysis, there is only one format that is much easier to use than others. 
Therefore, all data should be transformed into this format before analyzing. This 
format is called the 'tidy' dataset in tidyverse, and following three rules make a 
dataset 'tidy':

1. Each variable must have its own column.
2. Each observation must have its own row.
3. Each value must have its own cell.

If, for example, the flights dataset were organized such that each carrier, origin, or 
dest had their own sets of columns, the data would no longer be tidy.

### Piping

In base R programming, functions wrap around the objects that they are applied to, which
are often indexed, and this manipulated object is saved as a new one. What is written is
arranged like an onion: in the following example, the first step of the command is in
the center of code (calling the object flights), followed by indexing the 15th and 16th
columns. As we move away from the center, a function is applied, and finally the output
of that function is assigned to a new object. 


```r
sub <- apply(flights[,c(15:16)], 2, mean, na.rm = T)
```

Piping, or using '%>%' to pass objects from one function to the next, introduces a
programming method that makes the process more intuitive by alligning the code with the
order of operation:


```r
flights %>% 
  select(15, 16) %>%  # or use select(air_time, distance)
  apply(., 2, mean, na.rm = T) -> sub
```
In the above code, the flight tibble was piped into the 'select' function, which indexed
its 15th and 16th rows only. 'Select' does not require an argument where flights is
referenced because it was built to accept a piped argument implicitly. Note that
selecting by column name (no quotations needed) is also possible and
more useful in most cases. After being piped to 'select', the result was then piped to 
the function 'apply'. 'Apply' is an older function that is not built to implicitly
accept piped objects; therefore, it requires the placeholder '.' to be placed 
where the input data frame is expected. Finally, this modified data frame 
is assigned to 'sub' at the end, but alternatively it could have been assigned at the 
beginning as in the non-piped version.

## The power of tidyverse: all you need in a handful of functions

As in the 'select' function, there are a variety of functions that come with the
tidyverse package, but only a small set are needed to do almost any kind of data 
wrangling that you ever wanted to do. These are the only functions we touch on in this
brief introduction. However, beyond tidyverse, there are also a variety of 
packages that implement more advanced piping-compatible functions that speed the 
manipulation of large data sets in particular (e.g., dbplyr, purrrlyr). 

The most commonly used tidyverse commands, with a brief description, include:
* select() - select columns
* filter() - retain rows according to boolean criteria
* arrange() - sorts data
* rename() - renames existing columns
* mutate() - writes new columns
* group_by() / ungroup() - groups data according to column values (such as factors)
* summarise() - reduces dataset to an aggregated leve. Used after grouping (which 
defines the aggregation level) and along with functions that define how to aggregate
(e.g., count(), n(), sum(), mean()).
* gather() / spread() - converts data between the tidy format and 'long' formats
* full_join(), left_join(), etc. - joins data contained in two data frames according to
certain criteria that define how rows are compatible (i.e., joining in relational 
databases)

Below is an example of how the function 'apply' in the previous example can be replaced
using tidyverse commands, as well as functions such as 'aggregate' using 'group_by' and 'summarise'


```r
  flights %>%
  select(air_time, distance) %>% 
  summarise(mn_airtime = mean(air_time, na.rm = T),
            mn_distance = mean(distance))
```

```
## [90m# A tibble: 1 x 2[39m
##   mn_airtime mn_distance
##        [3m[90m<dbl>[39m[23m       [3m[90m<dbl>[39m[23m
## [90m1[39m       151.       [4m1[24m040.
```

```r
 # or if the operation should occur by groupings:
  flights %>%
  select(dest, air_time, distance) %>%
  group_by(dest) %>% 
  summarise(mn_airtime = mean(air_time, na.rm = T),
            mn_distance = mean(distance))
```

```
## `summarise()` ungrouping output (override with `.groups` argument)
```

```
## [90m# A tibble: 105 x 3[39m
##    dest  mn_airtime mn_distance
##    [3m[90m<chr>[39m[23m      [3m[90m<dbl>[39m[23m       [3m[90m<dbl>[39m[23m
## [90m 1[39m ABQ        249.        [4m1[24m826 
## [90m 2[39m ACK         42.1        199 
## [90m 3[39m ALB         31.8        143 
## [90m 4[39m ANC        413.        [4m3[24m370 
## [90m 5[39m ATL        113.         757.
## [90m 6[39m AUS        213.        [4m1[24m514.
## [90m 7[39m AVL         89.9        584.
## [90m 8[39m BDL         25.5        116 
## [90m 9[39m BGR         54.1        378 
## [90m10[39m BHM        123.         866.
## [90m# … with 95 more rows[39m
```

Here is a smattering of demonstrations on how to use the other important functions and their equivalents in base R:

#### filter()

```r
#filter()
flights[flights$month==3 & flights$dest=="DEN",]
```

```
## [90m# A tibble: 643 x 19[39m
##     year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##    [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m    [3m[90m<int>[39m[23m          [3m[90m<int>[39m[23m     [3m[90m<dbl>[39m[23m    [3m[90m<int>[39m[23m          [3m[90m<int>[39m[23m
## [90m 1[39m  [4m2[24m013     3     1      630            630         0      831            910
## [90m 2[39m  [4m2[24m013     3     1      648            649        -[31m1[39m      830            912
## [90m 3[39m  [4m2[24m013     3     1      649            649         0      839            920
## [90m 4[39m  [4m2[24m013     3     1      814            815        -[31m1[39m     [4m1[24m012           [4m1[24m056
## [90m 5[39m  [4m2[24m013     3     1      827            830        -[31m3[39m     [4m1[24m045           [4m1[24m106
## [90m 6[39m  [4m2[24m013     3     1      843            800        43     [4m1[24m042           [4m1[24m031
## [90m 7[39m  [4m2[24m013     3     1      857            900        -[31m3[39m     [4m1[24m057           [4m1[24m135
## [90m 8[39m  [4m2[24m013     3     1      922            925        -[31m3[39m     [4m1[24m115           [4m1[24m205
## [90m 9[39m  [4m2[24m013     3     1     [4m1[24m056           [4m1[24m100        -[31m4[39m     [4m1[24m258           [4m1[24m326
## [90m10[39m  [4m2[24m013     3     1     [4m1[24m144           [4m1[24m137         7     [4m1[24m327           [4m1[24m403
## [90m# … with 633 more rows, and 11 more variables: arr_delay [3m[90m<dbl>[90m[23m, carrier [3m[90m<chr>[90m[23m,[39m
## [90m#   flight [3m[90m<int>[90m[23m, tailnum [3m[90m<chr>[90m[23m, origin [3m[90m<chr>[90m[23m, dest [3m[90m<chr>[90m[23m, air_time [3m[90m<dbl>[90m[23m,[39m
## [90m#   distance [3m[90m<dbl>[90m[23m, hour [3m[90m<dbl>[90m[23m, minute [3m[90m<dbl>[90m[23m, time_hour [3m[90m<dttm>[90m[23m[39m
```

```r
flights %>% 
  filter(month == 3, dest == "DEN")
```

```
## [90m# A tibble: 643 x 19[39m
##     year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##    [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m    [3m[90m<int>[39m[23m          [3m[90m<int>[39m[23m     [3m[90m<dbl>[39m[23m    [3m[90m<int>[39m[23m          [3m[90m<int>[39m[23m
## [90m 1[39m  [4m2[24m013     3     1      630            630         0      831            910
## [90m 2[39m  [4m2[24m013     3     1      648            649        -[31m1[39m      830            912
## [90m 3[39m  [4m2[24m013     3     1      649            649         0      839            920
## [90m 4[39m  [4m2[24m013     3     1      814            815        -[31m1[39m     [4m1[24m012           [4m1[24m056
## [90m 5[39m  [4m2[24m013     3     1      827            830        -[31m3[39m     [4m1[24m045           [4m1[24m106
## [90m 6[39m  [4m2[24m013     3     1      843            800        43     [4m1[24m042           [4m1[24m031
## [90m 7[39m  [4m2[24m013     3     1      857            900        -[31m3[39m     [4m1[24m057           [4m1[24m135
## [90m 8[39m  [4m2[24m013     3     1      922            925        -[31m3[39m     [4m1[24m115           [4m1[24m205
## [90m 9[39m  [4m2[24m013     3     1     [4m1[24m056           [4m1[24m100        -[31m4[39m     [4m1[24m258           [4m1[24m326
## [90m10[39m  [4m2[24m013     3     1     [4m1[24m144           [4m1[24m137         7     [4m1[24m327           [4m1[24m403
## [90m# … with 633 more rows, and 11 more variables: arr_delay [3m[90m<dbl>[90m[23m, carrier [3m[90m<chr>[90m[23m,[39m
## [90m#   flight [3m[90m<int>[90m[23m, tailnum [3m[90m<chr>[90m[23m, origin [3m[90m<chr>[90m[23m, dest [3m[90m<chr>[90m[23m, air_time [3m[90m<dbl>[90m[23m,[39m
## [90m#   distance [3m[90m<dbl>[90m[23m, hour [3m[90m<dbl>[90m[23m, minute [3m[90m<dbl>[90m[23m, time_hour [3m[90m<dttm>[90m[23m[39m
```

#### arrange()

```r
o <- order(flights$distance)
flights[o,c('year','month','day','distance')]
```

```
## [90m# A tibble: 336,776 x 4[39m
##     year month   day distance
##    [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m    [3m[90m<dbl>[39m[23m
## [90m 1[39m  [4m2[24m013     7    27       17
## [90m 2[39m  [4m2[24m013     1     3       80
## [90m 3[39m  [4m2[24m013     1     4       80
## [90m 4[39m  [4m2[24m013     1     4       80
## [90m 5[39m  [4m2[24m013     1     4       80
## [90m 6[39m  [4m2[24m013     1     5       80
## [90m 7[39m  [4m2[24m013     1     6       80
## [90m 8[39m  [4m2[24m013     1     7       80
## [90m 9[39m  [4m2[24m013     1     8       80
## [90m10[39m  [4m2[24m013     1     9       80
## [90m# … with 336,766 more rows[39m
```

```r
flights[rev(o),c('year','month','day','distance')]
```

```
## [90m# A tibble: 336,776 x 4[39m
##     year month   day distance
##    [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m    [3m[90m<dbl>[39m[23m
## [90m 1[39m  [4m2[24m013     9    30     [4m4[24m983
## [90m 2[39m  [4m2[24m013     9    29     [4m4[24m983
## [90m 3[39m  [4m2[24m013     9    28     [4m4[24m983
## [90m 4[39m  [4m2[24m013     9    27     [4m4[24m983
## [90m 5[39m  [4m2[24m013     9    25     [4m4[24m983
## [90m 6[39m  [4m2[24m013     9    23     [4m4[24m983
## [90m 7[39m  [4m2[24m013     9    22     [4m4[24m983
## [90m 8[39m  [4m2[24m013     9    21     [4m4[24m983
## [90m 9[39m  [4m2[24m013     9    20     [4m4[24m983
## [90m10[39m  [4m2[24m013     9    18     [4m4[24m983
## [90m# … with 336,766 more rows[39m
```

```r
flights %>% 
  select(year, month, day, distance) %>% 
  arrange(distance)
```

```
## [90m# A tibble: 336,776 x 4[39m
##     year month   day distance
##    [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m    [3m[90m<dbl>[39m[23m
## [90m 1[39m  [4m2[24m013     7    27       17
## [90m 2[39m  [4m2[24m013     1     3       80
## [90m 3[39m  [4m2[24m013     1     4       80
## [90m 4[39m  [4m2[24m013     1     4       80
## [90m 5[39m  [4m2[24m013     1     4       80
## [90m 6[39m  [4m2[24m013     1     5       80
## [90m 7[39m  [4m2[24m013     1     6       80
## [90m 8[39m  [4m2[24m013     1     7       80
## [90m 9[39m  [4m2[24m013     1     8       80
## [90m10[39m  [4m2[24m013     1     9       80
## [90m# … with 336,766 more rows[39m
```

```r
flights %>% 
  select(year, month, day, distance) %>% 
  arrange(desc(distance))
```

```
## [90m# A tibble: 336,776 x 4[39m
##     year month   day distance
##    [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m    [3m[90m<dbl>[39m[23m
## [90m 1[39m  [4m2[24m013     1     1     [4m4[24m983
## [90m 2[39m  [4m2[24m013     1     2     [4m4[24m983
## [90m 3[39m  [4m2[24m013     1     3     [4m4[24m983
## [90m 4[39m  [4m2[24m013     1     4     [4m4[24m983
## [90m 5[39m  [4m2[24m013     1     5     [4m4[24m983
## [90m 6[39m  [4m2[24m013     1     6     [4m4[24m983
## [90m 7[39m  [4m2[24m013     1     7     [4m4[24m983
## [90m 8[39m  [4m2[24m013     1     8     [4m4[24m983
## [90m 9[39m  [4m2[24m013     1     9     [4m4[24m983
## [90m10[39m  [4m2[24m013     1    10     [4m4[24m983
## [90m# … with 336,766 more rows[39m
```

#### rename()

```r
flights2 <- data.frame(flights, year2 = flights$year)
flights2 <- as_tibble(flights2[c(dim(flights2)[2],2:(dim(flights2)[2]-1))])
flights2
```

```
## [90m# A tibble: 336,776 x 19[39m
##    year2 month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##    [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m    [3m[90m<int>[39m[23m          [3m[90m<int>[39m[23m     [3m[90m<dbl>[39m[23m    [3m[90m<int>[39m[23m          [3m[90m<int>[39m[23m
## [90m 1[39m  [4m2[24m013     1     1      517            515         2      830            819
## [90m 2[39m  [4m2[24m013     1     1      533            529         4      850            830
## [90m 3[39m  [4m2[24m013     1     1      542            540         2      923            850
## [90m 4[39m  [4m2[24m013     1     1      544            545        -[31m1[39m     [4m1[24m004           [4m1[24m022
## [90m 5[39m  [4m2[24m013     1     1      554            600        -[31m6[39m      812            837
## [90m 6[39m  [4m2[24m013     1     1      554            558        -[31m4[39m      740            728
## [90m 7[39m  [4m2[24m013     1     1      555            600        -[31m5[39m      913            854
## [90m 8[39m  [4m2[24m013     1     1      557            600        -[31m3[39m      709            723
## [90m 9[39m  [4m2[24m013     1     1      557            600        -[31m3[39m      838            846
## [90m10[39m  [4m2[24m013     1     1      558            600        -[31m2[39m      753            745
## [90m# … with 336,766 more rows, and 11 more variables: arr_delay [3m[90m<dbl>[90m[23m,[39m
## [90m#   carrier [3m[90m<chr>[90m[23m, flight [3m[90m<int>[90m[23m, tailnum [3m[90m<chr>[90m[23m, origin [3m[90m<chr>[90m[23m, dest [3m[90m<chr>[90m[23m,[39m
## [90m#   air_time [3m[90m<dbl>[90m[23m, distance [3m[90m<dbl>[90m[23m, hour [3m[90m<dbl>[90m[23m, minute [3m[90m<dbl>[90m[23m, time_hour [3m[90m<dttm>[90m[23m[39m
```

```r
flights2 <- 
  flights %>% 
  rename(year2 = year)
flights2
```

```
## [90m# A tibble: 336,776 x 19[39m
##    year2 month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##    [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m    [3m[90m<int>[39m[23m          [3m[90m<int>[39m[23m     [3m[90m<dbl>[39m[23m    [3m[90m<int>[39m[23m          [3m[90m<int>[39m[23m
## [90m 1[39m  [4m2[24m013     1     1      517            515         2      830            819
## [90m 2[39m  [4m2[24m013     1     1      533            529         4      850            830
## [90m 3[39m  [4m2[24m013     1     1      542            540         2      923            850
## [90m 4[39m  [4m2[24m013     1     1      544            545        -[31m1[39m     [4m1[24m004           [4m1[24m022
## [90m 5[39m  [4m2[24m013     1     1      554            600        -[31m6[39m      812            837
## [90m 6[39m  [4m2[24m013     1     1      554            558        -[31m4[39m      740            728
## [90m 7[39m  [4m2[24m013     1     1      555            600        -[31m5[39m      913            854
## [90m 8[39m  [4m2[24m013     1     1      557            600        -[31m3[39m      709            723
## [90m 9[39m  [4m2[24m013     1     1      557            600        -[31m3[39m      838            846
## [90m10[39m  [4m2[24m013     1     1      558            600        -[31m2[39m      753            745
## [90m# … with 336,766 more rows, and 11 more variables: arr_delay [3m[90m<dbl>[90m[23m,[39m
## [90m#   carrier [3m[90m<chr>[90m[23m, flight [3m[90m<int>[90m[23m, tailnum [3m[90m<chr>[90m[23m, origin [3m[90m<chr>[90m[23m, dest [3m[90m<chr>[90m[23m,[39m
## [90m#   air_time [3m[90m<dbl>[90m[23m, distance [3m[90m<dbl>[90m[23m, hour [3m[90m<dbl>[90m[23m, minute [3m[90m<dbl>[90m[23m, time_hour [3m[90m<dttm>[90m[23m[39m
```

#### mutate()

```r
flights2 <- as_tibble(data.frame(flights, air_time_hr = flights$air_time/60, distance_1000m = flights$distance/1000))


flights2 <-
  flights %>% 
  mutate(air_time_hr = air_time/60, distance_1000m = distance/1000)
flights2
```

```
## [90m# A tibble: 336,776 x 21[39m
##     year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
##    [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m [3m[90m<int>[39m[23m    [3m[90m<int>[39m[23m          [3m[90m<int>[39m[23m     [3m[90m<dbl>[39m[23m    [3m[90m<int>[39m[23m          [3m[90m<int>[39m[23m
## [90m 1[39m  [4m2[24m013     1     1      517            515         2      830            819
## [90m 2[39m  [4m2[24m013     1     1      533            529         4      850            830
## [90m 3[39m  [4m2[24m013     1     1      542            540         2      923            850
## [90m 4[39m  [4m2[24m013     1     1      544            545        -[31m1[39m     [4m1[24m004           [4m1[24m022
## [90m 5[39m  [4m2[24m013     1     1      554            600        -[31m6[39m      812            837
## [90m 6[39m  [4m2[24m013     1     1      554            558        -[31m4[39m      740            728
## [90m 7[39m  [4m2[24m013     1     1      555            600        -[31m5[39m      913            854
## [90m 8[39m  [4m2[24m013     1     1      557            600        -[31m3[39m      709            723
## [90m 9[39m  [4m2[24m013     1     1      557            600        -[31m3[39m      838            846
## [90m10[39m  [4m2[24m013     1     1      558            600        -[31m2[39m      753            745
## [90m# … with 336,766 more rows, and 13 more variables: arr_delay [3m[90m<dbl>[90m[23m,[39m
## [90m#   carrier [3m[90m<chr>[90m[23m, flight [3m[90m<int>[90m[23m, tailnum [3m[90m<chr>[90m[23m, origin [3m[90m<chr>[90m[23m, dest [3m[90m<chr>[90m[23m,[39m
## [90m#   air_time [3m[90m<dbl>[90m[23m, distance [3m[90m<dbl>[90m[23m, hour [3m[90m<dbl>[90m[23m, minute [3m[90m<dbl>[90m[23m, time_hour [3m[90m<dttm>[90m[23m,[39m
## [90m#   air_time_hr [3m[90m<dbl>[90m[23m, distance_1000m [3m[90m<dbl>[90m[23m[39m
```
#### group_by() with count()

```r
#count() with group_by()
#this yields data in a 'long' format
flights2a <- t(table(flights[,c('origin', 'dest')]))
head(flights2a)
```

```
##      origin
## dest    EWR   JFK   LGA
##   ABQ     0   254     0
##   ACK     0   265     0
##   ALB   439     0     0
##   ANC     8     0     0
##   ATL  5022  1930 10263
##   AUS   968  1471     0
```

```r
#this yields 'tidy' data
flights2 <- 
  flights %>% 
  group_by(origin, dest) %>% 
  count()
flights2
```

```
## [90m# A tibble: 224 x 3[39m
## [90m# Groups:   origin, dest [224][39m
##    origin dest      n
##    [3m[90m<chr>[39m[23m  [3m[90m<chr>[39m[23m [3m[90m<int>[39m[23m
## [90m 1[39m EWR    ALB     439
## [90m 2[39m EWR    ANC       8
## [90m 3[39m EWR    ATL    [4m5[24m022
## [90m 4[39m EWR    AUS     968
## [90m 5[39m EWR    AVL     265
## [90m 6[39m EWR    BDL     443
## [90m 7[39m EWR    BNA    [4m2[24m336
## [90m 8[39m EWR    BOS    [4m5[24m327
## [90m 9[39m EWR    BQN     297
## [90m10[39m EWR    BTV     931
## [90m# … with 214 more rows[39m
```
#### spread() / gather() to convert between long and tidy formats:

```r
flights2b <-
  flights2 %>% 
  as_tibble() %>% 
  spread(key = origin, value = n, fill = 0)

#result in the same formats 
flights2b
```

```
## [90m# A tibble: 105 x 4[39m
##    dest    EWR   JFK   LGA
##    [3m[90m<chr>[39m[23m [3m[90m<dbl>[39m[23m [3m[90m<dbl>[39m[23m [3m[90m<dbl>[39m[23m
## [90m 1[39m ABQ       0   254     0
## [90m 2[39m ACK       0   265     0
## [90m 3[39m ALB     439     0     0
## [90m 4[39m ANC       8     0     0
## [90m 5[39m ATL    [4m5[24m022  [4m1[24m930 [4m1[24m[4m0[24m263
## [90m 6[39m AUS     968  [4m1[24m471     0
## [90m 7[39m AVL     265     0    10
## [90m 8[39m BDL     443     0     0
## [90m 9[39m BGR       0     0   375
## [90m10[39m BHM       0     1   296
## [90m# … with 95 more rows[39m
```

```r
head(flights2a) 
```

```
##      origin
## dest    EWR   JFK   LGA
##   ABQ     0   254     0
##   ACK     0   265     0
##   ALB   439     0     0
##   ANC     8     0     0
##   ATL  5022  1930 10263
##   AUS   968  1471     0
```

```r
flights2b %>% 
  gather(key = origin, value = n, -dest) %>% 
  filter(n!=0)
```

```
## [90m# A tibble: 224 x 3[39m
##    dest  origin     n
##    [3m[90m<chr>[39m[23m [3m[90m<chr>[39m[23m  [3m[90m<dbl>[39m[23m
## [90m 1[39m ALB   EWR      439
## [90m 2[39m ANC   EWR        8
## [90m 3[39m ATL   EWR     [4m5[24m022
## [90m 4[39m AUS   EWR      968
## [90m 5[39m AVL   EWR      265
## [90m 6[39m BDL   EWR      443
## [90m 7[39m BNA   EWR     [4m2[24m336
## [90m 8[39m BOS   EWR     [4m5[24m327
## [90m 9[39m BQN   EWR      297
## [90m10[39m BTV   EWR      931
## [90m# … with 214 more rows[39m
```

```r
head(flights2)
```

```
## [90m# A tibble: 6 x 3[39m
## [90m# Groups:   origin, dest [6][39m
##   origin dest      n
##   [3m[90m<chr>[39m[23m  [3m[90m<chr>[39m[23m [3m[90m<int>[39m[23m
## [90m1[39m EWR    ALB     439
## [90m2[39m EWR    ANC       8
## [90m3[39m EWR    ATL    [4m5[24m022
## [90m4[39m EWR    AUS     968
## [90m5[39m EWR    AVL     265
## [90m6[39m EWR    BDL     443
```

## Plotting in tidyverse

Tidyverse also uses ggplot2, which is intended to simplify the process of creating plots
so that data can be quickly and easily visualized as an iterative component of the
exploratory analysis process. Some advantages include an clear method for translating
data to visuals, having many preconfigured attributes available, and being able to build
and modify previously stored plot objects without needing to recreate them. A downside
is that to take advantage of the full power and flexibility of ggplot2 requires a wide
knowledge of what is available as options to include in graphics, and therefore involve
a long learning curve. However, the ultimate results are well worth the 
learning investment. For a basic explanation and cheat sheet see
[here](https://ggplot2.tidyverse.org/)

### ggplot: Key components

ggplot has __three__ key components: 

1.  __data__, this must be a `data.frame`

2. A set of aesthetic mappings (`aes`) between variables in the data and 
   visual properties, and 

3. At least one `layer` which describes how to render each observation.


```r
sub <- 
  flights %>% 
  sample_n(100, replace = F) %>% 
  filter(!is.na(distance), !is.na(air_time), !is.na(origin), !is.na(month), !is.na(dest))

ggplot(data = sub, aes(x = distance, y = air_time)) + geom_point()
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-1-1.png" width="672" />

Different syntax, equivalent outcome:


```r
ggplot(sub, aes(distance, air_time)) + geom_point()
ggplot()                    + geom_point(data = sub, aes(distance, air_time))
ggplot(data = sub)            + geom_point(aes(x = distance, y = air_time))
ggplot(sub)                   + geom_point(aes(distance, air_time))
```

Can be stored as an object for later use. This is a useful feature of Rgadget: because 
default plots are created in ggplot, they can be stored and modified by the user at a
later point.


```r
p <- ggplot(sub, aes(distance, air_time)) + geom_point()
```

The class:

```r
class(p)
```

```
## [1] "gg"     "ggplot"
```
The structure (a bit of Latin - not run here):

```r
str(p)
```

### aesthetic

Adding more variables to a two dimensional scatterplot can be done by mapping the variables to an aesthetic (colour, fill, size, shape, alpha)

#### colour


```r
p <- ggplot(sub, aes(distance, air_time))
p + geom_point(aes(colour = origin))
p + geom_point(aes(colour = dest))
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-6-1.png" width="50%" /><img src="Tidyverse_files/figure-html/unnamed-chunk-6-2.png" width="50%" />

Manual control of colours or other palette schemes (here brewer):

```r
p + geom_point(aes(colour = origin)) +
  scale_colour_manual(values = c("orange","brown","green"))
p + geom_point(aes(colour = dest)) +
  scale_colour_brewer(palette = "Set1")
```

```
## Warning in RColorBrewer::brewer.pal(n, pal): n too large, allowed maximum for palette Set1 is 9
## Returning the palette you asked for with that many colors
```

```
## Warning: Removed 72 rows containing missing values (geom_point).
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-7-1.png" width="50%" /><img src="Tidyverse_files/figure-html/unnamed-chunk-7-2.png" width="50%" />

Note, to view all the brewer palettes do:

```r
RColorBrewer::display.brewer.all()
```



#### shape


```r
p + geom_point(aes(distance, air_time, shape = origin))
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-9-1.png" width="672" />

#### size


```r
p + geom_point(aes(distance, air_time, size = month))
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-10-1.png" width="672" />

One can also "fix" the aesthetic manually, e.g.:


```r
ggplot(sub, aes(distance, air_time)) + geom_point(colour = "blue", shape = 8, size = 10)
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-11-1.png" width="672" />

Note here that the call to colour, shape, etc. is done outside the `aes`-call. One can also combine calls inside and outside the `aes`-function (here we showing overlay of adjacent datapoints):

```r
p + geom_point(aes(distance, air_time, size = month), alpha = 0.3, col = "red")
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-12-1.png" width="672" />


### Facetting

Splitting a graph into subsets based on a categorical variable. 


```r
ggplot(sub) + 
  geom_point(aes(distance, air_time, colour = as.factor(year))) + 
  facet_wrap(~ origin)
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-13-1.png" width="672" />

One can also split the plot using two variables using the function `facet_grid`:


```r
ggplot(sub) +
  geom_point(aes(distance, air_time)) +
  facet_grid(as.factor(year) ~ origin)
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-14-1.png" width="672" />

### Adding layers

The power of ggplot comes into place when one adds layers on top of other layers. Let's for now look at only at two examples.

### Add a line to a scatterplot


```r
ggplot(sub, aes(distance, air_time)) +
  geom_point() +
  geom_line()
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-15-1.png" width="672" />

#### Add a smoother to a scatterplot


```r
p <- ggplot(sub, aes(distance, air_time))
p + geom_point() + geom_smooth()
```

```
## `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

```r
p + geom_point() + geom_smooth(method = "lm")
```

```
## `geom_smooth()` using formula 'y ~ x'
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-16-1.png" width="33%" /><img src="Tidyverse_files/figure-html/unnamed-chunk-16-2.png" width="33%" />



```
## `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-17-1.png" width="672" />


## Statistical summary graphs
___

There are some useful *inbuilt* routines within the ggplot2-packages which allows one to create some simple summary plots of the raw data.

#### bar plot

One can create bar graph for discrete data using the `geom_bar`


```r
ggplot(sub, aes(dest)) + geom_bar()
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-18-1.png" width="672" />

The graph shows the number of observations we have of each destination. The original data is first transformed behind the scene into a table of counts, before being rendered. 

#### histograms

For continuous data one uses the `geom_histogram`-function (left default bin-number, right bindwith specified as 50 mins): 


```r
p <- ggplot(sub, aes(air_time))
p + geom_histogram()
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

```r
p + geom_histogram(binwidth = 50)
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-19-1.png" width="50%" /><img src="Tidyverse_files/figure-html/unnamed-chunk-19-2.png" width="50%" />

One can add another variable (left) or better use facet (right):


```r
p + geom_histogram(aes(fill = origin))
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

```r
p + geom_histogram() + facet_wrap(~ origin, ncol = 1)
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-20-1.png" width="50%" /><img src="Tidyverse_files/figure-html/unnamed-chunk-20-2.png" width="50%" />

#### Frequency polygons

Alternatives to histograms for continuous data are frequency polygons:

```r
p + geom_freqpoly(lwd = 1)
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

```r
p + geom_freqpoly(aes(colour = origin), lwd = 1)
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-21-1.png" width="50%" /><img src="Tidyverse_files/figure-html/unnamed-chunk-21-2.png" width="50%" />

#### Box-plots

Boxplots, which are more condensed summaries of the data than histograms, are called using `geom_boxplot`. Here two versions of the same graph are used, the one on the left is the default, but on the right we have reordered the maturity variable on the x-axis such that the median value of length increases from left to right:

```r
ggplot(sub, aes(dest, air_time)) + geom_boxplot()
p <- ggplot(sub, aes(reorder(dest, air_time), air_time)) + geom_boxplot()
p
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-22-1.png" width="50%" /><img src="Tidyverse_files/figure-html/unnamed-chunk-22-2.png" width="50%" />

It is sometimes useful to plot the "raw" data over summary plots. Using `geom_point` as an overlay is sometimes not very useful when points overlap too much; `geom_jitter` can sometimes be more useful:


```r
p + geom_point(colour = "red", alpha = 0.5, size = 1)
p + geom_jitter(colour = "red", alpha = 0.5, size = 1)
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-23-1.png" width="50%" /><img src="Tidyverse_files/figure-html/unnamed-chunk-23-2.png" width="50%" />

Read the help on `geom_violin` and create a code that results in this plot:

<img src="Tidyverse_files/figure-html/unnamed-chunk-24-1.png" width="672" />

</div>
</div>
## Other statistical summaries

Using `stat_summary` one can call specific summary statistics. Here are examples of 4 plots, going from top-left to bottom right we have:

* Raw data with median length at age (red) superimposed
* A pointrange plot showing the mean and the range
* A pointrange plot showing the mean and the standard error
* A pointrange plot showing the bootstrap mean and standard error


```r
sub$distance <- round(sub$distance)
p <- ggplot(sub, aes(distance, air_time))
p + geom_point(alpha = 0.25) + stat_summary(fun.y = "median", geom = "point", colour = "red")
```

```
## Warning: `fun.y` is deprecated. Use `fun` instead.
```

```r
p + stat_summary(fun.y = "mean", fun.ymin = "min", fun.ymax = "max", geom = "pointrange")
```

```
## Warning: `fun.y` is deprecated. Use `fun` instead.
```

```
## Warning: `fun.ymin` is deprecated. Use `fun.min` instead.
```

```
## Warning: `fun.ymax` is deprecated. Use `fun.max` instead.
```

```r
p + stat_summary(fun.data = "mean_se")
```

```
## Warning: Removed 40 rows containing missing values (geom_segment).
```

```r
p + stat_summary(fun.data = "mean_cl_boot")
```

```
## Warning: Computation failed in `stat_summary()`:
## Hmisc package required for this function
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-25-1.png" width="50%" /><img src="Tidyverse_files/figure-html/unnamed-chunk-25-2.png" width="50%" /><img src="Tidyverse_files/figure-html/unnamed-chunk-25-3.png" width="50%" /><img src="Tidyverse_files/figure-html/unnamed-chunk-25-4.png" width="50%" />

## Some controls

### labels


```r
p <- ggplot(sub, aes(distance, air_time, colour = origin)) + geom_point()
p + labs(x = "Distance (miles)", y = "Air time (minutes)", 
         colour = "Origin", 
         title = "My flight plot",
         subtitle = "My nice subtitle",
         caption = "My caption")
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-26-1.png" width="672" />

### Legend position


```r
p + theme(legend.position = "none")
p <- p + theme(legend.position = c(0.8, 0.3))
p
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-27-1.png" width="50%" /><img src="Tidyverse_files/figure-html/unnamed-chunk-27-2.png" width="50%" />

### breaks

Controls which values appear as tick marks


```r
p +
  scale_x_continuous(breaks = seq(5, 45, by = 10)*100) +
  scale_y_continuous(breaks = seq(50, 400, by = 50))
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-28-1.png" width="672" />

### limits


```r
p + ylim(100, 500)
```

```
## Warning: Removed 31 rows containing missing values (geom_point).
```

```r
p + ylim(NA, 500) # setting only upper limit
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-29-1.png" width="50%" /><img src="Tidyverse_files/figure-html/unnamed-chunk-29-2.png" width="50%" />



## Further readings
___

* The ggplot2 site: http://ggplot2.tidyverse.org
* The ggplot2 book in the making: https://github.com/hadley/ggplot2-book
    - A rendered version of the book: http://www.hafro.is/~einarhj/education/ggplot2
        - needs to be updates
* [R4DS - Data visualisation](http://r4ds.had.co.nz/data-visualisation.html)
* R graphics cookbook: http://www.cookbook-r.com/Graphs
* [Data Visualization Cheat Sheet](https://github.com/rstudio/cheatsheets/raw/master/data-visualization-2.1.pdf)



