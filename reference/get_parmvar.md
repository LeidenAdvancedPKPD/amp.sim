# Get the variables within a NONMEM model that should be passed to the simulation model

This function go through all formulas and control flows to check if a
parameter is created ad-hoc or taken from the input file. This is
important as these variables need to be set for simulation

## Usage

``` r
get_parmvar(lstblock, returnall = FALSE)
```

## Arguments

- lstblock:

  list with each item being a separate structured dollar block, usually
  obtain from
  [`nmlistblock`](https://leidenadvancedpkpd.github.io/amp.sim/reference/nmlistblock.md)

- returnall:

  logical indicating if all variables should be returned or just the
  ones that are not defined

## Value

a vector with model variables for the simulation model

## Author

Richard Hooijmaijers

## Examples

``` r
mod    <- system.file("example_models","PK.1CMT.ORAL.COV.mod", package = "amp.sim")
mdll   <- get_nmblock(mod,block=c("PK","DES"))
mdlls  <- nmlistblock(mdll)
get_parmvar(mdlls)
#> [1] "WEIGHT"
```
