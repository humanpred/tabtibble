# Print a single table from a tablist

Print a single table from a tablist

## Usage

``` r
print_tabtibble(x, ...)

# Default S3 method
print_tabtibble(x, caption = NULL, ..., topic_cols = character(0))
```

## Arguments

- x:

  A table to print

- ...:

  Passed to the backend's table constructor
  ([`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html) /
  [`tinytable::tt()`](https://vincentarelbundock.github.io/tinytable/man/tt.html)
  / [`gt::gt()`](https://gt.rstudio.com/reference/gt.html) /
  [`flextable::flextable()`](https://davidgohel.github.io/flextable/reference/flextable.html)),
  or to `x`'s own
  [`knit_print()`](https://rdrr.io/pkg/knitr/man/knit_print.html)
  method.

- caption:

  The table's caption, or `NULL` (the default). Under Quarto, ignored –
  the crossref wrapper in
  [`knit_print.tab_list()`](https://humanpred.github.io/tabtibble/reference/knit_print.tab_list.md)
  applies it instead, so it is not duplicated in the rendered Typst
  figure. Under R Markdown, applied as the table's own caption (see
  [`render_backend_table()`](https://humanpred.github.io/tabtibble/reference/render_backend_table.md));
  [`knit_print.tab_list()`](https://humanpred.github.io/tabtibble/reference/knit_print.tab_list.md)
  always supplies it.

- topic_cols:

  Character vector of column names to group into repeating topic
  headers; only used by the `"typst"` backend under Quarto (see
  [`render_backend_table()`](https://humanpred.github.io/tabtibble/reference/render_backend_table.md)).

## Value

`x`, invisibly

## Methods (by class)

- `print_tabtibble(default)`: Print a single table from a tablist using
  the backend selected by the `tabtibble.backend` option ("markdown"
  (default), "tinytable", "gt", "flextable", or "typst"; see
  [`render_backend_table()`](https://humanpred.github.io/tabtibble/reference/render_backend_table.md))
  when `x` is a plain data.frame. An `x` that is already a `gt`,
  `tinytable`, `flextable`, or `table1` object (see
  [`new_tab_list()`](https://humanpred.github.io/tabtibble/reference/new_tab_tibble.md))
  is printed via its own
  [`knitr::knit_print()`](https://rdrr.io/pkg/knitr/man/knit_print.html)
  method instead, regardless of `tabtibble.backend`, so a table the
  caller built with a specific package is rendered exactly as they built
  it; under R Markdown (see
  [`detect_render_mode()`](https://humanpred.github.io/tabtibble/reference/detect_render_mode.md)),
  `caption` (when supplied) is still shown for it, as a plain bold
  paragraph before the table, since there is no single API across those
  packages for adding a caption to an already-built object.
