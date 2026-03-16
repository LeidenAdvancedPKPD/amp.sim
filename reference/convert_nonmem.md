# Convert NONMEM model to R syntax

This function converts a NONMEM model to syntax useable in R
simulations. Currently deSolve, rxode2 (nonmem2rx) and mrgsolve are
available syntaxes to use Additionally a code to control the simulations
is created to directly test the simulations

## Usage

``` r
convert_nonmem(
  model,
  out,
  ext = NULL,
  mod_return = NULL,
  type_return = "mrgsolve",
  overwrite = FALSE,
  control = "file",
  verbose = TRUE
)
```

## Arguments

- model:

  character with the model file to be read in and converted

- out:

  character with the name of the output file without a file extension

- ext:

  character with the name of the NONMEM ext file (if not provided
  estimates are read directly from control stream)

- mod_return:

  a character vector indicating which items should be returned from the
  model function. For more information see details

- type_return:

  character indicating the type of model that should be created.
  Currently "deSolve", "rxode2", "nonmem2rx" and "mrgsolve" are accepted

- overwrite:

  logical indicating if the output model should be overwritten

- control:

  character indicating how the model control code should be returned.
  Currently "file", "console", "string", "script" and "model" (only for
  rxode2/DeSolve) are accepted

- verbose:

  logical indicating if additional information is written to the console

## Value

a converted file is generated and a message is returned

## Details

For the mod_return argument, the additional variables are added to the
output in case the type_return is either mrgsolve or deSolve.

## Author

Richard Hooijmaijers

## Examples

``` r
mod  <- system.file("example_models","PK.1CMT.ORAL.mod", package = "amp.sim")
outf <- tempfile()

convert_nonmem(mod, outf, verbose = FALSE)
readLines(paste0(outf,".cpp")) |> head(n=15) |> cat(sep="\n")
#> $PLUGIN autodec nm-vars Rcpp
#> $PROB 1 CMT PK model with oral absorption
#> 
#> $PARAM
#> THETA1 = 0.1, THETA2 = 2, THETA3 = 1
#> 
#> $CMT
#> A1 A2
#> 
#> $PK
#> 
#>  KA =  THETA(1) * exp(ETA(1)) ;
#>  CL =  THETA(2) * exp(ETA(2)) ;
#>  V =  THETA(3) ;
#>  S2 =  V ;

convert_nonmem(mod, outf, verbose = FALSE, type_return = "nonmem2rx") |> suppressMessages()
readLines(paste0(outf,".r")) |> head(n=15) |> cat(sep="\n")
#> library(rxode2)
#> model <- function()
#> {
#>     description <- c(";; Importance: 0", ";; Description: 1 CMT PK model with oral absorption", 
#>         "1 CMT PK model with oral absorption")
#>     sigma <- lotri({
#>         eps1 ~ 0.0575959
#>     })
#>     validation <- "could not read in input data; validation skipped"
#>     ini({
#>         t.KA <- c(0, 0.0825086)
#>         label("KA (1/h)")
#>         t.CL <- c(0, 2.67639)
#>         label("CL (l/h)")
#>         t.V <- c(0, 1.58756)
```
