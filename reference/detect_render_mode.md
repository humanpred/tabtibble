# Detect whether the current knit is running under Quarto or plain R Markdown

`knitr::opts_knit$get("quarto.version")` is set whenever Quarto drives
the render (the same signal flextable's own `knit_print.flextable()`
uses); `QUARTO_PROJECT_ROOT` / `QUARTO_DOCUMENT_PATH` are set by the
Quarto CLI itself, including for a single-file (non-project) render, and
are checked as a fallback. Verified against a real Quarto 1.9.37 Typst
render (all three set) and a plain
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
(all three absent).

## Usage

``` r
detect_render_mode()
```

## Value

`"quarto"` or `"rmarkdown"`. The `tabtibble.render_mode` option forces
the result (for tests, or when detection is wrong for some environment);
it must be one of those two values.
