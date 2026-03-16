# Create a simulation model from original model

This function creates a simulation model from an original NONMEM model
where dollar blocks are replaced and/or commented based on input file
and other simulation functions within package

## Usage

``` r
make_nmsimmodel(omod, smod, data, subprobs = 1, table = NULL, sigma_ext = NULL)
```

## Arguments

- omod:

  character string for the original model

- smod:

  character string for the simulation model (for writing the model to
  disk)

- data:

  character string for the input dataset for the simulation

- subprobs:

  numeric indicating the number of subproblems in simulation model

- table:

  character of length 1 with the items for the dollar table block (if
  null it will use items in input dataset)

- sigma_ext:

  character with teh name of the ext file which includes the sigma value
  (in case residual error is coded in the dollar sigma block)

## Value

a simulation model (file) is created

## Details

The function will adapt an original model in such a way that it can be
used directly for simulations the assumptions are that an input dataset
is created using
[sample_par](https://leidenadvancedpkpd.github.io/amp.sim/reference/sample_par.md)
and
[simdata](https://leidenadvancedpkpd.github.io/amp.sim/reference/simdata.md).
This means that all THETA and ETA values are available in the simulation
dataset as respectively STHETAN and SETAN (simulated THETA/ETA n).
Furthermore it is assumed that the input dataset is a csv file. The
function will first comment all applicable dollar blocks. Then a OMEGA
is added with 0 FIX and the INPUT, DATA and TABLE blocks are appended
with information based on the input dataset. Finally all THETAs and ETAs
are replaced with the items in the dataset and the simulation model is
written to disk.

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
readLines(mod_out) |> head(n=15) |> cat(sep="\n")
#> ;; Importance: 0
#> ;; Description: 1 CMT PK model with oral absorption
#> $PROB  1 CMT PK model with oral absorption
#> $DATA file1cb32d649e7d.csv IGNORE=@
#> $INPUT
#>  ID DOSE TIME AMT ADDL II DV STHETA1 STHETA2 STHETA3 SETA1 SETA2
#> ; $INPUT
#> ; STUDYID ID TRT CMT AMT TIME TAFD TALD DV EVID MDV CNTRY SEX AGE WEIGHT HEIGHT BMI FLAGPK STIME
#> ; $DATA NM.theoph.02B.csv IGNORE=@
#> $SUBROUTINES  ADVAN6 TOL=3
#> $MODEL
#> COMP = (ABS)
#> COMP = (CENTRAL)
#> 
#> $PK
```
