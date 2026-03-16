# Get parameter values from model or ext file

This function gets the parameter values from a NONMEM model or ext file
including naming and additional variables if present

## Usage

``` r
get_param(model, lstblock, ext = NULL, addparam = TRUE)
```

## Arguments

- model:

  character vector with the model content

- lstblock:

  list with each item being a separate structured dollar block, usually
  obtain from
  [`nmlistblock`](https://leidenadvancedpkpd.github.io/amp.sim/reference/nmlistblock.md)

- ext:

  character with the name of the NONMEM ext file (if not provided
  estimates are read directly from the list block)

- addparam:

  logical indicating if the function should try to add parameters
  (besides THETAs and the ones defined in covariates) the additional
  parameters are always returned so it can be used for warnings

## Value

a list with parameters, names and matrices

## Author

Richard Hooijmaijers

## Examples

``` r
mod    <- system.file("example_models","PK.1CMT.ORAL.COV.mod", package = "amp.sim")
mdll   <- get_nmblock(mod,block=c("PK","DES"))
mdlls  <- nmlistblock(mdll)
get_param(mod, mdlls)
#> $params
#> THETA1 THETA2 THETA3 THETA4 WEIGHT 
#>    0.1    2.0    1.0    0.2 -999.0 
#> 
#> $theta_names
#> [1] ""
#> 
#> $omega_matrix
#>      ETA1 ETA2
#> ETA1 0.01 0.00
#> ETA2 0.00 0.02
#> 
#> $omega_string
#>     ETA1     ETA2 
#>  "0.01 " "0 0.02" 
#> 
#> $sigma_matrix
#>      EPS1
#> EPS1  0.1
#> 
#> $sigma_string
#>  EPS1 
#> "0.1" 
#> 
#> $add_params
#> [1] "WEIGHT"
#> 
#> $all_params
#>  [1] "WEIGHT"  "COV1"    "KA"      "CL"      "V"       "S2"      "K20"    
#>  [8] "F1"      "CP"      "DADT(1)" "DADT(2)"
#> 
```
