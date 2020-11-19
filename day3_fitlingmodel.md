---
title: "Fitting a model to data"
---




# Fitting a model to data

## Introducing likelihood functions

In Gadget, a likelihood function is specified by supplying likelihood components within the likelihood
file, which is referred to by the main file. Individual likelihood component scores are summed together 
after being multiplied by weights to form a total likelihood score, and each likelihood score is defined by the type of likelihood component specified. 
Component types define both the kind of data and likelihood function being calculated for that component.
Although we refer to 'likelihood scores' throughout this description, it should be kept in mind that these
are more accurately sums of log likelihoods, so that the objective function used for model fitting attempts to minimize the total likelihood score.


## Incorporating data (Ling case study cont.)
In introducing likelihood components, we will first go through those used within the ling example
in detail, but only mention the other types as they follow similar patterns of implementation. 
To use Rgadget to set up likelihood files, the first consideration that should be made is what 
data are available that would be useful for creating a likelihood component. These have been 
provided for you here: in the 'data_provided' folder, you will find catch data (as introduced 
with the fleets), as well as survey indices, catch distribution, and 'stock' distribution data. 
Catch distributions include numbers at length as well as numbers at age and length by fleet. 
These therefore include both biological samples in fishery data as well as survey data. 
Each length- or age-bin has been defined as having the lower bound only inclusive, except that 
the lower bound of the smallest bin and the upper bound of the largest bin are open-ended to 
include all values lower or higher, respectively. These numbers are then used within Gadget 
to form proportions among defined bins, which are compared to the same proportions among the 
same bins simulated in the model. Stock distribution data are numbers within each stock, which 
for ling is immature or mature, but could for example be gender-specific stocks. Stock distribution 
numbers are similarly used to form proportions within Gadget.

As we saw when incorporating catch data into fleet files (day 2), certain attributes need to 
be present in order for the proper and internally consistent Gadget aggregation files to be
created alongside these data files. For catch and stock distribution data, these include area,
length, and age aggregations. Even when there is only a single bin, these aggregations need 
to be specified. For example a single area and a single age group is needed for length 
distributions, in addition to the length bins. Note that bins need not be evenly distributed
across the total length range; instead they are highly flexible and can be specified as any
grouping. Therefore the user should be careful to ensure that the definitions make sense and 
that bins do not overlap. In our example below, we show how to add those necessary attributes,
although in reality to do this we also use another R package named 'mfdb' that is aimed at 
database management and data extraction [more on this in day 5]. 


```r
library(tidyverse)
library(Rgadget)

#assuming you are beginning in a fresh session; this information should be in an 
#initialization script

base_dir <- 'ling_model'
vers <- c('01-base')
gd <- normalizePath(gadget.variant.dir(sprintf(paste0("%s/",vers),base_dir)))

ling.imm <- gadgetstock('lingimm',gd)
ling.mat <- gadgetstock('lingmat',gd)
area_file <- read.gadget.file(gd, 'Modelfiles/area')

minage <- ling.imm[[1]]$minage
maxage <- ling.mat[[1]]$maxage
maxlength <- ling.mat[[1]]$maxlength 
minlength <- ling.imm[[1]]$minlength
dl <- ling.imm[[1]]$dl



create_intervals <-  function (prefix, vect) {
  
  x<-
    structure(vect[1:(length(vect)-1)], names = paste0(prefix, vect[1:(length(vect)-1)])) %>% 
    as.list(.) %>% 
    purrr::map(~structure(seq(.,vect[-1][which(vect[1:(length(vect)-1)]==.)],1)[-length(seq(.,vect[-1][which(vect[1:(length(vect)-1)]==.)],1))], 
                          min = ., 
                          max = vect[-1][which(vect[1:(length(vect)-1)]==.)]))
  
  x[[length(x)]] <- c(x[[length(x)]], attributes(x[[length(x)]])$max) %>% 
    structure(., 
              min = min(.), 
              max = max(.))
  
  
  return(x)
}
#just to see what this function does:
create_intervals('len',seq(minlength, maxlength, dl)) %>% .[1:3]
```

```
## $len20
## [1] 20 21 22 23
## attr(,"min")
## [1] 20
## attr(,"max")
## [1] 24
## 
## $len24
## [1] 24 25 26 27
## attr(,"min")
## [1] 24
## attr(,"max")
## [1] 28
## 
## $len28
## [1] 28 29 30 31
## attr(,"min")
## [1] 28
## attr(,"max")
## [1] 32
```


```r
#catch distribution data available:
#length distributions do not regard age bins
ldist.surv <- structure(read_csv('data_provided/ldist_sur.csv'),
                        area = list(area_file[[1]]$areas) %>% set_names(.),
                        length = create_intervals('len',seq(minlength, maxlength, dl)),
                        age = create_intervals('all',seq(minage, maxage, maxage-minage))
)
ldist.lln <- structure(read_csv('data_provided/ldist_lln.csv'),
                       area = list(area_file[[1]]$areas) %>% set_names(.),
                       length = create_intervals('len',seq(minlength, maxlength, dl)),
                       age = create_intervals('all',seq(minage, maxage, maxage-minage))
)
ldist.bmt <- structure(read_csv('data_provided/ldist_bmt.csv'),
                       area = list(area_file[[1]]$areas) %>% set_names(.),
                       length = create_intervals('len',seq(minlength, maxlength, dl)),
                       age = create_intervals('all',seq(minage, maxage, maxage-minage))
)
ldist.gil <- structure(read_csv('data_provided/ldist_gil.csv'),
                       area = list(area_file[[1]]$areas) %>% set_names(.),
                       length = create_intervals('len',seq(minlength, maxlength, dl)),
                       age = create_intervals('all',seq(minage, maxage, maxage-minage))
)

attributes(ldist.surv) %>% 
  purrr::map(head)
```

```
## $names
## [1] "year"   "step"   "area"   "age"    "length" "number"
## 
## $class
## [1] "spec_tbl_df" "tbl_df"      "tbl"         "data.frame" 
## 
## $row.names
## [1] 1 2 3 4 5 6
## 
## $spec
## $spec$cols
## $spec$cols$year
## <collector_double>
## 
## $spec$cols$step
## <collector_double>
## 
## $spec$cols$area
## <collector_double>
## 
## $spec$cols$age
## <collector_character>
## 
## $spec$cols$length
## <collector_character>
## 
## $spec$cols$number
## <collector_double>
## 
## 
## $spec$default
## <collector_guess>
## 
## $spec$skip
## [1] 1
## 
## 
## $area
## $area$`1`
## [1] 1
## 
## 
## $length
## $length$len20
## [1] 20 21 22 23
## attr(,"min")
## [1] 20
## attr(,"max")
## [1] 24
## 
## $length$len24
## [1] 24 25 26 27
## attr(,"min")
## [1] 24
## attr(,"max")
## [1] 28
## 
## $length$len28
## [1] 28 29 30 31
## attr(,"min")
## [1] 28
## attr(,"max")
## [1] 32
## 
## $length$len32
## [1] 32 33 34 35
## attr(,"min")
## [1] 32
## attr(,"max")
## [1] 36
## 
## $length$len36
## [1] 36 37 38 39
## attr(,"min")
## [1] 36
## attr(,"max")
## [1] 40
## 
## $length$len40
## [1] 40 41 42 43
## attr(,"min")
## [1] 40
## attr(,"max")
## [1] 44
## 
## 
## $age
## $age$all3
##  [1]  3  4  5  6  7  8  9 10 11 12 13 14 15
## attr(,"min")
## [1] 3
## attr(,"max")
## [1] 15
```


```r
#age bins needed for age-length distributions
aldist.surv <- structure(read_csv('data_provided/aldist_sur.csv'),
                         area = list(area_file[[1]]$areas) %>% set_names(.),
                         length = create_intervals('len',seq(minlength, maxlength, dl)),
                         age = create_intervals('age',c(minage:11, maxage))
)
aldist.lln <- structure(read_csv('data_provided/aldist_lln.csv'),
                        area = list(area_file[[1]]$areas) %>% set_names(.),
                        length = create_intervals('len',seq(minlength, maxlength, dl)),
                        age = create_intervals('age',c(minage:11, maxage))
)
aldist.bmt <- structure(read_csv('data_provided/aldist_bmt.csv'),
                        area = list(area_file[[1]]$areas) %>% set_names(.),
                        length = create_intervals('len',seq(minlength, maxlength, dl)),
                        age = create_intervals('age',c(minage:11, maxage))
)
aldist.gil <- structure(read_csv('data_provided/aldist_gil.csv'),
                        area = list(area_file[[1]]$areas) %>% set_names(.),
                        length = create_intervals('len',seq(minlength, maxlength, dl)),
                        age = create_intervals('age',c(minage:11, maxage))
)

attributes(aldist.surv)$age %>% head(3)
```

