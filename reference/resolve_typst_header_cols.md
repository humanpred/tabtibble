# Resolve the number of leading row-header columns

Resolve the number of leading row-header columns

## Usage

``` r
resolve_typst_header_cols(x, header_cols = NULL)
```

## Arguments

- x:

  A data.frame (the data columns only).

- header_cols:

  `NULL` (none), or the `"tabtibble_header_cols"` attribute: the number
  of leading data columns that label their rows.

## Value

A single integer, `0` when there are none.
