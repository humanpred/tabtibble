# Print a single table from a tablist

Print a single table from a tablist

## Usage

``` r
print_tabtibble(x, caption, ...)

# Default S3 method
print_tabtibble(x, caption, ...)
```

## Arguments

- x:

  A table to print

- caption:

  The caption for the table

- ...:

  Passed to
  [`pander::pander`](https://rdrr.io/pkg/pander/man/pander.html)

## Value

The result of
[`pander::pander`](https://rdrr.io/pkg/pander/man/pander.html)

## Methods (by class)

- `print_tabtibble(default)`: Print a single table from a tablist using
  [`pander::pander()`](https://rdrr.io/pkg/pander/man/pander.html)
