# Wrapper function around dput to provide more options

This function wraps around the dput function and provide more options to
save result in a vector

## Usage

``` r
dput2(x, comment = FALSE, obj = NULL, collapse = NULL, ...)
```

## Arguments

- x:

  An object passed to `dput`

- comment:

  logical indicating if comment characters should be prepended to
  results

- obj:

  character of length one indicating the name of the object that should
  be prepended to result

- collapse:

  character of length one with the collapse character. If provided the
  result will be pasted with this collapse character

- ...:

  additional arguments passed to dput

## Value

a vector with the result from dput

## Author

Richard Hooijmaijers

## Examples

``` r
dput2(setNames(runif(5),letters[1:5]))
#> [1] "c(a = 0.0807501375675201, b = 0.834333037259057, c = 0.600760886212811, "
#> [2] "d = 0.157208441523835, e = 0.0073994412086904)"                          
```
