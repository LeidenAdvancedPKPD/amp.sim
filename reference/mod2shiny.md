# Creates a basic simulation app for a given R model

This function fills in a default template for simulations within shiny

## Usage

``` r
mod2shiny(
  parvector,
  modfile,
  evnt,
  init = NULL,
  naming = NULL,
  apptitle = "Shiny app title",
  outloc = ".",
  omega = NULL,
  sigma = NULL,
  delloc = FALSE,
  framework = "deSolve",
  logo = paste0(system.file(package = "amp.sim"), "/logo.png"),
  times = NULL
)
```

## Arguments

- parvector:

  named vector with the model parameters, should contain all parameters
  used by the model

- modfile:

  A script with the model defined in it, it is assumed that this file is
  created using
  [`convert_nonmem`](https://leidenadvancedpkpd.github.io/amp.sim/reference/convert_nonmem.md)

- evnt:

  dataframe with the events used by the model (this is saved as rds
  together with the app)

- init:

  vector with the compartment initialization (only applicable for
  deSolve framework)

- naming:

  named vector with the names in parvector and the new values to use
  within the shiny app

- apptitle:

  string with the title to be used for the app

- outloc:

  character with location where the resulting shiny app should be saved

- omega:

  vector with the omega matrix for the model (only applicable for rxode2
  framework)

- sigma:

  vector with the sigma matrix for the model (only applicable for rxode2
  framework)

- delloc:

  logical indicating if the location should be deleted first

- framework:

  character indicating the simulation framework that was used, currently
  "deSolve", "rxode2", "nonmem2rx" and "mrgsolve" are supported

- logo:

  character with a png of the company logo added in the header of the
  shiny app

- times:

  character vector with the times to simulate or set to NULL to use a
  default time vector

## Value

creates necessary app files for a shiny simulation app

## Details

This function creates a default shiny app that can be used as a starting
point for further development. There are already some basic features
available but it is intended to be adapted when used for production. For
the automatic creation of an app it is assumed that the model is created
using the
[convert_nonmem](https://leidenadvancedpkpd.github.io/amp.sim/reference/convert_nonmem.md)
function. Although it is not strictly necessary, the information
provided to this function will be in the correct format when this
function is used. Some of the arguments in this function are only
necessary in case a certain conversion framework is used. In general a
single subject is simulated, but be aware that for the deSolve and
rxode2 framework OMEGA/ETA is implemented.

## Author

Richard Hooijmaijers

## Examples

``` r
nmmod <- system.file("example_models","PK.1CMT.ORAL.mod", package = "amp.sim")
outf  <- tempfile()
convert_nonmem(nmmod, out=outf, verbose = FALSE)
prm   <- c(THETA1 = 0.3, THETA2 = 2, THETA3 = 5)
evnt  <- mrgsolve::ev(amt = 100, ii = 24, addl = 1)
nams  <- c(THETA1 = "KA (1/h)", THETA2 = "CL (l/h)", THETA3 = "V (l)") 
mod2shiny(prm, modfile= paste0(outf,".cpp"), evnt = evnt,
          naming = nams, framework = "mrgsolve", outloc=tempdir())
#> Shiny app created in location '/tmp/Rtmpj39p8i'. It can be submitted using:
#> shiny::runApp('/tmp/Rtmpj39p8i',launch.browser=TRUE)
```