```
## $age3
## [1] 3
## attr(,"min")
## [1] 3
## attr(,"max")
## [1] 4
## 
## $age4
## [1] 4
## attr(,"min")
## [1] 4
## attr(,"max")
## [1] 5
## 
## $age5
## [1] 5
## attr(,"min")
## [1] 5
## attr(,"max")
## [1] 6
```


```r
#stock distribution data available:
matp.surv <- structure(read_csv('data_provided/matp_sur.csv'),
                       area = list(area_file[[1]]$areas) %>% set_names(.),
                       length = create_intervals('len',seq(minlength, maxlength, dl*2)),
                       age = list(mat_ages = ling.mat[[1]]$minage:ling.mat[[1]]$maxage)
)

#attributes(matp.surv)
```

For ling, length-based indices were used by choosing 7 'slices' of abundance indices across the
length range of ling observed. Index bounds are defined as above, generally inclusive of the 
lower bound only, but open-ended for the smallest and largest bins. It is important to note 
that only area and length attributes are included as attributes on these data frames, rather than
age, as in the distributional components. The length attribute allows `gadget_update` to recognize
these data as length-based indices, rather than age-based or acoustic indices, for example. It is
also important to keep in mind
here that each slice will have its own estimated catchability per survey (single data frame below)
and area combination (multiple areas may be within a data frame). 


```r
#survey index data available: 
slices <- 
  list('len20' = c(20,52), 'len52' = c(52,60), 'len60' = c(60,72), 
       'len72' = c(72,80), 'len80' = c(80,92), 'len92' = c(92,100), 
       'len100' = c(100,160) )

# just to illustrate slices:

ldist.surv %>% 
  mutate(length = substring(length, 4) %>% as.numeric) %>% 
  filter(year %in% c(2000,2005,2010,2015)) %>% 
  group_by(year,length) %>% 
  summarise(n = sum(number)) %>% 
  ggplot(aes(x = length, y = n)) + geom_line() + 
  geom_vline(aes(xintercept = length), 
             lty = 2, col = 'orange', 
             data = slices %>% 
               bind_rows() %>% 
               t() %>% .[-1,1] %>% 
               tibble(length = .)) + 
  facet_wrap(~year)
```

<img src="day3_fitlingmodel_files/figure-html/unnamed-chunk-4-1.png" width="672" />


```r
# set up aggregation info for length-based survey indices
SI1 <- structure(read_csv('data_provided/SI1.csv'),
                 area = list(area_file[[1]]$areas) %>% set_names(.),
                 length = create_intervals('len', slices[[1]]))
SI2 <- structure(read_csv('data_provided/SI2.csv'),
                 area = list(area_file[[1]]$areas) %>% set_names(.),
                 length = create_intervals('len', slices[[2]]))
SI3 <- structure(read_csv('data_provided/SI3.csv'),
                 area = list(area_file[[1]]$areas) %>% set_names(.),
                 length = create_intervals('len', slices[[3]]))
SI4 <- structure(read_csv('data_provided/SI4.csv'),
                 area = list(area_file[[1]]$areas) %>% set_names(.),
                 length = create_intervals('len', slices[[4]]))
SI5 <- structure(read_csv('data_provided/SI5.csv'),
                 area = list(area_file[[1]]$areas) %>% set_names(.),
                 length = create_intervals('len', slices[[5]]))
SI6 <- structure(read_csv('data_provided/SI6.csv'),
                 area = list(area_file[[1]]$areas) %>% set_names(.),
                 length = create_intervals('len', slices[[6]]))
SI7 <- structure(read_csv('data_provided/SI7.csv'),
                 area = list(area_file[[1]]$areas) %>% set_names(.),
                 length = create_intervals('len', slices[[7]]))
```

### Exercise

* Change the aggregation levels of the age-length distribution data so that data are compared to model results within the bins 3 - 6, 7, 8, 9, 10 - 11, and 12 - 15.


## Setting up likelihood components
Using Rgadget, writing the files that specify the likelihood componenets is straightforward. 
When calling `gadgetlikelihood` and then writing it with `write.gadget.file`, a likelihood file
is created within R and written to disc.  The likelihood file contains a list of likelihood 
component specifications, and within each component is where the likelihood function, data, and
weighting of the likelihood component is specified.

