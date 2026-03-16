# get the initial states for the differential equations

This function will extracts the initial states for the differential
equations from a NONMEM model

## Usage

``` r
get_inits(lstblock)
```

## Arguments

- lstblock:

  list with each item being a separate strucured dollor block, usually
  obtain from
  [`nmlistblock`](https://leidenadvancedpkpd.github.io/amp.sim/reference/nmlistblock.md)

## Value

a named vector with the state values

## Author

Richard Hooijmaijers

## Examples

``` r
mod    <- system.file("example_models","PK.1CMT.ORAL.mod", package = "amp.sim")
mdll   <- get_nmblock(mod,block=c("PK","DES"))
mdlls  <- nmlistblock(mdll)
get_inits(mdlls)
#>  A1  A2 
#> "0" "0" 
```
