# Get coding for template models

This function returns the code for some template models

## Usage

``` r
tmpl_model(tmpl, ret = "console")
```

## Arguments

- tmpl:

  character with template

- ret:

  character indicating how the result should be returned. Currently
  "console", "string" and "script" are accepted

## Value

model syntax is returned either to console or script (within Rstudio) or
a character string

## Details

There are templates available for 1-2 CMT PK models for IV/bolus/oral
administration as both analytical as closed form and parameterized with
constants or as CL/V. To see which templates are available in the
package run the function without arguments

## Author

Richard Hooijmaijers

## Examples

``` r
tmpl_model()
#>  [1] "ana1CMTbolusC.tmp" "ana1CMTbolusK.tmp" "ana1CMTivC.tmp"   
#>  [4] "ana1CMTivK.tmp"    "ana1CMToralC.tmp"  "ana1CMToralK.tmp" 
#>  [7] "ana2CMTbolusC.tmp" "ana2CMTbolusK.tmp" "ana2CMTivC.tmp"   
#> [10] "ana2CMTivK.tmp"    "ana2CMToralC.tmp"  "ana2CMToralK.tmp" 
#> [13] "des1CMTbolusC.tmp" "des1CMTbolusK.tmp" "des1CMTivC.tmp"   
#> [16] "des1CMTivK.tmp"    "des1CMToralC.tmp"  "des1CMToralK.tmp" 
#> [19] "des2CMTbolusC.tmp" "des2CMTbolusK.tmp" "des2CMTivC.tmp"   
#> [22] "des2CMTivK.tmp"    "des2CMToralC.tmp"  "des2CMToralK.tmp" 
tmpl_model("ana1CMTbolusK.tmp")
#> library(ggplot2)
#> ana1CMTbolus <- function(Dose,pars,t){
#>   Dose * pars['C'] * exp(-pars['L']*t)
#> }
#> pars   <- c(C=1,L=1)
#> times  <- seq(0,24,length.out=200)
#> out    <- amp.sim::mdose(Dose=10,tau=24,ndose=1,t=times,func=ana1CMTbolus,pars=pars)
#> ggplot(out,aes(time,y)) + geom_line()
```
