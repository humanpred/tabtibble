# Render a data.frame as a raw Typst table, with optional repeating topic headers

Emits a fenced `{=typst}` block (which Quarto passes through verbatim)
containing a `#table(...)` whose column header repeats
(`table.header(repeat: true, ...)`) on every page the table continues
onto. When `topic_cols` is non-empty, each distinct combination of topic
values is additionally emitted once, as its own repeating header row
(`table.header(level = 2, ...)` for the first topic column, `level = 3`
for the second, and so on) spanning the data columns, immediately above
its rows; `x` must already be sorted by `topic_cols`
([`new_tab_tibble()`](https://humanpred.github.io/tabtibble/reference/new_tab_tibble.md)
checks this). A topic header is never left alone at the bottom of a page
– Typst keeps a `table.header` row with at least the row after it,
verified against a render long enough to force the break. Without
`topic_cols`, this is an ordinary repeating-header table.

## Usage

``` r
render_typst_table(x, topic_cols = character(0), ...)
```

## Arguments

- x:

  A data.frame.

- topic_cols:

  Character vector of column names (outer to inner) to group into
  repeating topic headers, or `character(0)` (the default) for an
  ordinary table.

- ...:

  Unused; present for interface consistency with the other backends.

## Value

`NULL`, invisibly; called for the side effect of writing the rendered
table with [`cat()`](https://rdrr.io/r/base/cat.html).
