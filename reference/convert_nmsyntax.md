# Convert NONMEM specific syntax to R syntax

This function converts a NONMEM syntax to R syntax, mainly for functions
and operators

## Usage

``` r
convert_nmsyntax(x, type = "mrgsolve")
```

## Arguments

- x:

  character vector with the syntax to be converted

- type:

  character with the type of syntax to convert to (currently "deSolve"
  and "mrgsolve" and "rxode2" are supported)

## Value

character vector with the converted syntax

## Author

Richard Hooijmaijers

## Examples

``` r
convert_nmsyntax("IF(VAR.GT.0) VAR2 = PHI(1)")
#> [1] "if(VAR > 0) VAR2 = R::pnorm(1, 0.0, 1.0, 1, 0)"
```
