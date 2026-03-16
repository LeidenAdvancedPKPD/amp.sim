# Create data.frame with dosing for usage in simulation with deSolve

This function creates a data.frame that can be used for events of a
deSolve simulation

## Usage

``` r
dose_func(cmt, value, tinf, tau, ndose, times)
```

## Arguments

- cmt:

  number of compartment or differential equation where the dosing should
  be given

- value:

  the value of the dosing that should be given

- tinf:

  in case value is set an infusion is assumed with tinf as infusion time

- tau:

  dosing interval to be used

- ndose:

  number of doses to be used

- times:

  In case tau and ndose cannot be used (unequal dosing), this parameter
  can be used to set times of dosing (e.g c(0,24,168))

## Value

a data frame that can be used as an event dataset within deSolve

## Author

Richard Hooijmaijers

## Examples

``` r
 dose_func(8,100,tau=48,ndose=5,tinf=2)
#>    var time value method
#> 1   A8    0    50    add
#> 6   A8    2     0    rep
#> 2   A8   48    50    add
#> 7   A8   50     0    rep
#> 3   A8   96    50    add
#> 8   A8   98     0    rep
#> 4   A8  144    50    add
#> 9   A8  146     0    rep
#> 5   A8  192    50    add
#> 10  A8  194     0    rep
```
