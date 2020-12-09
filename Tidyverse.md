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
library(nycflights13)
```


```r
present_table <- function(x){
  x %>% 
    slice(1:20) %>% 
    DT::datatable()
}
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

Piping, or using `%>%` to pass objects from one function to the next, introduces a
programming method that makes the process more intuitive by alligning the code with the
order of operation:


```r
flights %>% 
  select(15, 16) %>%  # or use select(air_time, distance)
  apply(., 2, mean, na.rm = T) -> sub
```
In the above code, the flight tibble was piped into the 'select' function, which indexed
its 15th and 16th rows only. `Select` does not require an argument where flights is
referenced because it was built to accept a piped argument implicitly. Note that
selecting by column name (no quotations needed) is also possible and
more useful in most cases. After being piped to 'select', the result was then piped to 
the function `apply`. `Apply` is an older function that is not built to implicitly
accept piped objects; therefore, it requires the placeholder `.` to be placed 
where the input data frame is expected. Finally, this modified data frame 
is assigned to 'sub' at the end, but alternatively it could have been assigned at the 
beginning as in the non-piped version.

## The power of tidyverse: all you need in a handful of functions

As in the `select` function, there are a variety of functions that come with the
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
* gather() / spread() - converts data between the `wide` and `long` (tidy) formats
* full_join(), left_join(), etc. - joins data contained in two data frames according to
certain criteria that define how rows are compatible (i.e., joining in relational 
databases)

Below is an example of how the function `apply` in the previous example can be replaced
using tidyverse commands, as well as functions such as `aggregate` using `group_by` and `summarise`


```r
  flights %>%
  select(air_time, distance) %>% 
  summarise(mn_airtime = mean(air_time, na.rm = T),
            mn_distance = mean(distance)) %>% 
  present_table() #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-b118f756b7555894f9e8" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-b118f756b7555894f9e8">{"x":{"filter":"none","data":[["1"],[150.686460198078],[1039.91260362971]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>mn_airtime<\/th>\n      <th>mn_distance<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

```r
 # or if the operation should occur by groupings:
  flights %>%
  select(dest, air_time, distance) %>%
  group_by(dest) %>% 
  summarise(mn_airtime = mean(air_time, na.rm = T),
            mn_distance = mean(distance)) %>%
  present_table() #this last line not necessary - helps with printing to web page
