# Simulations using NONMEM

## Introduction

This vignette describes the steps to simulate a NONMEM model using the
`amp.sim` package. Although the example is relatively simple, it should
showcase the general principle that can be applied to any type of model.
The `amp.sim` package include various functions that can be used to help
in the otherwise manual tasks when simulating solely with NONMEM. The
functions are set-up in way that all sampling is done within R, and that
all model parameters are added to the input file. This method is chosen
because the flexibility it provides to perform different kind of
sampling methods (e.g. including uncertainty, variability or a
combination). Once a standardized input data set is available, the
creation of simulation model from any kind of NONMEM model can be
automated fairly easy.

## Simulation dataset

### The basics

The basis of a NONMEM simulation is creating a valid dataset. Within
NONMEM all information regarding dosing, output time-points, covariates
and parameters can be added to a data set. The following chunk shows how
the `simdata` function can be used to create a starting point for a
simulation data set:

``` r
library(amp.sim)
simd <- simdata(time = seq(0,120,1), dosetime = 0, doseheight = 100, 
                addl = 2, ii = 24, numid = 10)
```

This function will create by default a data set for one dose level (or
compound, compartment, etc), if needed for multiple subjects. In case
multiple dose levels, compartments, etc. are necessary there are
different possibilities. The following example shows a couple of
examples using some simple base R functions:

``` r
# lapply can be used for multiple repetitions
simd <- lapply(seq(300,600,1200),function(x) {
  simdata(time = seq(0,120,1), dosetime = 0, doseheight = x,
          addl = 2, ii = 24, numid = 10)
})
simd <- do.call(rbind,simd)
# .. or rbind to do a few repetitions 
simd <- rbind(cbind(simd,CMT=1),cbind(simd,CMT=2),cbind(simd,CMT=3))
```

### Additional variables

The example above creates a basic dataset with only the bare minimum for
a simulation. In many cases additional variables need to be added. These
variables can be covariates or just variables used within the control
stream. There are many different ways that variables can be added to the
data and depends on the type of simulation to perform. Some important
considerations are:

1.  Should all subjects receive the same value(s)?
2.  Should the same subjects be present in each strata/treatment/dose
    group/etc.?
3.  Are there correlations that should be taken into account?
4.  How should time-varying covariates be handled?

This vignette will not go through all possibilities and leave it up to
the reader to add variables based on the type of simulation. However, be
aware to add all variables used in a control stream in this step to
prevent NONMEM from crashing. Some simple examples are included here for
the creation of additional variables:

``` r
simd$WEIGHT <- 70
simd$TRT    <- sample(1:3,10,replace=TRUE)
simd$AGE    <- as.integer(rnorm(10,39,5))
```

### Inclusion of model parameters

Within the last step the model parameters are added to the data set. To
do so the `sample_par` function can be used. The function takes the
NONMEM ext file, which include the final parameter estimates, as input.
It is possible to sample from the covariance matrix to take into account
parameter uncertainty. In this case the covariance matrix (NONMEM cov
file) should also be provided to the function. The following chunk show
some examples on how the function can be used:

``` r
# Simple sampling for 10 subjects with the same THETAs but different ETAs
samp <- sample_par("run1.ext",inc_eta=TRUE,nrepl=10)

# We could include sampling with uncertainty and omit ETA values
# samp <- sample_par("run2.ext","run2.cov",inc_eta=FALSE,nrepl=10,uncert = TRUE)

# Or have uncertainty and variability
# samp <- sample_par("run2.ext","run2.cov",inc_eta=TRUE,nrepl=10,uncert = FALSE)

# Or use the result from a bootstrap to sample uncertainty
# samp <- sample_par("run2.ext",bootstrap=".", uncert = TRUE)

# In case of clinical trial simulations where a combination of replicates and subjects
# should be used, the sample_sim function can be used 
# samp <- sample_sim(ext="run2.ext",cov="run2.cov", type="unc_sameIIV", nrepl=10, nsub=20)
```

The resulting data frame will include $\theta$ and/or $\eta$ values
based on the settings. The naming will always be prepended with the
letter ‘S’ (for simulated or sampled) which is important for subsequent
steps.

In case residual error should be included in the simulations it might be
necessary to adapt the sampled dataset within this step. This is the
case when residual error is coded as $\theta$ and uncertainty is
included. In these cases the $\theta$ value should likely be set to a
single value (population estimate). In case residual is coded as
$\sigma$ the simulation model might need adaptation but more on that
later.

At this point the simulation dataset can be combined with the parameter
estimates to create a final dataset and export the result to a csv file:

