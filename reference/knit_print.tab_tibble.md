# Print a tab_tibble

Print a tab_tibble

## Usage

``` r
# S3 method for class 'tab_tibble'
knit_print(x, ...)
```

## Arguments

- x:

  The `tab_tibble` object to print

- ...:

  Passed to subsequent methods

## Value

The result of `knit_print(x$table, ...)`: by default (see
[`knit_print.tab_list()`](https://humanpred.github.io/tabtibble/reference/knit_print.tab_list.md))
a
[`knitr::asis_output()`](https://rdrr.io/pkg/knitr/man/asis_output.html)
value, so a chunk printing a `tab_tibble` needs no `results='asis'`.

## See also

Other knitters:
[`knit_print.tab_list()`](https://humanpred.github.io/tabtibble/reference/knit_print.tab_list.md)
