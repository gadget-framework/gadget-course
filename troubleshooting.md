

# Troubleshooting Gadget models

Uh oh. You ran callGadget and a bunch of red gibberish error message about 
something with a null status popped out. Now what?

First step is to print a log from a Gadget run, but ONLY when Gadget is running a **simulation**. If run while optimising, you could end up with a crashed computer as well. Open the log and see what the last line tells you. Most often it tells you that a file or data can not be found. 



### File / data / Gadget cannot be found

Look for the file that is missing according to the log and make a note of its locatino. Then check all directories involved to see that it matches the search directories:
* What is your current R working directory in relation to your file paths?
* What is your Gadget working directory in relation to your  model? Set the via Gadget using `Sys.setenv(GADGET_WORKING_DIR=normalizePath(pathname))`.
* Where is your Gadget executable in relation to where callGadget thinks it is? The default can be found and changed under the `gadget.exe` argument within callGadget.

### Fleet / Data / Likelihood problems

#### Fleet does not exist in an area

You may get an error whenever there are data assigned to a fleet that came from
an area where that fleet does not exist. When using Rgadget, fleet catch/landings data frames need to have an attribute assigned to them that specifies the areas *in which the fleet exists*. This information is used to assign fleets to areas in
the model. Note that it *does not matter whether data from all areas where the fleet exists are in the file or not*. So for example, a fleet assigned to areas 1
& 2 can have data only coming from area 1, but a fleet assigned only to area 1
cannot also have data coming from area 2. 

#### Certain likelihood scores or values are not being calculated

If you find that a likelihood component is not returning realistic values, it is wise first to check that temporal and spatial the structure of your model and the structure of your data match. It is also important to check that different sources of data are consistent. For example, you will run into problems if you have a catchdistribution likelihood component with catchdistribution data that comes from a time and place that does not match any catch data being extracted.

### Starting value is outside the bounds of the parameter

This problem is exactly as it states - check your parameter file. Sometimes this 
happens due to a programming error, but sometimes this also happens when, after running a Gadget optimisation run, Gadget leaves you with an optimised parameter value that is ever
so slightly beyond the bounds that you specified within the optimisation run. 
Parameter bounds in the optimisation routine are not set as hard bounds, rather as a penalty, defined by the BoundLikelihood likelihood component, its value and weight. The penalty is calculated as the distance of the parameter value from its bound x the likelihood component value x its weight. Therefore, if the likelihood increases strongly as the bound is approached in the optimisation search, then there may be a small space beyond the bound where the optimisation algorithm could converge if the penalties or weights are not high enough. 

###  Update Gadget and Rgadget, restart the Rsession

Package incompatibilities? Bug fixes? No good explanations here as to when this should be done, it just works sometimes and should be done regularly anyway (roughly monthly at a minimum).

## List of known Gadget quirks

Once in a while, you get a far more interesting error in the log. These can be 
difficult to figure out, but here are a few known bugs that may be causing it.

* Survey indices with more than one are **must** have data for both areas within a given year, if that year is present in the data at all

* Where little age data are present, the simulated annealing optimisation routine can tend to get stuck in local optima where biomass is very high. For example, if recruitment is estimated each year as in the ling example, then at least one recruitment value will be optimised very close to the upper bound, but open further investigation, results with lower likelihood can be found away from these bounds. The reason for this is unknown and efforts are underway to analyze the reason for this problem, but in the meantime it can have serious consequences on model results. Therefore, it is best practice to always set the seed for the optimisation run and create a profile of the likelihood score while varying the value of any suspect parameters. In this case of recruitment estimates, the upper bound that applies to all recruitment estimates may need to be varied instead of the parameter value itself, because any change in a single year's recruitment parameter will affect other year's recruitment values as well as growth.

## Gadget is working properly, but results are strange

### Programming errors
This is most likely to be a programming error in an Rgadget script that has caused strange input or
settings, so the first step is to carefully check over the Gadget files. The most likely culprits are
*trying to include the same parameter in multiple places, but accidentally naming it incorrectly (thereby generating an additional poorly specified parameter)
*wrongly specified likelihood component names that end up not grouped within the call to `gadget.reiterative`

### Old files hanging around in the Gadget model directory
If nothing is obvious, delete all Gadget files in the project, check all working directories, and rewrite the Gadget files. Perhaps some old model specifications were not rewritten by new ones, or old likelihood components that were written by a previous version are still hanging around in the folders. In general, when developing a set of Rgadget script of a single Gadget model, it is best practice to delete all
generated Gadget files while testing and running it. This is because simple programming errors, for 
example in naming a likelihood component, can cause serious problems in your model structure (e.g.,
including the same data in two separate likelihood components). If the incorrectly generated files 
are not deleted, Gadget may read them and incorporate them as part of your model. 

### Gadget iterative gives errors

Step through your model files looking for bugs, especially in the 
likelihood files. Look at the weights that are being assigned in every
instance, which could lead you to problematic data or likelihood structures.

### The Gadget working directory is incorporating files from another Gadget model
When recreating Gadget files and calling Gadget, check all working directories carefully. *This is especially problematic when working on two scripts of two different models simultaneously in the same R session.* Because there is only one Gadget working directory per R session environment, 
which is set using `Sys.setenv(GADGET_WORKING_DIR=normalizePath(pathname))`, if you set 
the Gadget working directory containing project A's data, and don't switch it back to project
B's working directory when running project B, then you may start including project A data 
and likelihood components into a project B model run. More on file and path organization can be found in the Gadget User Guide section 1.3 'Running Gadget'.

### Your model is not good
If these errors are ruled out, you will have to look at the model results themselves. Some starting 
places:
* Did your model converge? If no, increase optimisation length or change optimisation parameters or methods. In complex models or those no age data, it has been observed that the simulated annealing algorithm needs to run for a long time to avoid landing in local optimum.
* Is there understocking? Try restricting parameter bounds so that the model begins in a more realistic starting point.
* Are parameter bound constricting? Loosen them if necessary.
* Are parameter bounds realistic? Check to make sure parameter values are not on the wrong scale or have the wrong interpretation.
* Are there more 'NAs' than data in your likelihood function? Because NAs are not actually included in Gadget, to consider this question you need to compare the model structure (e.g., # age-length bins) to the number of data points you include in the likelihood. For example, if you have 10 ages x 100 lengths = 1000 bins, but only 50 data points to compare with, then the optimisation routine can have a hard time fitting that data source. Try changing the aggregation levels of the data (grouping attributes of the data frame) to larger aggregations for the purpose of comparing the model to data.
* **Does the growth process look realistic**? This is an important question to ask of all Gadget models, since Gadget models are more likely to be used in scenarios where there is little or poor ageing data. In this scenario, model results hinge heavily on how growth is modeled. Therefore, results for growth-related paramters should be scrutinized carefully (e.g., Linfinity and k in Von Bertalannfy growth, alpha & beta in the translation of lengths to weights, maxlengthgroupgrowth should be reduced, especially when the beta paramater hits a bound).
* Check the list of known Gadget quirks.
