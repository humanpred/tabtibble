# Example Usage

``` r

library(tabtibble)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

The `tabtibble` package is typically used to create a list of tables for
reporting, often in `quarto` or `rmarkdown`.

A simple example is to create a list of tables with each number of
cylinders grouped together.

``` r

d_tab <-
  mtcars %>%
  tidyr::nest(table = !"cyl") %>%
  dplyr::mutate(
    caption = glue::glue("Cars with {cyl} cylinders")
  ) %>%
  new_tab_tibble()
```

Then, print it! By default (the `tabtibble.knitr.auto.asis` option,
`TRUE`), no `results='asis'` chunk option is needed – the same mechanism
pander uses for its `knitr.auto.asis` option, returning the rendered
markdown as
[`knitr::asis_output()`](https://rdrr.io/pkg/knitr/man/asis_output.html)
so knitr inserts it directly.

``` r

knit_print(d_tab)
```

|  mpg |  disp |  hp | drat |    wt |  qsec |  vs |  am | gear | carb |
|-----:|------:|----:|-----:|------:|------:|----:|----:|-----:|-----:|
| 21.0 | 160.0 | 110 | 3.90 | 2.620 | 16.46 |   0 |   1 |    4 |    4 |
| 21.0 | 160.0 | 110 | 3.90 | 2.875 | 17.02 |   0 |   1 |    4 |    4 |
| 21.4 | 258.0 | 110 | 3.08 | 3.215 | 19.44 |   1 |   0 |    3 |    1 |
| 18.1 | 225.0 | 105 | 2.76 | 3.460 | 20.22 |   1 |   0 |    3 |    1 |
| 19.2 | 167.6 | 123 | 3.92 | 3.440 | 18.30 |   1 |   0 |    4 |    4 |
| 17.8 | 167.6 | 123 | 3.92 | 3.440 | 18.90 |   1 |   0 |    4 |    4 |
| 19.7 | 145.0 | 175 | 3.62 | 2.770 | 15.50 |   0 |   1 |    5 |    6 |

Cars with 6 cylinders {.table}

|  mpg |  disp |  hp | drat |    wt |  qsec |  vs |  am | gear | carb |
|-----:|------:|----:|-----:|------:|------:|----:|----:|-----:|-----:|
| 22.8 | 108.0 |  93 | 3.85 | 2.320 | 18.61 |   1 |   1 |    4 |    1 |
| 24.4 | 146.7 |  62 | 3.69 | 3.190 | 20.00 |   1 |   0 |    4 |    2 |
| 22.8 | 140.8 |  95 | 3.92 | 3.150 | 22.90 |   1 |   0 |    4 |    2 |
| 32.4 |  78.7 |  66 | 4.08 | 2.200 | 19.47 |   1 |   1 |    4 |    1 |
| 30.4 |  75.7 |  52 | 4.93 | 1.615 | 18.52 |   1 |   1 |    4 |    2 |
| 33.9 |  71.1 |  65 | 4.22 | 1.835 | 19.90 |   1 |   1 |    4 |    1 |
| 21.5 | 120.1 |  97 | 3.70 | 2.465 | 20.01 |   1 |   0 |    3 |    1 |
| 27.3 |  79.0 |  66 | 4.08 | 1.935 | 18.90 |   1 |   1 |    4 |    1 |
| 26.0 | 120.3 |  91 | 4.43 | 2.140 | 16.70 |   0 |   1 |    5 |    2 |
| 30.4 |  95.1 | 113 | 3.77 | 1.513 | 16.90 |   1 |   1 |    5 |    2 |
| 21.4 | 121.0 | 109 | 4.11 | 2.780 | 18.60 |   1 |   1 |    4 |    2 |

Cars with 4 cylinders {.table}

|  mpg |  disp |  hp | drat |    wt |  qsec |  vs |  am | gear | carb |
|-----:|------:|----:|-----:|------:|------:|----:|----:|-----:|-----:|
| 18.7 | 360.0 | 175 | 3.15 | 3.440 | 17.02 |   0 |   0 |    3 |    2 |
| 14.3 | 360.0 | 245 | 3.21 | 3.570 | 15.84 |   0 |   0 |    3 |    4 |
| 16.4 | 275.8 | 180 | 3.07 | 4.070 | 17.40 |   0 |   0 |    3 |    3 |
| 17.3 | 275.8 | 180 | 3.07 | 3.730 | 17.60 |   0 |   0 |    3 |    3 |
| 15.2 | 275.8 | 180 | 3.07 | 3.780 | 18.00 |   0 |   0 |    3 |    3 |
| 10.4 | 472.0 | 205 | 2.93 | 5.250 | 17.98 |   0 |   0 |    3 |    4 |
| 10.4 | 460.0 | 215 | 3.00 | 5.424 | 17.82 |   0 |   0 |    3 |    4 |
| 14.7 | 440.0 | 230 | 3.23 | 5.345 | 17.42 |   0 |   0 |    3 |    4 |
| 15.5 | 318.0 | 150 | 2.76 | 3.520 | 16.87 |   0 |   0 |    3 |    2 |
| 15.2 | 304.0 | 150 | 3.15 | 3.435 | 17.30 |   0 |   0 |    3 |    2 |
| 13.3 | 350.0 | 245 | 3.73 | 3.840 | 15.41 |   0 |   0 |    3 |    4 |
| 19.2 | 400.0 | 175 | 3.08 | 3.845 | 17.05 |   0 |   0 |    3 |    2 |
| 15.8 | 351.0 | 264 | 4.22 | 3.170 | 14.50 |   0 |   1 |    5 |    4 |
| 15.0 | 301.0 | 335 | 3.54 | 3.570 | 14.60 |   0 |   1 |    5 |    8 |

Cars with 8 cylinders {.table}

Set `options(tabtibble.knitr.auto.asis = FALSE)` to go back to writing
directly with [`cat()`](https://rdrr.io/r/base/cat.html) instead, which
does require `results='asis'` on the chunk (and warns when it is
missing).

## Quarto + Typst reports

Each table is wrapped in a fenced Div with a Quarto label
(`#tbl-<label>`), so it can be cross-referenced with `@tbl-<label>` and,
when the report is rendered to a Typst PDF, appears in a Typst list of
tables. Add a label column when you want to choose the label yourself;
otherwise a stable one is derived from the caption, so re-rendering the
same report reproduces the same labels:

``` r

d_tab_labelled <-
  mtcars %>%
  tidyr::nest(table = !"cyl") %>%
  dplyr::mutate(
    caption = glue::glue("Cars with {cyl} cylinders"),
    label = glue::glue("cyl-{cyl}")
  ) %>%
  new_tab_tibble()
d_tab_labelled$label
#> [1] "cyl-6" "cyl-4" "cyl-8"
```

In the Typst document, add a list of tables near the top with:

    ```{=typst}
    #outline(title: [List of Tables], target: figure.where(kind: "quarto-float-tbl"))
    ```

(`"quarto-float-tbl"` is Quarto’s own kind string for a
crossreferenceable table from computational output; the native Typst
`table` kind is for tables written directly in Typst source.)

## Rendering backends

By default, each table is rendered as a Markdown (pipe) table via
[`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html), so
`tabtibble` itself needs no extra table-formatting package. Set the
`tabtibble.backend` option to `"tinytable"`, `"gt"`, or `"flextable"` to
render plain data.frame tables with that package instead (each package
is only required when you select its backend):

``` r

options(tabtibble.backend = "tinytable")
```

A table you already built with `gt`, `tinytable`, `flextable`, or
`table1` is printed exactly as you built it, using that package’s own
printing method, regardless of `tabtibble.backend`.

Caption and cell text containing Typst-significant characters
(`* _ # @ $ < > \` \[ \]`or a backslash) render literally;`tabtibble\`
escapes them once, for every backend, so you never need to escape them
yourself.

## Topic-grouped listings (`"typst"` backend)

The `"typst"` backend reproduces what LaTeX’s TopicLongTable gave: a
listing sorted by one or more “topic” columns (for example subject, then
analyte) that prints each topic value once, as a group header above its
rows, instead of repeating it on every row. When the group runs onto the
next page, the column header and the current topic repeat at the top of
that page, so a reader never sees a page of data with no idea which
subject it belongs to. Declare the topic columns with `topic_cols`; the
underlying table must already be sorted by them:

``` r

conc <-
  tibble::tibble(
    subject = rep(c("S001", "S002"), each = 3),
    time    = rep(0:2, times = 2),
    conc    = c(0, 5.1, 4.3, 0, 6.0, 5.2)
  )

d_tab_topic <-
  tibble::tibble(
    table      = list(conc),
    caption    = "Concentrations by subject",
    label      = "conc-by-subject",
    topic_cols = list("subject")
  ) %>%
  new_tab_tibble()

options(tabtibble.backend = "typst")
```

``` r

knit_print(d_tab_topic)
```

| subject | time | conc |
|:--------|-----:|-----:|
| S001    |    0 |  0.0 |
| S001    |    1 |  5.1 |
| S001    |    2 |  4.3 |
| S002    |    0 |  0.0 |
| S002    |    1 |  6.0 |
| S002    |    2 |  5.2 |

Concentrations by subject {.table}

Without `topic_cols`, the `"typst"` backend is an ordinary table whose
column header repeats on every page. The other backends ignore
`topic_cols` gracefully: the named columns stay as ordinary columns, so
their values just repeat on every row.

Column alignment defaults to right for numeric columns and left for
everything else; override it with a `tabtibble_align` attribute (a named
character vector of `"left"`, `"right"`, or `"center"`) set on the table
before calling
[`new_tab_tibble()`](https://humanpred.github.io/tabtibble/reference/new_tab_tibble.md):

``` r

attr(conc, "tabtibble_align") <- c(subject = "left", time = "center", conc = "right")
d_tab_topic_aligned <-
  tibble::tibble(table = list(conc), caption = "Aligned columns", topic_cols = list("subject")) %>%
  new_tab_tibble()
```