``` r
inp    <- merge(simd,samp)
inp    <- inp[order(inp$ID,inp$TIME),]
write.csv(inp,csv="sim.input.csv",row.names = FALSE, na = ".")
```

The resulting dataset would look something like this:

``` r
head(simd)
```

      ID DOSE TIME AMT ADDL II DV WEIGHT AGE STHETA1 STHETA2 STHETA3  SETA1  SETA2
    1  1  100    0 100    2 24 NA     70  40   0.234    1.25    30.1 -0.224  0.025
    2  1  100    0  NA   NA NA NA     70  37   0.234    1.25    30.1 -0.513  0.216
    3  1  100    1  NA   NA NA NA     70  27   0.234    1.25    30.1 -0.212  0.072
    4  1  100    2  NA   NA NA NA     70  38   0.234    1.25    30.1 -0.373 -0.046
    5  1  100    3  NA   NA NA NA     70  34   0.234    1.25    30.1 -0.199  0.153
    6  1  100    4  NA   NA NA NA     70  40   0.234    1.25    30.1  0.194 -0.127

## Simulation model

In the previous step we saw that sampling of $\theta$ and $\eta$ values
was done in R and added to the dataset. This means that it is not
necessary to do sample $\theta$ or $\eta$ values in NONMEM. One
important characteristic of this method is that we do not use certain
dollar blocks. Furthermore, the original model needs to be rewritten so
that the parameters are read from the dataset. These things are fairly
easy to automate and for this reason the `make_nmsimmodel` function is
available:

``` r
make_nmsimmodel("run1.mod", smod = "sim1.mod", data = "sim.input.csv")
```

In the example above the original model is read-in (run1.mod), adapted
within R and finally written under a different name as simulation model.
This new model should be directly ready for simulation. The only
exception might be handling of residual error:

1.  In case residual error should be taken into account and is coded as
    $\sigma$; The true sigma value should be manually replaced in the
    simulation model
2.  In case residual error should be taken into account, and uncertainty
    simulation should be performed and is coded as $\theta$; Within the
    `sample_par` function the “restheta” should be provided. In these
    cases the residual error is set to the population estimate to use
    one value for all subjects.

## Split simulations

The main idea behind setting up the simulation using this package is
that there is one dataset and one simulation model. However in many
cases the output of the simulations can be quite big, especially when
uncertainty is taken into account or in case of a full clinical trial
simulation (CTS). To overcome size problems or very long runtimes, it is
possible to split the simulation in multiple chunks using the
`split_sim` function:

``` r
split_sim(data    = "sim.input.csv",
          model   = "run2sim_final.mod",
          locout  = "simulation",
          splitby = "DOSE",
          numout  = 3)
```

Within this function, the dataset and model should be provided so that
multiple copies can be made for both. Also, a variable to split on
should be given and the number of outputs/models. The function will then
try, as good as possible, to create equally sized chunks. An important
note here, is that you can use a data frame for `data` instead of a csv
file. This is convenient because in that case you do not need to use a
huge csv file that should be split. Although, You do need a csv file in
order to make the initial simulation model (e.g. ‘run2sim_final.mod’
above). It is suggested to do this with only the head of the simulation
input and then do the splitting, for example:

``` r
write.csv(head(inp),csv="sim.input.csv",row.names = FALSE, na = ".")
make_nmsimmodel("run1.mod", smod = "sim1.mod", data = "sim.input.csv")

split_sim(data    = inp,
          model   = "sim1.mod",
          locout  = "simulation",
          splitby = "DOSE",
          numout  = 3)
```

## Run the simulation

At this point, everything should be in place to perform the simulation.
The only thing left to do is to run the model(s) in NONMEM. Obviously
there are many different ways to do this, and based on the
infrastructure in your organization. Therefore, the `amp.sim` package
does not have any functionality for this. **Below pseudo code for a
general R function to run all models within a certain folder is shown**:

``` r
# NOTE: THIS IS EXAMPLE CODE; run_models IS NOT A FUNCTION AVAILABLE IN THE PACKAGE
mods <- list.files("simulation",pattern="\\.mod$",full.names = TRUE)
run_models(mods)
```

## Final thoughts

When simulating in NONMEM a large portion of the work is creating a
dataset and rewrite a model to a simulation model. This package helps in
both tasks. The sampling of parameters is done entirely within R. This
makes it easy to control the kind of sampling that is necessary. Also,
using this method it is easier to automate the creation of a simulation
model. Overall the package reduces the number of manual tasks that are
necessary making it less error prone. Finally, the package provides
functions to set-up and perform the simulations. For post-processing of
the results like calculations and plotting no functionality is present.
This is mainly because it is too dependent on the type of project, also
there are many other R packages available to perform these tasks.
