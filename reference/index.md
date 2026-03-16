# Package index

## Converting models

Functions to convert NONMEM models

### Main functions

- [`convert_nonmem()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/convert_nonmem.md)
  : Convert NONMEM model to R syntax

### Helper functions

- [`conv_pow()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/conv_pow.md)
  : Convert infix power notation to prefix notation
- [`convert_nmsyntax()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/convert_nmsyntax.md)
  : Convert NONMEM specific syntax to R syntax

## Simulations in NONMEM

Functions to perform NONMEM Simulations

- [`make_nmsimmodel()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/make_nmsimmodel.md)
  : Create a simulation model from original model
- [`split_sim()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/split_sim.md)
  : Split a large NONMEM simulation in chunks

## Simulations in R

Functions to perform Simulations in R

- [`dose_func()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/dose_func.md)
  : Create data.frame with dosing for usage in simulation with deSolve
- [`mdose()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/mdose.md)
  : Performs multiple dosing in case of analytical solution of model
- [`model_validation()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/model_validation.md)
  : Validates NONMEM estimation model with an mrgsolve simulation model

## Shiny functionality

Functions to create and run shiny apps

- [`mod2shiny()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/mod2shiny.md)
  : Creates a basic simulation app for a given R model
- [`settings2df()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/settings2df.md)
  : Add settings to dataframe
- [`overlaying()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/overlaying.md)
  : Performs overlaying of simulations

## General functionality

Functions general applicable for simulations

- [`sample_par()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/sample_par.md)
  : Sample model parameters from a multivariate normal distribution
- [`sample_sim()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/sample_sim.md)
  : Sample model parameters for a simulation
- [`simdata()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/simdata.md)
  : Create a simulation dataset for NONMEM simulation
- [`tmpl_model()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/tmpl_model.md)
  : Get coding for template models

## Utility functions

Utility functions

- [`cut_equal()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/cut_equal.md)
  : cut function for (appr.) equal intervals
- [`get_est()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/get_est.md)
  : Get model estimates from NONMEM ext or model file
- [`get_inits()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/get_inits.md)
  : get the initial states for the differential equations
- [`get_nmblock()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/get_nmblock.md)
  : Get information from dollar blocks inside NONMEM control streams
- [`get_param()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/get_param.md)
  : Get parameter values from model or ext file
- [`get_parmvar()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/get_parmvar.md)
  : Get the variables within a NONMEM model that should be passed to the
  simulation model
- [`dput2()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/dput2.md)
  : Wrapper function around dput to provide more options
- [`pos_clpar()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/pos_clpar.md)
  : Get position of closing parenthesis
- [`par_delete()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/par_delete.md)
  : Delete parenthesis including a numeric within a vector
- [`nmlistblock()`](https://leidenadvancedpkpd.github.io/amp.sim/reference/nmlistblock.md)
  : convert a block to a list
