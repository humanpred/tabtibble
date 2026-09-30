
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

<div id="tbl-foo-018cc6">

|   a |
|----:|
|   1 |

foo

</div>

No `results='asis'` chunk option is needed: by default
(`tabtibble.knitr.auto.asis`, `TRUE`), `knit_print()` returns
`knitr::asis_output()`, the same mechanism pander uses for its
`knitr.auto.asis` option. Set
`options(tabtibble.knitr.auto.asis = FALSE)` to opt out and write
directly with `cat()` instead (which does need `results='asis'`).

## Quarto + Typst reports

Each table is wrapped in a fenced Div with a Quarto label
(`#tbl-<label>`), derived automatically from its caption when not
supplied, so it can be cross-referenced with `@tbl-<label>` and appears
in a Typst list of tables when the report is rendered to a Typst PDF.
Tables can be rendered as Markdown (the default, no extra dependency),
or with `tinytable`, `gt`, or `flextable` via the `tabtibble.backend`
option. See `vignette("example-usage", package = "tabtibble")` for
details.