Here we start with the distributional components. In all cases, each component receives a distinct 
name (to be referenced later so keep them short and distinct), weights (1 to yield equal weights 
for now), data as imported above, and the fleet names and stock names to which these data apply. 
As a default, Rgadget specifies a sum of squares function to calculate the likelihood score
(`sumofsquares`), although a variety of other functions are possible, including one for stratified 
sum of squares (`stratified`), multinomial function (`multinomial`), pearson function (`pearson`), 
gamma function (`gamma`), log function (`log`), multivariate normal function (`mvn`) or a 
multivariate logistic function (`mvlogistic`). Many of these functions have been tailored for 
specific data situations (e.g., including tagging or predation data into a likelihood component). 
More on these functions can be read in the [Gadget User Guide](https://hafro.github.io/gadget/docs/userguide). To change the default setting to 
the stratified sum of squares, for example, one would include an additional argument `function = 'stratified',` to the `gadget_update` call. 


```r
lik <-
  gadgetlikelihood('likelihood',gd,missingOkay = TRUE) %>% 
  gadget_update("catchdistribution",
                name = "ldist.surv",
                weight = 1,
                data = ldist.surv,
                fleetnames = c("surv"),
                stocknames = c("lingimm","lingmat")) %>% 
  gadget_update("catchdistribution",
                name = "aldist.surv",
                weight = 1,
                data = aldist.surv, 
                fleetnames = c("surv"),
                stocknames = c("lingimm","lingmat")) %>% 
  gadget_update("catchdistribution",
                name = "ldist.lln",
                weight = 1,
                data = ldist.lln, 
                fleetnames = c("lln"),
                stocknames = c("lingimm","lingmat")) %>% 
  gadget_update("catchdistribution",
                name = "aldist.lln",
                weight = 1,
                data = aldist.lln,
                fleetnames = c("lln"),
                stocknames = c("lingimm","lingmat")) %>% 
  gadget_update("catchdistribution",
                name = "ldist.gil",
                weight = 1,
                data = ldist.gil,
                fleetnames = c("gil"),
                stocknames = c("lingimm","lingmat")) %>% 
  gadget_update("catchdistribution",
                name = "aldist.gil",
                weight = 1,
                data = aldist.gil,
                fleetnames = c("gil"),
                stocknames = c("lingimm","lingmat")) %>% 
  gadget_update("catchdistribution",
                name = "ldist.bmt",
                weight = 1,
                data = ldist.bmt,
                fleetnames = c("bmt"),
                stocknames = c("lingimm","lingmat")) %>% 
  gadget_update("catchdistribution",
                name = "aldist.bmt",
                weight = 1,
                data = aldist.bmt,
                fleetnames = c("bmt"),
                stocknames = c("lingimm","lingmat")) %>% 
  gadget_update("stockdistribution",
                name = "matp.surv",
                weight = 1,
                data = matp.surv,
                fleetnames = c("surv"),
                stocknames =c("lingimm","lingmat")) 

lik
```

```
## ; Generated by Rgadget 0.5
## ; 
## [component]
## name	ldist.surv
## weight	1
## type	catchdistribution
## datafile	Data/catchdistribution.ldist.surv.sumofsquares
## function	sumofsquares
## aggregationlevel	0
## overconsumption	0
## epsilon	10
## areaaggfile	Aggfiles/catchdistribution.ldist.surv.area.agg
## ageaggfile	Aggfiles/catchdistribution.ldist.surv.age.agg
## lenaggfile	Aggfiles/catchdistribution.ldist.surv.len.agg
## fleetnames	surv
## stocknames	lingimm	lingmat
## ; 
## [component]
## name	aldist.surv
## weight	1
## type	catchdistribution
## datafile	Data/catchdistribution.aldist.surv.sumofsquares
## function	sumofsquares
## aggregationlevel	0
## overconsumption	0
## epsilon	10
## areaaggfile	Aggfiles/catchdistribution.aldist.surv.area.agg
## ageaggfile	Aggfiles/catchdistribution.aldist.surv.age.agg
## lenaggfile	Aggfiles/catchdistribution.aldist.surv.len.agg
## fleetnames	surv
## stocknames	lingimm	lingmat
## ; 
## [component]
## name	ldist.lln
## weight	1
## type	catchdistribution
## datafile	Data/catchdistribution.ldist.lln.sumofsquares
## function	sumofsquares
## aggregationlevel	0
## overconsumption	0
## epsilon	10
## areaaggfile	Aggfiles/catchdistribution.ldist.lln.area.agg
## ageaggfile	Aggfiles/catchdistribution.ldist.lln.age.agg
## lenaggfile	Aggfiles/catchdistribution.ldist.lln.len.agg
## fleetnames	lln
## stocknames	lingimm	lingmat
## ; 
## [component]
## name	aldist.lln
## weight	1
## type	catchdistribution
## datafile	Data/catchdistribution.aldist.lln.sumofsquares
## function	sumofsquares
## aggregationlevel	0
## overconsumption	0
## epsilon	10
## areaaggfile	Aggfiles/catchdistribution.aldist.lln.area.agg
## ageaggfile	Aggfiles/catchdistribution.aldist.lln.age.agg
## lenaggfile	Aggfiles/catchdistribution.aldist.lln.len.agg
## fleetnames	lln
## stocknames	lingimm	lingmat
## ; 
## [component]
## name	ldist.gil
## weight	1
## type	catchdistribution
## datafile	Data/catchdistribution.ldist.gil.sumofsquares
## function	sumofsquares
## aggregationlevel	0
## overconsumption	0
## epsilon	10
## areaaggfile	Aggfiles/catchdistribution.ldist.gil.area.agg
## ageaggfile	Aggfiles/catchdistribution.ldist.gil.age.agg
## lenaggfile	Aggfiles/catchdistribution.ldist.gil.len.agg
## fleetnames	gil
## stocknames	lingimm	lingmat
## ; 
## [component]
## name	aldist.gil
## weight	1
## type	catchdistribution
## datafile	Data/catchdistribution.aldist.gil.sumofsquares
## function	sumofsquares
## aggregationlevel	0
## overconsumption	0
## epsilon	10
## areaaggfile	Aggfiles/catchdistribution.aldist.gil.area.agg
## ageaggfile	Aggfiles/catchdistribution.aldist.gil.age.agg
## lenaggfile	Aggfiles/catchdistribution.aldist.gil.len.agg
## fleetnames	gil
## stocknames	lingimm	lingmat
## ; 
## [component]
## name	ldist.bmt
## weight	1
## type	catchdistribution
## datafile	Data/catchdistribution.ldist.bmt.sumofsquares
## function	sumofsquares
## aggregationlevel	0
## overconsumption	0
## epsilon	10
## areaaggfile	Aggfiles/catchdistribution.ldist.bmt.area.agg
## ageaggfile	Aggfiles/catchdistribution.ldist.bmt.age.agg
## lenaggfile	Aggfiles/catchdistribution.ldist.bmt.len.agg
## fleetnames	bmt
## stocknames	lingimm	lingmat
## ; 
## [component]
## name	aldist.bmt
## weight	1
## type	catchdistribution
## datafile	Data/catchdistribution.aldist.bmt.sumofsquares
## function	sumofsquares
## aggregationlevel	0
## overconsumption	0
## epsilon	10
## areaaggfile	Aggfiles/catchdistribution.aldist.bmt.area.agg
## ageaggfile	Aggfiles/catchdistribution.aldist.bmt.age.agg
## lenaggfile	Aggfiles/catchdistribution.aldist.bmt.len.agg
## fleetnames	bmt
## stocknames	lingimm	lingmat
## ; 
## [component]
## name	matp.surv
## weight	1
## type	stockdistribution
## datafile	Data/stockdistribution.matp.surv.sumofsquares
## function	sumofsquares
## overconsumption	0
## epsilon	10
## areaaggfile	Aggfiles/stockdistribution.matp.surv.area.agg
## ageaggfile	Aggfiles/stockdistribution.matp.surv.age.agg
## lenaggfile	Aggfiles/stockdistribution.matp.surv.len.agg
## fleetnames	surv
## stocknames	lingimm	lingmat
```

Note here that Rgadget automatically creates references to necessary data files ('Data/...') and
aggregation files ('Agg/...') that define the bin structure as defined by data attributes 
(see previous section). When `write.gadget.file` is finally called after we are done adding 
all likelihood components, these data and agg files will be written alongside this likelihood 
file, and a reference to this likelihood file will also be drawn within the 'main' file. 

You can also see how individual aggregation files will be printed by e.g.:

```r
lik[[2]]$ageaggfile
```

```
## ; Generated by Rgadget 0.5
## age3	3
## age4	4
## age5	5
## age6	6
## age7	7
## age8	8
## age9	9
## age10	10
## age11	11	12	13	14	15
```
which gives you the age aggregation for the second likelihood component.

### Setting up survey indices

Incorporating survey index components is very similar except that 1) the fact that the survey 
index is length-based is determined by the length attribute of the data frame, which sets the
argument `si_type` to a value of `lengths`, and 2) a catchability function is also specified
under the argument `'fittype'`. In addition, the argument `biomass` has a default setting of 0,
signifying  a numbers-based index (rather than a biomass-based index, which has a value of 1). 
Other options for `si_type` can be read about in the [Gadget User Guide](https://hafro.github.io/gadget/docs/userguide), and `ages`, `fleets`, `acoustic`, and `effort`.

The catchability function defines the type of linear regression to be used to calculate 
the likelihood score. Options include a linear fit on the orignal or log scale (`linearfit` 
or `loglinearfit`), linear fit with a fixed slope on the original or log scale (`fixedslopelinearfit`
or `fixedslopeloglinearfit`), linear fit with a fixed intercept on the original or log scale
(`fixedinterceptlinearfit` or `fixedinterceptlinearfit`), or a linear/loglinear function with 
both the slope and intercept fixed (`fixedlinearfit` or `fixedloglinearfit`). In the first set 
of cases (linear or loglinear fits), two parameters would be estimated; in the next two sets of 
cases, only a single parameter is estimated (slope or intercept, whichever is not fixed). In 
the last set of cases (fixed liner or loglinear fits), no parameters are estimated. Whenever a 
parameter is fixed, its value needs to be included as an additional argument to `gadget_update`.
For example, catchability of the indices of smaller sized fish below are estimated using a 
log linear fit with both slopes and intercepts estimated, but catchabilities for indices of 
larger sized fish are calculated using log linear fits with fixed slopes. The slopes are 
fixed to a value of 1, so the argument `slope = 1` is included in the `gadget_update` call.

Notice that, unlike the distributional likelihood components, a fleet is not specified 
for the survey indices, unless `si_type` is set to `fleets`, `effort`, `acoustic` (rather than `length` as in our example). 
When indices are not length- or age-based, a single catchability is estimated, rather 
than the series of catchabilities estimated for each age or length index series. 
Each survey index is 
matched to stock size observations at a given time and area; therefore, if there are two 
length- or age-based survey index series with the same time and area, they can each be 
incorporated as separate likelihood components as long as they have different names. 


```r
lik <-
  lik %>%  
  gadget_update("surveyindices",
                name = paste0("si.", names(slices)[1]),
                weight = 1,
                data = SI1,
                fittype = 'loglinearfit',
                stocknames = c("lingimm","lingmat")) %>% 
  gadget_update("surveyindices",
                name = paste0("si.", names(slices)[2]),
                weight = 1,
                data = SI2,
                fittype = 'loglinearfit',
                stocknames = c("lingimm","lingmat")) %>% 
  gadget_update("surveyindices",
                name = paste0("si.", names(slices)[3]),
                weight = 1,
                data = SI3,
                fittype = 'fixedslopeloglinearfit',
                slope=1,
                stocknames = c("lingimm","lingmat")) %>% 
  gadget_update("surveyindices",
                name = paste0("si.", names(slices)[4]),
                weight = 1,
                data = SI4,
                fittype = 'fixedslopeloglinearfit',
                slope=1,
                stocknames = c("lingimm","lingmat")) %>% 
  gadget_update("surveyindices",
                name = paste0("si.", names(slices)[5]),
                weight = 1,
                data = SI5,
                fittype = 'fixedslopeloglinearfit',
                slope=1,
                stocknames = c("lingimm","lingmat")) %>% 
  gadget_update("surveyindices",
                name = paste0("si.", names(slices)[6]),
                weight = 1,
                data = SI6,
                fittype = 'fixedslopeloglinearfit',
                slope=1,
                stocknames = c("lingimm","lingmat")) %>% 
  gadget_update("surveyindices",
                name = paste0("si.", names(slices)[7]),
                weight = 1,
                data = SI7,
                fittype = 'fixedslopeloglinearfit',
                slope=1,
                stocknames = c("lingimm","lingmat")) 
lik 
```



Finally, there are two components to the likelihood that do not incorporate data but 
are instead used to ensure that the optimisation search algorithm remains within 
reasonable ranges of the defined model. The first component provides penalties to for 
exceeding parameter bounds as set by the user in the input parameter file. 
In this example, the weight is set to 0.5, 
but see the troubleshooting page for cases in which it may be wise to set this weight
higher. The data frame provided to this likelihood component specifies the power and
parameter weights supplied if the parameter value exceeds its upper and lower bounds. 
If the likelihood of a parameter exceeds either the upper or lower bound, 
the distance between the bound and the parameter value is squared and multiplied by the
parameter weights 10 000; then the sum of these scores across all parameters is 
multiplied by the 0.5 weighting before being summed along with the other 
likelihood components to form the total. 

### Penalty functions

Understocking introduces a penalty when there are insufficent prey to met the requirements
of the predators. For example, if landings of the fleets exceeds available biomass, 
then the penalty is applied. The understocking penalty likelihood is then defined as 
the sum of the number of prey that are 'missing', raised to a power set by default
to 2, and multiplied by the likelihood weight of 100 as indicated below.


```r
lik <-
  lik %>% 
  gadget_update("penalty",
                name = "bounds",
                weight = "0.5",
                data = data.frame(
                  switch = c("default"),
                  power = c(2),
                  upperW=10000,
                  lowerW=10000,
                  stringsAsFactors = FALSE)) %>%
  gadget_update("understocking",
                name = "understocking",
                weight = "100")

lik %>% 
  write.gadget.file(gd)
```

Notice that when the likelihood file is written, so are all the supporting 
aggregation files under the 'Aggfiles' folder.

## Fitting a Gadget model to data 

Now that all data and likelihood components are incorporated, it is possible to run `gadget_optimise` to run a fitting procedure. Like any other optimisation routine, what is still needed are 1) starting values for the parameters, and 2) optimisation routine settings.

