## getting started:
library(tidyverse)
library(Rgadget)


## print_to_screen

print_to_screen <- function(gd,file){
  read_lines(paste(gd,file,sep='/')) %>%
    paste(collapse = '\n') %>% 
    cat()
}


## Dummy file

dummy <- 
  gadgetfile('test',file_type = 'generic', 
             components = list(fruit=list(apple=1,orange=5),
                               vegetable=list(cucumber=1))) 

dummy
dummy$fruit
str(dummy)

write.gadget.file(obj=dummy,path='somewhere_over_the_rainbow')

## simple model

gd <- gadget.variant.dir('simple_model')
gd

## lets look at the files in gd
#fs::dir_ls(gd) ## nothing has happened

## Time file
schedule <- 
  expand.grid(year = 1:10, step = 1:4) %>% 
  arrange(year)

gadgetfile('Modelfiles/time',
           file_type = 'time',
           components = list(list(firstyear = min(schedule$year),
                                  firststep=1,
                                  lastyear=max(schedule$year),
                                  laststep=4,
                                  notimesteps=c(4,3,3,3,3)))) %>% ## number of time steps and step length in months
  write.gadget.file(gd)

## lets look again
fs::dir_ls(gd)

## what is in the main file:

print_to_screen(gd,'main')

## Area file

gadgetfile('Modelfiles/area',
           file_type = 'area',
           components = list(list(areas = 1,
                                  size = 1,
                                  temperature = schedule %>% 
                                    mutate(area = 1, temperature = 5)))) %>% 
  write.gadget.file(gd)

## Stock file 
stock <- gadgetstock('simple_stock',gd,missingOkay = TRUE)
stock

stock <- 
  stock %>% 
  gadget_update('stock',
                livesonareas = 1,
                maxage = 1,
                minage = 1,
                minlength = 0,
                maxlength = 2,
                dl = 1) %>% 
  gadget_update('doesgrow',0) %>% 
  gadget_update('naturalmortality',0) %>% 
  gadget_update('refweight',data=tibble(length=0:2,mean=0:2)) %>% 
  gadget_update('initialconditions',
                normalparam = tibble(age = 1,
                                     area = 1,
                                     age.factor = 1,   
                                     area.factor =1,
                                     mean = 1,
                                     stddev = .1,
                                     alpha = 1,
                                     beta = 1))
stock %>% 
  write.gadget.file(gd)
stock
## let's look at the files in gd

fs::dir_ls(gd)

print_to_screen(gd,'main')

## Starting a simulation
gadget_evaluate(gd, log = 'simple_log')

## .. but what has really happened

fit <- gadget.fit(wgts = NULL,gd = gd)
plot(fit,data='res.by.year',type = 'num.total') 
names(fit)
fit$res.by.year 

## now what has happend in gd
fs::dir_ls(gd)

## what is in params.out
print_to_screen(gd,'params.out')

## Model variables

gadgetstock('simple_stock',gd) %>% 
  gadget_update('naturalmortality',0.2)

gadgetstock('simple_stock',gd) %>% 
  gadget_update('naturalmortality',"#M") %>% 
  write.gadget.file(gd)

gadget_evaluate(gd)

## what is in params.out
print_to_screen(gd,'params.out')  

## we can now change that value in the parameter file
read.gadget.parameters(paste(gd,'params.out', sep = '/')) %>% 
  init_guess('M',value = 0.2) %>% 
  write.gadget.parameters(file = 'simple_model/params.in')

print_to_screen(gd,'params.in')

gadget_evaluate(gd,params.in = 'params.in')

## what is happening to our stock

fit <- gadget.fit(wgts = NULL,gd = gd, params.file = 'params.in')
plot(fit,data='res.by.year',type = 'num.total') 


## working with formulas:

to.gadget.formulae(quote((1+exp(a*b))))

parse.gadget.formulae('(* #a #b)')

parse.gadget.formulae('(* #a #b)') %>% 
  eval(list(a=7,b=6)) 

## even more complicated formula:

to.gadget.formulae(quote(linf*(1-exp(-1*k(3-a0)))))
## Exercise

stock %>% 
  gadget_update('naturalmortality','#M') %>% 
  gadget_update('initialconditions',
                normalparam = tibble(age = 1,
                                     area = 1,
                                     age.factor = '#init.num',   
                                     area.factor =1,
                                     mean = 1,
                                     stddev = .1,
                                     alpha = 1,
                                     beta = 1)) %>% 
  write.gadget.file(gd)

