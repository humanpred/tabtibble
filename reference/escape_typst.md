# Escape Typst/Pandoc-markdown-significant characters

Backslash-escapes each of `* _ # @ $ < > \ \` \[
\]`so that it renders as a literal character rather than being interpreted as markup, whether the text is embedded in the surrounding Quarto/Pandoc markdown (captions) or handed to`knitr::kable()`/`tinytable::tt()`, whose output is itself parsed as markdown or Typst source respectively. Verified against Quarto 1.9.37 + Typst 0.14.2: `gt`and`flextable`already escape their own cell content on the way to Typst, so this function is applied to captions always, and to cell text only for the "markdown" and "tinytable" backends (see`render_backend_table()`); applying it to `gt`/`flextable\`
output would double-escape.

\[ \]: R:%20

## Usage

``` r
escape_typst(x)
```

## Arguments

- x:

  A character vector.

## Value

`x` with each special character backslash-escaped.
