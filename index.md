# tabtibble

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

|   a |
|----:|
|   1 |

foo

No `results='asis'` chunk option is needed: by default
(`tabtibble.knitr.auto.asis`, `TRUE`),
[`knit_print()`](https://rdrr.io/pkg/knitr/man/knit_print.html) returns
[`knitr::asis_output()`](https://rdrr.io/pkg/knitr/man/asis_output.html),
the same mechanism pander uses for its `knitr.auto.asis` option. Set
`options(tabtibble.knitr.auto.asis = FALSE)` to opt out and write
directly with [`cat()`](https://rdrr.io/r/base/cat.html) instead (which
does need `results='asis'`).

## Quarto + Typst reports

Each table is wrapped in a fenced Div with a Quarto label
(`#tbl-<label>`), derived automatically from its caption when not
supplied, so it can be cross-referenced with `@tbl-<label>` and appears
in a Typst list of tables when the report is rendered to a Typst PDF.
Tables can be rendered as Markdown (the default, no extra dependency),
or with `tinytable`, `gt`, `flextable`, or natively in `typst` (which
also supports topic-grouped listings, reproducing LaTeX’s TopicLongTable
– a group value is printed once, above its rows, and repeats at the top
of each page the group continues onto) via the `tabtibble.backend`
option. See
[`vignette("example-usage", package = "tabtibble")`](https://humanpred.github.io/tabtibble/articles/example-usage.md)
for details.