```

```
## `summarise()` ungrouping output (override with `.groups` argument)
```

<!--html_preserve--><div id="htmlwidget-a24aef48ee984cf8abe7" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-a24aef48ee984cf8abe7">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"],["ABQ","ACK","ALB","ANC","ATL","AUS","AVL","BDL","BGR","BHM","BNA","BOS","BQN","BTV","BUF","BUR","BWI","BZN","CAE","CAK"],[249.169291338583,42.0681818181818,31.7870813397129,413.125,112.930450792897,212.727913728743,89.8888888888889,25.4660194174757,54.1173184357542,122.776951672862,114.382149901381,38.9530022633471,194.882882882883,46.4498007968128,55.7295404814004,334.102702702703,38.4997036158862,258.371428571429,93.1981132075472,64.0368171021378],[1826,199,143,3370,757.108219575951,1514.25297252973,583.581818181818,116,378,865.996632996633,758.213484920259,190.636961568223,1578.98325892857,265.091541135574,296.808374279,2465,179.418304323414,1882,603.551724137931,397]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>dest<\/th>\n      <th>mn_airtime<\/th>\n      <th>mn_distance<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[2,3]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

Here is a smattering of demonstrations on how to use the other important functions and their equivalents in base R:

#### filter()

```r
#filter()
flights[flights$month==3 & flights$dest=="DEN",] %>% 
  present_table() #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-97e6d5ac3e73b69a751f" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-97e6d5ac3e73b69a751f">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"],[2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013],[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[630,648,649,814,827,843,857,922,1056,1144,1251,1500,1510,1603,1615,1702,1714,1738,1825,1838],[630,649,649,815,830,800,900,925,1100,1137,1250,1500,1513,1600,1615,1704,1719,1730,1815,1838],[0,-1,0,-1,-3,43,-3,-3,-4,7,1,0,-3,3,0,-2,-5,8,10,0],[831,830,839,1012,1045,1042,1057,1115,1258,1327,1439,1653,1709,1803,1822,1850,1909,1940,2012,2034],[910,912,920,1056,1106,1031,1135,1205,1326,1403,1535,1726,1725,1850,1850,1929,1948,1957,2052,2104],[-39,-42,-41,-44,-21,11,-38,-50,-28,-36,-56,-33,-16,-47,-28,-39,-39,-17,-40,-30],["WN","UA","UA","DL","F9","UA","UA","WN","UA","UA","WN","UA","UA","DL","WN","UA","UA","F9","DL","UA"],[459,311,343,914,835,561,1643,102,1737,580,564,704,434,920,3,1214,509,797,884,390],["N297WN","N421UA","N564UA","N351NW","N209FR","N573UA","N19141","N296WN","N76522","N453UA","N786SW","N556UA","N585UA","N3765","N240WN","N16713","N564UA","N211FR","N365NW","N411UA"],["LGA","EWR","LGA","LGA","LGA","LGA","EWR","EWR","LGA","EWR","LGA","LGA","EWR","JFK","EWR","EWR","LGA","LGA","LGA","EWR"],["DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN"],[212,201,208,206,217,201,208,213,210,205,212,207,205,212,213,207,202,211,206,205],[1620,1605,1620,1620,1620,1620,1605,1605,1620,1605,1620,1620,1605,1626,1605,1605,1620,1620,1620,1605],[6,6,6,8,8,8,9,9,11,11,12,15,15,16,16,17,17,17,18,18],[30,49,49,15,30,0,0,25,0,37,50,0,13,0,15,4,19,30,15,38],["2013-03-01T11:00:00Z","2013-03-01T11:00:00Z","2013-03-01T11:00:00Z","2013-03-01T13:00:00Z","2013-03-01T13:00:00Z","2013-03-01T13:00:00Z","2013-03-01T14:00:00Z","2013-03-01T14:00:00Z","2013-03-01T16:00:00Z","2013-03-01T16:00:00Z","2013-03-01T17:00:00Z","2013-03-01T20:00:00Z","2013-03-01T20:00:00Z","2013-03-01T21:00:00Z","2013-03-01T21:00:00Z","2013-03-01T22:00:00Z","2013-03-01T22:00:00Z","2013-03-01T22:00:00Z","2013-03-01T23:00:00Z","2013-03-01T23:00:00Z"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>year<\/th>\n      <th>month<\/th>\n      <th>day<\/th>\n      <th>dep_time<\/th>\n      <th>sched_dep_time<\/th>\n      <th>dep_delay<\/th>\n      <th>arr_time<\/th>\n      <th>sched_arr_time<\/th>\n      <th>arr_delay<\/th>\n      <th>carrier<\/th>\n      <th>flight<\/th>\n      <th>tailnum<\/th>\n      <th>origin<\/th>\n      <th>dest<\/th>\n      <th>air_time<\/th>\n      <th>distance<\/th>\n      <th>hour<\/th>\n      <th>minute<\/th>\n      <th>time_hour<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2,3,4,5,6,7,8,9,11,15,16,17,18]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

