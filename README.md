# Introduction

There are quite a few R packages available to simulate pharmacometric models in R.
This package is not intended to be yet another simulation package, but rather a package that can be used alongside available simulation frameworks.
This means that the package does not include functionality to perform the actual simulations, but has the following main features:

1. Automate and streamline simulations within NONMEM
2. Translate NONMEM models to R simulation frameworks (support for  `deSolve`, `rxode2` and `mrgsolve`)
3. Directly create `shiny` applications of (translated) models

# Installation

Currently the package is under active development and can be installed using:

```R
devtools::install_github("richardhooijmaijers/pmxsimtools")
```

# Usage

The pkgdown website contains various articles on how to use the package and what should be taken into account when translating models.

