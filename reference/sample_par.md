# Sample model parameters from a multivariate normal distribution

This function samples model parameters from NONMEMs covariate matrix
(*.cov) and final parameter estimates (*.ext). Furthermore etas can also
be sampled where eta blocks are taken into account (see details)

## Usage

``` r
sample_par(
  ext,
  covmat = NULL,
  bootstrap = NULL,
  seed = NULL,
  nrepl = 10,
  inc_theta = TRUE,
  inc_eta = FALSE,
  verbose = FALSE,
  dropfixed = FALSE,
  uncert = FALSE,
  restheta = NULL
)
```

## Arguments

- ext:

  character string with location of ext file with final model parameters

- covmat:

  character string with location of cov file with covariance matrix or
  data.frame of cov file

- bootstrap:

  character string with location of ext files from bootrstrap or vector
  with ext files from bootstrap (relevant in case ext files should be
  excluded because of minimization issues)

- seed:

  a numeric with the seed number used in set.seed to enable
  reproducibility, when not provided the seed from the global
  environment will be used (e.g. using
  [base::set.seed](https://rdrr.io/r/base/Random.html))

- nrepl:

  numeric with the number of replicates to sample

- inc_theta:

  logical indicating if THETAs should be added to result

- inc_eta:

  logical indicating if ETAs should be added to result

- verbose:

  logical indicating if additional information should be added to result
  (e.g. OMEGA/SIGMA values)

- dropfixed:

  logical indicating if parameters that are fixed should be dropped (can
  only be done in case covmat is provided)

- uncert:

  logical indicating if the uncertainty should be sampled

- restheta:

  character with the theta that describes residual error (e.g. "THETA3")
  in case uncertainty is sampled this parameter will be set to the
  population value

## Value

a dataframe with sampled values

## Details

In general the function can be used to sample from covariance matrix so
the different parameters can be added to a simulation dataset or model
to enable uncertainty simulations. In most cases it is not necessary to
include OMEGAs or SIGMAs in these type of simulations. It can be
convenient to add ETAs in the simulation dataset to perform a simulation
where no \$THETA or \$OMEGA information is necessary. In case inc_eta is
TRUE, the ETAs from the ext files are used and placed in a matrix to
take into account covariance or 'BLOCKS'. A matrix from the ext file is
constructed based on the naming of OMEGA values (e.g. OMEGA.2.1. will be
added to row 2, column 1 and column 1, row 2). The matrix is used as
Sigma for the mvrnorm function with mu=0.

## See also

[MASS::mvrnorm](https://rdrr.io/pkg/MASS/man/mvrnorm.html)

## Author

Richard Hooijmaijers

## Examples

``` r
ext <- system.file("example_models","PK.1CMT.ORAL.COV.ext", package = "amp.sim")
cov <- system.file("example_models","PK.1CMT.ORAL.COV.cov", package = "amp.sim")
sample_par(ext, inc_eta = TRUE, nrepl = 5)
#>   ID   STHETA1 STHETA2 STHETA3  STHETA4       SETA1      SETA2
#> 1  1 0.0827885  2.6728 1.58939 0.353994 -0.08900397 -0.1918347
#> 2  2 0.0827885  2.6728 1.58939 0.353994 -0.01041112 -0.3412298
#> 3  3 0.0827885  2.6728 1.58939 0.353994 -0.06753981  0.4407470
#> 4  4 0.0827885  2.6728 1.58939 0.353994  0.10349327  0.1036561
#> 5  5 0.0827885  2.6728 1.58939 0.353994 -0.04793634 -0.1916024
sample_par(ext, cov, uncert = TRUE, nrepl = 5)
#> Warning: Negative values present, take into account when using results within model
#>   ID    STHETA1  STHETA2  STHETA3    STHETA4
#> 1  1 0.07913362 2.568358 1.427934  0.3698506
#> 2  2 0.08071131 2.631000 1.181154 -0.1449949
#> 3  3 0.08442318 2.722236 1.615941  0.5648214
#> 4  4 0.08655393 2.756001 1.692673  0.3736599
#> 5  5 0.08247440 2.739620 1.596263  0.2476445
```
