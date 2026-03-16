# Add settings to dataframe

This function adds settings or input elements to a dataframe for
displaying in app

## Usage

``` r
settings2df(savedsims, leaveout = c("go", "updOpts", "sett", "refr", "tabsel"))
```

## Arguments

- savedsims:

  reactiveValue that contains the saved simulations

- leaveout:

  character vector with the the elements that should be lefted out the
  dataframe

## Value

a dataframe with settings

## Author

Richard Hooijmaijers

## Examples

``` r
if(requireNamespace("tidyr")){
  sim1 <- list(THETA1  = 0.5, THETA2 = 1,
               alllabs =c("THETA1%=%DUMMY1","THETA2%=%DUMMY2"))
  sim2 <- list(THETA1  = 0.9, THETA2 = 1.5)
  settings2df(list(sim1 = sim1, sim2 = sim2))
} 
#> Loading required namespace: tidyr
#> # A tibble: 2 × 3
#>   name   sim1  sim2 
#>   <chr>  <chr> <chr>
#> 1 DUMMY1 0.5   0.9  
#> 2 DUMMY2 1     1.5  
```
