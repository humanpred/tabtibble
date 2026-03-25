# Print a tab_list

Print a tab_list

## Usage

``` r
# S3 method for class 'tab_list'
knit_print(
  x,
  ...,
  caption,
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

- print_fun:

  Override the default printing using `print_tabtibble`. If provided it
  is a function taking arguments of `x` (one data.frame to print),
  `caption` (the caption for that data.frame), and `...`.

- tab_prefix, tab_suffix:

  Any text to add before/after each figure (`NULL` to omit)

## Value

`x` invisibly

## Details

Individual tables are printed with the
[`print_tabtibble()`](https://humanpred.github.io/tabtibble/reference/print_tabtibble.md)
S3 generic function.

## See also

Other knitters:
[`knit_print.tab_tibble()`](https://humanpred.github.io/tabtibble/reference/knit_print.tab_tibble.md)
