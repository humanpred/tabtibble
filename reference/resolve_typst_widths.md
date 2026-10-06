# Resolve per-column Typst column widths

Resolve per-column Typst column widths

## Usage

``` r
resolve_typst_widths(x, widths = NULL)
```

## Arguments

- x:

  A data.frame (the data columns only).

- widths:

  `NULL` for Typst's automatic widths, or the `"tabtibble_widths"`
  attribute: Typst track sizes (`"auto"`, a length such as `"3cm"`,
  `".5in"`, or `"40%"`, or a fraction such as `"2fr"`), either all named
  by column (each column once, no other names) or none named, in column
  order.

## Value

The Typst `columns:` value: the number of columns when `widths` is
`NULL`, otherwise a Typst array of track sizes.
