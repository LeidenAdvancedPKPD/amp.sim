# convert a block to a list

This function will convert a NONMEM block to a list including the type
and separate formula parts

## Usage

``` r
nmlistblock(dollmodel)
```

## Arguments

- dollmodel:

  list with each item being a separate dollar block, usually obtain from
  [`get_nmblock`](https://leidenadvancedpkpd.github.io/amp.sim/reference/get_nmblock.md)

## Value

a list with the structured code

## Author

Richard Hooijmaijers

## Examples

``` r
nmmod <- system.file("example_models","PK.1CMT.ORAL.mod", package = "amp.sim")
lst   <- get_nmblock(nmmod, block = "PROB")
nmlistblock(lst)
#> $PROB
#> $PROB[[1]]
#> $PROB[[1]]$orig
#> [1] "1 CMT PK model with oral absorption"
#> 
#> $PROB[[1]]$type
#> [1] "comment"
#> 
#> $PROB[[1]]$LHS
#> [1] ""
#> 
#> $PROB[[1]]$RHS
#> [1] ""
#> 
#> $PROB[[1]]$comm
#> [1] ""
#> 
#> $PROB[[1]]$cntrl
#> [1] ""
#> 
#> $PROB[[1]]$dupl
#> [1] FALSE
#> 
#> 
#> 
```
