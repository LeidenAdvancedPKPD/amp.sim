# Get information from dollar blocks inside NONMEM control streams

This function returns a list with indices or content of dollar blocks

## Usage

``` r
get_nmblock(model, block, ret = "content", omitbn = TRUE)
```

## Arguments

- model:

  character vector of length 1 with filename of model, in case length is
  greater than 1 it is assumed to be a vector with model code

- block:

  character vector with names of the model blocks. Take into account
  that grep is used with respect to partial matching

- ret:

  character with the type of return value can be either "content" or
  "index"

- omitbn:

  logical indicating if the name of the block should be omited when
  return (has only effect if ret="content")

## Value

a list with either a numeric vector with the indices or a character
vector with the content of the dollar blocks

## Author

Richard Hooijmaijers

## Examples

``` r
mod  <- system.file("example_models","PK.1CMT.ORAL.mod", package = "amp.sim")
get_nmblock(mod,"OMEGA")
#> $OMEGA
#> [1] ""             ".01 ; ETA KA" ".02 ; ETA CL" ""            
#> 
```