```r
flights %>% 
  filter(month == 3, dest == "DEN") %>% 
  present_table() #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-57d4908688a56971735d" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-57d4908688a56971735d">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"],[2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013],[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[630,648,649,814,827,843,857,922,1056,1144,1251,1500,1510,1603,1615,1702,1714,1738,1825,1838],[630,649,649,815,830,800,900,925,1100,1137,1250,1500,1513,1600,1615,1704,1719,1730,1815,1838],[0,-1,0,-1,-3,43,-3,-3,-4,7,1,0,-3,3,0,-2,-5,8,10,0],[831,830,839,1012,1045,1042,1057,1115,1258,1327,1439,1653,1709,1803,1822,1850,1909,1940,2012,2034],[910,912,920,1056,1106,1031,1135,1205,1326,1403,1535,1726,1725,1850,1850,1929,1948,1957,2052,2104],[-39,-42,-41,-44,-21,11,-38,-50,-28,-36,-56,-33,-16,-47,-28,-39,-39,-17,-40,-30],["WN","UA","UA","DL","F9","UA","UA","WN","UA","UA","WN","UA","UA","DL","WN","UA","UA","F9","DL","UA"],[459,311,343,914,835,561,1643,102,1737,580,564,704,434,920,3,1214,509,797,884,390],["N297WN","N421UA","N564UA","N351NW","N209FR","N573UA","N19141","N296WN","N76522","N453UA","N786SW","N556UA","N585UA","N3765","N240WN","N16713","N564UA","N211FR","N365NW","N411UA"],["LGA","EWR","LGA","LGA","LGA","LGA","EWR","EWR","LGA","EWR","LGA","LGA","EWR","JFK","EWR","EWR","LGA","LGA","LGA","EWR"],["DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN","DEN"],[212,201,208,206,217,201,208,213,210,205,212,207,205,212,213,207,202,211,206,205],[1620,1605,1620,1620,1620,1620,1605,1605,1620,1605,1620,1620,1605,1626,1605,1605,1620,1620,1620,1605],[6,6,6,8,8,8,9,9,11,11,12,15,15,16,16,17,17,17,18,18],[30,49,49,15,30,0,0,25,0,37,50,0,13,0,15,4,19,30,15,38],["2013-03-01T11:00:00Z","2013-03-01T11:00:00Z","2013-03-01T11:00:00Z","2013-03-01T13:00:00Z","2013-03-01T13:00:00Z","2013-03-01T13:00:00Z","2013-03-01T14:00:00Z","2013-03-01T14:00:00Z","2013-03-01T16:00:00Z","2013-03-01T16:00:00Z","2013-03-01T17:00:00Z","2013-03-01T20:00:00Z","2013-03-01T20:00:00Z","2013-03-01T21:00:00Z","2013-03-01T21:00:00Z","2013-03-01T22:00:00Z","2013-03-01T22:00:00Z","2013-03-01T22:00:00Z","2013-03-01T23:00:00Z","2013-03-01T23:00:00Z"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>year<\/th>\n      <th>month<\/th>\n      <th>day<\/th>\n      <th>dep_time<\/th>\n      <th>sched_dep_time<\/th>\n      <th>dep_delay<\/th>\n      <th>arr_time<\/th>\n      <th>sched_arr_time<\/th>\n      <th>arr_delay<\/th>\n      <th>carrier<\/th>\n      <th>flight<\/th>\n      <th>tailnum<\/th>\n      <th>origin<\/th>\n      <th>dest<\/th>\n      <th>air_time<\/th>\n      <th>distance<\/th>\n      <th>hour<\/th>\n      <th>minute<\/th>\n      <th>time_hour<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2,3,4,5,6,7,8,9,11,15,16,17,18]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

#### arrange()

```r
o <- order(flights$distance)
flights[o,c('year','month','day','distance')]%>% 
  present_table() #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-55bdde9ca10799800aab" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-55bdde9ca10799800aab">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"],[2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013],[7,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[27,3,4,4,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],[17,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>year<\/th>\n      <th>month<\/th>\n      <th>day<\/th>\n      <th>distance<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2,3,4]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

```r
flights[rev(o),c('year','month','day','distance')]%>% 
  present_table() #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-14aa84c626cb422e1b97" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-14aa84c626cb422e1b97">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"],[2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013],[9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9],[30,29,28,27,25,23,22,21,20,18,16,15,14,13,11,10,9,8,7,6],[4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>year<\/th>\n      <th>month<\/th>\n      <th>day<\/th>\n      <th>distance<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2,3,4]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

```r
flights %>% 
  select(year, month, day, distance) %>% 
  arrange(distance) %>% 
  present_table() #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-42715c37edafba6e6fd6" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-42715c37edafba6e6fd6">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"],[2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013],[7,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[27,3,4,4,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],[17,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>year<\/th>\n      <th>month<\/th>\n      <th>day<\/th>\n      <th>distance<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2,3,4]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

