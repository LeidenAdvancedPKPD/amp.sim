# Get position of closing parenthesis

This function gets the position of the closing parenthesis after the
first opening one

## Usage

``` r
pos_clpar(x)
```

## Arguments

- x:

  character string for which the parenthesis should be searched

## Value

a numeric with the position of the closing parenthesis (will be -1 if no
match is present)

## Author

Richard Hooijmaijers

## Examples

``` r
tst <- "IF (test == A(1)) a(1)=(1*5)/2"
pos_clpar(tst)
#> -1 
#> 17 
substring(tst,1,pos_clpar(tst))
#> [1] "IF (test == A(1))"
```
