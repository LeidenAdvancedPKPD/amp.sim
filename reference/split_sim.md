# Split a large NONMEM simulation in chunks

This function splits a large simulation dataset and accompanying model
in chunks to prevent memory problems within the simulation or to enable
simulating over multiple cores

## Usage

``` r
split_sim(data, model, locout, splitby = "ID", numout = 4)
```

## Arguments

- data:

  character string for input dataset or a dataframe with the simulation
  data (see details)

- model:

  character string for the simulation model

- locout:

  character string for the location of the split input dataset and
  models

- splitby:

  character string with the variable in the data to be split on (if this
  is not ID it could lead to unexpected results)

- numout:

  the number of 'equal length' outputs to be created.

## Value

split CSV and models files are written to disk

## Details

In general the data can be a character string defining the input dataset
(csv file) or a dataframe it is proposed to use a dataframe as in many
cases the splitting should take place for a large problem. In case a
dataframe is used (e.g. from loading an Rdata object) it is not
necessary to import a huge csv file.

## Author

Richard Hooijmaijers

## Examples

``` r
nmmod   <- system.file("example_models","PK.1CMT.ORAL.mod", package = "amp.sim")
dat     <- simdata(0:24, dosetime = 0, doseheight = 10, addl = 2, ii = 24, 
                   numid = 50, STHETA1= 1, STHETA2 = 2, STHETA3 = 1,
                   SETA1 = 0, SETA2 = 0)
tmp_out <- tempfile(fileext = ".csv")
mod_out <- tempfile(fileext = ".mod")

write.csv(dat,file=tmp_out, na=".", quote=FALSE, row.names = FALSE)
make_nmsimmodel(nmmod, mod_out, data=tmp_out)
#> Check residual error; in case coded as sigma use 'sigma_ext' otherwise check if the correct THETA is used icw uncertainty

split_sim(data = tmp_out, model = mod_out, locout=tempdir())
list.files(tempdir(), pattern="\\.mod$")
#> [1] "file1c9724e1ab18.mod"   "file1c977a01fd73.1.mod"
#> [3] "file1c977a01fd73.2.mod" "file1c977a01fd73.3.mod"
#> [5] "file1c977a01fd73.4.mod" "file1c977a01fd73.mod"  
```
