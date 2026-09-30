# Print a tab_list

Print a tab_list

## Usage

``` r
# S3 method for class 'tab_list'
knit_print(
  x,
  ...,
  caption,
  label = NULL,
  topic_cols = NULL,
  print_fun = NULL,
  tab_prefix = NULL,
  tab_suffix = "\n\n"
)
```

## Arguments

- x:

  The `tab_list` object to print

- ...:

  passed to `print_fun`

- caption:

  The caption for each table as a character vector

- label:

  Character vector of Quarto labels (without the `tbl-` prefix), one per
  table, matching `x` in length. `NULL` (the default) derives a label
  from each caption via
  [`derive_label()`](https://humanpred.github.io/tabtibble/reference/derive_label.md).

- topic_cols:

  A list the same length as `x`, each element a character vector of
  column names to group into repeating topic headers (used only by the
  `"typst"` backend; see
  [`render_backend_table()`](https://humanpred.github.io/tabtibble/reference/render_backend_table.md));
  `NULL` (the default) is treated as an empty vector for every table.
  Before a table using the `"typst"` backend, a Typst rule allowing its
  figure to break across pages is emitted ahead of the table's own
  crossref div – see `emit_typst_breakable_figure_rule()`.

- print_fun:

  Override the default printing using `print_tabtibble`. If provided it
  is a function taking arguments of `x` (one data.frame to print),
  `caption` (the caption for that data.frame), and `...`.

- tab_prefix, tab_suffix:

  Any text to add before/after each figure (`NULL` to omit)

## Value

With `tabtibble.knitr.auto.asis` `TRUE` (the default), a
[`knitr::asis_output()`](https://rdrr.io/pkg/knitr/man/asis_output.html)
character value holding the rendered markdown. With it `FALSE`, `x`
invisibly (the markdown is written with
[`cat()`](https://rdrr.io/r/base/cat.html) as a side effect instead).

## Details

Individual tables are printed with the
[`print_tabtibble()`](https://humanpred.github.io/tabtibble/reference/print_tabtibble.md)
S3 generic function. Under Quarto (see
[`detect_render_mode()`](https://humanpred.github.io/tabtibble/reference/detect_render_mode.md)),
each table is wrapped in a fenced Div with id `#tbl-<label>` (Quarto's
syntax for a crossreferenceable table from computational output), so
`@tbl-<label>` resolves and, when the report target is Typst, the table
appears in a Typst
`#outline(target: figure.where(kind: "quarto-float-tbl"))` (the list of
tables; that outline call belongs in the report template, not here). The
caption is emitted once, as the Div's trailing paragraph, which Quarto
promotes to the figure's caption; it is Typst/Pandoc-escaped (see
[`escape_typst()`](https://humanpred.github.io/tabtibble/reference/escape_typst.md))
so caption text containing markup-significant characters renders
literally.

Under plain R Markdown, that Div is skipped: rendered by plain Pandoc
(no Quarto filter to interpret it), it would show up as a literal,
uncaptioned wrapper rather than a table figure. Instead, each table
carries an ordinary caption the output target understands – see
[`render_backend_table()`](https://humanpred.github.io/tabtibble/reference/render_backend_table.md)
– so a report that never used Quarto keeps working exactly as it did
before crossref support was added.

By default (the `tabtibble.knitr.auto.asis` option, `TRUE`), the
rendered markdown is captured and returned as
[`knitr::asis_output()`](https://rdrr.io/pkg/knitr/man/asis_output.html),
the same mechanism pander uses for its `knitr.auto.asis` option: knitr
inserts an asis-classed return value into the document directly,
whatever the chunk's own `results` setting, so a chunk printing a
`tab_tibble`/`tab_list` needs no `results='asis'` chunk option. Set
`options(tabtibble.knitr.auto.asis = FALSE)` to opt out and go back to
writing directly with [`cat()`](https://rdrr.io/r/base/cat.html)
(requiring `results='asis'`, with a warning when it is missing) – useful
if something downstream needs to see the literal
[`cat()`](https://rdrr.io/r/base/cat.html) side effect rather than a
returned value.

## See also

Other knitters:
[`knit_print.tab_tibble()`](https://humanpred.github.io/tabtibble/reference/knit_print.tab_tibble.md)
