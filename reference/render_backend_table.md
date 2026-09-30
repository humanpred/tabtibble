# Render a plain data.frame table body through the selected backend

Render a plain data.frame table body through the selected backend

## Usage

``` r
render_backend_table(x, topic_cols = character(0), caption = NULL, ...)
```

## Arguments

- x:

  A data.frame.

- topic_cols:

  Character vector of column names to group into repeating topic headers
  (see
  [`render_typst_table()`](https://humanpred.github.io/tabtibble/reference/render_typst_table.md));
  only used by the `"typst"` backend under Quarto. The other backends –
  and `"typst"` itself outside Quarto, see below – ignore it gracefully:
  the named columns stay as ordinary columns, so their values repeat on
  every row, as if `topic_cols` had not been set.

- caption:

  The table's caption, or `NULL`. Ignored under Quarto (the crossref
  wrapper in
  [`knit_print.tab_list()`](https://humanpred.github.io/tabtibble/reference/knit_print.tab_list.md)
  applies it instead); under R Markdown, applied via the backend's own
  captioning (see above).

- ...:

  Passed to the backend's table constructor
  ([`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html) /
  [`tinytable::tt()`](https://vincentarelbundock.github.io/tinytable/man/tt.html)
  / [`gt::gt()`](https://gt.rstudio.com/reference/gt.html) /
  [`flextable::flextable()`](https://davidgohel.github.io/flextable/reference/flextable.html));
  unused by `"typst"`.

## Value

`NULL`, invisibly; called for the side effect of writing the rendered
table with [`cat()`](https://rdrr.io/r/base/cat.html).