```r
flights %>% 
  select(year, month, day, distance) %>% 
  arrange(desc(distance)) %>% 
  present_table() #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-170de669969527ebba4b" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-170de669969527ebba4b">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"],[2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013],[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20],[4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983,4983]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>year<\/th>\n      <th>month<\/th>\n      <th>day<\/th>\n      <th>distance<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2,3,4]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

#### rename()

```r
flights2 <- data.frame(flights, year2 = flights$year)
flights2 <- as_tibble(flights2[c(dim(flights2)[2],2:(dim(flights2)[2]-1))])
flights2 %>% 
  present_table() #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-d4bcf39acc05f17625d5" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-d4bcf39acc05f17625d5">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"],[2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013],[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[517,533,542,544,554,554,555,557,557,558,558,558,558,558,559,559,559,600,600,601],[515,529,540,545,600,558,600,600,600,600,600,600,600,600,600,559,600,600,600,600],[2,4,2,-1,-6,-4,-5,-3,-3,-2,-2,-2,-2,-2,-1,0,-1,0,0,1],[830,850,923,1004,812,740,913,709,838,753,849,853,924,923,941,702,854,851,837,844],[819,830,850,1022,837,728,854,723,846,745,851,856,917,937,910,706,902,858,825,850],[11,20,33,-18,-25,12,19,-14,-8,8,-2,-3,7,-14,31,-4,-8,-7,12,-6],["UA","UA","AA","B6","DL","UA","B6","EV","B6","AA","B6","B6","UA","UA","AA","B6","UA","B6","MQ","B6"],[1545,1714,1141,725,461,1696,507,5708,79,301,49,71,194,1124,707,1806,1187,371,4650,343],["N14228","N24211","N619AA","N804JB","N668DN","N39463","N516JB","N829AS","N593JB","N3ALAA","N793JB","N657JB","N29129","N53441","N3DUAA","N708JB","N76515","N595JB","N542MQ","N644JB"],["EWR","LGA","JFK","JFK","LGA","EWR","EWR","LGA","JFK","LGA","JFK","JFK","JFK","EWR","LGA","JFK","EWR","LGA","LGA","EWR"],["IAH","IAH","MIA","BQN","ATL","ORD","FLL","IAD","MCO","ORD","PBI","TPA","LAX","SFO","DFW","BOS","LAS","FLL","ATL","PBI"],[227,227,160,183,116,150,158,53,140,138,149,158,345,361,257,44,337,152,134,147],[1400,1416,1089,1576,762,719,1065,229,944,733,1028,1005,2475,2565,1389,187,2227,1076,762,1023],[5,5,5,5,6,5,6,6,6,6,6,6,6,6,6,5,6,6,6,6],[15,29,40,45,0,58,0,0,0,0,0,0,0,0,0,59,0,0,0,0],["2013-01-01T10:00:00Z","2013-01-01T10:00:00Z","2013-01-01T10:00:00Z","2013-01-01T10:00:00Z","2013-01-01T11:00:00Z","2013-01-01T10:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T10:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>year2<\/th>\n      <th>month<\/th>\n      <th>day<\/th>\n      <th>dep_time<\/th>\n      <th>sched_dep_time<\/th>\n      <th>dep_delay<\/th>\n      <th>arr_time<\/th>\n      <th>sched_arr_time<\/th>\n      <th>arr_delay<\/th>\n      <th>carrier<\/th>\n      <th>flight<\/th>\n      <th>tailnum<\/th>\n      <th>origin<\/th>\n      <th>dest<\/th>\n      <th>air_time<\/th>\n      <th>distance<\/th>\n      <th>hour<\/th>\n      <th>minute<\/th>\n      <th>time_hour<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2,3,4,5,6,7,8,9,11,15,16,17,18]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

