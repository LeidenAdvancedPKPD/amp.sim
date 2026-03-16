# Convert infix power notation to prefix notation

This function will transform the power notation that can be used in R to
the one needed by mrgsolve

## Usage

``` r
conv_pow(x)
```

## Arguments

- x:

  character vector with the formulas to convert

## Value

a vector with the transformed power notations

## Author

Richard Hooijmaijers

## Examples

``` r
conv_pow("y = par1*(par2/par3)^xy + a - par4**(2/par5)")
#> [1] "y = par1 * pow((par2/par3), xy) + a - pow(par4, (2/par5))"
```
