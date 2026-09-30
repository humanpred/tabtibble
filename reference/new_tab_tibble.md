# Create a new `tab_tibble` object

Create a new `tab_tibble` object

## Usage

``` r
new_tab_tibble(x)

new_tab_list(x)
```

## Arguments

- x:

  The object to convert. A data.frame (or tibble) with columns `table`
  (list of tables; see `new_tab_list()`), `caption` (character), and
  optionally `label` (character, unique, a valid Quarto label without
  the `tbl-` prefix – see
  [`derive_label()`](https://humanpred.github.io/tabtibble/reference/derive_label.md))
  and `topic_cols` (list column, one character vector per table, naming
  columns – in outer-to-inner order – that the `"typst"` backend groups
  into repeating topic headers instead of repeating their values on
  every row; see
  [`render_typst_table()`](https://humanpred.github.io/tabtibble/reference/render_typst_table.md)).
  When `label` is absent or `NA`/empty for a row, a stable label is
  derived from that row's caption, so re-rendering the same caption
  always yields the same label. Each `topic_cols[[i]]` must name columns
  present in `table[[i]]`, and `table[[i]]` must already be sorted by
  them.

## Value

An object with the desired class

## Functions

- `new_tab_list()`: Create a new `tab_list` object