```r
flights2 <- 
  flights %>% 
  rename(year2 = year)
flights2  %>% 
  present_table()  #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-785cda2b9cb472a80d97" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-785cda2b9cb472a80d97">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"],[2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013],[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[517,533,542,544,554,554,555,557,557,558,558,558,558,558,559,559,559,600,600,601],[515,529,540,545,600,558,600,600,600,600,600,600,600,600,600,559,600,600,600,600],[2,4,2,-1,-6,-4,-5,-3,-3,-2,-2,-2,-2,-2,-1,0,-1,0,0,1],[830,850,923,1004,812,740,913,709,838,753,849,853,924,923,941,702,854,851,837,844],[819,830,850,1022,837,728,854,723,846,745,851,856,917,937,910,706,902,858,825,850],[11,20,33,-18,-25,12,19,-14,-8,8,-2,-3,7,-14,31,-4,-8,-7,12,-6],["UA","UA","AA","B6","DL","UA","B6","EV","B6","AA","B6","B6","UA","UA","AA","B6","UA","B6","MQ","B6"],[1545,1714,1141,725,461,1696,507,5708,79,301,49,71,194,1124,707,1806,1187,371,4650,343],["N14228","N24211","N619AA","N804JB","N668DN","N39463","N516JB","N829AS","N593JB","N3ALAA","N793JB","N657JB","N29129","N53441","N3DUAA","N708JB","N76515","N595JB","N542MQ","N644JB"],["EWR","LGA","JFK","JFK","LGA","EWR","EWR","LGA","JFK","LGA","JFK","JFK","JFK","EWR","LGA","JFK","EWR","LGA","LGA","EWR"],["IAH","IAH","MIA","BQN","ATL","ORD","FLL","IAD","MCO","ORD","PBI","TPA","LAX","SFO","DFW","BOS","LAS","FLL","ATL","PBI"],[227,227,160,183,116,150,158,53,140,138,149,158,345,361,257,44,337,152,134,147],[1400,1416,1089,1576,762,719,1065,229,944,733,1028,1005,2475,2565,1389,187,2227,1076,762,1023],[5,5,5,5,6,5,6,6,6,6,6,6,6,6,6,5,6,6,6,6],[15,29,40,45,0,58,0,0,0,0,0,0,0,0,0,59,0,0,0,0],["2013-01-01T10:00:00Z","2013-01-01T10:00:00Z","2013-01-01T10:00:00Z","2013-01-01T10:00:00Z","2013-01-01T11:00:00Z","2013-01-01T10:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T10:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>year2<\/th>\n      <th>month<\/th>\n      <th>day<\/th>\n      <th>dep_time<\/th>\n      <th>sched_dep_time<\/th>\n      <th>dep_delay<\/th>\n      <th>arr_time<\/th>\n      <th>sched_arr_time<\/th>\n      <th>arr_delay<\/th>\n      <th>carrier<\/th>\n      <th>flight<\/th>\n      <th>tailnum<\/th>\n      <th>origin<\/th>\n      <th>dest<\/th>\n      <th>air_time<\/th>\n      <th>distance<\/th>\n      <th>hour<\/th>\n      <th>minute<\/th>\n      <th>time_hour<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2,3,4,5,6,7,8,9,11,15,16,17,18]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

#### mutate()

```r
flights2 <- as_tibble(data.frame(flights, air_time_hr = flights$air_time/60, distance_1000m = flights$distance/1000)) %>% 
  present_table() #this last line not necessary - helps with printing to web page



flights2 <-
  flights %>%  
  mutate(air_time_hr = air_time/60, distance_1000m = distance/1000)
