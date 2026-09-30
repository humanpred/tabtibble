# Detect the current knitr/pandoc output target

Detect the current knitr/pandoc output target

## Usage

``` r
detect_output_target()
```

## Value

One of `"typst"`, `"latex"`, `"html"`, `"docx"`, or `"other"` (any
other/undetected target, including not being inside a knit at all). The
`tabtibble.output_target` option forces the result (for tests, or when
detection is wrong for some environment).
