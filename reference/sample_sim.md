# Sample model parameters for a simulation

This function samples parameters for a simulation. It wraps around the
[sample_par](https://leidenadvancedpkpd.github.io/amp.sim/reference/sample_par.md)
function on the background

## Usage

``` r
sample_sim(nrepl = 2, nsub = 3, type = "noIIV", ...)
```

## Arguments

- nrepl:

  Number of replicates for the simulation

- nsub:

  Number of subjects for the simulation

- type:

  character with the type of simulation to perform (see details)

- ...:

  Additional arguments passed to
  [sample_par](https://leidenadvancedpkpd.github.io/amp.sim/reference/sample_par.md)
  mainly for passing information for ext and cov files

## Value

a dataframe with sampled values

## Details

This function is a high level function wrapper for the `sample_par`
function specified for different types of simulations that might occur.
Currently the following situations can be sampled:

- `noIIV`: Sample without uncertainty and without IIV

- `sameIIV`: Sample without uncertainty and with the same IIV values
  within subjects

- `varIIV`: Sample without uncertainty and with different IIV values
  within subjects

- `unc_noIIV`: Sample with uncertainty and without IIV

- `unc_sameIIV`: Sample with uncertainty and and with the same IIV
  values within subjects

- `unc_varIIV`: Sample with uncertainty and with different IIV values
  within subjects

In all the cases above where uncertainty is sampled, this is done only
for THETA values.

## Author

Richard Hooijmaijers

## Examples

``` r
ext <- system.file("example_models","PK.1CMT.ORAL.COV.ext", package = "amp.sim")
cov <- system.file("example_models","PK.1CMT.ORAL.COV.cov", package = "amp.sim")
sample_sim(nrepl=2,nsub=3,type="unc_varIIV", ext=ext,cov=cov)
#>     REP ID    STHETA1  STHETA2  STHETA3   STHETA4       SETA1       SETA2
#> 1     1  1 0.08112494 2.467101 1.505011 0.3364156 -0.19083840 -0.16025019
#> 1.1   1  2 0.08112494 2.467101 1.505011 0.3364156 -0.12523917  0.20389460
#> 1.2   1  3 0.08112494 2.467101 1.505011 0.3364156 -0.02820872 -0.17281255
#> 2     2  1 0.08747512 2.781070 1.596124 0.1583866 -0.35495274 -0.17502489
#> 2.1   2  2 0.08747512 2.781070 1.596124 0.1583866  0.10841665 -0.09672304
#> 2.2   2  3 0.08747512 2.781070 1.596124 0.1583866 -0.08076806 -0.14939751
sample_sim(nrepl=2,nsub=3,type="sameIIV", ext=ext)
#>     REP ID   STHETA1 STHETA2 STHETA3  STHETA4       SETA1      SETA2
#> 1     1  1 0.0827885  2.6728 1.58939 0.353994  0.03196811 -0.1591824
#> 2     1  2 0.0827885  2.6728 1.58939 0.353994 -0.08755221  0.3547140
#> 3     1  3 0.0827885  2.6728 1.58939 0.353994  0.18826396  0.1513724
#> 1.1   2  1 0.0827885  2.6728 1.58939 0.353994  0.03196811 -0.1591824
#> 2.1   2  2 0.0827885  2.6728 1.58939 0.353994 -0.08755221  0.3547140
#> 3.1   2  3 0.0827885  2.6728 1.58939 0.353994  0.18826396  0.1513724
```