gadget_evaluate(gd,log = 'test')

read.gadget.parameters('simple_model/params.out') %>% 
  init_guess('M',value = 0.2) %>% 
  init_guess('init.num', value = 1) %>% 
  write.gadget.parameters(file = 'simple_model/params.in')


read.gadget.parameters('simple_model/params.out') %>% 
  init_guess('M',value = 0.6) %>% 
  init_guess('init.num', value = 10) %>% 
  write.gadget.parameters(file = 'simple_model/params.in2')

fit <- gadget.fit(wgts = NULL, 
                  ## make sure that this is relative to
                  ## gadget directory
                  params.file = 'params.in',
                  gd = gd)

fit2 <- gadget.fit(wgts = NULL, 
                   ## make sure that this is relative to
                   ## gadget directory
                   params.file = 'params.in2',
                   gd = gd)

plot(fit,data='res.by.year',type='num.total')
plot(fit2,data='res.by.year',type='num.total')

fit$res.by.year %>% 
  bind_rows(fit2$res.by.year,.id = 'model') %>% 
  ggplot(aes(year,total.number,col = as.factor(model))) + geom_line()


parse.gadget.formulae(' (/ 1 (+ 1 (exp (* (* -1 #alpha) (- 50 #l50)))))') %>% 
  eval(list(alpha = 0.1, l50 = 75))



## Defining predation

## visualising suitability functions:

prey.length <- 1:50
pred.length <- seq(40,100,by=10) 

param <- c(alpha = -20, beta = -0.5,gamma = 0.1, delta = 1)

suit <- suitability(params = param, 
                    l = prey.length,
                    L = pred.length,
                    type = 'exponential',
                    to.data.frame = TRUE)

ggplot(suit,aes(l,suit,col=as.factor(L))) + geom_line()

## notify model that stock is available for consumption

gadgetstock('simple_stock',gd) %>% 
  gadget_update("iseaten",1) %>% 
  write.gadget.file(gd)

## Fleet setup:

harvest.rate <- 
  structure(data.frame(year=unique(schedule$year),step=2,area=1,number=1),
            area_group = list(`1` = 1)) 
## note that the call to data.frame is wrapped with structure 


View(harvest.rate)

gadgetfleet('Modelfiles/fleet',gd,missingOkay = TRUE)

gadgetfleet('Modelfiles/fleet',gd,missingOkay = TRUE) %>% 
  gadget_update('linearfleet',
                name = 'simple_fleet',
                suitability = 
                  list(simple_stock=list(type='function',
                                         suit_func = 'constant',
                                         value=0.2)),
                data = harvest.rate) %>% 
  write.gadget.file(gd)

print_to_screen(gd,'Modelfiles/fleet')
print_to_screen(gd,'Data/fleet.simple_fleet.data')

fit <- gadget.fit(wgts = NULL, gd = gd, params.file = 'params.in')
plot(fit,data = 'res.by.year',type='num.total') + 
  expand_limits(y=0)  

plot(fit,data = 'res.by.year',type='num.catch') + 
  expand_limits(y=0) 

## Define varying rates
harvest.rate <- 
  structure(data.frame(year=unique(schedule$year),step=2,area=1,
                       ## HR are now random variations around 1
                       number= exp(rnorm(length(unique(schedule$year))))),
            area_group = list(`1` = 1)) 
View(harvest.rate)

## update the fleet file
gadgetfleet('Modelfiles/fleet',gd,missingOkay = TRUE) %>% 
  gadget_update('linearfleet',
                name = 'simple_fleet',
                suitability = 
                  list(simple_stock=list(type='function',suit_func = 'constant',value=0.2)),
                data = harvest.rate) %>% 
  write.gadget.file(gd)

## And re-run

fit <- gadget.fit(wgts = NULL, gd = gd, params.file = 'params.in')

plot(fit,data = 'res.by.year',type='num.total') + 
  expand_limits(y=0)  

plot(fit,data = 'res.by.year',type='num.catch') + 
  expand_limits(y=0) 


## change fleet to number fleet

catch <- 
  structure(data.frame(year=unique(schedule$year),
                       step=2,area=1,
                       number= 500),
            area_group = list(`1` = 1)) 

## update the fleet file
gadgetfleet('Modelfiles/fleet',gd,missingOkay = TRUE) %>% 
  gadget_update('numberfleet',
                name = 'simple_fleet',
                suitability = 
                  list(simple_stock=list(type='function',suit_func = 'constant',value=0.2)),
                data = catch) %>% 
  write.gadget.file(gd)

