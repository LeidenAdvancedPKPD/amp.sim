# Create a simulation dataset for NONMEM simulation

This function creates a simulation dataset including information for
dosing and sampling. The function is setup to return a data frame to be
used within NONMEM or other frameworks

## Usage

``` r
simdata(time, dosetime, doseheight, addl, ii, rate = NA, numid = 5, ...)
```

## Arguments

- time:

  a vector with all sampling times to be used

- dosetime:

  a vector with the different dosing times

- doseheight:

  a vector with the different dosing heights (to be added to AMT)

- addl:

  a vector with the additional dose levels (must be same length as
  doseheight)

- ii:

  a vector with the interdose interval (must be same length as
  doseheight)

- rate:

  a vector with the dosing rate (must be same length as doseheight)

- numid:

  a vector with the number of IDs to be created

- ...:

  additional variables to be added to the resulting dataset

## Value

a dataframe that can be used for NONMEM simulations

## Author

Richard Hooijmaijers

## Examples

``` r
# Include additional variables
sim1 <- simdata(seq(0,24,1),0.5,100,10,12,NA,2, WEIGHT=70, ETA=0)

# unequal dosing scheme
sim2 <- simdata(seq(0,24,1), dosetime = c(0.5,1), doseheight = c(100,200),
                addl = c(10,5), ii = c(12,24), numid = 2)

# Directly create a sequence of different dose levels
sim3 <- lapply(seq(25,60,5),function(x){
  simdata(time=1:12,dosetime=0,doseheight=x,addl=139,ii=120,rate=0,numid=10)
}) 
sim3 <- do.call(rbind,sim3)
```