flights2 %>% 
  present_table() #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-b1b052fea2c324c352b6" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-b1b052fea2c324c352b6">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"],[2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013,2013],[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[517,533,542,544,554,554,555,557,557,558,558,558,558,558,559,559,559,600,600,601],[515,529,540,545,600,558,600,600,600,600,600,600,600,600,600,559,600,600,600,600],[2,4,2,-1,-6,-4,-5,-3,-3,-2,-2,-2,-2,-2,-1,0,-1,0,0,1],[830,850,923,1004,812,740,913,709,838,753,849,853,924,923,941,702,854,851,837,844],[819,830,850,1022,837,728,854,723,846,745,851,856,917,937,910,706,902,858,825,850],[11,20,33,-18,-25,12,19,-14,-8,8,-2,-3,7,-14,31,-4,-8,-7,12,-6],["UA","UA","AA","B6","DL","UA","B6","EV","B6","AA","B6","B6","UA","UA","AA","B6","UA","B6","MQ","B6"],[1545,1714,1141,725,461,1696,507,5708,79,301,49,71,194,1124,707,1806,1187,371,4650,343],["N14228","N24211","N619AA","N804JB","N668DN","N39463","N516JB","N829AS","N593JB","N3ALAA","N793JB","N657JB","N29129","N53441","N3DUAA","N708JB","N76515","N595JB","N542MQ","N644JB"],["EWR","LGA","JFK","JFK","LGA","EWR","EWR","LGA","JFK","LGA","JFK","JFK","JFK","EWR","LGA","JFK","EWR","LGA","LGA","EWR"],["IAH","IAH","MIA","BQN","ATL","ORD","FLL","IAD","MCO","ORD","PBI","TPA","LAX","SFO","DFW","BOS","LAS","FLL","ATL","PBI"],[227,227,160,183,116,150,158,53,140,138,149,158,345,361,257,44,337,152,134,147],[1400,1416,1089,1576,762,719,1065,229,944,733,1028,1005,2475,2565,1389,187,2227,1076,762,1023],[5,5,5,5,6,5,6,6,6,6,6,6,6,6,6,5,6,6,6,6],[15,29,40,45,0,58,0,0,0,0,0,0,0,0,0,59,0,0,0,0],["2013-01-01T10:00:00Z","2013-01-01T10:00:00Z","2013-01-01T10:00:00Z","2013-01-01T10:00:00Z","2013-01-01T11:00:00Z","2013-01-01T10:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T10:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z","2013-01-01T11:00:00Z"],[3.78333333333333,3.78333333333333,2.66666666666667,3.05,1.93333333333333,2.5,2.63333333333333,0.883333333333333,2.33333333333333,2.3,2.48333333333333,2.63333333333333,5.75,6.01666666666667,4.28333333333333,0.733333333333333,5.61666666666667,2.53333333333333,2.23333333333333,2.45],[1.4,1.416,1.089,1.576,0.762,0.719,1.065,0.229,0.944,0.733,1.028,1.005,2.475,2.565,1.389,0.187,2.227,1.076,0.762,1.023]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>year<\/th>\n      <th>month<\/th>\n      <th>day<\/th>\n      <th>dep_time<\/th>\n      <th>sched_dep_time<\/th>\n      <th>dep_delay<\/th>\n      <th>arr_time<\/th>\n      <th>sched_arr_time<\/th>\n      <th>arr_delay<\/th>\n      <th>carrier<\/th>\n      <th>flight<\/th>\n      <th>tailnum<\/th>\n      <th>origin<\/th>\n      <th>dest<\/th>\n      <th>air_time<\/th>\n      <th>distance<\/th>\n      <th>hour<\/th>\n      <th>minute<\/th>\n      <th>time_hour<\/th>\n      <th>air_time_hr<\/th>\n      <th>distance_1000m<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[1,2,3,4,5,6,7,8,9,11,15,16,17,18,20,21]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->
#### group_by() with count()