fit <- gadget.fit(wgts = NULL, gd = gd, params.file = 'params.in')

## Put gadget formulae instead


catch <- 
  structure(data.frame(year=unique(schedule$year),step=2,area=1,
                       ## put a gadget parameter for each year
                       number= sprintf('#catch.%s',unique(schedule$year))),
            area_group = list(`1` = 1)) 

## Defining recruitment

recruits <- 
  tibble(year = 1:10, ## Year of recruitment,
         step = 1, ## timing of recruitment (q1)
         area = 1, ## where does the rec. take place
         age = 1, ## age of recruits
         number = 1, ## num. of recruits (x10 000)
         mean = 1, ## mean length
         stddev = .1, ## std in length
         alpha = 1, ## a in w = aL^b
         beta = 1)

gadgetstock('simple_stock',gd) %>% 
  gadget_update('doesrenew',
                normalparam = recruits) %>% 
  write.gadget.file(gd)

fit <- gadget.fit(wgts = NULL, params.file = 'params.in',gd=gd) 

plot(fit,data = 'res.by.year',type='num.total') + 
  expand_limits(y=0)  

plot(fit,data = 'res.by.year',type='num.catch') + 
  expand_limits(y=0)  

## Add recruitment as variable

gadgetstock('simple_stock',gd) %>% 
  gadget_update('doesrenew',
                normalparam = tibble(year = 1:10, ## Year of recruitment,
                                     step = 1, ## timing of recruitment (q1)
                                     area = 1, ## where does the rec. take place
                                     age = 1, ## age of recruits
                                     number = ifelse(year == 1, 0,sprintf('#rec.%s',year)), ## num. of recruits (x10 000)
                                     mean = '#ml', ## mean length
                                     stddev = '#sdl', ## std in length
                                     alpha = '#alpha', ## a in w = aL^b
                                     beta = '#beta')) %>% 
  write.gadget.file(gd)


gadgetstock('simple_stock',gd) %>% 
  gadget_update("iseaten",1) %>% 
  write.gadget.file(gd)


## Defining growth, simple growth model

gd <- gadget.variant.dir('simple_growth_model')
gd

## lets look at the files in gd
#fs::dir_ls(gd) ## nothing has happened

## Time file
schedule <- 
  expand.grid(year = 1:10, step = 1:4) %>% 
  arrange(year)

gadgetfile('Modelfiles/time',
           file_type = 'time',
           components = list(list(firstyear = min(schedule$year),
                                  firststep=1,
                                  lastyear=max(schedule$year),
                                  laststep=4,
                                  notimesteps=c(4,3,3,3,3)))) %>% ## number of time steps and step length in months
  write.gadget.file(gd)



## Area file

gadgetfile('Modelfiles/area',
           file_type = 'area',
           components = list(list(areas = 1,
                                  size = 1,
                                  temperature = schedule %>% 
                                    mutate(area = 1, temperature = 5)))) %>% 
  write.gadget.file(gd)

## Stock file 
stock <- gadgetstock('growth_stock',gd,missingOkay = TRUE)
stock

stock <- 
  stock %>% 
  gadget_update('stock',
                livesonareas = 1,
                maxage = 1,
                minage = 1,
                minlength = 0,
                maxlength = 100,
                dl = 1) %>% 
  gadget_update('naturalmortality',0) %>% 
  gadget_update('refweight',data=tibble(length=0:100,mean=1)) %>% 
  gadget_update('initialconditions',
                normalparam = tibble(age = 1,
                                     area = 1,
                                     age.factor = 1,   
                                     area.factor =1,
                                     mean = 1,
                                     stddev = .1,
                                     alpha = 1,
                                     beta = 1))
stock %>% 
  write.gadget.file(gd)
stock

gadget_evaluate(gd, log = 'growth_log')

read.gadget.parameters(paste(gd, 'params.out', sep = '/')) %>% 
  init_guess('alpha', value = 1) %>% 
  init_guess('beta', value = 1) %>% 
  init_guess('linf', value = 100) %>% 
  init_guess('k', value = 100) %>% 
  write.gadget.parameters(paste(gd, 'params.in', sep = '/'))

fit <- gadget.fit(wgts = NULL, params.file = 'params.in', gd = gd)

fit$stock.full %>% 
  ggplot(aes(length,number,col=as.factor(year))) + 
  geom_line()