### Create starting values

If we start here with the same simple `gadget_evaluate` simulation as in day 2 of the 
ling model, we can see that a file called 'params.out' is automatically generated
(same timestamp as the simple_log). However, if you open this file, is shows that 
each parameter was given a value of 1 with bounds set to {-9999, 9999} and no 
optimisation (0). Therefore, this simulation was run with very unrealistic parameters.
Obviously this is not a helpful run in itself, but it is at least useful for 
conveniently generating an initial parameter file with the correct Gadget 
structure containing all the parameters specified throughout the Gadget model files. 


```r
gadget_evaluate(gd,log = 'ling_log')
```

```
## [1] "/home/runner/work/gadget-course/gadget-course/ling_model/01-base"
```

```r
read.gadget.parameters(paste0(gd,'/params.out'))  %>% 
  DT::datatable(.)  #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-36e8a517eb958fb6b9f8" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-36e8a517eb958fb6b9f8">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81"],["ling.Linf","ling.k","ling.walpha","ling.wbeta","ling.bbin","lingimm.M","lingimm.init.scalar","ling.init.F","lingimm.init.3","lingimm.init.4","lingimm.init.5","lingimm.init.6","lingimm.init.7","lingimm.init.8","lingimm.init.9","lingimm.init.10","ling.recl","ling.mat1","ling.mat2","ling.rec.scalar","ling.rec.1982","ling.rec.sd","ling.rec.1983","ling.rec.1984","ling.rec.1985","ling.rec.1986","ling.rec.1987","ling.rec.1988","ling.rec.1989","ling.rec.1990","ling.rec.1991","ling.rec.1992","ling.rec.1993","ling.rec.1994","ling.rec.1995","ling.rec.1996","ling.rec.1997","ling.rec.1998","ling.rec.1999","ling.rec.2000","ling.rec.2001","ling.rec.2002","ling.rec.2003","ling.rec.2004","ling.rec.2005","ling.rec.2006","ling.rec.2007","ling.rec.2008","ling.rec.2009","ling.rec.2010","ling.rec.2011","ling.rec.2012","ling.rec.2013","ling.rec.2014","ling.rec.2015","ling.rec.2016","ling.rec.2017","ling.rec.2018","lingmat.M","lingmat.init.scalar","lingmat.init.5","lingmat.init.6","lingmat.init.7","lingmat.init.8","lingmat.init.9","lingmat.init.10","lingmat.init.11","lingmat.init.12","lingmat.init.13","lingmat.init.14","lingmat.init.15","lingmat.walpha","lingmat.wbeta","ling.surv.alpha","ling.surv.l50","ling.lln.alpha","ling.lln.l50","ling.bmt.alpha","ling.bmt.l50","ling.gil.alpha","ling.gil.l50"],[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999,-9999],[9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>switch<\/th>\n      <th>value<\/th>\n      <th>lower<\/th>\n      <th>upper<\/th>\n      <th>optimise<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[2,3,4,5]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

Now that the structure is set, it is much easier to change the bounds and starting 
values to more realistic ones using `init_guess`. This function uses the `grepl`
function internally to match names, so that large chunks of parameters with similar
names can have their bounds similarly changed.


```r
lw_pars <- c(0.00000228, 3.20) #same values as in day 2

## update the input parameters with sane initial guesses
read.gadget.parameters(sprintf('%s/params.out',gd)) %>% 
  init_guess('rec.[0-9]|init.[0-9]',1,0.001,1000,1) %>%
  init_guess('recl',12,4,20,1) %>% 
  init_guess('rec.sd',5, 4, 20,1) %>% 
  init_guess('Linf',160, 100, 200,1) %>% 
  init_guess('k$',90, 40, 100,1) %>% 
  init_guess('bbin',6, 1e-08, 100, 1) %>% 
  init_guess('alpha', 0.5,  0.01, 3, 1) %>% 
  init_guess('l50',50,10,100,1) %>% 
  init_guess('walpha',lw_pars[1], 1e-10, 1,0) %>% 
  init_guess('wbeta',lw_pars[2], 2, 4,0) %>% 
  init_guess('M$',0.15,0.001,1,0) %>% 
  init_guess('rec.scalar',400,1,500,1) %>% 
  init_guess('init.scalar',200,1,300,1) %>% 
  init_guess('mat2',60,0.75*60,1.25*60,1) %>% 
  init_guess('mat1',70,  10, 200, 1) %>% 
  init_guess('init.F',0.4,0.1,1,1) %>% 
  write.gadget.parameters(.,file=sprintf('%s/params.in',gd))

