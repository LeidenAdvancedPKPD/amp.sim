# Performs multiple dosing in case of analytical solution of model

This function takes a function that defines a model in analytical
solution and performs multiple dosing for it

## Usage

``` r
mdose(Dose, tau, ndose, t, func, ...)
```

## Arguments

- Dose:

  numeric vector with the dosing height

- tau:

  numeric vector with the tau of dosing

- ndose:

  numeric vector with the number of doses

- t:

  numeric vector with the time-points that should be outputted

- func:

  name of the function for which multiple dosing should be applied

- ...:

  arguments for func

## Value

a data frame with the superimposed results

## Details

This function will create a list that can be used to perform
superposition which is necessary in case of an analytical solution in a
multiple dose setting. The function will check if there is an overlap in
arguments and will use the arguments given to `mdose` for the function
given in `func` if applicable (e.g. it is likely that `func` has an
argument for Dose, in this case it will use the Dose argument provide in
`mdose`) The function can have any number of arguments that can be
passed using "...". However there should at least be an argument `t`
which is the time vector for which simulations are necessary.

## Author

Richard Hooijmaijers

## Examples

``` r
ana1CMTiv <- function(Dose,pars,t){
  Dose * pars['C'] * exp(-pars['L']*t)
}
res <- mdose(10, tau = 24, ndose = 5, t = 0:240, 
             func = ana1CMTiv, pars = c(L=.01,C=5))
plot(res$time,res$y, type="l")

```
