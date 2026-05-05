# Performs overlaying of simulations

This function basically appends the simulation output and add this to a
reactiveValue

## Usage

``` r
overlaying(out, input, savedsims = NULL)
```

## Arguments

- out:

  dataframe with the results from a simulation to be appended for
  overlaying

- input:

  list with the input elements from a shiny app

- savedsims:

  reactiveValue or list that contains the saved simulations

## Value

a list with a dataframe with the appended simulations and settings

## Author

Richard Hooijmaijers

## Examples

``` r
if(requireNamespace("shiny")){
  out   <- data.frame(time=0:4, A1=rnorm(5), numsim=1)
  input <- shiny::reactiveValues(CL=2, KA=0.3, updOpts="appsim")
  overlayres <- overlaying(out,input)
  savedsims  <- list(res = overlayres$results, sett = overlayres$settings)
  overlayres <- overlaying(input=input,out=out,savedsims=savedsims)
  head(overlayres$result)
}
#> Loading required namespace: shiny
#>   time          A1 numsim Simulation
#> 1    0 -0.58701399      1      sim 1
#> 2    1 -0.32785359      1      sim 1
#> 3    2 -0.08536101      1      sim 1
#> 4    3 -2.05240389      1      sim 1
#> 5    4  0.15074825      1      sim 1
#> 6    0 -0.58701399      2      sim 2
```