read.gadget.parameters(sprintf('%s/params.in',gd))  %>% 
  DT::datatable(.)  #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-7910311647aee94915c1" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-7910311647aee94915c1">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81"],["ling.Linf","ling.k","ling.walpha","ling.wbeta","ling.bbin","lingimm.M","lingimm.init.scalar","ling.init.F","lingimm.init.3","lingimm.init.4","lingimm.init.5","lingimm.init.6","lingimm.init.7","lingimm.init.8","lingimm.init.9","lingimm.init.10","ling.recl","ling.mat1","ling.mat2","ling.rec.scalar","ling.rec.1982","ling.rec.sd","ling.rec.1983","ling.rec.1984","ling.rec.1985","ling.rec.1986","ling.rec.1987","ling.rec.1988","ling.rec.1989","ling.rec.1990","ling.rec.1991","ling.rec.1992","ling.rec.1993","ling.rec.1994","ling.rec.1995","ling.rec.1996","ling.rec.1997","ling.rec.1998","ling.rec.1999","ling.rec.2000","ling.rec.2001","ling.rec.2002","ling.rec.2003","ling.rec.2004","ling.rec.2005","ling.rec.2006","ling.rec.2007","ling.rec.2008","ling.rec.2009","ling.rec.2010","ling.rec.2011","ling.rec.2012","ling.rec.2013","ling.rec.2014","ling.rec.2015","ling.rec.2016","ling.rec.2017","ling.rec.2018","lingmat.M","lingmat.init.scalar","lingmat.init.5","lingmat.init.6","lingmat.init.7","lingmat.init.8","lingmat.init.9","lingmat.init.10","lingmat.init.11","lingmat.init.12","lingmat.init.13","lingmat.init.14","lingmat.init.15","lingmat.walpha","lingmat.wbeta","ling.surv.alpha","ling.surv.l50","ling.lln.alpha","ling.lln.l50","ling.bmt.alpha","ling.bmt.l50","ling.gil.alpha","ling.gil.l50"],[160,90,2.28e-06,3.2,6,0.15,200,0.4,1,1,1,1,1,1,1,1,12,70,60,400,1,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0.15,200,1,1,1,1,1,1,1,1,1,1,1,2.28e-06,3.2,0.5,50,0.5,50,0.5,50,0.5,50],[100,40,1e-10,2,1e-08,0.001,1,0.1,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,4,10,45,1,0.001,4,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,1,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.001,1e-10,2,0.01,10,0.01,10,0.01,10,0.01,10],[200,100,1,4,100,1,300,1,1000,1000,1000,1000,1000,1000,1000,1000,20,200,75,500,1000,20,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1,300,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1,4,3,100,3,100,3,100,3,100],[1,1,0,0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>switch<\/th>\n      <th>value<\/th>\n      <th>lower<\/th>\n      <th>upper<\/th>\n      <th>optimise<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[2,3,4,5]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

Now is a good point to scan the resulting 'params.in' file to make sure that
a parameter was not forgotten and left with default values and bounds.

#### Exercise
* Suppose that age sampling was done so that the same sampling effort was spread across all 
ages equally (roughly 30 fish per length range to attain roughly 30 age samples per age).
Change the likelihood component function for age-length data to the appropriate function.

* Change the survey indices to be biomass indices using `gadget_update`.

* Use `init_guess` to change the bounds of only one set of selectivity parameters.


## Set optimisation routine

To run an optimisation via `gadget_optimize` is simple, the user provides an input parameter file with starting values
(below as `params.in = 'params.in'`), and providing a file name to which final parameter
values should be written (below as `params.out = 'params.init'`).


```r
timestamp()
gadget_optimize(gd,params.in = 'params.in', params.out = 'params.init')
timestamp()
```

