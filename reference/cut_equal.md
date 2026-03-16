# cut function for (appr.) equal intervals

This function uses cut to make categories based on approximately equal
number of bins

## Usage

``` r
cut_equal(x, n, type = 1, ntries = 1000)
```

## Arguments

- x:

  the vector that should be cut into equal bins

- n:

  the number of bins that should be used

- type:

  the type of algorithm to be used (see details)

- ntries:

  number of samples/tries for type 2

## Value

a character vector with the categories/bins

## Details

Generating equal bins can be quite difficult. There are multiple ways of
assessing if bins are equal. This function provides a method based on
quantiles (type=1) or a method based on sampling proposed by M. Ruppert
(type=2). In general type 1 is faster but less accurate, while type 2 is
slower and more accurate (in case of a reasonable ntries)

## Author

Richard Hooijmaijers

## Examples

``` r
 table(cut_equal(1:20,5))
#> 
#>     1+2+3+4 13+14+15+16 17+18+19+20     5+6+7+8  9+10+11+12 
#>           4           4           4           4           4 
```
