# Validates NONMEM estimation model with an mrgsolve simulation model

This function uses the estimates from a NONMEM run and compares this
with the results of a simulation run. This function is inspired by a
blog post from mrgsolve and mainly looks at the differences in
population predictions

## Usage

``` r
model_validation(
  nmtable,
  simmodel,
  rounding = 4,
  comppred = "CP",
  out = "validate/result.tex",
  ...
)
```

## Arguments

- nmtable:

  either a character with a file or a data frame including the NONMEM
  table output

- simmodel:

  character with the file including the mrgsolve model

- rounding:

  numeric with the rounding applied for comparing

- comppred:

  character with the variable in mrgsolve model that should be compared
  with PRED variable in NONMEM

- out:

  character with the name of the output to create

- ...:

  additional arguments passed through to `mrgsim` function

## Value

a file with a PDF report is returned

## Details

For a correct comparison, the nmtable should include all variables
related to dosing (e.g. AMT/CMT/EVID). The simulation model should be
available as a separate file that can be read in using
[`mrgsolve::mread`](https://mrgsolve.org/docs/reference/mread.html). To
use the function, the packages `R3port`, `ggplot2`, `mrgsolve` and
`dplyr` should be installed. Be aware that no variables are renamed in
\$TABLE in the NONMEM control stream (e.g. AMT2=AMT). This can have
unexpected results when comparing.

## Author

Richard Hooijmaijers

## Examples

``` r
if (FALSE) { # \dontrun{
  res  <- model_validation(system.file("testfiles/compareParfile",package="amp.sim"),
                           system.file("testfiles/compareModel.cpp",package="amp.sim"),
                           out=NULL)
} # }
```