Now that reasonable bounds and starting values have been set for an 
optimisation run, default settings can be used to run a short and simple
Gadget optimisation. If you open the `params.init` file, comments can be found 
at the top that detail the computer and timing of the run (as in a simulation run),
as well as optimisation information (something like 'Hooke & Jeeves algorithm ran 
for 1039 function evaluations'), the likelihood value at the end '1e+10' and a 
reason for stopping ('because the maximum number of function evaluations was reached').
You can also see from the timestamps above that this run took roughly 30 seconds,
depending on the computer being used. 

Obviously, the default settings for optimisation (1000 function evaluations 
using the Hooke and Jeeves algorithm), are insufficient to find a reasonable 
optimum. Gadget can also take quite a while to optimise a model (~ 6 hours for
ling on a very fast computer). Therefore, it is best to plan ahead of time on 
which computer and when a model will be optimised, as well as which optimisation
methods will be used. 

To change from the default settings, an opimisation file needs to be provided
to `gadget_optimize` via the `control` argument. This is the file we provide for 
demonstration: it shows that we have implemented 3 consecutive optimisation 
routines. The first begins with simulated annealing (and parameter settings 
needed for it as well as a seed), followed by a Hooke and Jeeves algorithm 
that begins where simulated annealing leaves off, and finally a BFGS algorithm.
The three routines are listed in this manner to consecutively to transition from
a broader global search (simulated annealing) to one that provides faster 
(Hooke and Jeeves) and more precise (BFGS) results, in an attempt to make the 
search more efficient. These three are the only algorithms currently implemented, 
but others are in a development phase. Also note that a seed is set in the 
beginning algorithm: it is good practice to both use random starting values
as well as a set seed to check for possible optimisation problems. More 
information on parameters specific to each algorithm can be found in the [Gadget User Guide](https://hafro.github.io/gadget/docs/userguide).

Each algorithm also has a low maximum number of iterations set in the 
optimisation file below, which is clearly not enough to be realistic: realistic 
values used for ling are given as notes within the optinfofile and are not read 
below. However, the each model presents new challenges to the search algorithm, 
so in some complex cases it may be necessary to rely mostly on simulating annealing, 
whereas in other more well-defined cases it may be possible to rely mostly on the
faster algorithms. At this point in development, speeding Gadget runs is mostly 
done by using computers with multiple cores and faster processors. 


```r
optinfo <- read.gadget.file('data_provided', 'optinfofile')
optinfo
```

```
## ; Generated by Rgadget 0.5
## [simann]
## simanniter	200		; number of simulated annealing iterations, normally set to 1000000 for ling
## simanneps	0.001		; minimum epsilon, simann halt criteria
## t	30000000		; simulated annealing initial temperature
## rt	0.85		; temperature reduction factor
## nt	2		; number of loops before temperature adjusted
## ns	5		; number of loops before step length adjusted
## vm	1		; initial value for the maximum step length
## cstep	2		; step length adjustment factor
## lratio	0.3		; lower limit for ratio when adjusting step length
## uratio	0.7		; upper limit for ratio when adjusting step length
## check	4		; number of temperature loops to check
## seed	5908
## [hooke]
## hookeiter	100		; number of hooke & jeeves iterations, normally set to 40000 for ling
## hookeeps	1e-04		; minimum epsilon, hooke & jeeves halt criteria
## rho	0.5		; value for the resizing multiplier
## lambda	0		; initial value for the step length
## [bfgs]
## bfgsiter	100		; number of bfgs iterations, normally set to 10000 for ling
## bfgseps	0.01		; minimum epsilon, bfgs halt criteria
## sigma	0.01		; armijo convergence criteria
## beta	0.3		; armijo adjustment factor
## 	
```

Here, we have implemented a fitting procedure that begins where the 
last default optimisation values left off (in the 'params.init' file). 
The 'params.opt' file will therefore be the result of a longer and more
well-defined search as described by the 'optinfofile'.


```r
timestamp()
gadget_optimize(gd,params.in = 'params.in', params.out = 'params.init', control = optinfo)
timestamp()
```

#### Exercise
* Try changing the parameter starting values to the params.forsim file within the 'data_provided' folder. Does the optimisation finish any quicker?


## Using the iterative reweighting function to fit a Gadget statistical model

The total objective function used the modeling process combines
equations \ref{eq:SSSI} to \ref{eq:SSalk} using the following formula:

\begin{equation}\label{eq:loglik}
l^{T} = \sum_g  w_{gf}^{SI}
l_{g,S}^{SI} + \sum_{f\in \{S,T,G,L\}} \left(
w_{f}^{LD}  l_{f}^{LD} + w_{f}^{AL}
l_{f}^{AL}\right) + w^{M}l^{M}
\end{equation}
where $f=S,T,G$ or $L$ denotes the spring survey, trawl, gillnet and
longline fleets respectively and $w$'s are the weights assigned to each likelihood components. 

The weights, $w_i$, are necessary for several reasons. First of all it
is used to to prevent some components from dominating the likelihood
function. When one data source dominates, the model fits that one exactly
and ignores information from the other data sources. Another would be to 
reduce the effect of low quality
data. It can be used as an a priori estimates of the variance in each
subset of the data. 


Assigning likelihood weights is not a trivial matter; it has in the past
been the most time-consuming part of developing a Gadget model. Historicall this was
been done using some form of 'expert judgement'. General heuristics
have recently been developed to estimated these weights
objectively. Here the iterative re--weighting heuristic introduced by
@stefansson2003issues, and subsequently implemented in
@taylor2007simple, is used. Rgadget implements this heuristing using the `gadget.iterative` function.


The general idea behind the iterative re-weighting is to assign the
inverse variance of the fitted residuals as component weights. This pattern 
suggests that the more variable the residuals are from a particular data
source, the less weight it should receive. The
variances, and hence the final weights, are calculated according the
following algorithm: 

1. Calculate the initial sums of squares (SS) given the initial
parameterization for all likelihood components. Assign the inverse SS
as the initial weight for all likelihood components, resulting in a total initial score of 1 for each component. 
2. For each likelihood component, do an optimization run with
the initial weighted SS for that component set to 10 000. This run represents
a model fit where essentially only that component contributes to model
fitting, and therefore that component receives the best fit achievable.
Then estimate the residual variance using the resulting SS of that component divided
by the degrees of freedom ($df^*$), i.e. $\hat{\sigma}^2 = \frac{SS}{df^*}$.
3.  After the optimization of each component separately, set the final weight 
for each component to be the inverse of the estimated variance from the step above
(weight $=1/\hat{\sigma}^2$). 


The number of non-zero data-points ($df^{*}$) is used as a proxy for the degrees 
of freedom. While this may be a satisfactory proxy for larger data sets, it could be
a gross overestimate of the degrees of freedom for smaller data sets. 
In particular, if the survey indices are weighed on their own while the
annual recruitment is estimated, they could be over-fitted. In general, 
problem such as these can be solved with component grouping. Component grouping
is achieved in step 2: likelihood components that should behave similarly, such
as survey indices representing similar age ranges, are weighted and optimized 
together. 

The `gadget.iterative` function implements the iterative reweighting heuristic and is invoked in the following manner:

```r
## In its current version, gadget.iterative needs to be run from within the
## directory that contains the Gadget model
old <- getwd()
file.copy(sprintf('%s/optinfofile','data_provided'),gd)
```

```
## [1] TRUE
```

```r
setwd(gd)

## run gadget iterative
## WARNING: Each time gadget.iterative runs with the given optinfofile,
## it takes 11 mins to run on a reasonably fast computer with 2 cores.
timestamp() 
```

```
## ##------ Thu Nov 19 10:47:35 2020 ------##
```

```r
run <- gadget.iterative() # This works for Linux or Mac, but Windows throws an error due to incompatability in the parallel package
#run <- gadget.iterative(run.serial = TRUE) #This will work, but will take several times as long to run. For demonstration purposes, it is highly recommended to reduce the number of iterations in the optinfofile to a very small number for all algorithms.
timestamp()
```

```
## ##------ Thu Nov 19 10:51:46 2020 ------##
```


This will start an iterative run that will estimate the weights for all likelihood
components, and run a final optimisation run with the resulting likelihood weights.
Penalising likelihood components, such as `boundlikelihood` and `understocking`, are 
left as is. As the iterative reweighting requires several optimisation runs,
`gadget.iterative` tries to spread these runs across the available cores on your 
computer. In the case of the number of cores lower than the number of runs, the excess
runs will wait until a core becomes available. The resulting parameter estimates are
then stored in a folder called `WGTS` in your model directory, where the file 
`params.final` contains the final parameter estimate.  

When running `gadget.iterative` with standard setting you assume that all 
data sets have enough data to allow all parameters to be estimated without 
overfitting the data. It is not always the case that this is appropriate. 
For instance survey indices have in general only one data point per year, 
step and size group, and when estimating annual recruitment this usually 
leads overfitting of that particular component when heavily emphasized. 
Similar problem can arise when only one year, or a few disjoint years, 
worth of compositional data is supplied to the likelihood function. To 
account for this issue the user can group similar likelihood components 
together using the `grouping` argument in the `gadget.iterative` function.
When estimating annual recruitment, for example, this ensures that at least 
two data points are available to estimate each of the recruitment parameters.
In the case of Ling, the survey indices were split into two groups, sizes 20 
to 72 cm and 72 to 160 cm, and the compositional data from the commercial 
trawl and gillnet fleets were grouped due to a low number of data points. 

Note that when rerunning gadget.reiterative, it is best for file management 
purposes to delete the old 'WGTS' folder before reruinning `gadget.iterative`, 
for example by running `unlink("WGTS", recursive=TRUE)`.
Alternatively, if both sets of results should be kept, then the 'WGTS' folder
should be renamed by changing the default argument `wgts = 'WGTS'`. This is
especially important when visualizing model results in the next step using
`gadget.fit`.


```r
run <- gadget.iterative(grouping = list(sind1=c('si.len20','si.len52','si.len60'),
                                        sind2=c('si.len72','si.len80','si.len92',
                                                'si.len100'),
                                        comm=c('ldist.gil','ldist.bmt',
                                               'aldist.gil','aldist.bmt')),
                        wgts = 'WGTS2') # if working on Windows, can run with argument run.serial = TRUE (see above)
```

Note that if a likelihood component is not present in the defined 
grouping list it is assumed that the component is treated individually. 
<!-- Sometimes this is not enough to prevent overfitting and therefore the  -->
<!-- user can define a maximum weight of sorts by defining the minimum CV  -->
<!-- for survey indices used for weight assignment. This is done using the  -->
<!-- `cv.floor` argument: -->

<!-- ```{r eval=FALSE} -->
<!-- run <- gadget.iterative(cv.floor = 0.2, -->
<!--                         wgts = 'WGTS3') # if working on Windows, can run with argument run.serial = TRUE (see above) -->
<!-- ``` -->

<!-- The `cv.floor` argument is often used after the final optimisation  -->
If the final run has crashed it is convenient to be able to pick up the "thread" 
where the run crashed and resume the final optimisation. The `resume.final` 
switch allows for this and essentially only runs the last optimisation, thereby
assuming that the preceding steps have been completed:


```r
run <- gadget.iterative(resume.final = TRUE,
                        wgts = 'WGTS')  # if working on Windows, can run with argument run.serial = TRUE (see above)
```

Related to `resume.final` there are the `run.final` and `run.serial` arguments 
that instruct the function to whether to run the final optimisation from the 
beginning and whether all optimisations should be run on a single core respectively. 

Note for Windows users: the user needs to explicitly define a cluster for `gadget.iterative` to run in parallel, see [here](https://www.r-bloggers.com/implementing-mclapply-on-windows-a-primer-on-embarrassingly-parallel-computation-on-multicore-systems-with-r/) for ways around this problem. 

In post-hoc analyses of the effect of certain data sources on model fitting, 
differential treatment of data is often investigated. For example, the effect 
of a certain dataset can be analysed by omitting it from the estimation or changing 
its grouping. `gadget.iterative` allows you to have multiple `WGTS` folders in the 
same model directory by setting the `wgts` argument. In addition the user can 
explicitly define (or remove) which component are to be used in the optimisation 
using a combination of the `comp` and `inverse` arguments:


```r
## only want to fit to ldist.gil, all others discarded
run <- gadget.iterative(comp = 'ldist.gil',
                        wgts = 'WGTS')  # if working on Windows, can run with argument run.serial = TRUE (see above)

## remove ldist.gil, all others kept
run <- gadget.iterative(comp = 'ldist.gil', 
                        inverse = TRUE,
                        wgts = 'WGTS')  # if working on Windows, can run with argument run.serial = TRUE (see above)
```

## Visualize Gadget statistical model fit

To obtain information on the model fit and properties of the model, one can 
use the `gadget.fit` function to query the model and return conveniently 
structured output. Notice that there is a default argument in `gadget.fit` 
that matches `gadget.reiterative`: the `wgts = 'WGTS'` argument. This means that
by default gadget.fit will load the reiterative results stored under 'WGTS', 
but this can be changed. Here we load results from the first run of 
`gadget.iterative` where no grouping was implemented.


```r
setwd(gd)  # Make sure we are in gd first, or put gd as an argument to gadget.fit
fit <- gadget.fit()
```

```
## [1] "Reading input data"
## [1] "Running Gadget"
## [1] "Reading output files"
## [1] "Gathering results"
## [1] "Merging input and output"
```


```r
theme_set(theme_light()) ## set the plot theme (optional)

library(patchwork)  ## optional packages 
scale_fill_crayola <- function(n = 100, ...) {
  
  # taken from RColorBrewer::brewer.pal(12, "Paired")
  pal <- c("#A6CEE3", "#1F78B4", "#B2DF8A", "#33A02C",
           "#FB9A99", "#E31A1C", "#FDBF6F", "#FF7F00",
           "#CAB2D6", "#6A3D9A", "#FFFF99", "#B15928")
  pal <- rep(pal, n)
  ggplot2::scale_fill_manual(values = pal, ...)
  
}
```

The `fit` object is essentially a list of data.frames that contain the likelihood data merged with the model output. 


```r
fit %>% names()
```

```
##  [1] "sidat"             "resTable"          "nesTable"         
##  [4] "suitability"       "stock.recruitment" "res.by.year"      
##  [7] "stomachcontent"    "likelihoodsummary" "catchdist.fleets" 
## [10] "stockdist"         "SS"                "stock.full"       
## [13] "stock.std"         "stock.prey"        "fleet.info"       
## [16] "predator.prey"     "params"            "catchstatistics"
```

and one can access those data.frames simply by calling their name:

```r
fit$sidat  %>% 
  DT::datatable(.)  #this last line not necessary - helps with printing to web page
```

<!--html_preserve--><div id="htmlwidget-5e98f62af8971cf45a20" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-5e98f62af8971cf45a20">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99","100","101","102","103","104","105","106","107","108","109","110","111","112","113","114","115","116","117","118","119","120","121","122","123","124","125","126","127","128","129","130","131","132","133","134","135","136","137","138","139","140","141","142","143","144","145","146","147","148","149","150","151","152","153","154","155","156","157","158","159","160","161","162","163","164","165","166","167","168","169","170","171","172","173","174","175","176","177","178","179","180","181","182","183","184","185","186","187","188","189","190","191","192","193","194","195","196","197","198","199","200","201","202","203","204","205","206","207","208","209","210","211","212","213","214","215","216","217","218","219","220","221","222","223","224","225","226","227","228","229","230","231","232","233","234","235","236","237","238"],["si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len100","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len20","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len52","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len60","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len72","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len80","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92","si.len92"],[1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018],[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],["len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len100","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len20","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len52","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len60","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len72","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len80","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92","len92"],[1064957.4,1501844.9,2121133.8,2918135.3,3805308.6,4666493.9,5406589.8,5993668.1,6486113.3,6837613.7,7131883.1,7401845,7647710.2,7697024.3,7602025.4,7489851.7,7460180.6,7463407.5,7474958.4,7436049.1,7341209.2,7178546.7,6968166.4,6763372.6,6559195.2,6596565.8,6903272.8,7488795.8,8164780.8,8784575,9206540.1,9514769.9,9754378.2,9713572.9,6330190.8,5559824.3,5319353.3,5262177.5,7231862.2,10949596,7652253.4,5969683.4,5420614.6,5021939.3,4505878.6,8178784.9,8313084,6421885.1,5576429,5321098.2,8509164.4,6754861.4,4390142.2,8018389.8,12694805,13928566,16271578,24960827,12306134,13653881,14988891,13277130,7353224.1,5736035.8,5318202.8,2291367.7,3423585.5,7573120.9,3749613.2,3218250.4,2847256.3,2690605.5,2950093.5,4001780.9,4571657.4,3856157.3,3133537,2746125.2,2484228.6,2876770.6,3741929.5,3776573.1,3247250.1,2855160,3196425.3,3656194,3123486.4,3003225.2,4375667.3,5944576.9,7022564.7,9086081.7,9377070.6,7329439.8,6946778.6,6937520.4,5706891.7,3918496.1,2964228.6,2200228.8,1604671.3,2256503.1,5282664.8,5033628.9,4467209.1,4004167,3814812.1,4249650.2,5417921.7,5861209.8,5269393.5,4464059.5,3865534.4,3554814.4,4100281.6,4852590.3,4898891.9,4441161.5,4099158.1,4465591.6,4689690.5,4237457.7,4448369.3,5946764.6,7674370.3,9376589.7,11617262,11462710,10038194,9406923.5,8869590.9,7274077.3,5376546.3,4095894.6,3015081.5,2486410.6,2691223,3070325.2,3030483.4,2774515.2,2518624.3,2417849.5,2661028.2,3185998.3,3448359.8,3213604.1,2786287.6,2413342.5,2262837.2,2467974.3,2790926.1,2872441.7,2712707,2570486.5,2668302.2,2717648.6,2584834.1,2736171.9,3417930.7,4324421.4,5318735.1,6335026.1,6439406.1,5929260,5488040.8,5037123.7,4211010.9,3285705,2537904.4,1908739.4,2396637.7,3274958.5,3837389.2,3969983.8,3803959,3557027.9,3450635.5,3689758,4174484.3,4402427.7,4213178.4,3790040.1,3382666.5,3164808.2,3281804.8,3554765.7,3695065.4,3602147.2,3495834.4,3510839.6,3489889.7,3409365.5,3607385.1,4269814,5191677.5,6387901.7,7428710.5,7742377.2,7411715,6920116.7,6270508.8,5409274.2,4468697.1,3529801.8,858391.2,1238801.4,1692375.9,2064590.9,2255894.8,2273297.5,2194416.5,2134343.9,2204974.6,2352738.6,2452288.8,2416437.9,2271705.4,2060281.4,1908675.9,1902711.6,2004571.2,2081677.6,2076439.2,2030999.3,2001594.9,1962750.7,1922061.9,1985967.5,2210428.9,2633439.8,3194740.6,3730998.7,3988486.5,3960010.4,3758838.9,3488198.8,3145211.6,2687371.6],[-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-11.671745,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-15.260384,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-17.801255,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-11.18121,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.80556,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-10.739016,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013,-11.006013],[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.1855943,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1.3874785,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,20.161545,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,11.529722,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,10.873191,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,5.7988715,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,7.2651149,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,9.802109,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023,11.540023],["lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat","lingimm\tlingmat"],["lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths","lengths"],["fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","loglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit","fixedslopeloglinearfit"],["100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","100 - 160","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","20 - 52","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","52 - 60","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","60 - 72","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","72 - 80","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","80 - 92","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100","92 - 100"],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],[57,52.0455,41,33,62.4,39,35,45,26,56,25,31,32,32,28,18,14,28,29,35,40,47,91,55,57,63,83,152,156,102,149,136,222,190,24,37.0455,24,28,46,35,18,11,23,16,24,9,36,16,14,15,8,20,33,38,78,118,132,151,122,127.4,133.143,88,35,16,18,26,25,47,26,40,15,21,39.4,27,66,35,18,17,7,15,22,6,8,5,6,13,24,18,24,42,81,71,100,96.2,72,81,41,24,25,18,15,33,66,102.5,86,63,69.4,66,96,95,78,55,41,33,31,32,45,24,23,34,49,61,75,87,140,144,139,197.4,233.357,229,239.75,122,97,55,56,67,77,119.591,73,64,87.4,56,45,68,45,50,23,46,21,24,43,30,22,32,34,45,79,62,109,97,95,106,158.357,174,183,163,171,95,78,72,85,149.682,115,75,127.6,69,48,67,31,99,41,39,54,32,62,44,36,54,36,68,96,113,188,144,95,107,148.143,226,236.25,201,345,173,215,152,40,48.1364,32,37,60.8,42,21,18,19,47,19,14,26,21,24,17,9,24,21,29,34,43,87,39,43,34,44,75,107,80,113,107,118,102],[100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92],[160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,160,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,52,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,72,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,92,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100],[9.08568734692826,12.8129944023852,18.0964595652388,24.8960803238089,32.4650020725498,39.812207119034,46.1263375754668,51.1349979049468,55.3362956495284,58.3351223976408,60.845682692511,63.1488634760641,65.2464631891512,65.6671865855943,64.8567031768663,63.8996929088986,63.6465538276176,63.674084134933,63.7726306739548,63.4406758608441,62.6315489611071,61.2437933400187,59.448933160867,57.7017342237176,55.9597941050718,56.2786214943806,58.8952932120609,63.8906844947878,69.6578526098817,74.9456287412457,78.545625295019,81.175288785602,83.2195077370164,82.8713771940505,27.3036323579786,23.4102144279537,22.2146428745471,21.9318332529636,31.973288618245,52.2841069845347,34.1885627998033,25.4699841295611,22.7168960502293,20.749825273145,18.2466217704059,36.9950705641741,37.7163816639459,27.773162171157,23.493129161284,22.2232826083872,38.7733979450086,29.4885733715728,17.6922956618856,36.1364783493842,62.3042930543301,69.5463196390434,83.623694637361,138.882494330915,60.0492018735245,67.9232431676513,75.8666409954615,65.7069311484608,32.6104190874,24.2924392958567,22.2089465528465,8.18448889529526,13.1747710118178,33.7698036056255,24.5628110892294,19.8699047610512,16.7645255845938,15.4985779285004,17.6104813505483,26.8842359069278,32.3386746967205,25.5364947433667,19.1479304084251,15.9440707483218,13.874072887795,17.0061233589466,24.4930013950975,24.8081914509948,20.1187629052243,16.8291288966701,19.6831865486531,23.7178400705375,19.0627705107946,18.0520748212701,30.431219538543,46.5543595498033,58.6649675506982,83.8708727167802,87.620656624762,62.2517111635664,57.7883948898785,57.681563761983,43.9918684468841,26.1110673003885,17.7276639591838,11.723329040412,7.56576695826443,12.1414049077643,73.6063445640519,70.136387078917,62.2441409218825,55.7923144951401,53.1539260033524,59.2127702098176,75.490955146587,81.667537963226,73.421428064975,62.2002557708052,53.8606683828578,49.5312315836609,57.1315333615796,67.6138742798854,68.2590205559594,61.8812050375791,57.1158790031736,62.2216033831895,65.3440995994599,59.0428852388656,61.9816353753792,82.8596211875693,106.931324625012,130.649306443585,161.869855846782,159.716395766357,139.867811859802,131.071964367052,123.585006553431,101.353816757283,74.9144483902099,57.0704068192325,42.0108290379694,34.6445595698805,54.5952179235611,62.2858356183049,61.477589050307,56.2849165514091,51.0938121909915,49.0494546007051,53.9826742264545,64.6324260355219,69.9547955557186,65.1924482510552,56.5237361302709,48.9580238098782,45.904813558572,50.0663061880224,56.6178345822901,58.2714923974061,55.031050874554,52.1459093642823,54.1302374775028,55.1312981334735,52.4369704724402,55.5070691491654,69.3374987558184,87.7269288818918,107.897971242886,128.514853834464,130.632347942853,120.283321681427,111.332573870465,102.18509061101,85.4262384663,66.6551157252797,51.4849359518571,38.7214450464667,51.9645291828546,71.0085118605485,83.2032822772382,86.0782332809668,82.4784398851283,77.1244148056996,74.8175867963455,80.0023037560792,90.5122669274201,95.4545956996576,91.3512425842974,82.1766466331724,73.3438650552457,68.6202040746657,71.1569551384559,77.0753651900996,80.1173801992917,78.1027033394901,75.7976012382793,76.1229479326481,75.6687066887888,73.9227597979317,78.2162728654167,92.5792305647036,112.567317520174,138.504165359185,161.071255604561,167.872259521774,160.702754701931,150.043791018521,135.958821614525,117.285306420725,96.8914662663812,76.5340913421301,14.2506457092108,20.5660540968668,28.0961050832148,34.2754602451199,37.4514062493314,37.7403184749969,36.4307696536806,35.4334698917176,36.6060507405119,39.0591658383552,40.7118559294012,40.1166745316232,37.7138871077675,34.2039157585457,31.6870257111316,31.5880089385885,33.2790387064635,34.5591263731505,34.4721606837503,33.7177867852737,33.2296274394044,32.5847525477959,31.9092543913226,32.9701879894705,36.6966007099102,43.7192478048879,53.0377250179542,61.9404539739297,66.215156944142,65.7424088401539,62.4026451365063,57.9095932741324,52.2154656199879,44.6146006163566]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>name<\/th>\n      <th>year<\/th>\n      <th>step<\/th>\n      <th>area<\/th>\n      <th>label<\/th>\n      <th>number<\/th>\n      <th>intercept<\/th>\n      <th>slope<\/th>\n      <th>sse<\/th>\n      <th>stocknames<\/th>\n      <th>sitype<\/th>\n      <th>fittype<\/th>\n      <th>length<\/th>\n      <th>age<\/th>\n      <th>survey<\/th>\n      <th>fleet<\/th>\n      <th>observed<\/th>\n      <th>lower<\/th>\n      <th>upper<\/th>\n      <th>predict<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[2,3,4,6,7,8,9,17,18,19,20]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

For further information on what the relevant data.frames contain refer to the help page for `gadget.fit`. 

In addition a plot routine for the `fit` object is implement in Rgadget. The input to the `plot` function is simply the `gadget.fit` object, the data set one wants to plot and the type. The default plot is a survey index plot:

```r
plot(fit)
```

<img src="day3_fitlingmodel_files/figure-html/unnamed-chunk-23-1.png" width="672" />

To produce a likelihood summary:

```r
plot(fit,data='summary')
```

<img src="day3_fitlingmodel_files/figure-html/unnamed-chunk-24-1.png" width="672" />

A weighted summary plot:

```r
plot(fit,data='summary',type = 'weighted')
```

<img src="day3_fitlingmodel_files/figure-html/unnamed-chunk-25-1.png" width="672" />

and a pie chart of likelihood components:

```r
plot(fit,data='summary',type='pie')
```

<img src="day3_fitlingmodel_files/figure-html/unnamed-chunk-26-1.png" width="672" />

To plot the fit to catch proportions (either length or age) you simply do:

```r
tmp <- plot(fit,data = 'catchdist.fleets')
names(tmp)
```

```
## [1] "aldist.bmt"  "aldist.gil"  "aldist.lln"  "aldist.surv" "ldist.bmt"  
## [6] "ldist.gil"   "ldist.lln"   "ldist.surv"
```

and then plot them one by one:

```r
tmp$aldist.surv
```

<img src="day3_fitlingmodel_files/figure-html/unnamed-chunk-28-1.png" width="672" />

```r
tmp$ldist.surv
```

<img src="day3_fitlingmodel_files/figure-html/unnamed-chunk-29-1.png" width="672" />


One can also produce bubble plots

```r
bubbles <- plot(fit,data = 'catchdist.fleets',type='bubble')
names(bubbles)
```

```
## [1] "ldist"  "aldist"
```

Age bubbles

```r
bubbles$aldist
```

<img src="day3_fitlingmodel_files/figure-html/unnamed-chunk-31-1.png" width="672" />

Length bubbles

```r
bubbles$ldist
```

<img src="day3_fitlingmodel_files/figure-html/unnamed-chunk-32-1.png" width="672" />

One can also illustrate the fit to growth in the model:

```r
grplot <- plot(fit,data = 'catchdist.fleets',type='growth')
names(grplot)
```

```
## [1] "aldist.bmt"  "aldist.gil"  "aldist.lln"  "aldist.surv"
```
Illstrate the fit to the autumn survey

```r
grplot$aldist.surv
```

<img src="day3_fitlingmodel_files/figure-html/unnamed-chunk-34-1.png" width="672" />

And the fit to maturity data:

```r
plot(fit,data='stockdist')
```

```
## $matp.surv
```

<img src="day3_fitlingmodel_files/figure-html/unnamed-chunk-35-1.png" width="672" />

And selection by year and step

```r
plot(fit,data="suitability")
```

<img src="day3_fitlingmodel_files/figure-html/unnamed-chunk-36-1.png" width="672" />

Age age compostion

```r
plot(fit,data='stock.std') + scale_fill_crayola()
```

<img src="day3_fitlingmodel_files/figure-html/unnamed-chunk-37-1.png" width="672" />


And the standard ICES plots

```r
plot(fit,data='res.by.year',type='total') + theme(legend.position = 'none') +
  plot(fit,data='res.by.year',type='F') + theme(legend.position = 'none') +
  plot(fit,data = 'res.by.year',type='catch') + theme(legend.position = 'none') +
  plot(fit, data='res.by.year',type='rec')
```

<img src="day3_fitlingmodel_files/figure-html/unnamed-chunk-38-1.png" width="672" />

#### Exercise
* Try plotting the catchabilities on the normal scale (exponentiated, not log as given) across ages for each survey. What shape are they when plotted?
* What information is stored under fit$SS?
* Try changing the grouping structure above to one that makes more sense to you. Do model results fit any better?


```r
fit$sidat %>% 
  select(lower, intercept) %>% 
  distinct() %>% 
  mutate(catchability = exp(intercept)) %>% 
  ggplot(aes(x = lower, y = catchability)) + 
  geom_line()

fit$SS
```


