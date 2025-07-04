# pmxsimtools 0.2.1

## New features

- Added new argument "times" to `mod2shiny` function to let the user choose which times to use for simulations (#10)
- Added support for `nonmem2rx` package for translating models (#18)

## Improvements

- Adapted sequence of block for mrgsolve conversion in "mrgsolve.tmpl" (#9)
- Better decription of `sample_sim` function and improved help file for this (#11)
- Added support for power conversions done in for initial states in models for mrgsolve (#12) 
- Added support for other way of definfing number of compartments in models for mrgsolve (#13) 
- Improved usage of seed in `sample_par` function (#17)
- For mrgsolve assignement of same variables (e.g. A1=A(1)) is commented out to overcom issues in simulations (#14)
- Paramater values for dataset variables that should be provided on simulation level are set to -999 to "enforce" user to provide valid value for simulations (#14)
- Created `get_iiv_ruv_ctl` to better obtain omega and sigma structures directly from model file (#15) 

## Bug fixes

- Used `signif` to add values in shiny app, to avoid small numbers ending up being 0 when round is used (#10) 
- Adapted `get_est` for issues in obtaining certain omega structures directly from model file (#15) 

# pmxsimtools < 0.2.1

These were initial versions of the pacakge for internal usage only. Starting from version 0.2.1, the package is considered stable and iteration of versions is monitored here
