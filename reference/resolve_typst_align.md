# Resolve per-column Typst table alignment

Resolve per-column Typst table alignment

## Usage

``` r
resolve_typst_align(x, align = NULL)
```

## Arguments

- x:

  A data.frame (the data columns only, i.e. with any `topic_cols`
  already removed).

- align:

  `NULL` to use the default (numeric columns right-aligned, everything
  else left), or the `"tabtibble_align"` attribute set by the caller: a
  character vector of `"left"`/`"right"`/`"center"`, either named by
  column or in column order.

## Value

A character vector of Typst alignment keywords, one per column of `x`.
