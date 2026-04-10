# Get model estimates from NONMEM ext or model file

This function gets the estimates (THETA, ETA and OMEGA) from a NONMEM
ext or model file to be used within the simulations in R. The model file
is included as option as the names of THETAs can be obtained in case
this is set as comment in the model file

## Usage

``` r
get_est(from)
```

## Arguments

- from:

  the model or ext file (or data.frame/model text string from results
  object) to be read in to obtain estimates. extension or class of
  object of file determines the actions to be taken

## Value

a list with theta, eta and omega values

## Details

the function will return a list with theta, eta, omega and naming of
theta values. In case a model is used as input, the values represent the
initial values from a model. In case the ext file is used, the final
estimates are taken. The eta values are all set to 0. The omega values
are returned as a matrix so it can be used for sampling (e.g. using
mvrnorm). naming of thetas is taken from the model comments in the THETA
block or in case an ext file is used naming is set to THETA1:n. In case
the model is used as input, there are some assumptions within the
function on how the model is coded. For the omega block the value of
omega must always be placed on a separate line (e.g. \$OMEGA 0.1 is not
permitted as 0.1 should be placed on the next line. Also covariance
within the omega block should be placed on the same line separated by
spaces (e.g. for a BLOCK(2) the first line should state variance eta1
and the second line should state covariance eta1, eta2 followed by
variance eta2). For the theta block, it is assumed that in case lower
and upper boundaries are available they are separated by commas.

## Author

Richard Hooijmaijers

## Examples

``` r
# get the initial estimates from the model or final estimates from ext file
mod  <- system.file("example_models","PK.1CMT.ORAL.mod", package = "amp.sim")
ext  <- system.file("example_models","PK.1CMT.ORAL.ext", package = "amp.sim")
get_est(mod)
#> $THETA
#> THETA1 THETA2 THETA3 
#>    0.1    2.0    1.0 
#> 
#> $THETAN
#> [1] "KA (1/h)" "CL (l/h)" "V (l)"   
#> 
#> $OMEGA
#>      [,1] [,2]
#> [1,] 0.01 0.00
#> [2,] 0.00 0.02
#> 
#> $ETA
#> ETA1 ETA2 
#>    0    0 
#> 
#> $SIGMA
#>      [,1]
#> [1,]  0.1
#> 
get_est(ext)
#> table.name is not a column in data. Nothing done.
#> $THETA
#>    THETA1    THETA2    THETA3 
#> 0.0825086 2.6763900 1.5875600 
#> 
#> $THETAN
#> [1] "THETA1" "THETA2" "THETA3"
#> 
#> $OMEGA
#>           [,1]      [,2]
#> [1,] 0.0205517 0.0000000
#> [2,] 0.0000000 0.0481301
#> 
#> $ETA
#> ETA1 ETA2 
#>    0    0 
#> 
#> $SIGMA
#>           [,1]
#> [1,] 0.0575959
#> 
```