```r
#count() with group_by()
#this yields data in a `wide` format
flights2a <- t(table(flights[,c('origin', 'dest')]))
head(flights2a) #this last line not necessary - helps with printing to web page
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
#this yields 'tidy' 'long' data
flights2 <- 
  flights %>% 
  group_by(origin, dest) %>% 
  count()
flights2    %>% 
  present_table()  #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-cba4156e0936f6761833" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-cba4156e0936f6761833">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99","100","101","102","103","104","105","106","107","108","109","110","111","112","113","114","115","116","117","118","119","120","121","122","123","124","125","126","127","128","129","130","131","132","133","134","135","136","137","138","139","140","141","142","143","144","145","146","147","148","149","150","151","152","153","154","155","156","157","158","159","160","161","162","163","164","165","166","167","168","169","170","171","172","173","174","175","176","177","178","179","180","181","182","183","184","185","186","187","188","189","190","191","192","193","194","195","196","197","198","199","200","201","202","203","204","205","206","207","208","209","210","211","212","213","214","215","216","217","218","219","220","221","222","223","224"],["EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","EWR","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","JFK","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA","LGA"],["ALB","ANC","ATL","AUS","AVL","BDL","BNA","BOS","BQN","BTV","BUF","BWI","BZN","CAE","CHS","CLE","CLT","CMH","CVG","DAY","DCA","DEN","DFW","DSM","DTW","EGE","FLL","GRR","GSO","GSP","HDN","HNL","HOU","IAD","IAH","IND","JAC","JAX","LAS","LAX","LGA","MCI","MCO","MDW","MEM","MHT","MIA","MKE","MSN","MSP","MSY","MTJ","MYR","OKC","OMA","ORD","ORF","PBI","PDX","PHL","PHX","PIT","PVD","PWM","RDU","RIC","ROC","RSW","SAN","SAT","SAV","SBN","SDF","SEA","SFO","SJU","SLC","SNA","STL","STT","SYR","TPA","TUL","TVC","TYS","XNA","ABQ","ACK","ATL","AUS","BHM","BNA","BOS","BQN","BTV","BUF","BUR","BWI","CHS","CLE","CLT","CMH","CVG","DCA","DEN","DFW","DTW","EGE","FLL","HNL","HOU","IAD","IAH","IND","JAC","JAX","LAS","LAX","LGB","MCI","MCO","MEM","MIA","MKE","MSP","MSY","MVY","OAK","ORD","ORF","PBI","PDX","PHL","PHX","PIT","PSE","PSP","PWM","RDU","RIC","ROC","RSW","SAN","SAT","SDF","SEA","SFO","SJC","SJU","SLC","SMF","SRQ","STL","STT","SYR","TPA","ATL","AVL","BGR","BHM","BNA","BOS","BTV","BUF","BWI","CAE","CAK","CHO","CHS","CLE","CLT","CMH","CRW","CVG","DAY","DCA","DEN","DFW","DSM","DTW","EYW","FLL","GRR","GSO","GSP","HOU","IAD","IAH","ILM","IND","JAX","LEX","MCI","MCO","MDW","MEM","MHT","MIA","MKE","MSN","MSP","MSY","MYR","OMA","ORD","ORF","PBI","PHL","PIT","PWM","RDU","RIC","ROC","RSW","SAV","SBN","SDF","SRQ","STL","SYR","TPA","TVC","TYS","XNA"],[439,8,5022,968,265,443,2336,5327,297,931,973,545,36,104,1424,1754,5026,724,2673,1134,1719,2859,3148,411,3178,110,3793,719,1120,745,15,365,976,1236,3973,1301,23,1242,2010,4912,1,1356,4941,2043,926,867,2633,1094,354,2377,1155,15,56,346,754,6100,584,2351,571,49,2723,559,376,770,1482,1667,513,1437,1134,330,736,4,894,1831,5127,1067,354,825,2516,189,157,2334,315,24,323,291,254,265,1930,1471,1,730,5898,599,1364,3582,371,1221,960,707,2870,742,997,3270,703,732,1166,103,4254,342,714,2661,274,689,2,1299,3987,11262,668,276,5464,1,3314,183,1095,1633,221,312,2326,746,1739,783,976,1933,1249,365,19,1304,3100,249,1679,1339,1603,356,46,2092,8204,329,4752,2113,284,474,1,333,1311,2987,10263,10,375,296,3267,4283,294,126,15,12,864,52,500,2112,6168,2058,138,271,391,4716,3704,4858,158,5040,17,4008,46,486,104,425,1803,2951,110,87,179,1,376,3677,2070,862,142,5781,1525,218,3713,1011,3,95,8857,206,2464,607,1067,278,3581,538,224,761,68,6,217,737,1822,293,2145,77,308,745]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>origin<\/th>\n      <th>dest<\/th>\n      <th>n<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":3},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->
#### spread() / gather() to convert between wide and long (tidy) formats:

```r
flights2b <-
  flights2 %>% 
  as_tibble() %>% 
  spread(key = origin, value = n, fill = 0)

