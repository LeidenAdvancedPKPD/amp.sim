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
#> table.name is not a column in data. Nothing done.
#>   ID   STHETA1 STHETA2 STHETA3  STHETA4       SETA1       SETA2
#> 1  1 0.0827885  2.6728 1.58939 0.353994  0.21514923 -0.06554339
#> 2  2 0.0827885  2.6728 1.58939 0.353994  0.14291588  0.05706713
#> 3  3 0.0827885  2.6728 1.58939 0.353994 -0.14008039 -0.12381181
#> 4  4 0.0827885  2.6728 1.58939 0.353994  0.09642579  0.31445602
#> 5  5 0.0827885  2.6728 1.58939 0.353994 -0.13367776 -0.17802000
sample_par(ext, cov, uncert = TRUE, nrepl = 5)
#>   ID    STHETA1  STHETA2  STHETA3    STHETA4
#> 1  1 0.08045363 2.636853 1.385970 0.33874927
#> 2  2 0.08073782 2.668343 1.395896 0.08608657
#> 3  3 0.08018396 2.477594 1.294906 0.50479642
#> 4  4 0.09117568 2.776652 1.615882 0.24538773
#> 5  5 0.07919310 2.575649 1.447648 0.21982308
```
