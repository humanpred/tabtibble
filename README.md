
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tabtibble

<!-- badges: start -->

[![R-CMD-check](https://github.com/humanpred/tabtibble/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/humanpred/tabtibble/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/humanpred/tabtibble/graph/badge.svg)](https://app.codecov.io/gh/humanpred/tabtibble)
<!-- badges: end -->

The goal of tabtibble is to simplify printing many tables in reports
typically created with `quarto` or `rmarkdown`.

## Installation

You can install the development version of tabtibble like so:

``` r
remotes::install_github("humanpred/tabtibble")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(tabtibble)
my_tt <- new_tab_tibble(tibble::tibble(table = list(data.frame(a = 1)), caption = "foo"))
knit_print(my_tt)
```