#result in the same formats 
flights2b  %>% 
  present_table()  #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-9a3f939cd8ec148b6e3f" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-9a3f939cd8ec148b6e3f">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"],["ABQ","ACK","ALB","ANC","ATL","AUS","AVL","BDL","BGR","BHM","BNA","BOS","BQN","BTV","BUF","BUR","BWI","BZN","CAE","CAK"],[0,0,439,8,5022,968,265,443,0,0,2336,5327,297,931,973,0,545,36,104,0],[254,265,0,0,1930,1471,0,0,0,1,730,5898,599,1364,3582,371,1221,0,0,0],[0,0,0,0,10263,0,10,0,375,296,3267,4283,0,294,126,0,15,0,12,864]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>dest<\/th>\n      <th>EWR<\/th>\n      <th>JFK<\/th>\n      <th>LGA<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[2,3,4]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
head(flights2)  %>% 
  present_table()
```

<!--html_preserve--><div id="htmlwidget-15a133e729dbf445892d" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-15a133e729dbf445892d">{"x":{"filter":"none","data":[["1","2","3","4","5","6"],["EWR","EWR","EWR","EWR","EWR","EWR"],["ALB","ANC","ATL","AUS","AVL","BDL"],[439,8,5022,968,265,443]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>origin<\/th>\n      <th>dest<\/th>\n      <th>n<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":3},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
[here.](https://ggplot2.tidyverse.org/)

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

### Aesthetic mapping

Adding more variables to a two dimensional scatterplot can be done by mapping the variables to aesthetics (colour, fill, size, shape, alpha)

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
## Warning: Removed 70 rows containing missing values (geom_point).
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

The power of ggplot comes into play when one adds layers on top of other layers. Let's for now look at only at two examples.

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

<img src="Tidyverse_files/figure-html/unnamed-chunk-25-1.png" width="672" />

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

<img src="Tidyverse_files/figure-html/unnamed-chunk-25-2.png" width="672" />

```r
p + stat_summary(fun.data = "mean_se")
```

```
## Warning: Removed 44 rows containing missing values (geom_segment).
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-25-3.png" width="672" />

```r
p + stat_summary(fun.data = "mean_cl_boot")
```

```
## Warning: Computation failed in `stat_summary()`:
## Hmisc package required for this function
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-25-4.png" width="672" />

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
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-27-1.png" width="672" />

```r
p <- p + theme(legend.position = c(0.8, 0.3))
p
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-27-2.png" width="672" />

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
## Warning: Removed 34 rows containing missing values (geom_point).
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-29-1.png" width="672" />

```r
p + ylim(NA, 500) # setting only upper limit
```

<img src="Tidyverse_files/figure-html/unnamed-chunk-29-2.png" width="672" />



## Further readings
___

* The ggplot2 site: http://ggplot2.tidyverse.org
* The ggplot2 book in the making: https://github.com/hadley/ggplot2-book
    - A rendered version of the book: http://www.hafro.is/~einarhj/education/ggplot2
        - needs to be updates
* [R4DS - Data visualisation](http://r4ds.had.co.nz/data-visualisation.html)
* R graphics cookbook: http://www.cookbook-r.com/Graphs
* [Data Visualization Cheat Sheet](https://github.com/rstudio/cheatsheets/raw/master/data-visualization-2.1.pdf)



